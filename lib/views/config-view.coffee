{TextEditorView, ScrollView} = require 'atom-space-pen-views'
{$} = require 'space-pen'

module.exports =
  class ConfigView extends ScrollView
    @content: ->
      @div =>
        @h1 'Compile Watch'
        @h2 'Coming Soon'

    getTitle: ->
      'Compile Watch'

    getIconName: ->
      'settings'
