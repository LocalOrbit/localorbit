class AddMasqueradeToAudits < ActiveRecord::Migration
  def change
    add_column :audits, :masquerader_id, :integer
    add_column :audits, :masquerader_username, :string
    add_index :audits, :masquerader_id
  end
end
