module Quickbooks
  class Account
    class << self
      def query_account (acct_name, session)
        account = Quickbooks::Model::Account.new

        service = Quickbooks::Service::Account.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.query("Select Id From Account where Name = '#{acct_name}'")
      end
    end
  end
end