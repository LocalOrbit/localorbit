module PaymentProvider
  module Handlers
    class PlanHandler < AbstractMasterHandler

      def self.plan_created(event_params)
        event_name = event_params[:name]
        created    = event_params[:created]
        stripe_id  = event_params[:id]

        plan = Plan.where(stripe_id: stripe_id)
        if plan.empty?
          Plan.create(name: event_name, stripe_id: stripe_id, created_at: created, ryo_eligible: false)
        end
      end

      def self.plan_deleted(name, created, stripe_id)
        # Stubbed here for full-circle plan managment.  This is for future reference
      end

    end
  end
end
