class GeneralProduct < ActiveRecord::Base
  has_many :product
  belongs_to :organization, inverse_of: :general_products
end
