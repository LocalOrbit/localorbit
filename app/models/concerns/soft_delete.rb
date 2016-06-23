module SoftDelete
  extend ActiveSupport::Concern

  included do
    scope :visible, -> { where(visible_conditional) }
    scope :delivery_visible, -> { where(delivery_visible_conditional) }
    scope :delivery_not_deleted, -> { where('deleted_at is null') }
  end

  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def undelete
    update_attribute(:deleted_at, nil)
  end

  module ClassMethods
    def soft_delete(*ids)
      records = ids.empty? ? all : where(id: ids)
      records.update_all(deleted_at: Time.current) if records.any?
      records
    end

    def soft_delete_all
      update_all(deleted_at: Time.current)
    end

    def visible_conditional
      arel_table[:deleted_at].eq(nil).or(arel_table[:deleted_at].gt(Time.current.end_of_minute))
    end

    def delivery_visible_conditional
      (arel_table[:deleted_at].eq(nil).or(arel_table[:deleted_at].gt(Time.current.end_of_minute))).and(arel_table[:inactive_at].eq(nil).or(arel_table[:inactive_at].gt(Time.current.end_of_minute)))
    end
  end
end
