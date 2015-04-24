module.exports =
  class Format
    inPath: null
    outPath: null

    constructor: (@inPath, @outPath) ->

    quotePath: (path) ->
      return ['"', path, '"'].join('')

    renderComplete: ->
      atom.notifications.addSuccess(@renderCompleteMessage)
