module MapHelper
  def static_map(geocodes, center, width, height, zoom=9)
    return "" unless center
    markers = "/"
    unless geocodes.empty?
      markers += geocodes.map {|g| "pin-s-circle(#{g.longitude},#{g.latitude})" }.join(",")
    end
    width = width > 640 ? 640 : width
    height = height > 640 ? 640 : height

    "//api.tiles.mapbox.com/v3/#{Figaro.env.mapbox_api_key}#{markers}/#{center.longitude},#{center.latitude},#{zoom}/#{width}x#{height}@2x.png"
  end

  def google_static_map(geocodes, center, width, height, zoom=11)
    return "" unless center
    markers = "?markers="
    unless geocodes.empty?
      markers += geocodes.map {|g| "#{g.latitude},#{g.longitude}" }.join("|")
    end
    width = width > 640 ? 640 : width
    height = height > 640 ? 640 : height

    "//maps.googleapis.com/maps/api/staticmap#{markers}&format=png&style=feature:road.highway|saturation:-100&center=#{center.latitude},#{center.longitude}&zoom=#{zoom}&size=#{width}x#{height}&key=#{Figaro.env.google_maps_key}"
  end
end
