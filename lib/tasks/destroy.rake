namespace :destroy do
  desc "Safely removes an organization from Local Orbit"
  task :organization, [:id] => [:environment] do |_t, args|
    def metric(prefix, key, value)
      puts "#{prefix} #{key}: #{value}"
      puts "----------------------------------------"
    end

    def header(org)
      puts "========================================"
      puts %(You are destroying "#{org.name}")
      puts "This will have the following impact"
      puts "========================================"
    end

    org = Organization.find(args[:id])

    header(org)
    metric("Delete", "Bank Accounts", org.bank_accounts.count)
    metric("Delete", "Carts", org.carts.count)
    metric("Delete", "Locations", org.locations.count)
    metric("Delete", "Payments To", Payment.where(payee_type: "Organization", payee_id: org.id).count)
    metric("Delete", "Payments From", Payment.where(payer_type: "Organization", payer_id: org.id).count)
    metric("Delete", "Prices", Price.where(organization_id: org.id).count)
    metric("Delete", "Products", org.products.count)
    metric("Delete", "Orders", org.orders.count)
    metric("Remove Associations with ", "User", org.users.count)

    STDOUT.puts %(Do you want to continue removing "#{org.name}"? (y/n))
    input = STDIN.gets.strip

    exit if input != "y"

    org.carts.each(&:destroy!)
    org.orders.each(&:destroy!)
    prices = Price.where(organization_id: org.id)
    prices.each(&:destroy!)

    org.users = []
    org.save!

    payments = Payment.where(payee_type: "Organization", payee_id: args[:id])
    payments += Payment.where(payer_type: "Organization", payer_id: args[:id])
    payments.each(&:destroy!)

    org.destroy!
  end
end
