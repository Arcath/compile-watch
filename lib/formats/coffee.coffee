CoffeeScript = require 'coffee-script'

Format = require '../format'

class Coffee extends Format
  this.outputFileType = 'js'
  this.name = "Coffee Script"

  renderFile: ->
    js = CoffeeScript.compile @getText()
    fs.writeFileSync @outPath, js
    atom.notifications.addSuccess('Coffee Compile completed!')



process.compileWatch.formats['coffee'] = Coffee
