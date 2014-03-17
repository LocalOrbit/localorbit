class UserMailer < ActionMailer::Base
  layout "email"
  default from: "service@localorb.it"

  def organization_invitation(user, organization, inviter, market)
    @user = user
    @organization = organization
    @inviter = inviter
    @market = market

    mail(
      to: @user.email,
      subject: "You have been added to an organization"
    )
  end

end
