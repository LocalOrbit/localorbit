module SoftDelete
  extend ActiveSupport::Concern

  included do
    scope :visible, -> { where(visible_conditional) }
  end

  def soft_delete
    update_attribute(:deleted_at, Time.current)
    send(:after_soft_delete) if respond_to?(:after_soft_delete)
  end

  def soft_delete_all
    update_all(deleted_at: Time.current)
    all.each {|record| record.send(:after_soft_delete) if record.respond_to?(:after_soft_delete) }
  end

  module ClassMethods
    def soft_delete(*ids)
      records = ids.empty? ? all : where(id: ids)
      records.update_all(deleted_at: Time.current) if records.any?
      records.reload.each {|record| record.send(:after_soft_delete) if record.respond_to?(:after_soft_delete) }
      records
    end

    def soft_delete_all
      update_all(deleted_at: Time.current)
      all.each {|record| record.send(:after_soft_delete) if record.respond_to?(:after_soft_delete) }
    end

    def visible_conditional
      arel_table[:deleted_at].eq(nil).or(arel_table[:deleted_at].gt(Time.current))
    end
  end
end
