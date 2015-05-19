require_relative "../../config/environment"

module DownloadStripeBankAccounts
  class << self
    def go(file:)
      puts "(Stripe key #{Figaro.env.stripe_publishable_key})"
      data = get_all
      write_yaml file, data
    end

    def get_all
      all_accounts = Util::StripeEnumerator.create(limit: 100) { |params| Stripe::Account.all(params) }
      stripe_bank_accounts = []
      all_accounts.each do |acct|
        if bank_accounts = acct.bank_accounts
          if bank_accounts.data
            bank_accounts.data.each do |ba|
              stripe_bank_accounts << {
                stripe_account_id: ba.account,
                bank_account_id: ba.id,
                country: ba.country,
                fingerprint: ba.fingerprint,
                routing_number: ba.routing_number,
                bank_name: ba.bank_name,
                last4: ba.last4
              }
            end
          end
        end
      end
      return stripe_bank_accounts
    end

    def write_yaml(fname, data)
      File.write fname, YAML.dump(data)
      puts "Wrote #{fname}"
    end

  end
end

DownloadStripeBankAccounts.go file: "tools/stripe-migration/downloaded_stripe_bank_accounts.yml"
