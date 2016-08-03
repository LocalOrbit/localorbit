class Admin::QlikController < AdminController

  def index
    ticket = JSON.parse(Qlik::Authenticate.request_ticket(current_user, current_market).body)
    redirect_to "https://#{ENV['BI_SERVER']}/LO/Hub?qlikTicket=#{ticket['Ticket']}"
  end
end