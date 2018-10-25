class SendEmailConfirmationRequest
  include Interactor
  include DeadCode

  def perform
    dead_code!

    require_in_context :user

    user.send_confirmation_instructions if user
  end
end
