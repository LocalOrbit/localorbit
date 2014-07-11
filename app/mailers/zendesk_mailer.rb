class ZendeskMailer < ActionMailer::Base
  default to: Figaro.env.zendesk_email

  def request_unit(user, new_unit_params)
    @user = user
    @unit_params = new_unit_params

    mail(
      from: user.pretty_email,
      subject: "A new unit has been requested"
    )
  end

  def request_category(user, category)
    @user = user
    @category = category

    mail(
      from: user.pretty_email,
      subject: "A new category has been requested"
    )
  end
end
