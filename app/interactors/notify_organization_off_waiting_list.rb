class NotifyOrganizationOffWaitingList
  include Interactor
  include Users

  def perform
    return if organization.on_waiting_list?
    return if organization.users.empty?

    market = organization.markets.last
    UserMailer.delay.organization_off_waiting_list(organization, market)
  end
end
