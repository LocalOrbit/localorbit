require 'yaml'

map = {}
name = "organization_balanced_customer_uris"
File.readlines("#{name}.csv").each do |line|
  if line.strip =~ /^(\d+)\s(.*)$/
    organization_id = $1.to_i
    balanced_customer_uri = $2
    map[organization_id] = balanced_customer_uri
  end
end
File.open("#{name}.yml","w") do |f|
  f.print YAML.dump(map)
end

map = {}
name = "market_balanced_customer_uris"
File.readlines("#{name}.csv").each do |line|
  if line.strip =~ /^(\d+)\s(.*)$/
    organization_id = $1.to_i
    balanced_customer_uri = $2
    map[organization_id] = balanced_customer_uri
  end
end
File.open("#{name}.yml","w") do |f|
  f.print YAML.dump(map)
end
