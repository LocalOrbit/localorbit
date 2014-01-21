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
end
