class Location < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :organization
  include SoftDelete
  belongs_to :organization, inverse_of: :locations

  validates :address, :city, :state, :zip, :organization, :country, presence: true
  validates :default_billing,  uniqueness: {scope: [:organization_id, :deleted_at]}, if: "!!default_billing"
  validates :default_shipping, uniqueness: {scope: [:organization_id, :deleted_at]}, if: "!!default_shipping"

  before_create :set_defaults_if_necessary
  before_save :ensure_default_address_label
  after_update :set_new_defaults

  def self.alphabetical_by_name
    order(name: :asc)
  end

  def self.default_billing
    find_by(default_billing: true)
  end

  def self.default_shipping
    find_by(default_shipping: true)
  end

  def ensure_default_address_label
   if (not self.name) || self.name == ""
      self.name = "Default Address"
    end
  end

  private

  def set_defaults_if_necessary
    if !Location.visible.where(organization_id: organization_id).exists?
      self.default_shipping = true
      self.default_billing = true
    end
  end

  def set_new_defaults
    return true if deleted_at.nil?
    return true unless default_billing || default_shipping

    loc = Location.visible.where(organization_id: organization_id).order(:id).first
    loc.update_attribute(:default_billing, true)  if loc && default_billing
    loc.update_attribute(:default_shipping, true) if loc && default_shipping
    true
  end
end
