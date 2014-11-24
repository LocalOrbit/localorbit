class BaseMailer < ActionMailer::Base
  layout "email"
  default(
    from: proc { default_from },
    reply_to: proc { default_reply_to },
  )

  private

  def default_from
    if @market
      "#{@market.name.inspect} <service@localorbit.com>"
    else
      "Local Orbit <service@localorbit.com>"
    end
  end

  def default_reply_to
    if @market
      "#{@market.contact_name.inspect} <#{@market.contact_email}>"
    else
      nil
    end
  end
end
