module LocalOrbit
  class DeviseMailer < Devise::Mailer

    def reset_password_instructions(user, token, opts={})
      @market = user.primary_market if user.primary_market.present?
      super
    end
  end
end
