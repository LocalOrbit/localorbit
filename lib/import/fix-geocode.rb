def print_report(failed_locations)
  failed_locations.each do |l|
    puts "--------------------------------------------------"
    puts l[:id]
    puts l[:reason]
    puts "--------------------------------------------------"
  end
end

@failed_locations = []

def save_location_and_report(location)
  begin
    unless location.save
      @failed_locations << {location_id: location.id, reason: location.errors.to_s}
    end
  rescue Exception => e
    @failed_locations << {location_id: location, reason: e.message + e.backtrace.join("\n") }
  end
end

locations = Location.all.select {|l| l.geocode.nil? }
market_addresses = MarketAddress.all.select {|l| l.geocode.nil? }

locations.each {|l| save_location_and_report(l) }
market_addresses.each {|ma| save_location_and_report(ma) }

print_report(@failed_locations)
