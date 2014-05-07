class RegistrationsController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :ensure_market_affiliation

  def show
    @registration = Registration.new(buyer: true)
  end

  def create
    @registration = Registration.new(registration_params)

    if !@registration.save
      flash.now[:alert] = "Unable to complete registration..."
      render :show
    end
  end

  protected

  def registration_params
    params.require(:registration).permit(
      :name,
      :contact_name,
      :contact_email,
      :password,
      :password_confirmation,
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
  end
end
