class UnderwriteOrganization
  include Interactor

  def setup
    context[:balanced_customer] ||= Balanced::Customer.find(organization.balanced_customer_uri)
  end

  def perform
    update_balanced_customer_info

    organization.update_attribute(:balanced_underwritten, balanced_customer.is_identity_verified?)
  end

  private

  def update_balanced_customer_info
    balanced_customer.name = representative_params[:name]
    balanced_customer.ssn_last4 = representative_params[:ssn_last4]
    balanced_customer.dob = "#{representative_params[:dob][:year]}-#{representative_params[:dob][:month]}"
    balanced_customer.address = representative_params[:address]

    if representative_params[:ein].present?
      balanced_customer.ein = representative_params[:ein]
      balanced_customer.business_name = organization.name
    end

    context[:balanced_customer] = balanced_customer.save
  end
end
