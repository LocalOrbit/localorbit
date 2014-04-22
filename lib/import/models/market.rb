require 'import/models/base'
class Import::Market < Import::Base
  self.table_name = "domains"
  self.primary_key = "domain_id"

  has_many :organizations, class_name: "::Import::Organization"
  belongs_to :timezone, class_name: "Import::Timezone", foreign_key: :tz_id

  has_many :market_organizations, class_name: "Import::MarketOrganization", foreign_key: "domain_id"
  has_many :organizations, through: :market_organizations, class_name: "Import::Organization"

  def import
    market = ::Market.new(
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

    organizations.each do |org|
      puts org.name
    end

    market
  end

  def parse_subdomain
    hostname.split('.').first
  end
end
