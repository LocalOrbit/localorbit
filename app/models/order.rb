class Order < ActiveRecord::Base
  belongs_to :market
  belongs_to :organization
  has_many :items, inverse_of: :order

  validates :billing_address, presence: true
  validates :billing_city, presence: true
  validates :billing_organization_name, presence: true
  validates :billing_phone, presence: true
  validates :billing_state, presence: true
  validates :billing_zip, presence: true
  validates :delivery_address, presence: true
  validates :delivery_city, presence: true
  validates :delivery_fees, presence: true
  validates :delivery_id, presence: true
  validates :delivery_phone, presence: true
  validates :delivery_state, presence: true
  validates :delivery_status, presence: true
  validates :delivery_zip, presence: true
  validates :market_id, presence: true
  validates :order_number, presence: true
  validates :organization_id, presence: true
  validates :payment_method, presence: true
  validates :payment_status, presence: true
  validates :placed_at, presence: true
  validates :total_cost, presence: true

  def self.orders_for_user(user)
    if user.admin?
      all
    elsif user.market_manager?
      select('orders.*').
      joins("LEFT JOIN user_organizations ON user_organizations.organization_id = orders.organization_id
             LEFT JOIN managed_markets ON managed_markets.market_id = orders.market_id").
      where("user_organizations.user_id = :user_id OR managed_markets.user_id = :user_id", user_id: user.id)
    else
      select('orders.*').joins("INNER JOIN user_organizations ON user_organizations.organization_id = orders.organization_id").
        where('user_organizations.user_id = ?', user.id)
    end
  end
end
