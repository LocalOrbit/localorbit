class SetDefaultPaymentTypesForOrgs < ActiveRecord::Migration
  class Market < ActiveRecord::Base; end
  class Organization < ActiveRecord::Base; end
  class MarketOrganization < ActiveRecord::Base; end

  def up
    Organization.find_each do |org|
      mo = MarketOrganization.find_by(organization_id: org.id)
      market = Market.find(mo.market_id)

      org.allow_purchase_orders = market.default_allow_purchase_orders
      org.allow_credit_cards    = market.default_allow_credit_cards
      org.allow_ach             = market.default_allow_ach
      org.save!
    end
  end

  def down
    # Nothing to do here
  end
end
