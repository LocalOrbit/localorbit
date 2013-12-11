class Market < ActiveRecord::Base
  validates :name, :subdomain, uniqueness: true
end
