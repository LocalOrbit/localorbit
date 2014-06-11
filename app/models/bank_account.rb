class BankAccount < ActiveRecord::Base
  include SoftDelete

  attr_accessor :save_for_future

  belongs_to :bankable, polymorphic: true

  validates :bankable_id, presence: true, uniqueness: { scope: [:account_type, :bank_name, :last_four]}
end
