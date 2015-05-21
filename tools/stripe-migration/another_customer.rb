require_relative("../../config/environment")
require_relative('balanced_export')

def uri_to_id(uri)
  uri.split("/").last if uri
end

market = Market.find(18)

export = BalancedExport.new

market.organizations.visible.each do |org|
  if balanced_customer_id = uri_to_id(org.balanced_customer_uri)
    row = export.search('customer_guid', balanced_customer_id).first
    if row
      scid = row['stripe.customer_id']
      puts "#{org.id}\t#{balanced_customer_id}\t#{scid}"
    else
      puts "(miss org #{org.id})"
    end
  end
end

