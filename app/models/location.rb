class Location < ActiveRecord::Base
  belongs_to :organization, inverse_of: :locations

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :address, :city, :state, :zip, :organization, presence: true
  validates :default_billing, uniqueness: { scope: :organization_id }, if: "!!default_billing"

  def self.alphabetical_by_name
    order(name: :asc)
  end

  def self.default_billing
    find_by(default_billing: true)
  end
end
