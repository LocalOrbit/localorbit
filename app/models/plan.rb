class Plan < ActiveRecord::Base
  audited allow_mass_assignment: true
  has_many :organizations, inverse_of: :plan

  def self.options_for_select
    order(:name).pluck(:name, :id)
  end

  def self.ryo_enabled_plans
    where(ryo_eligible: true).where.not(stripe_id: nil).order(:name).pluck(:stripe_id)
  end
end
