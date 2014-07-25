class UnderwriteEntity
  include Interactor

  def setup
    representative_params.delete_if {|_, v| v.blank? }
  end

  def perform
    return unless can_update_underwriting?
    context[:balanced_customer] ||= Balanced::Customer.find(entity.balanced_customer_uri)

    balanced_customer.name      = representative_params[:name]
    balanced_customer.ssn_last4 = representative_params[:ssn_last4]
    balanced_customer.address   = representative_params[:address]

    set_date_of_birth(representative_params[:dob])
    set_business_fields(representative_params[:ein])

    context[:balanced_customer] = balanced_customer.save

    entity.update_attribute(:balanced_underwritten, balanced_customer.is_identity_verified?)
  end

  private

  def can_update_underwriting?
    !entity.balanced_underwritten? && representative_params.any?
  end

  def set_date_of_birth(date_params)
    if date_params.present?
      balanced_customer.dob = "#{date_params[:year]}-#{"%02d" % date_params[:month].to_i}"
    end
  end

  def set_business_fields(ein)
    if ein.present?
      balanced_customer.ein = ein.gsub(/[^\d]/, "")
      balanced_customer.business_name = entity.name
    end
  end
end
