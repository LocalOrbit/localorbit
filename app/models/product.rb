class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :organization
  belongs_to :location

  has_many :lots

  validates :name, presence: true
  validates :category_id, presence: true
  validates :organization_id, presence: true

  validate :ensure_organization_can_sell

  private

  def ensure_organization_can_sell
    unless organization.present? && organization.can_sell?
      errors.add(:organization, "must be able to sell products")
    end
  end
end
