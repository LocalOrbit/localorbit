module SoftDelete
  extend ActiveSupport::Concern

  included do
    scope :visible, -> { where("deleted_at IS NULL OR deleted_at > ?", Time.current) }
  end

  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  module ClassMethods
    def soft_delete(*ids)
      records = where(id: ids)
      records.update_all(deleted_at: Time.current) if records.any?

      records
    end
  end
end
