class Registration
  include ActiveModel::Model

  attr_accessor :market,
                :name,
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
                :seller,
                :user,
                :organization

  validates :market, :name, :contact_name, :contact_email, :password,
            :password_confirmation, :address_label, :address,
            :city, :state, :zip, presence: true

  def save
    if valid?
      organization = Organization.new(organization_params)
      organization.markets = [market]
      organization.locations.build(location_params)
      self.user = organization.users.build(user_params)
      organization.save

    else
      false
    end
  end

  def organization_params
    {
      name: name,
      allow_credit_cards: market.default_allow_credit_cards,
      allow_purchase_orders: market.default_allow_purchase_orders,
      allow_ach: market.default_allow_ach
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
