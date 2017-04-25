module Quickbooks
  class Vendor
    class << self
      def create_vendor (org, session)
        vendor = Quickbooks::Model::Vendor.new
        vendor.company_name = "#{org.id}-#{org.name}"
        vendor.display_name = "#{org.id}-#{org.name}"
        vendor.print_on_check_name = org.qb_check_name.nil? ? org.name : org.qb_check_name

        billing_address = org.locations.default_billing.nil? ? org.locations.first : org.locations.default_billing
        address = Quickbooks::Model::PhysicalAddress.new
        address.line1 = billing_address.address
        address.city = billing_address.city
        address.country = billing_address.country
        address.country_sub_division_code = billing_address.state
        address.postal_code = billing_address.zip
        vendor.billing_address = address

        service = Quickbooks::Service::Vendor.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.create(vendor)
      end
    end
  end
end