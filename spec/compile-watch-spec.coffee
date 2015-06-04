Format = require '../lib/format'

{$} = require 'space-pen'
fs = require 'fs-plus'
path = require 'path'

if fs.existsSync path.join(__dirname, 'examples', 'test.passed')
  fs.unlinkSync path.join(__dirname, 'examples', 'test.passed')

if fs.existsSync path.join(__dirname, 'examples', 'auto-watched.passed')
  fs.unlinkSync path.join(__dirname, 'examples', 'auto-watched.passed')

class Spec extends Format
  this.outputFileType = 'passed'
  this.name = "Spec Parser"

  renderCompleteMessage: 'Spec parsed successfully'

  renderFile: ->
    fs.writeFileSync @outPath, @getText()
    @renderComplete()

describe 'Compile Watch', ->
  [activationPromise, editor, editorView] = []

  beforeEach ->
    atom.project.setPaths([path.join(__dirname, 'examples')])

    activationPromise = atom.packages.activatePackage('compile-watch')
    activationPromise.fail (reason) ->
      throw reason
    activationPromise.then ->
      process.compileWatch.formats['spec'] = Spec

  it 'should load formats', ->
    waitsForPromise ->
      activationPromise

    runs ->
      expect(process.compileWatch.formats['spec']).not.toBe undefined
      expect(process.compileWatch.formats['sass']).not.toBe undefined
      expect(process.compileWatch.formats['coffee']).not.toBe undefined
      expect(process.compileWatch.formats['less']).not.toBe undefined

  it 'should load your config', ->
    waitsForPromise ->
      activationPromise

    runs ->
      expect(process.compileWatch.projectConfig).not.toBe {}

  it 'should auto watch a file', ->
    waitsForPromise ->
      atom.workspace.open 'auto-watched.spec'

    runs ->
      waitsForPromise ->
        activationPromise

      runs ->
        waitsFor ->
          fs.existsSync(path.join(__dirname, 'examples', 'auto-watched.passed'))

        runs ->
          expect(fs.existsSync(path.join(__dirname, 'examples', 'auto-watched.passed'))).toBe true

  describe 'New Watcher View', ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open 'test.spec'

      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
        jasmine.attachToDOM(workspaceElement)
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)

    it 'should attach', ->
      atom.commands.dispatch editorView, 'compile-watch:watch'

      waitsForPromise ->
        activationPromise

      runs ->
        targetView = $(atom.workspace.getModalPanels()[0].getItem()).view()
        expect(targetView).toBeVisible()
        expect(targetView.targetEditor.getText()).not.toBe ''

    it 'should contain the input path and format', ->
      atom.commands.dispatch editorView, 'compile-watch:watch'

      waitsForPromise ->
        activationPromise

      runs ->
        targetView = $(atom.workspace.getModalPanels()[0].getItem()).view()
        expect(targetView.inPath).toBe path.join(__dirname, 'examples', 'test.spec')
        expect(targetView.format).toBe Spec

    it 'should suggest the target path', ->
      atom.commands.dispatch editorView, 'compile-watch:watch'

      waitsForPromise ->
        activationPromise

      runs ->
        targetView = $(atom.workspace.getModalPanels()[0].getItem()).view()
        expect(targetView.targetEditor.getText()).toBe path.join(__dirname, 'examples', 'test.passed')

    it 'should not appear for unknown formats', ->
      waitsForPromise ->
        atom.workspace.open 'test.donothave'

      runs ->
        atom.commands.dispatch editorView, 'compile-watch:watch'

        waitsForPromise ->
          activationPromise

        runs ->
          notification = atom.notifications.notifications.reverse()[0]
          expect(notification.type).toBe 'warning'
          expect(notification.message).toBe 'No format for donothave'

  describe 'Watching a File', ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open 'test.spec'

      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
        jasmine.attachToDOM(workspaceElement)
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)

    it 'should watch a file', ->
      waitsForPromise ->
        activationPromise

      runs ->
        process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'test.spec'), path.join(__dirname, 'examples', 'test.passed'), Spec, editor]

        waitsFor ->
          fs.existsSync path.join(__dirname, 'examples', 'test.passed')

        runs ->
          expect(fs.existsSync(path.join(__dirname, 'examples', 'test.passed'))).toBe true

    it 'should re-render on save', ->
      waitsForPromise ->
        activationPromise

      runs ->
        process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'test.spec'), path.join(__dirname, 'examples', 'test.passed'), Spec, editor]

        waitsFor ->
          fs.existsSync path.join(__dirname, 'examples', 'test.passed')

        runs ->
          expect(process.compileWatch.watchers[path.join(__dirname, 'examples', 'test.spec')].inPath).toBe path.join(__dirname, 'examples', 'test.spec')

          fs.unlinkSync path.join(__dirname, 'examples', 'test.passed')

          process.compileWatch.watchers[path.join(__dirname, 'examples', 'test.spec')].editor.buffer.emitter.emit 'did-save'

          expect(fs.existsSync(path.join(__dirname, 'examples', 'test.passed'))).toBe true
          notification = atom.notifications.notifications.reverse()[0]
          expect(notification.type).toBe 'success'
          expect(notification.message).toBe 'Spec parsed successfully'

    it 'should stop watching on editor closed', ->
      waitsForPromise ->
        activationPromise

      runs ->
        process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'test.spec'), path.join(__dirname, 'examples', 'test.passed'), Spec, editor]

        expect(process.compileWatch.watchers[path.join(__dirname, 'examples', 'test.spec')]).not.toBe undefined

        process.compileWatch.watchers[path.join(__dirname, 'examples', 'test.spec')].editor.emitter.emit 'did-destroy'

        expect(process.compileWatch.watchers[path.join(__dirname, 'examples', 'test.spec')]).toBe undefined

  describe 'Sub File Compiling', ->
    beforeEach ->
      if fs.existsSync path.join(__dirname, 'examples', 'parent-file.passed')
        fs.unlinkSync path.join(__dirname, 'examples', 'parent-file.passed')

      if fs.existsSync path.join(__dirname, 'examples', 'sub-file.passed')
        fs.unlinkSync path.join(__dirname, 'examples', 'sub-file.passed')

      waitsForPromise ->
        atom.workspace.open 'sub-file.spec'

      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
        jasmine.attachToDOM(workspaceElement)
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)

    it 'should tell you that this file is a sub of another', ->
      notification = atom.notifications.notifications.reverse()[0]
      expect(notification.type).toBe 'info'
      expect(notification.message).toBe 'This file is included in another'
      expect(notification.options.detail).toBe 'parent-file.spec'

    it 'should render the parent file when this one is watched', ->
      waitsForPromise ->
        activationPromise

      runs ->
        process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'sub-file.spec'), editor]

        waitsFor ->
          fs.existsSync path.join(__dirname, 'examples', 'parent-file.passed')

        runs ->
          expect(fs.existsSync(path.join(__dirname, 'examples', 'parent-file.passed'))).toBe true
          expect(fs.existsSync(path.join(__dirname, 'examples', 'sub-file.passed'))).toBe false

    it 'should re-render the parent on save of the sub file', ->
      waitsForPromise ->
        activationPromise

      runs ->
        process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'sub-file.spec'), editor]

        waitsFor ->
          fs.existsSync path.join(__dirname, 'examples', 'parent-file.passed')

        runs ->
          fs.unlinkSync path.join(__dirname, 'examples', 'parent-file.passed')

          process.compileWatch.watchers[path.join(__dirname, 'examples', 'sub-file.spec')].editor.buffer.emitter.emit 'did-save'

          expect(fs.existsSync(path.join(__dirname, 'examples', 'parent-file.passed'))).toBe true



  describe 'Coffee Watcher', ->
    beforeEach ->
      if fs.existsSync path.join(__dirname, 'examples', 'test.js')
        fs.unlinkSync path.join(__dirname, 'examples', 'test.js')

      waitsForPromise ->
        atom.workspace.open 'test.coffee'

      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
        jasmine.attachToDOM(workspaceElement)
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)

    it 'should compile a file', ->
      process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'test.coffee'), path.join(__dirname, 'examples', 'test.js'), process.compileWatch.formats['coffee'], editor]

      expect(fs.existsSync(path.join(__dirname, 'examples', 'test.js'))).toBe true

  describe 'SASS Watcher', ->
    beforeEach ->
      if fs.existsSync path.join(__dirname, 'examples', 'test.css')
        fs.unlinkSync path.join(__dirname, 'examples', 'test.css')

      waitsForPromise ->
        atom.workspace.open 'test.scss'

      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
        jasmine.attachToDOM(workspaceElement)
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)

    it 'should compile a file', ->
      process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'test.scss'), path.join(__dirname, 'examples', 'test.css'), process.compileWatch.formats['sass'], editor]

      waitsFor ->
        fs.existsSync(path.join(__dirname, 'examples', 'test.css'))

      runs ->
        expect(fs.existsSync(path.join(__dirname, 'examples', 'test.css'))).toBe true

  describe 'LESS Watcher', ->
    beforeEach ->
      if fs.existsSync(path.join(__dirname, 'examples', 'test.less-css'))
        fs.unlinkSync path.join(__dirname, 'examples', 'test.less-css')

      waitsForPromise ->
        atom.workspace.open 'test.less'

      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
        jasmine.attachToDOM(workspaceElement)
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)

    it 'should compile a file', ->
      process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'test.less'), path.join(__dirname, 'examples', 'test.less-css'), process.compileWatch.formats['less'], editor]

      expect(fs.existsSync(path.join(__dirname, 'examples', 'test.css'))).toBe true

  describe 'Live Script Watcher', ->
    beforeEach ->
      if fs.existsSync path.join(__dirname, 'examples', 'test-ls.js')
        fs.unlinkSync path.join(__dirname, 'examples', 'test-ls.js')

      waitsForPromise ->
        atom.workspace.open 'test.ls'

      runs ->
        workspaceElement = atom.views.getView(atom.workspace)
        jasmine.attachToDOM(workspaceElement)
        editor = atom.workspace.getActiveTextEditor()
        editorView = atom.views.getView(editor)

    it 'should compile a file', ->
      process.compileWatch.emitter.emit 'watch-file', [path.join(__dirname, 'examples', 'test-ls.ls'), path.join(__dirname, 'examples', 'test-ls.js'), process.compileWatch.formats['ls'], editor]

      expect(fs.existsSync(path.join(__dirname, 'examples', 'test-ls.js'))).toBe true
