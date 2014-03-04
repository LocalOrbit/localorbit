module SoftDelete
  extend ActiveSupport::Concern

  included do
    scope :visible, lambda { where('deleted_at IS NULL OR deleted_at > ?', Time.current) }
  end

  module ClassMethods
    def soft_delete(id)
      find(id).update_attribute(:deleted_at, Time.current)
    end
  end
end
