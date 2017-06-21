module Quickbooks
  class Customer
    class << self
      def create_customer (org, session)
        customer = Quickbooks::Model::Customer.new
        customer.company_name = "#{org.id}-#{org.name}"
        customer.display_name = "#{org.id}-#{org.name}"

        billing_address = org.locations.default_billing ? org.locations.default_billing : org.locations.first
        address = Quickbooks::Model::PhysicalAddress.new
        address.line1 = billing_address.address
        address.city = billing_address.city
        address.country = billing_address.country
        address.country_sub_division_code = billing_address.state
        address.postal_code = billing_address.zip
        customer.billing_address = address

        customer.primary_email_address = billing_address.email

        shipping_address = org.locations.default_shipping ? org.locations.default_shipping : org.locations.first
        address = Quickbooks::Model::PhysicalAddress.new
        address.line1 = shipping_address.address
        address.city = shipping_address.city
        address.country = shipping_address.country
        address.country_sub_division_code = shipping_address.state
        address.postal_code = shipping_address.zip
        customer.shipping_address = address

        service = Quickbooks::Service::Customer.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.create(customer)
      end
    end
  end
end