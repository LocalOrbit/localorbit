class MakeAuditCommentTextType < ActiveRecord::Migration
  def change
  	change_column :audits, :comment, :text
  end
end
