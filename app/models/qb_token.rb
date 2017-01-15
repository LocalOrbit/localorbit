class QbToken < ActiveRecord::Base
  attr_encrypted :access_token, key: 'This is a key for the encryption'
  attr_encrypted :access_secret, key: 'This is a key for the encryption'
  attr_encrypted :realm_id, key: 'This is a key for the encryption'
  belongs_to :organization

end