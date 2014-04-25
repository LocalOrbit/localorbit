require 'import/models/base'
class Import::Market < Import::Base
  self.table_name = "domains"
  self.primary_key = "domain_id"

  has_many :organizations, class_name: "::Import::Organization"
  has_many :delivery_schedules, class_name: "Import::DeliverySchedule", foreign_key: :domain_id
  belongs_to :timezone, class_name: "Import::Timezone", foreign_key: :tz_id

  has_many :market_organizations, class_name: "Import::MarketOrganization", foreign_key: "domain_id"
  has_many :organizations, -> { where("organizations_to_domains.orgtype_id = 3") }, through: :market_organizations, class_name: "Import::Organization"
  has_many :market_org, -> { where("organizations_to_domains.orgtype_id = 2") }, through: :market_organizations, class_name: "Import::Organization", source: :organization

  def import
    market = ::Market.where(legacy_id: domain_id).first
    if market.nil?
      market = ::Market.new(
        legacy_id: domain_id,
        name: name,
        subdomain: parse_subdomain,
        active: is_live,
        timezone: timezone.tz_code,
        profile: market_profile,
        policies: market_policies,
        tagline: custom_tagline,
        contact_name: secondary_contact_name,
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
        market_seller_fee: fee_percen_hub
      )
    end

    if market.valid?
      organizations.each {|org| market.organizations << org.import }

      market_org.each do |org|
        org.market_addresses.each do |address|
          market.addresses << address.import
        end

        org.users.each do |user|
          if user.is_deleted == 0
            imported_user = user.import
            if imported_user && !market.managers.include?(imported_user)
              market.managers << imported_user
            end
          end
        end
      end

      market.save

      delivery_schedules.each do |ds|
        market.delivery_schedules << ds.import(market)
      end
    end

    market.save
    market
  end

  def parse_subdomain
    hostname.split('.').first
  end
end
