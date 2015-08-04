class ExternalProduct < ActiveRecord::Base

	serialize :source_data, JSON

	has_one :product
	belongs_to :organization 

  def self.contrive_key(fields)
    raise ArgumentError if fields.empty?
    Digest::SHA1.base64digest(fields.join("--")).chomp("=")
  end

end
