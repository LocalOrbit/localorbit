require 'csv'

# Import the units from a csv export
# of the legacy units
class ImportLegacyUnits
  def self.run(filename, opts={})
    new(filename, opts).run
  end

  def initialize(filename, opts = {})
    @filename       = filename
    @units          = []
    @verbose        = opts[:verbose]
    @original_count = Unit.count if @verbose
  end

  def run
    load_csv
    store(@units)

    if @verbose
      puts "#{@original_count} Exisiting Units"
      puts "Created #{Unit.count - @original_count} new Units."
      puts "There were #{@units.size} rows detected in the import file"
    end
  end

  def load_csv
    CSV.foreach(@filename, headers: true) do |row|
      unit = {singular: row['name'], plural: row['plural']}
      @units << unit
      if @verbose
        if unit[:singular].pluralize != unit[:plural] || unit[:plural].singularize != unit[:singular]
          puts "Rails gets the inflection wrong for: #{unit[:singular]}/#{unit[:plural]}"
        end
      end
    end
  end

  def store(units)
    units.each do |unit|
      Unit.find_or_create_by!(singular: unit[:singular], plural: unit[:plural])
    end
  end
end
