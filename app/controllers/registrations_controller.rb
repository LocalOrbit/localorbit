class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_market_affiliation
  skip_before_action :ensure_active_organization

  def show
    @registration = Registration.new(buyer: true)
  end

  def create
    @registration = Registration.new(registration_params)

    if @registration.save
      MarketMailer.delay.registration(current_market, @registration.organization)
      redirect_to dashboard_path if @registration.user.confirmed?
    else
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
      :fax
    )
    results.merge!(market: current_market)
  end
end
