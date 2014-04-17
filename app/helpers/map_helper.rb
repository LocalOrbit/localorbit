module MapHelper
  def static_map(geocodes, center, width, height, zoom = 9)
    markers = "/"
    unless geocodes.empty?
      markers += geocodes.map{|g| "pin-s-grocery(#{g.longitude},#{g.latitude})" }.join(",")
    end

    "http://api.tiles.mapbox.com/v3/#{Figaro.env.mapbox_api_key}#{markers}/#{center.longitude},#{center.latitude},#{zoom}/#{width}x#{height}@2x.png"
  end
end