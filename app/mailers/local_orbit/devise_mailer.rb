module LocalOrbit
  class DeviseMailer < Devise::Mailer
    def reset_import_password_instructions(user, token, opts={})
      @token = token

      if organization = user.organizations.first
        market = organization.original_market
        opts[:reply_to] = market.try(:contact_email)
      end

      devise_mail(user, :reset_import_password_instructions, opts)
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
      if organization = user.organizations.first
        market = organization.original_market
        opts[:reply_to] = market.try(:contact_email)
      end

      super
    end
  end
end
