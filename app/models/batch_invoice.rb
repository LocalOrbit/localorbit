class BatchInvoice < ActiveRecord::Base
  module GenerationStatus
    NotStarted = "not_started"
    Generating = "generating"
    Complete = "complete"
    Failed = "failed"
  end

  belongs_to :user
  has_and_belongs_to_many :orders
  has_many :batch_invoice_errors

  validates_presence_of :user

  dragonfly_accessor :pdf

  scope :for_user, (lambda do |user|
    if user.admin?
      all
    else
      where(user:user)
    end
  end)
end
