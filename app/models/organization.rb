class Organization < ActiveRecord::Base
  has_many :market_organizations
  has_many :user_organizations

  validates :name, presence: true
end
