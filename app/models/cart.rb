class Cart < ActiveRecord::Base
  belongs_to :market
  belongs_to :organization
  belongs_to :delivery
  belongs_to :location

  validates :organization, presence:true
  validates :market, presence:true
  validates :delivery, presence:true
end
