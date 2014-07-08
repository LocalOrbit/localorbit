require "import/models/base"
module Imported
  class Organization < ActiveRecord::Base
    self.table_name = "organizations"

    has_many :locations, class_name: "Imported::Location", inverse_of: :organization
    has_many :market_organizations
    has_many :markets, class_name: "Imported::Market", through: :market_organizations
    has_many :orders, class_name: "Imported::Order", inverse_of: :organization
    has_many :products, class_name: "Imported::Product", inverse_of: :organization, autosave: true, dependent: :destroy
    has_many :user_organizations
    has_many :users, through: :user_organizations
  end
end

class Legacy::Organization < Legacy::Base
  self.table_name = "organizations"
  self.primary_key = "org_id"

  has_many :products, class_name: "Legacy::Product", foreign_key: :org_id
  has_many :market_addresses, class_name: "Legacy::MarketAddress", foreign_key: :org_id
  has_many :addresses, class_name: "Legacy::Address", foreign_key: :org_id
  has_many :users, class_name: "Legacy::User", foreign_key: :org_id
  has_many :orders, class_name: "Legacy::Order", foreign_key: :org_id

  has_many :market_organizations, class_name: "Legacy::MarketOrganization", foreign_key: :org_id
  has_many :markets, through: :market_organizations, class_name: "Legacy::Market", foreign_key: :org_id

  def import
    if is_deleted != 1
      attributes = {
        legacy_id: org_id,
        name: name.clean,
        can_sell: !!allow_sell,
        show_profile: !!public_profile,
        who_story: profile.try(:clean),
        how_story: product_how.try(:clean),
        facebook: facebook,
        twitter: twitter,
        allow_ach: payment_allow_ach,
        allow_purchase_orders: payment_allow_purchaseorder,
        allow_credit_cards: payment_allow_paypal
      }

      organization = Imported::Organization.where(legacy_id: org_id).first
      if organization.nil?
        puts "- Creating organization: #{name}"
        organization = Imported::Organization.new(attributes)

        case social_option_id
        when 1
          organization.display_facebook = true
        when 2
          organization.display_twitter = true
        end

        puts "- Importing profile photo..."
        photo = Dragonfly.app.fetch_url("http://app.localorb.it/img/organizations/cached/#{org_id}.320.260.png")
        organization.photo_uid = photo.store if photo.image?

      else
        puts "- Existing organization: #{organization.name}"
        organization.update(attributes)
      end

      puts "- Importing #{addresses.count} organization locations..."
      addresses.each do |address|
        organization.locations << address.import
      end

      puts "- Importing #{users.count} users..."
      users.each do |user|
        if user.is_deleted == 0
          imported_user = user.import
          if imported_user && !organization.users.include?(imported_user)
            organization.users << imported_user
          end
        end
      end

      if organization.save
        puts "- Importing #{products.count} products..."
        products.each {|product| organization.products << product.import(organization) }
      end

      organization
    end
  end
end
