#
# Timer
#
class Timer
  constructor: (@millis) ->
    @_handle = null

  start: (fn) ->
    fn()
    if !@_handle
      @_handle = setInterval fn, @millis
    null

  stop: ->
    if @_handle?
      clearInterval @_handle
      @_handle = null
    null

#
# JSONPoller 
#
# Requests JSON data from @uri every @millis and update @data with the results.
# @data is a ko.observable, so other objects may derive ko.computed properties from
# it.
#
# Dependencies:
#  - jQuery for $.getJSON()
#  - Knockout.js for ko.observable()
#
class JSONPoller
  constructor: ({@uri, @millis}) ->
    @_timer = new Timer(@millis)
    @data = ko.observable({})

  start: ->
    @_timer.start =>
      $.getJSON @uri, @data
    null

  stop: ->
    @_timer.stop()
    null

#
# EXPORTS:
#

Util = {}
Util.Timer = Timer
Util.JSONPoller = JSONPoller

window.Util = Util
