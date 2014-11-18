class PackingLabelsPrintable < ActiveRecord::Base
  belongs_to :user
  belongs_to :delivery

  dragonfly_accessor :pdf

  scope :for_user, -> (user) {
    if user.admin?
      all
    else
      where user: user
    end
  }
end
