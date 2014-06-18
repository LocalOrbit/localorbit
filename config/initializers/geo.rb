Geocode.geocoder = Graticule.service(:multi).new(
  Graticule.service(:mapbox).new(Figaro.env.mapbox_api_key),
  Graticule.service(:google).new(Figaro.env.google_maps_key)
)
