module.exports =
  class ChildWatcher
    filePath: null
    parentPath: null
    editor: null
    disposables: []

    constructor: (@filePath, @parentPath, @editor) ->
      @disposables.push @editor.buffer.emitter.on 'did-save', => @render()
      @editor.emitter.on 'did-destroy', => @editorClosed()

    render: ->
      process.compileWatch.emitter.emit @parentPath

    editorClosed: ->
      @stopWatching()
      atom.notifications.addInfo('Stopped Watching File', {detail: @filePath})
      delete process.compileWatch.watchers[@filePath]

    stopWatching: ->
      for disposable in @disposables
        disposable.dispose()
