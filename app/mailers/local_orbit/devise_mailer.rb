module LocalOrbit
  class DeviseMailer < Devise::Mailer
    def reset_import_password_instructions(user, token, opts={})
      @token = token
      devise_mail(user, :reset_import_password_instructions, opts)
    end
  end
end
