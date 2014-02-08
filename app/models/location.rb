class Location < ActiveRecord::Base
  belongs_to :organization

  validates :name, presence: true, uniqueness: true
  validates :address, :city, :state, :zip, :organization_id, presence: true
end
