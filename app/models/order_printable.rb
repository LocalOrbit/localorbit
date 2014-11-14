class OrderPrintable < ActiveRecord::Base
  belongs_to :user
  belongs_to :order

  dragonfly_accessor :pdf

  scope :for_user, -> (user) {
    if user.admin?
      all
    else
      where user: user
    end
  }
end
