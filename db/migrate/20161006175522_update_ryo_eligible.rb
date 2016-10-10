class UpdateRyoEligible < ActiveRecord::Migration
  def change
    Plan.where(:stripe_id => ['START', 'GROW']).each do |p|
      p.update_attribute :ryo_eligible, true
    end
  end
end
