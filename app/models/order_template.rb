class OrderTemplate < ActiveRecord::Base
  has_many :items, class_name: :OrderTemplateItem, inverse_of: :order_template
  belongs_to :market

  validates :market, :name, presence: true
end
