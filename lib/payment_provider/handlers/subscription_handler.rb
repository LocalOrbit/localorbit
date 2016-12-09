module PaymentProvider
  module Handlers
    class SubscriptionHandler < AbstractMasterHandler

      def self.customer_subscription_created(event_params)
        # There isn't a subscription model in LO, the subscription itself ultimately consisting 
        # of a constellation of market, organization, and plan data.  Implementing a subscription 
        # entity would entail:
        #   - Creating the appropriate model and thin controller (including a stripe id reference)
        #   - Joining all Organizations to their respect plans through the subscription entity
        #   - Updating the associations of both plans and organizations to go through the subscription join entity
        #   - Updating the fees page to leverage the submitted data through the new relation

        # The handler, then, will confirm the subscriber and plan and insert the subscription object accordingly

        # raise "Missing subscriber" unless subscriber = Organization.where(stripe_id: event_params[:customer])
        # raise "Missing plan" unless plan = Plan.where(stripe_id: event_params[:plan][:id]) 

        # return if Subscription.where(organization_id: subscribe, plan_id: plan, stripe_id: event_params[:id]).any?

        # Subscription.create(organization_id: subscribe, plan_id: plan, stripe_id: event_params[:id])
      end

    end
  end
end
