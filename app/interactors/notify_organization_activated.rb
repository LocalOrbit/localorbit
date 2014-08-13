class NotifyOrganizationActivated
  include Interactor

  def perform
    return if !organization.active? # Org was flipped to inactive
    return if organization.users.empty? # Nobody to notify
    return unless organization.needs_activated_notification? # It's the first time, send the notification

    organization.update_attributes(needs_activated_notification: false)
    UserMailer.delay.organization_activated(organization, market)
  end
end
