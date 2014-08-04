class Plan < ActiveRecord::Base
  has_many :markets, inverse_of: :plan

  def self.options_for_select
    order(:name).pluck(:name, :id)
  end
end
