class PaymentMethod
  include ActiveModel::Model

  @@bank_account_params = :bank_name,
      :name,
      :last_four,
      :balanced_uri,
      :account_type,
      :expiration_month,
      :expiration_year,
      :notes

  @@representative_params = :name,
      :ein,
      :dob,
      :ssn_last4,
      :address

  attr_accessor *@@bank_account_params
  attr_accessor *@@representative_params

  validates :ein, :ssn_last_4, :last_4, numericality: {greater_than: 0, only_integer: true}

  def ein=(ein)
    @ein = ein.gsub(/[^\d]/, '')
  end

  def save
    if valid?
      true
    else
      false
    end
  end

  def persisted?
    false
  end
end

end