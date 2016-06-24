class CategoryFee < ActiveRecord::Base
  belongs_to :category
  belongs_to :market

  validates :fee_pct, presence: true
  attr_accessor :_destroy

end