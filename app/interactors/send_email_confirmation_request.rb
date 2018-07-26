class SendEmailConfirmationRequest
  include Interactor

  def perform
    dead_code!

    require_in_context :user

    user.send_confirmation_instructions if user
  end
end
