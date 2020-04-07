module GoogleMaps
  def optimize_route(orig, dest, waypoints)
    response = open('http://maps.googleapis.com/maps/api/directions/json?origin=' + orig + '&dest=' + dest + '&waypoints=' + waypoints + '&key=' + ENV.fetch('GOOGLE_MAPS_KEY'))
    response = JSON.parse(response)

    return response[0]['routes']['waypoint_order']
  end
end