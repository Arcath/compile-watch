{Emitter} = require 'atom'

process.compileWatch =
  emitter: new Emitter()
  formats: {}
  watchers: {}
  projectConfig: {}

fs = require 'fs-plus'
path = require 'path'

formatsPath = path.join __dirname, 'formats'

ChildWatcher = require './child-watcher'
NewWatcherView = require './views/new-watcher-view'
Watcher = require './watcher'


module.exports =
  config:
    nodeBinary:
      type: 'string'
      default: path.join process.execPath, '../', 'resources', 'app', 'apm', 'bin', 'node'

  newWatcherView: null

  activate: ->
    @loadProjectConfig()
    @loadFormats()

    atom.commands.add 'atom-workspace', 'compile-watch:watch', => @watchFile()

    atom.workspace.observeTextEditors (editor) => @didOpenFile(editor)

    process.compileWatch.emitter.on 'watch-file', (data) => @addWatcher(data)

    @newWatcherView = new NewWatcherView()

  deactivate: ->
    for watcher in process.compileWatch.watchers
      watcher.stopWatching()
      delete process.compileWatch.watchers[watcher.inPath]

    process.compileWatch =
      emitter: new Emitter()
      formats: process.compileWatch.formats
      watchers: {}
      projectConfig: {}

  watchFile: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path
    fileType = filePath.split(".").reverse()[0]

    if @watchable(fileType)
      @newWatcherView.attach(filePath, @suggestPath(filePath), @suggestFormat(filePath), editor)
    else
      atom.notifications.addWarning("No format for #{fileType}")

  watchable: (fileType) ->
    not(process.compileWatch.formats[fileType] is undefined)

  suggestPath: (filePath) ->
    fileType = filePath.split(".").reverse()[0]

    unless process.compileWatch.formats[fileType] is undefined
      return filePath.replace('.' + fileType, '.' + process.compileWatch.formats[fileType].outputFileType)
    else
      return filePath

  suggestFormat: (filePath) ->
    fileType = filePath.split(".").reverse()[0]

    unless process.compileWatch.formats[fileType] is undefined
      return process.compileWatch.formats[fileType]

  addWatcher: (data) ->
    unless process.compileWatch.watchers[data[0]]
      if data.length == 2
        projectPath = atom.project.getPaths()[0]
        keyPath = data[0].replace(projectPath, '').substr(1).replace('\\','/')
        fileConfig = process.compileWatch.projectConfig.files[keyPath]
        if fileConfig.parent
          @addParentWatcher(data[0], projectPath, fileConfig, data[1])
        else
          throw 'data array too small'
      else
        process.compileWatch.watchers[data[0]] = new Watcher(data[0], data[1], data[2], data[3])
    else
      atom.notifications.addWarning('Already Watched')

  addParentWatcher: (subFilePath, projectPath, subFileConfig, editor) ->
    parentFilePath = path.join projectPath, subFileConfig.parent

    process.compileWatch.watchers[subFilePath] = new ChildWatcher(subFilePath, parentFilePath, editor)

    if process.compileWatch.watchers[parentFilePath]
      atom.notifications.addInfo('Parent File already wacthed')
    else
      parentFileConfig = process.compileWatch.projectConfig.files[subFileConfig.parent]
      parentFileOutput = path.join projectPath, parentFileConfig.output
      parentFormatClass = process.compileWatch.formats[parentFileConfig.format]

      process.compileWatch.watchers[parentFilePath] = new Watcher(parentFilePath, parentFileOutput, parentFormatClass, false)

  loadProjectConfig: ->
    try
      filePath = path.join atom.project.getPaths()[0], '.compile-watch.json'
    catch
      filePath = null

    if fs.existsSync filePath
      json = fs.readFileSync(filePath).toString()
      process.compileWatch.projectConfig = JSON.parse json

      atom.workspace.getTextEditors (editor) => @didOpenFile(editor)

  reloadProjectConfig: ->
    filePath = path.join atom.project.getPaths()[0], '.compile-watch.json'
    json = fs.readFileSync(filePath).toString()
    process.compileWatch.projectConfig = JSON.parse json
    atom.notifications.addInfo('Project Config updated!')

  didOpenFile: (editor) ->
    file = editor?.buffer.file
    filePath = file?.path

    projectPath = atom.project.getPaths()[0]

    keyPath = filePath.replace(projectPath, '').substr(1).replace(/\\/g,'/')

    if process.compileWatch.projectConfig
      if process.compileWatch.projectConfig.autowatch?
        if keyPath in process.compileWatch.projectConfig.autowatch
          data = []
          data[0] = filePath
          data[1] = path.join projectPath, process.compileWatch.projectConfig.files[keyPath].output
          data[2] = process.compileWatch.formats[process.compileWatch.projectConfig.files[keyPath].format]
          data[3] = editor

          @addWatcher(data)
      else
        if process.compileWatch.projectConfig.files?
          fileConfig = process.compileWatch.projectConfig.files[keyPath]
          if fileConfig?.parent
            atom.notifications.addInfo('This file is included in another', {detail: fileConfig.parent})

    if keyPath == '.compile-watch.json'
      atom.notifications.addInfo('Project Config Open')
      editor.buffer.emitter.on  'did-save', => @reloadProjectConfig()

  loadFormats: ->
    fs.readdirSync(formatsPath).forEach (file) ->
      require './formats/' + file
