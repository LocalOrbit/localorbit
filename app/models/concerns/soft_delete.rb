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
      time = Time.current
      records = where(id: ids)

      unless records.empty?
        records.update_all(deleted_at: time)
      end

      records
    end
  end
end
