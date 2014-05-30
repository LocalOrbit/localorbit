class UnderwriteEntity
  include Interactor

  def perform
    representative_params.delete_if {|k, v| v.blank? }
    if !entity.balanced_underwritten? && representative_params.any?
      context[:balanced_customer] ||= Balanced::Customer.find(entity.balanced_customer_uri)

      balanced_customer.name      = representative_params[:name]
      balanced_customer.ssn_last4 = representative_params[:ssn_last4]
      balanced_customer.address   = representative_params[:address]

      if representative_params[:dob].present?
        balanced_customer.dob = "#{representative_params[:dob][:year]}-#{'%02d' % representative_params[:dob][:month].to_i}"
      end

      if representative_params[:ein].present?
        balanced_customer.ein = representative_params[:ein].gsub(/[^\d]/, "")
        balanced_customer.business_name = entity.name
      end

      context[:balanced_customer] = balanced_customer.save

      entity.update_attribute(:balanced_underwritten, balanced_customer.is_identity_verified?)
    end
  end
end
