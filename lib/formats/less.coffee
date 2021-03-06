less = require 'less'
Format = require '../format'
fs = require 'fs-plus'

class LESS extends Format
  this.outputFileType = "css"
  this.name = "LESS"

  renderFile: ->
    less.render @getText(), (e, output) => @handleRender(e, output)

  handleRender: (e, output) ->
    if e
      atom.notifications.addError("LESS Compile Error", { detail: e.message })
    else
      fs.writeFileSync @outPath, output.css
      atom.notifications.addSuccess("LESS Compile completed!")

process.compileWatch.formats['less'] = LESS
