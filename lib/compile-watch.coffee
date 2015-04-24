{Emitter} = require 'atom'

process.compileWatch =
  emitter: new Emitter()
  formats: {}
  watchers: {}

fs = require 'fs-plus'
path = require 'path'

formatsPath = path.join __dirname, 'formats'

fs.readdirSync(formatsPath).forEach (file) ->
  require './formats/' + file

NewWatcherView = require './views/new-watcher-view'
Watcher = require './watcher'


module.exports =
  config:
    nodeBinary:
      type: 'string'
      default: path.join process.execPath, '../', 'resources', 'app', 'apm', 'bin', 'node'

  newWatcherView: null

  activate: ->
    atom.commands.add 'atom-workspace', 'compile-watch:watch', => @watchFile()

    process.compileWatch.emitter.on 'watch-file', (data) => @addWatcher(data)

    @newWatcherView = new NewWatcherView()

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
    process.compileWatch.watchers[data[0]] = new Watcher(data[0], data[1], data[2], data[3])
