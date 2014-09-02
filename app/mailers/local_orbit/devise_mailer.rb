module LocalOrbit
  class DeviseMailer < Devise::Mailer
    def reset_import_password_instructions(user, token, opts={})
      @token = token
      devise_mail(user, :reset_import_password_instructions, opts)
    end

    def invitation_instructions(record, token, opts = {})
      @token = token

      if organization = record.organizations.first
        @org_or_market_name = organization.name
        @market = organization.original_market
      elsif @market = record.primary_market
        @org_or_market_name = @market.name
      else
        @org_or_market_name = "Local Orbit"
      end

      devise_mail(record, :invitation_instructions,
                  opts.merge(
                      reply_to: @market.try(:contact_email),
                      subject: I18n.t("devise.mailer.invitation_instructions.subject", org_or_market_name: @org_or_market_name)))
    end
  end
end
