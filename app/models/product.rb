class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :organization
  has_many :lots

  validates :name, presence: true
  validates :category_id, presence: true
  validates :organization_id, presence: true
end
