class Import
  def self.setup
    Dir[Rails.root.join('lib/import/models/*.rb')].each {|f| require f }
    @@ready = true
  end

  def self.market(id)
    Import.setup unless defined?(@@ready) && @@ready

    ActiveRecord::Base.transaction do
      Legacy::Market.find(id).import
    end
  end
end
