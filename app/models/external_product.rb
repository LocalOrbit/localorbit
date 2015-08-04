class ExternalProduct < ActiveRecord::Base

  def self.contrive_key(fields)
    raise ArgumentError if fields.empty?

    Digest::SHA1.base64digest(fields.join("--")).chomp("=")
  end
end
