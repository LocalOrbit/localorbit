namespace :invalid do
  desc "report all invalid records in the system"
  task records: [:environment] do
    if !Rails.application.config.eager_load
      Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    end

    ActiveRecord::Base.subclasses.each do |model|
      next unless model.table_exists?

      model.find_each do |instance|
        begin
          if !instance.valid?
            puts "-----------------------------"
            puts "Invalid instance #{model}: #{instance.id}"
            puts ".........."
            puts instance.errors.inspect
            puts "-----------------------------"
          end
        rescue => e
          puts "-----------------------------"
          puts "Error validating #{model}: #{instance.id}"
          puts ".........."
          puts e.message
          puts "-----------------------------"
        end
      end
    end
  end
end
