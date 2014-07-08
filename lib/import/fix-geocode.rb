module Imported
  def self.fix_geocodes
    @failed_locations = []
    locations = []

    locations += Location.all.select {|l| l.geocode.nil? }
    locations += MarketAddress.all.select {|l| l.geocode.nil? }

    locations.each do |location|
      begin
        unless location.save
          @failed_locations << {location: location, reason: location.errors}
        end
      rescue => e
        @failed_locations << {location: location, reason: e.message + e.backtrace.join("\n")}
      end
    end

    print_report(@failed_locations)
  end

  private

  def self.print_report(failed_locations)
    failed_locations.each do |l|
      puts "--------------------------------------------------"
      puts "Could not import: #{l[:id]}"
      puts l[:reason]
      puts "--------------------------------------------------"
    end
  end
end
