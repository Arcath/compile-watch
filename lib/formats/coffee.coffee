CoffeeScript = require 'coffee-script'

Format = require '../format'

class Coffee extends Format
  this.outputFileType = 'js'
  this.name = "Coffee Script"

  renderFile: (editor) ->
    js = CoffeeScript.compile editor.getText()
    fs.writeFileSync @outPath, js
    atom.notifications.addSuccess('Coffee Compile completed!')



process.compileWatch.formats['coffee'] = Coffee
