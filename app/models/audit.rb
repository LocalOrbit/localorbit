require 'audited/adapters/active_record/audit'

class Audited::Adapters::ActiveRecord::Audit < ActiveRecord::Base
  def self.decorator_class
    AuditDecorator
  end
end

# Alias constant for easier use
Audit = Audited::Adapters::ActiveRecord::Audit
