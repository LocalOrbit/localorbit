class Promotion < ActiveRecord::Base
  belongs_to :product, inverse_of: :promotions
  belongs_to :market, inverse_of: :promotions

  validates :name, presence: true
  validates :title, presence: true
  validates :market, presence: true
  validates :product, presence: true

  validate :one_active_per_market, if: "market.present?"

  scope :active, -> { where(active: true) }

  def self.promotions_for_user(user)
    if user.admin?
      all
    else
      market_ids = user.markets.map(&:id)
      where(market_id: market_ids)
    end
  end

  private

  def one_active_per_market
    if market.reload.promotions.active.count > 1
      self.errors.add(:active, "There can only be one active promotion per market")
    end
  end
end
