LiveScript = require 'livescript'
fs = require 'fs-plus'

Format = require '../format'

class LiveScriptFormat extends Format
  this.outputFileType = 'js'
  this.name = "Live Script"

  renderFile: ->
    js = LiveScript.compile @getText()
    fs.writeFileSync @outPath, js
    atom.notifications.addSuccess('Coffee Compile completed!')



process.compileWatch.formats['ls'] = LiveScriptFormat
