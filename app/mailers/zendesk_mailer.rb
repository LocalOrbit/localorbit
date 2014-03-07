class ZendeskMailer < ActionMailer::Base
  default to: Figaro.env.zendesk_email

  def request_unit(user_email, user_name, new_unit_params)
    @user_name = user_name
    @unit_params = new_unit_params

    mail(
      from: user_email,
      subject: "A new unit has been requested"
    )
  end

  def request_category(user_email, user_name, category)
    @user_name = user_name
    @category = category

    mail(
      from: user_email,
      subject: "A new category has been requested"
    )
  end
end
