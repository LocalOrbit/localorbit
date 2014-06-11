class Plan < ActiveRecord::Base
  has_many :markets, inverse_of: :plan
end
