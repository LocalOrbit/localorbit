class ExternalProduct < ActiveRecord::Base # should associate these with general products TODO

	serialize :source_data, JSON

	has_one :product # but the product has a general product id 
	belongs_to :organization 

  def self.contrive_key(fields)
    raise ArgumentError if fields.empty?
    Digest::SHA1.base64digest(fields.join("--")).chomp("=")
  end

end
