class ConsignmentPrintable < ActiveRecord::Base
  belongs_to :user

  dragonfly_accessor :pdf

  scope :for_user, -> (user) {
    if user.admin?
      all
    else
      where user: user
    end
  }
end
