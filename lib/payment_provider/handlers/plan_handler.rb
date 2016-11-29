module PaymentProvider
  module Handlers
    class PlanHandler

      def self.extract_job_params(event)
        {
          event_type: event.type.tr('.','_'),
          name:       event.data.object.name,
          created:    event.data.object.created,
          stripe_id:  event.data.object.id
        }
      end

      def self.handle(params)
        self.public_send(params[:event_type], params[:name], params[:created], params[:stripe_id])

      rescue Exception => e
        error_info = ErrorReporting.interpret_exception(e, "Error handling #{self.name} event from Stripe", {params: params})
        Honeybadger.notify_or_ignore(error_info[:honeybadger_exception])
      end
      
      def self.plan_created(name, created, stripe_id)
        plan = Plan.where(stripe_id: stripe_id)
        if plan.empty?
          Plan.create!(name: name, stripe_id: stripe_id, created_at: created, ryo_eligible: false)
          Rails.logger.info "In plan_created method. New plan details: Name: #{name}, Created: #{created}, Stripe ID: #{stripe_id}"
        end
      end

      def self.plan_deleted(name, created, stripe_id)
        # Stubbed here for full-circle plan managment.  This is for future reference
        Rails.logger.info "In plan_deleted method: Name: #{name}, Created: #{created}, Stripe ID: #{stripe_id}"
      end

    end
  end
end
