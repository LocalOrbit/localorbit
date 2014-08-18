class MapMarket
  constructor: (@point, @content, market_plan) ->
    market_plan = market_plan.trim()
    @marker_color = switch
      when market_plan == "Automate" then "#ffd600"
      when market_plan == "Grow" then "#22ff00"
      when market_plan == "Start Up" then "#0026ff"
      else "#ccc"

  marker: =>
    @_marker ?= @buildMarker()

  buildMarker: =>
    marker = new L.Marker(@point, icon: new L.mapbox.marker.icon("marker-color": @marker_color))
    marker.bindPopup(@content).openPopup()
    marker

window.MapMarket = MapMarket
