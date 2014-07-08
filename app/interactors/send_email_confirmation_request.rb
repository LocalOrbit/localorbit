class SendEmailConfirmationRequest
  include Interactor

  def perform
    user.send_confirmation_instructions if user
  end
end
