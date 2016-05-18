class Registration
  include ActiveModel::Model

  attr_accessor :market,
                :name,
                :contact_name,
                :email,
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
                :organization,
                :terms_of_service,
                :buyer_org_type,
                :ownership_type,
                :non_profit,
                :professional_organizations

  validates :market, :name, :contact_name, :address,
            :city, :state, :zip, presence: true

  validates :terms_of_service, acceptance: true

  BUYER_ORG_TYPES = ["Individual", "Restaurant", "K-12 Foodservice", "University Foodservice", "Healthcare Foodservice", "Hotel Foodservice", "Grocery", "Meal Delivery Service", "Corporate Dining"]
  OWNERSHIP_TYPES = ["Women Owned","Minority Owned","Women and Minority Owned"]

  def save
    if valid?
      self.organization = Organization.new(organization_params)
      organization.markets = [market]
      organization.locations.build(location_params)
      organization.save!

      # create the user second so we have the organization available
      # to the confirmation email
      self.user = User.find_by(email: email) || User.new(user_params)
      user.organizations << organization
      user.attempt_set_password(user_params)
      user.invitation_token=nil
      user.save!
    else
      false
    end
  end

  def organization_params
    {
      name: name,
      can_sell: (seller == "1"),
      allow_credit_cards: market.default_allow_credit_cards,
      allow_purchase_orders: market.default_allow_purchase_orders,
      allow_ach: market.default_allow_ach,
      buyer_org_type: buyer_org_type,
      ownership_type: ownership_type,
      non_profit: non_profit,
      professional_organizations: professional_organizations
    }
  end

  def user_params
    {
      name: contact_name,
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      terms_of_service: terms_of_service
    }
  end

  def location_params
    {
      name: address_label || "Default Address", # if nil, Default Address
      address: address,
      city: city,
      state: state,
      zip: zip,
      phone: phone,
      fax: fax
    }
  end

  # Stub methods for Devise::Model::Validatable
  def self.validates_uniqueness_of(*_args)
    true
  end

  def email_changed?
    true
  end

  include Devise::Models::Validatable
end
