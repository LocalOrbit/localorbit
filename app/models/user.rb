class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :managed_markets_join, class_name: 'ManagedMarket'
  has_many :managed_markets, through: :managed_markets_join, source: :market

  has_many :user_organizations
  has_many :organizations, through: :user_organizations

  def admin?
    role == 'admin'
  end

  def market_manager?
    managed_markets.any?
  end

  def managed_organizations
    if admin?
      Organization.all
    elsif market_manager?
      Organization.
        joins("LEFT JOIN user_organizations ON user_organizations.organization_id = organizations.id
               LEFT JOIN market_organizations ON market_organizations.organization_id = organizations.id").
        where(["user_organizations.user_id = ? OR market_organizations.market_id IN (?)", id, managed_markets_join.map(&:market_id)]).uniq
    else
      organizations
    end
  end
end
