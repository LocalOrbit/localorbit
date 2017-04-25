module Quickbooks
  class Term
    class << self
      def query_term (due, session)
        service = Quickbooks::Service::Term.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.query("Select Id From Term where Name = '#{due}'")
      end
    end
  end
end