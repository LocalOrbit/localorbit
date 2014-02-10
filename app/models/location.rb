class Location < ActiveRecord::Base
  belongs_to :organization

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :address, :city, :state, :zip, :organization_id, presence: true

  def self.alphabetical_by_name
    order(name: :asc)
  end
end
