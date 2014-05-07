class Registration
  include ActiveModel::Model

  attr_accessor :name,
                :contact_name,
                :contact_email,
                :password,
                :password_confirmation,
                :address_label,
                :address,
                :city,
                :state,
                :zip,
                :phone,
                :fax,
                :buyer,
                :seller

  validates :name, :contact_name, :contact_email, :password,
            :password_confirmation, :address_label, :address,
            :city, :state, :zip, presence: true

  def save
    if valid?
      organization = Organization.new(organization_params)
      organization.locations.build(location_params)
      organization.users.build(user_params)
      organization.save
    else
      false
    end
  end

  def organization_params
    {
      name: name
    }
  end

  def user_params
    {
      name: contact_name,
      email: contact_email,
      password: password,
      password_confirmation: password_confirmation
    }
  end

  def location_params
    {
      name: address_label,
      address: address,
      city: city,
      state: state,
      zip: zip,
      phone: phone,
      fax: fax
    }
  end
end
