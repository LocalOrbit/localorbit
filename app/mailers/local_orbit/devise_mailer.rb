module LocalOrbit
  class DeviseMailer < Devise::Mailer
    include DeadCode

    def reset_import_password_instructions(user, token, opts={})
      dead_code!

      @token = token

      _set_reply_to(user, opts)

      devise_mail(user, :reset_import_password_instructions, opts)
    end

    def reset_password_instructions(user, token, opts={})
      @token = token

      _set_reply_to(user, opts)

      devise_mail(user, :reset_password_instructions, opts)
    end

    def invitation_instructions(user, token, opts = {})
      @token = token

      if organization = user.organizations.first
        @org_or_market_name = organization.name
        @market = organization.original_market
      elsif @market = user.default_market
        @org_or_market_name = @market.name
      else
        @org_or_market_name = "Local Orbit"
      end

      devise_mail(user, :invitation_instructions,
                  opts.merge(
                      reply_to: @market.try(:contact_email),
                      subject: I18n.t("devise.mailer.invitation_instructions.subject", org_or_market_name: @org_or_market_name)))
    end

    def confirmation_instructions(user, token, opts={})
      _set_reply_to(user, opts)
      super
    end

    private

    def _set_reply_to(user, opts)
      if organization = user.organizations.first
        market = organization.original_market
        opts[:reply_to] = market.try(:contact_email)
      end
    end
  end
end
