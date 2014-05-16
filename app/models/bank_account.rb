class BankAccount < ActiveRecord::Base
  belongs_to :bankable, polymorphic: true

  validates :bankable_id, presence: true, uniqueness: { scope: [:account_type, :bank_name, :last_four]}
end
