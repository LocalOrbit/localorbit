class BalancedExport
  attr_reader :data, :file

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

  def search_for_balanced_customer_uri(uri)
    bcid = uri_to_id(uri)
    search('customer_guid', bcid)
  end

  def stripe_customer_id_for_balanced_customer_uri(uri)
    rows = search_for_balanced_customer_uri(uri)
    scids = rows.map do |r| r['stripe.customer_id'] end.uniq
    if scids.length <= 1
      return scids.first  # returns nil if none found
    else
      raise "UNEXPECTED: balanced_customer_uri #{uri} maps to MULTIPLE stripe customer ids: #{scids.inspect} in export file #{@file}"
    end
  end

  def stripe_account_id_for_balanced_customer_uri(uri)
    rows = search_for_balanced_customer_uri(uri)
    ids = rows.map do |r| r['stripe.account_id'] end.uniq
    if ids.length <= 1
      return ids.first  # returns nil if none found
    else
      raise "UNEXPECTED: balanced_customer_uri #{uri} maps to MULTIPLE stripe account ids: #{ids.inspect} in export file #{@file}"
    end
  end

  def stripe_id_for_bank_account_balanced_uri(uri)
    fig = uri_to_id(uri)
    rows = search('funding_instrument_guid', fig)
    ids = rows.map do |r| r['stripe_customer.funding_instrument.id'] end.uniq
    if ids.length <= 1
      return ids.first
    else
      raise "UNEXPECTED: bank account balanced_uri #{uri} maps to MULTIPLE stripe_customer.funding_instrument.ids: #{ids.inspect} in export file #{@file}"
    end
  end

  private

  def uri_to_id(uri)
    if uri and uri =~ /\//
      uri.split("/").last
    else
      uri
    end
  end

  def load_export_data(file)
    @file = file
    CSV.read(@file, headers: true)
  end

  def here
    File.expand_path(File.dirname(__FILE__))
  end
end
