class Promotion < ActiveRecord::Base
  belongs_to :product, inverse_of: :promotions
  belongs_to :market, inverse_of: :promotions

  validates :name, presence: true
  validates :title, presence: true
  validates :market, presence: true
  validates :product, presence: true

  validate :one_active_per_market, if: "market.present?"

  scope :active, -> { where(active: true) }

  private

  def one_active_per_market
    if market.reload.promotions.active.reject {|p| p.id == self.id }.any?
      self.errors.add(:active, "There can only be one active promotion per market")
    end
  end
end
