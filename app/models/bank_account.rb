class BankAccount < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :bankable
  include SoftDelete

  attr_accessor :save_for_future

  belongs_to :bankable, polymorphic: true

  validate :account_is_unique_to_bankable

  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }
  scope :debitable_bank_accounts, -> { visible.verified.where(account_type: %w(savings checking)) }
  scope :creditable_bank_accounts, -> { visible.where(account_type: %w(savings checking)) }
  scope :credit_cards, -> { visible.where.not(account_type: %w(savings checking)) }
  

  def balanced_verification
    return nil if verified? || balanced_verification_uri.nil?
    @balanced_verification ||= Balanced::Verification.find(balanced_verification_uri)
  rescue Balanced::NotFound # Probably bad account info
    nil
  end

  def bank_account?
    account_type == "checking" || account_type == "savings"
  end

  def credit_card?
    !bank_account?
  end

  def display_name
    if bank_account?
      "ACH: #{bank_name} - *********#{last_four}#{" NOT VERIFIED" unless verified?}"
    else
      "#{bank_name} ending in #{last_four}"
    end
  end

  def expired?
    return false if bank_account?
    now = Time.current
    expiration_year < now.year || (expiration_month < now.month && expiration_year == now.year)
  end

  # Checking or savings accounts must be verified to process a debit
  # but can be credited without being verified (not recommended)
  # Credit cards must be current and can only be used in debits
  def usable_for?(transaction_type=:debit)
    (bank_account? && (verified? || transaction_type == :credit)) || (credit_card? && !expired? && transaction_type == :debit)
  end

  def verification_failed?
    return false if verified?
    return true if balanced_verification.nil?
    balanced_verification.try(:state) == "failed"
  end

  def primary_payment_provider
    if bankable and bankable.respond_to?(:primary_payment_provider)
      bankable.primary_payment_provider
    else
      raise "Bankable #{bankable.inspect} doesn't respond to :primary_payment_provider"
    end
  end
  private

  def account_is_unique_to_bankable
    accounts = bankable.bank_accounts.visible.where(account_type: account_type, last_four: last_four, bank_name: bank_name, name: name)
    accounts = accounts.where.not(id: id) if persisted?

    errors.add(:bankable_id, "already exists for this #{bankable_type.downcase}.") if accounts.any?
  end
end
