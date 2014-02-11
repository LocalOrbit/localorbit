class Organization < ActiveRecord::Base
  has_many :market_organizations
  has_many :user_organizations

  has_many :users, through: :user_organizations
  has_many :markets, through: :market_organizations

  has_many :products

  has_many :locations, inverse_of: :organization

  validates :name, presence: true

  accepts_nested_attributes_for :locations

  scope :selling, lambda { where(can_sell: true) }
end
