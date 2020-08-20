class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_market_affiliation
  skip_before_action :ensure_active_organization
  skip_before_action :ensure_user_not_suspended

  def index
  end

  def show
    @registration = Registration.new(buyer: true)
  end

  def create
    @registration = Registration.new(registration_params)

    success = verify_recaptcha(action: 'registration', minimum_score: 0.2, secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V3'))
    checkbox_success = verify_recaptcha(model: @registration) unless success

    if (success || checkbox_success) && @registration.save
      ActivateOrganization.perform(organization: @registration.organization, market: current_market)
      MarketMailer.delay.registration(current_market, @registration.organization)

      TermsOfService.accept(user:@registration.user,time:Time.now,ip_addr:request.remote_ip)

      redirect_to dashboard_path if @registration.user.confirmed?
    else
      if !success
        @show_checkbox_recaptcha = true
      end
      flash.now[:alert] = "Unable to complete registration..."
      render :show
    end
  end

  protected

  def registration_params
    results = params.require(:registration).permit(
      :name,
      :contact_name,
      :email,
      :password,
      :password_confirmation,
      :terms_of_service,
      :buyer,
      :seller,
      :address_label,
      :address,
      :city,
      :state,
      :zip,
      :phone,
      :fax,
      :buyer_org_type,
      :ownership_type,
      :non_profit,
      :professional_organizations,
    )
    results.merge!(market: current_market)
  end
end
