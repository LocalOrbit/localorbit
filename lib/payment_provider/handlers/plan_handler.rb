module PaymentProvider
  module Handlers
    class PlanHandler < AbstractMasterHandler

      def self.plan_created(event_params)
        return if Plan.where(stripe_id: event_params[:id]).any?

        Plan.create(name: event_params[:name], stripe_id: event_params[:id], created_at: event_params[:created], ryo_eligible: false)
      end

      def self.plan_deleted(name, created, stripe_id)
        # Stubbed here for full-circle plan managment.  This is for future reference
      end

    end
  end
end
