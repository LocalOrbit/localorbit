class Promotion < ActiveRecord::Base
  audited allow_mass_assignment: true
  extend DragonflyBackgroundResize

  belongs_to :product, inverse_of: :promotions
  belongs_to :market, inverse_of: :promotions

  validates :name, presence: true
  validates :title, presence: true
  validates :market, presence: true
  validates :product, presence: true

  validate :one_active_per_market, if: "market.present? && active?"

  dragonfly_accessor :image
  define_after_upload_resize(:image, 1200, 1200)
  validates_property :format, of: :image, in: %w(jpeg png gif)

  scope :active, -> { where(active: true) }

  def featureable?(market, buyer, delivery)
    inventory = product.available_inventory(delivery.deliver_on)
    product.prices.any? {|price| price.for_market_and_organization?(market, buyer) && price.min_quantity <= inventory }
  end

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
    if (self.persisted? && market.promotions.active.where.not(id: id).any?) ||
       (self.new_record? && market.promotions.active.any?)
      errors.add(:active, "There can only be one active promotion per market")
    end
  end
end
