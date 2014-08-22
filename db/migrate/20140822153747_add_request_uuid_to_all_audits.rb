class AddRequestUuidToAllAudits < ActiveRecord::Migration
  class Audit < ActiveRecord::Base
  end

  def up
    Audit.where(request_uuid: nil).find_each do |audit|
      audit.update_attribute :request_uuid, SecureRandom.uuid
    end
  end

  def down
    # nothing to do
  end
end
