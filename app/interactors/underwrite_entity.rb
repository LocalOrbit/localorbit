class UnderwriteEntity
  include Interactor

  def setup
    context[:balanced_customer] ||= Balanced::Customer.find(entity.balanced_customer_uri)
    representative_params.delete_if {|_, v| v.blank? }
  end

  def perform
    unless entity.balanced_underwritten?
      update_balanced_customer_info

      entity.update_attribute(:balanced_underwritten, balanced_customer.is_identity_verified?)
    end
  end

  private

  def update_balanced_customer_info
    if representative_params
      balanced_customer.name = representative_params[:name]
      balanced_customer.ssn_last4 = representative_params[:ssn_last4]
      if representative_params[:dob].present?
        balanced_customer.dob = "#{representative_params[:dob][:year]}-#{representative_params[:dob][:month]}"
      end
      balanced_customer.address = representative_params[:address]

      if representative_params[:ein].present?
        balanced_customer.ein = representative_params[:ein].gsub(/[^\d]/, "")
        balanced_customer.business_name = entity.name
      end
    end
    context[:balanced_customer] = balanced_customer.save
  end
end
