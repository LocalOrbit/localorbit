require "import/models/base"

module Imported
  class Market < ActiveRecord::Base
    self.table_name = "markets"

    has_many :addresses, class_name: "Imported::MarketAddress"
    has_many :delivery_schedules, class_name: "Imported::DeliverySchedule", inverse_of: :market
    has_many :managed_markets
    has_many :managers, through: :managed_markets, source: :user
    has_many :market_organizations, class_name: "Imported::MarketOrganization"
    has_many :orders, class_name: "Imported::Order"
    has_many :organizations, class_name: "Imported::Organization", through: :market_organizations
    has_many :payments, class_name: "Imported::Payment"
  end
end

class Legacy::Market < Legacy::Base
  TIMEZONES = {
    "Eastern Standard Time" => "Eastern Time (US & Canada)",
    "Central Standard Time" => "Central Time (US & Canada)",
    "Mountain Standard Time" => "Mountain Time (US & Canada)",
    "Pacific Standard Time" => "Pacific Time (US & Canada)",
  }

  self.table_name = "domains"
  self.primary_key = "domain_id"

  belongs_to :brand, class_name: "Legacy::Brand", foreign_key: :domain_id

  has_many :organizations, class_name: "Legacy::Organization"
  has_many :delivery_schedules, class_name: "Legacy::DeliverySchedule", foreign_key: :domain_id
  has_many :orders, class_name: "Legacy::Order", foreign_key: :domain_id

  has_many :market_organizations, class_name: "Legacy::MarketOrganization", foreign_key: "domain_id"
  has_many :organizations, -> { where("organizations_to_domains.orgtype_id = 3") }, through: :market_organizations, class_name: "Legacy::Organization"
  has_many :market_org, -> { where("organizations_to_domains.orgtype_id = 2") }, through: :market_organizations, class_name: "Legacy::Organization", source: :organization

  belongs_to :timezone, class_name: "Legacy::Timezone", foreign_key: :tz_id

  def import
    attributes = {
      legacy_id: domain_id,
      name: name.clean,
      subdomain: parse_subdomain,
      active: is_live,
      timezone: TIMEZONES[timezone.tz_name],
      profile: market_profile.clean,
      policies: market_policies.clean,
      tagline: custom_tagline.clean,
      contact_name: secondary_contact_name.clean,
      contact_phone: secondary_contact_phone,
      contact_email: secondary_contact_email,
      twitter: twitter,
      facebook: facebook,
      po_payment_term: po_due_within_days,
      default_allow_purchase_orders: payment_default_purchaseorder,
      default_allow_credit_cards: payment_default_paypal,
      default_allow_ach: payment_default_ach,
      allow_purchase_orders: payment_allow_purchaseorder,
      allow_credit_cards: payment_allow_paypal,
      allow_ach: payment_allow_ach,
      local_orbit_seller_fee: fee_percen_lo,
      market_seller_fee: fee_percen_hub,
      background_image: imported_background,
      background_color: imported_background_color,
      text_color: imported_text_color,
      closed: is_closed == 1
    }

    market = Imported::Market.where(legacy_id: domain_id).first
    if market.nil?
      puts "Importing market: #{name}"
      market = Imported::Market.new(attributes)
    else
      puts "Updating market: #{market.name}"
      market.update(attributes)
    end

    if market.valid?
      organizations.each_with_index do |org, index|
        puts "Importing organization #{index + 1} of #{organizations.count}"
        imported_organization = org.import
        market.organizations << imported_organization if imported_organization && !market.organizations.include?(imported_organization)
      end

      market_org.each_with_index do |org, index|
        puts "Importing market organization #{index + 1} of #{market_org.count}"
        imported_organization = org.import
        market.organizations << imported_organization if imported_organization && !market.organizations.include?(imported_organization)
      end

      market_org.each do |org|
        puts "Importing market addresses..."
        org.market_addresses.each do |address|
          market.addresses << address.import
        end

        puts "Importing market managers..."
        org.users.each do |user|
          next unless user.is_deleted == 0
          imported_user = user.import
          if imported_user && !market.managers.include?(imported_user)
            market.managers << imported_user
          end
        end
      end

      puts "Importing market logo..."
      %w(jpg gif png).each do |extension|
        begin
          logo = Dragonfly.app.fetch_url("http://app.localorb.it/img/#{domain_id}/logo-large.#{extension}")
          if logo.image?
            market.logo_uid = logo.store
            break
          end
        rescue
        end
      end

      puts "Importing market profile photo..."
      %w(jpg gif png).each do |extension|
        begin
          logo = Dragonfly.app.fetch_url("http://app.localorb.it/img/#{domain_id}/profile.#{extension}")
          if logo.image?
            market.photo_uid = logo.store
            break
          end
        rescue
        end
      end

      market.save

      puts "Importing #{delivery_schedules.count} delivery schedules..."
      delivery_schedules.each_with_index do |ds|
        market.delivery_schedules << ds.import(market)
      end

      puts "Importing #{orders.count} orders..."
      Legacy::Order.where(domain_id: market.legacy_id).each do |order|
        imported = order.import
        market.orders << imported if imported.present?
      end
      market.save

      puts "Importing payments..."
      Legacy::Payment.where(from_domain_id: market.legacy_id).uniq.each do |payment|
        payment.import(market).save!
      end
      Imported::Payment.where("payer_type LIKE ? or payee_type LIKE ?", "Imported::%", "Imported::%").each do |payment|
        payment.update(
          payer_type: payment.payer_type.try(:gsub, "Imported::", ""),
          payee_type: payment.payee_type.try(:gsub, "Imported::", "")
        )
      end

      puts "Setting market product delivery schedules..."
      market.organizations.each do |organization|
        organization.products.each {|p| p.update_delivery_schedules }
      end

      puts "Ensuring Geocodes..."
      ::MarketAddress.where(market_id: market.id).each do |address|
        address.send(:attach_geocode)
      end

    end

    market.save
    market
  end

  def parse_subdomain
    hostname.split(".").first
  end

  def imported_background
    if brand && brand.background
      brand.background.file_name
    end
  end

  def imported_text_color
    "#%06X" % brand.text_color if brand
  end

  def imported_background_color
    "#%06X" % brand.background_color if brand
  end
end
