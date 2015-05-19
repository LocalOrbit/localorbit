require_relative "../../config/environment"

module DownloadLoProdIds
  extend self

  def download_organizations
    puts "download_organizations..."; $stdout.flush
    data = {}
    Organization.visible.each do |org|
      data[org.id] = {
        organization_id: org.id,
        name: org.name,
        balanced_customer_uri: org.balanced_customer_uri,
        balanced_customer_id: balanced_uri_to_id(org.balanced_customer_uri),
        balanced_underwritten: org.balanced_underwritten,
        # stripe_customer_id: org.stripe_customer_id
      }
    end
    write_yaml "#{dir}/organizations.yml", data
  end

  def download_markets
    puts "download_markets..."; $stdout.flush
    data = {}
    Market.active.each do |market|
      data[market.id] = {
        market_id: market.id,
        name: market.name,
        balanced_customer_uri: market.balanced_customer_uri,
        balanced_customer_id: balanced_uri_to_id(market.balanced_customer_uri),
        balanced_underwritten: market.balanced_underwritten,
        # stripe_customer_id: market.stripe_customer_id,
        # stripe_account_id: market.stripe_customer_id,
      }
    end
    write_yaml "#{dir}/markets.yml", data
  end

  def download_bank_accounts
    puts "download_bank_accounts..."; $stdout.flush
    data = {}
    BankAccount.visible.each do |ba|
      data[ba.id] = {
        bank_account_id: ba.id,
        name: ba.name,
        balanced_uri: ba.balanced_uri,
        balanced_id: balanced_uri_to_id(ba.balanced_uri),
        balanced_verification_uri: ba.balanced_verification_uri,
        # stripe_id: ba.stripe_id,
        account_type: ba.account_type,
        bankable_type: ba.bankable_type,
        bankable_id: ba.bankable_id,
        bank_name: ba.bank_name,
        last_four: ba.last_four,
        expiration_month: ba.expiration_month,
        expiration_year: ba.expiration_year,
      }
    end
    write_yaml "#{dir}/bank_accounts.yml", data
  end

  def write_yaml(fname, data)
    File.write fname, YAML.dump(data)
    puts "Wrote #{fname}"
  end

  def dir
    dir = "tools/stripe-migration/lo-prod-ids"
  end

  def balanced_uri_to_id(uri)
    uri.split("/").last if uri
  end
end


DownloadLoProdIds.download_markets
DownloadLoProdIds.download_organizations
DownloadLoProdIds.download_bank_accounts
