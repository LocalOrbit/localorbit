class WebhookMailer < ActionMailer::Base
  default to: [
    ENV.fetch('ADMIN_EMAIL')
  ]

  def failed_payment(subscriber, event_params)
    @subscriber = subscriber
    @event_params = event_params

    mail(
      from: ENV.fetch('ADMIN_EMAIL'),
      subject: "Failed payment: #{@subscriber.name}"
    )
  end

  def successful_payment(subscriber, event_params)
    @subscriber = subscriber
    @event_params = event_params

    mail(
      from: ENV.fetch('ADMIN_EMAIL'),
      subject: "Successful payment: #{@subscriber.name}"
    )
  end

  def failed_event(exception, event)
    @event     = event
    @exception = exception
    mail(
      from: ENV.fetch('ADMIN_EMAIL'),
      subject: "Failed webhook event: #{@event.type}"
    )
  end
end
