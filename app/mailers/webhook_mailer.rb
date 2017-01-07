class WebhookMailer < ActionMailer::Base
  default to: [
    Figaro.env.zendesk_email
  ]

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

  def failed_event(exception, event)
    @event     = event
    @exception = exception
    mail(
      from: Figaro.env.zendesk_email,
      subject: "Failed webhook event: #{@event.type}"
    )
  end
end
