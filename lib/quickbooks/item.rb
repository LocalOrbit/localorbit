module Quickbooks
  class Item
    class << self
      def create_item(product, session, config)
        item = Quickbooks::Model::Item.new
        item.name = "#{product.id}-#{product.name}"
        item.description = product.short_description
        item.type = 'NonInventory'

        income_acct = Quickbooks::Model::BaseReference.new
        income_acct.name = config.income_account_name
        income_acct.value = config.income_account_id
        item.income_account_ref = income_acct

        expense_acct = Quickbooks::Model::BaseReference.new
        expense_acct.name = config.expense_account_name
        expense_acct.value = config.expense_account_id
        item.expense_account_ref = expense_acct

        asset_acct = Quickbooks::Model::BaseReference.new
        asset_acct.name = config.asset_account_name
        asset_acct.value = config.asset_account_id
        item.asset_account_ref = asset_acct

        service = Quickbooks::Service::Item.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.create(item)
      end

      def update_item (product, session)
        service = Quickbooks::Service::Item.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        item = service.fetch_by_id(product.qb_item_id)
        item.name = "#{product.id}-#{product.name}"
        item.description = product.short_description

        service.update(item, :sparse => true)
      end

      def query_item (item_name, session)
        item = Quickbooks::Model::Item.new

        service = Quickbooks::Service::Item.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.query("Select Id From Item where Name = '#{item_name}'")
      end
    end
  end
end