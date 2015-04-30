module.exports =
  class Watcher
    format: null
    inPath: null
    outPath: null
    disposables: []

    constructor: (@inPath, @outPath, formatClass, @editor) ->
      @format = new formatClass(@inPath, @outPath, @editor)

      atom.notifications.addInfo('Watching File!', {detail: "Source #{@inPath}\r\nDestination: #{@outPath}\r\nAs: #{formatClass.name}"})

      @render()

      if @editor
        @disposables.push @editor.buffer.emitter.on 'did-save', => @render()
        @disposables.push @editor.emitter.on 'did-destroy', => @editorClosed()
      else
        process.compileWatch.emitter.on @inPath, => @render()

    stopWatching: ->
      for disposable in @disposables
        disposable.dispose()

    render: ->
      @format.renderFile()

    editorClosed: ->
      @stopWatching()
      atom.notifications.addInfo('Stopped Watching File', {detail: @inPath})
      delete process.compileWatch.watchers[@inPath]
