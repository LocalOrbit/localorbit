# ENV['RAILS_ENV'] = 'development'
require_relative "../../config/environment"
# require 'yaml'
# require 'pry'

module PushOrganizationStripeCustomerIds
  extend self

  def update_organizations
    organizations = YAML.load_file("tools/stripe-migration/matched_organizations.yml")

    organizations.each do |o|
      oid = o[:organization_id]
      scid = o[:stripe_customer_id]
      if oid and scid
        organization = Organization.where(id:oid).first
        if organization
          log "Update Organization #{oid}, set stripe_customer_id #{scid}"
          organization.update(stripe_customer_id: scid)
        else
          log "COULD NOT FIND ORGANIZATION #{oid} - #{o.inspect}"
        end
      else
        log "NOT UPDATING: #{o.inspect} (missing organization_id or stripe_customer_id fields)"
      end
    end
  end

  def log(str)
    $stdout.puts "[#{Time.now.to_s}] - #{self.name} (#{Rails.env}): #{str}"
    $stdout.flush
  end

end

PushOrganizationStripeCustomerIds.update_organizations
