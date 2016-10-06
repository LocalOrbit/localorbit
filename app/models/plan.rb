class Plan < ActiveRecord::Base
  audited allow_mass_assignment: true
  has_many :organizations, inverse_of: :plan

  def self.options_for_select
    order(:name).pluck(:name, :id)
  end

  def self.ryo_enabled_plans
    # KXM ryo_enabled_plans will leverage the to-be-created boolean: plans.ryo_option
    # where(cross_selling: true).order(:name).pluck(:id)
    where(cross_selling: true).order(:name).pluck(:stripe_id)
  end
end
