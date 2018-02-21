class Users::SessionsController < Devise::SessionsController

  rescue_from ActionController::InvalidAuthenticityToken, with: :back_to_sign_in

  private

  def back_to_sign_in
    redirect_to new_user_session_path, notice: "Sorry, your browser's security token expired. Please sign in again."
  end

end
