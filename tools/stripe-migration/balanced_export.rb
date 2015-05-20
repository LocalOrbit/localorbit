class BalancedExport
  attr_reader :data

  def self.latest
    new
  end

  def initialize(file:nil)
    file ||= Dir["#{here}/from_balanced/*.csv"].sort.last
    @data = load_export_data(file)
  end


  def search(key, val)
    @data.select do |r| r[key] == val end.map(&:to_hash)
  end

  private
  def load_export_data(file)
    CSV.read(file, headers: true)
  end

  def here
    File.expand_path(File.dirname(__FILE__))
  end
end
