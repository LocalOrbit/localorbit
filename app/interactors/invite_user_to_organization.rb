class InviteUserToOrganization
  include Interactor

  def perform
    if context[:user] = User.find_for_authentication(email: email)
      add_to_organization_and_notify
    else
      create_user_and_send_app_invitation
    end
  end

  def add_to_organization_and_notify
    if !user.organizations.include? organization
      user.organizations << organization
      UserMailer.delay.organization_invitation(user, organization, inviter, market)
    elsif user.accepted_or_not_invited?
      fail!(message: "You have already added this user")
    else
      # User may be trying to resend an invitation
      user.deliver_invitation
    end
  end

  def create_user_and_send_app_invitation
    context[:user] = User.invite!({email: email}, inviter) do |u|
      u.skip_invitation = true
    end

    if user.persisted?
      user.organizations << organization
      user.deliver_invitation
    else
      fail!(message: user.errors.full_messages.join("\n"))
    end
  end
end
