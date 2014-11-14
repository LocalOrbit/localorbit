debug = (args...) ->
  # console.log "UTIL: ", args...

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
# Named args:
#  - uri: (optional) The endpoint to query via getJSON() (defaults to current path in browser)
#  - millis: (optional) Milliseconds between calls to getJSON() (defaults to one second ie. 1000 millis)
#
# Dependencies:
#  - jQuery for $.getJSON()
#  - Knockout.js for ko.observable()
#
class JSONPoller
  constructor: (args = {}) ->
    {@uri, @millis} = args
    @millis ||= 1000
    @uri ||= null # implies current URL is proper polling endpoint
    @_timer = new Timer(@millis)
    @data = ko.observable({})

  start: ->
    debug "start function called"
    @_timer.start =>
      $.getJSON @uri, (res) =>
        debug "ajax res", res
        @data(res)
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
