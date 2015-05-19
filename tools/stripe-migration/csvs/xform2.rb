require 'yaml'

org_ids = YAML.load_file("organization_balanced_customer_uris.yml")
rev = {}
org_ids.each do |id,uri|
  cid = uri.split("/").last
  rev[cid] = { organization_id: id, balanced_customer_uri: uri, balanced_customer_id: cid }
end
File.open("org_cust_ids.yml","w") do |f| f.print YAML.dump(rev) end

m_ids = YAML.load_file("market_balanced_customer_uris.yml")
rev = {}
m_ids.each do |id,uri|
  cid = uri.split("/").last
  rev[cid] = { market_id: id, balanced_customer_uri: uri, balanced_customer_id: cid }
end
File.open("market_cust_ids.yml","w") do |f| f.print YAML.dump(rev) end
