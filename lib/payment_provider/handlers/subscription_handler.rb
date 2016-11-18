module PaymentProvider
  module Handlers
    class SubscriptionHandler
    # KXM Inheritance?  Where should the class reside?

      def self.extract_job_params(event)
        {
          # event_type: event.type.tr('.','_'),
          # name:       event.data.object.name,
          # created:    event.data.object.created,
          # stripe_id:  event.data.object.id
        }
      end

      def self.handle(params)
        # KXM THis is the structure of the call, with params[:event_type] as the first parameter, the 'sub' parameters falling in line behind - the sub paramters remain to be defined...
        # self.public_send(params[:event_type], params[:name], params[:created], params[:stripe_id])

        Rails.logger.info "Handling a customer subscription event. Params: #{params.inspect}"

      rescue Exception => e
        error_info = ErrorReporting.interpret_exception(e, "Error handling #{self.name} event from Stripe", {params: params})
        Honeybadger.notify_or_ignore(error_info[:honeybadger_exception])
      end

      def self.customer_subscription_created(params)
        # KXM Create a subscription event entry... the rest of the creation should happen once the payment succeeds

        # KXM The event will be structurally similar to plan.create...
        # plan = Plan.where(stripe_id: stripe_id)
        # if plan.empty?
        #   Plan.create!(name: name, stripe_id: stripe_id, created_at: created, ryo_eligible: false)
        #   Rails.logger.info "In plan_created method. New plan details: Name: #{name}, Created: #{created}, Stripe ID: #{stripe_id}"
        # end
      end

    end
  end
end
