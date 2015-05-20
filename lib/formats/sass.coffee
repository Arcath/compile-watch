childProcess = require 'child_process'
path = require 'path'

Format = require '../format'

class Sass extends Format
  this.outputFileType = 'css'
  this.name = "SASS"

  binary: path.join(__dirname, "..", "..", "node_modules", "node-sass", "bin", "node-sass")

  renderFile: ->
    childProcess.exec @command(), (error, stdout, stderr) ->
      if error
        atom.notifications.addError('SASS compile Error', {detail: error.message})
      else
        atom.notifications.addSuccess('SASS Compile completed!')


  command: ->
    [@quotePath(atom.config.get('compile-watch.nodeBinary')), @quotePath(@binary), @quotePath(@inPath), @quotePath(@outPath)].join(' ')


process.compileWatch.formats['sass'] = Sass
process.compileWatch.formats['scss'] = Sass
