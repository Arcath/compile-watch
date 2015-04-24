module.exports =
  class Watcher
    format: null
    inPath: null
    outPath: null
    disposables: []

    constructor: (@inPath, @outPath, formatClass, @editor) ->
      @format = new formatClass(@inPath, @outPath)

      atom.notifications.addInfo('Watching File!', {detail: "Source #{@inPath}\r\nDestination: #{@outPath}\r\nAs: #{@format.name}"})

      @render()

      @disposables.push @editor.buffer.emitter.on 'did-save', => @render()

      @editor.emitter.on 'did-destroy', => @editorClosed()

    stopWatching: ->
      for disposable in @disposables
        disposable.dispose()

    render: ->
      @format.renderFile(@editor)

    editorClosed: ->
      @stopWatching()
      atom.notifications.addInfo('Stopped Watching File', {detail: @inPath})
      delete process.compileWatch.watchers[@inPath]
