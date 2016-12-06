class WebhookMailer < ActionMailer::Base
  # default to: Figaro.env.zendesk_email
  default to: "keith@localorb.it"

  def failed_payment(subscriber, event_params)
    @subscriber = subscriber
    @event_params = event_params

    mail(
      from: Figaro.env.zendesk_email,
      subject: "Failed payment: #{@subscriber.name}"
    )
  end

  def successful_payment(subscriber, event_params)
    @subscriber = subscriber
    @event_params = event_params

    mail(
      from: Figaro.env.zendesk_email,
      subject: "Successful payment: #{@subscriber.name}"
    )
  end

  def failed_event(params)
    @event = params[:event]
    mail(
      from: Figaro.env.zendesk_email,
      subject: "Failed webhook event: #{@event.type}"
    )
end
