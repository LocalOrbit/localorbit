class NotifyOrganizationActivated
  include Interactor
  include Users

  def perform
    return if !organization.active? # Org was flipped to inactive
    return if organization.users.empty? # Nobody to notify
    return unless organization.needs_activated_notification? # It's the first time, send the notification

    organization.update_attributes(needs_activated_notification: false)

    # Force confirm users upon initial activation
    organization.users.each do |u|
      confirm_user(u)
    end
    market = organization.markets.last
    UserMailer.delay.organization_activated(organization, market)
  end
end
