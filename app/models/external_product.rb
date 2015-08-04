class ExternalProduct < ActiveRecord::Base

	serialize :source_data, JSON

	has_one :product

  def self.contrive_key(organization_id, fields)
    raise ArgumentError if organization_id.nil? || fields.empty?

    Digest::SHA1.base64digest([organization_id, *fields].join("--")).chomp("=")
  end
end
