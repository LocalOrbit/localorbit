class RoleAction < ActiveRecord::Base

  scope :published, -> { where(published: true) }

end