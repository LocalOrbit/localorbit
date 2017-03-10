require "csv"

# Import the units from a csv export
# of the legacy units
class ImportRoleActions
  def self.run(filename, opts={})
    new(filename, opts).run
  end

  def initialize(filename, opts={})
    @filename       = filename
    @role_actions   = []
  end

  def run
    load_csv
    store(@role_actions)
  end

  def load_csv
    CSV.foreach(@filename, headers: true) do |role_action|
      @role_actions << role_action
    end
  end

  def store(role_actions)
    role_actions.each do |role_action|
      RoleAction.create(role_action.to_hash)
    end
  end
end
