CoffeeScript = require 'coffee-script'

Format = require '../format'

class Coffee extends Format
  this.outputFileType = 'js'
  this.name = "Coffee Script"

  renderFile: (editor) ->
    js = CoffeeScript.compile editor.getText()
    fs.writeFileSync @outPath, js



process.compileWatch.formats['coffee'] = Coffee
