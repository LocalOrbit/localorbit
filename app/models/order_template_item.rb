class OrderTemplateItem < ActiveRecord::Base
  belongs_to :order_template
  belongs_to :product

  validates :order_template, :product, :quantity, presence: true
end
