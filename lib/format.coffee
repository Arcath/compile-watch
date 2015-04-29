module.exports =
  class Format
    inPath: null
    outPath: null
    editor: null

    constructor: (@inPath, @outPath, @editor) ->

    quotePath: (path) ->
      return ['"', path, '"'].join('')

    renderComplete: ->
      atom.notifications.addSuccess(@renderCompleteMessage)

    getText: ->
      if @editor
        return @editor.getText()
      else
        return fs.readFileSync(@inPath).toString()
