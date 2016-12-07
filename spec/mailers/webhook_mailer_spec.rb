require "spec_helper"

describe WebhookMailer do
  let(:subscriber) { create(:market) }

  describe "event failed" do
    h = { 
      id: "evt_19No6q2VpjOYk6Tmhou8HN7A", 
      data: {
        object: {
          id: "in_19No6p2VpjOYk6TmrOCmZzL2",
          charge: "ch_19No6p2VpjOYk6TmwCZ6FHzb",
          customer: "cus_9hCVFBPgpw7DTe",
          payment: "ch_19No6p2VpjOYk6TmwCZ6FHzb"
        }
      }, 
      livemode: false, 
      type: "invoice.payment_succeeded" 
    }

    event = Stripe::Event.construct_from(h)
    exception = Exception.new

    it "sends an 'event failed' email upon event failure" do
      email = WebhookMailer.failed_event(exception, event)
      binding.pry

      expect(email.body).to include(event.id)
    end

  end

  describe "successfully processed successful payment" do
    h = { 
      id: "evt_19No6q2VpjOYk6Tmhou8HN7A", 
      data: {
        object: {
          id: "in_19No6p2VpjOYk6TmrOCmZzL2",
          charge: "ch_19No6p2VpjOYk6TmwCZ6FHzb",
          customer: "cus_9hCVFBPgpw7DTe",
          payment: "ch_19No6p2VpjOYk6TmwCZ6FHzb"
        }
      }, 
      livemode: false, 
      type: "invoice.payment_succeeded" 
    }

    event = Stripe::Event.construct_from(h)

    it "sends a 'successful payment' email" do
      email = WebhookMailer.successful_payment(subscriber, event.data.object)

      expect(email.body).to include("successful invoice payment")
      expect(email.body).to include(subscriber.name)
    end
  end

  describe "successfully processed failed payment" do
    h = { 
      id: "evt_19No6q2VpjOYk6Tmhou8HN7A", 
      data: {
        object: {
          id: "in_19No6p2VpjOYk6TmrOCmZzL2",
          charge: "ch_19No6p2VpjOYk6TmwCZ6FHzb",
          customer: "cus_9hCVFBPgpw7DTe",
          payment: "ch_19No6p2VpjOYk6TmwCZ6FHzb"
        }
      }, 
      livemode: false, 
      type: "invoice.payment_failed" 
    }

    event = Stripe::Event.construct_from(h)

    it "sends a 'successful payment' email" do
      email = WebhookMailer.failed_payment(subscriber, event.data.object)

      expect(email.body).to include("failed invoice payment")
      expect(email.body).to include(subscriber.name)
    end
  end
end
