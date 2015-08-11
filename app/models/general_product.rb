class GeneralProduct < ActiveRecord::Base
  has_many :product, inverse_of: :general_product
end