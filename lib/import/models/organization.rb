require 'import/models/base'
class Import::Organization < Import::Base
  self.table_name = "organizations"
  self.primary_key = "org_id"

  has_many :products, class_name: "Import::Product", foreign_key: "org_id"
  has_many :addresses, class_name: "Import::Address", foreign_key: "org_id"
  has_many :users, class_name: "Import::User", foreign_key: "org_id"

  has_many :market_organizations, class_name: "Import::MarketOrganization", foreign_key: "org_id"
  has_many :markets, through: :market_organizations, class_name: "Import::Market", foreign_key: "org_id"

  def import
    organization = ::Organization.where(legacy_id: org_id).first

    if organization.nil?
      organization = ::Organization.new(
        legacy_id: org_id,
        name: name,
        can_sell: !!allow_sell,
        who_story: profile,
        how_story: product_how,
        facebook: facebook,
        twitter: twitter,
        allow_ach: payment_allow_ach,
        allow_purchase_orders: payment_allow_purchaseorder,
        allow_credit_cards: payment_allow_paypal
      )

      case social_option_id
      when 1
        organization.display_facebook = true
      when 2
        organization.display_twitter = true
      end

      #products.each {|product| organization.products << product.import }
    end

    users.each do |user|
      if user.is_deleted == 0
        imported_user = user.import
        organization.users << imported_user if imported_user
      end
    end

    organization
  end
end
