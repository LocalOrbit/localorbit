Geocode.geocoder = Graticule.service(:multi).new(
  Graticule.service(:google).new(Figaro.env.google_maps_key)
)
