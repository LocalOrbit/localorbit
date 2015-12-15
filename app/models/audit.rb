require "audited/adapters/active_record/audit"

class Audited::Adapters::ActiveRecord::Audit < ActiveRecord::Base
  include PgSearch

  belongs_to :masquerader, class_name: "User"

  scope_accessible :search, method: :for_search, ignore_blank: true

  pg_search_scope :search_by_name, against: :name, using: {tsearch: {prefix: true}}

  def self.for_search(query)
    search_by_name(query)
  end

  def self.decorator_class
    AuditDecorator
  end
end

# Alias constant for easier use
Audit = Audited::Adapters::ActiveRecord::Audit
