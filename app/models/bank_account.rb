class BankAccount < ActiveRecord::Base
  belongs_to :bankable, polymorphic: true
end
