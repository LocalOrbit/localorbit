class MapMarket
  constructor: (@point, @content, market_plan) ->
    market_plan = market_plan.trim()
    @marker_color = switch
      when market_plan == "Automate" then "#ffe9e1"
      when market_plan == "Grow" then "#eaf9db"
      when market_plan == "Start Up" then "#fff8e1"
      else "#ccc"

  marker: =>
    @_marker ?= @buildMarker()

  buildMarker: =>
    marker = new L.Marker(@point, icon: new L.mapbox.marker.icon("marker-color": @marker_color))
    marker.bindPopup(@content).openPopup()
    marker

window.MapMarket = MapMarket
