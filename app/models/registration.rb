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
      self.organization = Organization.new(organization_params)
      self.organization.markets = [market]
      self.organization.locations.build(location_params)
      self.organization.save!

      # create the user second so we have the organization available
      # to the confirmation email
      self.user = User.new(user_params)
      self.user.organizations << organization
      self.user.save!
    else
      false
    end
  end

  def organization_params
    {
      name: name,
      can_sell: !!seller,
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
