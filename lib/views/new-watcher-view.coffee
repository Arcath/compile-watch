{TextEditorView} = require 'atom-space-pen-views'
{$, View} = require 'space-pen'

module.exports =
  class NewWatcherView extends View
    @content: ->
      @div class: 'compile-watch-target', =>
        @label "Output Path", class: 'icon icon-file-add', outlet: 'promptLabel'
        @subview 'targetEditor', new TextEditorView(mini: true)
        @div class: 'error-message', outlet: 'errorMessage'

    initialize: ->
      atom.commands.add @element,
      'core:cancel': => @detach()
      'core:confirm': => @watch()

    attach: (@inPath, suggestedPath, @format, @editor) ->
      @panel = atom.workspace.addModalPanel(item: this)

      @targetEditor.getModel().setText(suggestedPath)
      @targetEditor.focus()
      @targetEditor.getModel().scrollToCursorPosition()

    detach: ->
      @panel.destroy()
      atom.workspace.getActivePane()?.activate()

    watch: ->
      process.compileWatch.emitter.emit 'watch-file', [@inPath, @targetEditor.getText(), @format, @editor]
      @targetEditor.getModel().setText('')
      @detach()
