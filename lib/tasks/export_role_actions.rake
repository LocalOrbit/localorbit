namespace :export_role_actions do
  desc "Prints RoleActons.all in a seeds.rb way."
  task :seeds_format => :environment do
    RoleAction.order(:id).all.each do |action|
      puts "RoleAction.create(#{action.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
    end
  end
end