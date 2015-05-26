require 'yaml'
def do_count(fname)
  data = YAML.load_file(fname)
  hits = 0
  misses = 0
  data.values.each do |h|
    if h[:stripe_customer_id]
      hits += 1
    else
      misses += 1
    end
  end
  puts "#{fname}:"
  puts "Hits: #{hits}"
  puts "Miss: #{misses}"
  puts "Tot : #{hits + misses}"
end

do_count("market_customers.yml")
do_count("organization_customers.yml")

stripe_misses = YAML.load_file("missed_customers.yml").keys.length
puts "Stripe customers we couldn't find in LO: #{stripe_misses}"

