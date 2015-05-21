require_relative "../../config/environment"

puts "WHOA THERE"
puts "Edit this file #{__FILE__} and address the TODOs."
puts "ALSO: gear this action to focus on one market at a time?"

exit

def find_stripe_bank_accounts(sabas, bank_name, last_four)
  sabas.select do |saba|
    (saba[:bank_name] == bank_name and saba[:last4] == last_four)
  end
end

marketsh = YAML.load_file("tools/stripe-migration/market_stripe_account_ids.yml")

# TODO
# Market.active.each.select do |m|
#   m.stripe_account_id != nil
# end.each do |m|

marketsh.each do |mk|
  stripe_account_id = mk[:stripe_account_id]
  m = Market.find(mk[:market_id])
  
  stripe_account = Stripe::Account.retrieve(stripe_account_id)
  sabas = stripe_account.bank_accounts.data

  m.bank_accounts.each do |ba|
    if true # TODO ba.stripe_id.nil?
      if sabas = find_stripe_bank_accounts(sabas, ba.bank_name, ba.last_four)
        if sabas.count == 1
          saba = sabas.first

          # TODO ba.update(stripe_id: saba.id)

          #TODO puts "Updated BankAccount #{ba.id} with stripe_id #{ba.stripe_id}"
          puts "WOULDA Updated BankAccount #{ba.id} with stripe_id #{saba.id}"
        elsif sabas.count > 1
          puts "!! BankAccount #{ba.id} matched MORE THAN ONE Stripe Bank Account for Stripe Account #{stripe_account_id}"
          # TODO puts "!! BankAccount #{ba.id} matched MORE THAN ONE Stripe Bank Account for Stripe Account #{stripe_account_id}: #{sabas.inspect}"
        else
          puts "!! BankAccount #{ba.id} matched no Stripe Bank Account for Stripe Account #{stripe_account_id}"
        end
        $stdout.flush
      end
    end
  end
end
