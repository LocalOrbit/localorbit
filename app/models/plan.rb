class Plan < ActiveRecord::Base
  audited allow_mass_assignment: true
  has_many :markets, inverse_of: :plan

  def self.options_for_select
    order(:name).pluck(:name, :id)
  end
end
