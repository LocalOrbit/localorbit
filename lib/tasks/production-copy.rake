namespace :production_copy do
  desc "Copy all production data and S3 assets to a target env."
  task :to, [:env] => :environment do |_,args|
    args[:env] || raise("Supply environment, eg: rake production_copy:to[demo]")
    include CloneProductionHelper
    @config_name = args[:env].to_sym

    copy_production_to_local
    connect_production_copy
    cleanse_production_copy

    restore_cleansed_dump_to_target
    replicate_s3_bucket
  end

  desc "Get and cleanse a local copy of production"
  task bring_down: :environment  do
    include CloneProductionHelper
    copy_production_to_local
    connect_production_copy
    cleanse_production_copy
  end

  desc "Get a local copy of production (no cleansing)"
  task fetch_db: :environment do
    include CloneProductionHelper
    copy_production_to_local
  end

  desc "Push local prod copy out to a target environment, and sync its S3 bucket from production's S3 bucket"
  task :push_out, [:env] do |_, args|
    args[:env] || raise("Supply environment, eg: rake production_copy:push_out[demo]")
    include CloneProductionHelper
    @config_name = args[:env].to_sym
    restore_cleansed_dump_to_target
    replicate_s3_bucket unless (ENV["BUCKET"] =~ /^(n|off|false|skip)/i)
  end

  desc "Clone the production database to local Postgresql db 'localorbit-production-copy'"
  task :get do
    include CloneProductionHelper
    copy_production_to_local
  end

  desc "Clean up refs and user email and passwords"
  task cleanse: :environment do
    include CloneProductionHelper
    connect_production_copy
    cleanse_production_copy
  end

  desc "Copy the production S3 bucket to a target env"
  task :bucket, [:env] do |_, args|
    include CloneProductionHelper
    @config_name = args[:env].to_sym
    replicate_s3_bucket
  end

  desc "Put the cleansed prod copy data into the target database"
  task :put do
    include CloneProductionHelper
    restore_cleansed_dump_to_target
  end

  desc "Copy prod database over top of your local dev database"
  task stomp_dev_db: :environment do
    if ENV["REALLY"] != "YES"
      puts "THIS COMMAND REPLACES YOUR LOCAL DEV DB"
      puts "If you're certain, retype your command like this:"
      puts
      puts ">>  rake production_copy:stomp_dev_db REALLY=YES"
      puts
      puts "Aborting."
      exit 1
    end

    include CloneProductionHelper
    if ENV['DOWNLOAD_NEW'] == 'YES'
      puts "Backup and cleanse the prod db..."
      copy_production_to_local
      connect_production_copy
      cleanse_production_copy
    else
      puts "Not downloading a prod backup, assuming that's already been done, if not, retry with DOWNLOAD_NEW=YES"
    end
    stomp_local_dev_with_cleansed_prod_copy
  end

  desc "Copy prod S3 bucket assets to local dev environment"
  task stomp_dev_uploads: :environment do
    if ENV["REALLY"] != "YES"
      puts "THIS COMMAND REPLACES YOUR LOCAL DEV UPLOAD ASSETS"
      puts "If you're certain, retype your command like this:"
      puts
      puts ">>  rake production_copy:stomp_dev_uploads REALLY=YES"
      puts
      puts "Aborting."
      exit 1
    end
    include CloneProductionHelper
    sync_prod_uploads_to_local_dev
  end

  desc "Run a console connected to 'localorbit-production-copy'"
  task console: :environment do
    include CloneProductionHelper
    console
  end
end

#
# HELPERS:
#

module CloneProductionHelper
  def configs
    {
      staging: {
        app: "localorbit-staging",
        env: "staging",
        bucket: "localorbit-uploads-staging",
        database: "HEROKU_POSTGRESQL_COBALT"
      },
      # alpha: {
      #   app: "localorbit-alpha",
      #   env: "alpha",
      #   bucket: "localorbit-alpha",
      #   database: "HEROKU_POSTGRESQL_IVORY"
      # },
      # dev1: {
      #   app: "localorbit-dev1",
      #   env: "dev1",
      #   bucket: "localorbit-uploads-dev1",
      #   database: "HEROKU_POSTGRESQL_COBALT"
      # },
      # dev2: {
      #   app: "localorbit-dev2",
      #   env: "dev2",
      #   bucket: "localorbit-uploads-dev2",
      #   database: "HEROKU_POSTGRESQL_AQUA"
      # },
      # dev3: {
      #   app: "localorbit-dev3",
      #   env: "dev3",
      #   bucket: "localorbit-uploads-dev3",
      #   database: "HEROKU_POSTGRESQL_BROWN"
      # },
      # dev4: {
      #   app: "localorbit-dev4",
      #   env: "dev4",
      #   bucket: "localorbit-uploads-dev4",
      #   database: "HEROKU_POSTGRESQL_AMBER"
      # },
    }
  end

  def config
    @config_name || raise("Please set @config_name, eg, @config_name = :demo")
    configs[@config_name] || raise("No config for '#{@config_name}'")
  end

  def target_app
    # "localorbit-demo"
    config[:app]
  end

  def target_env
    # "demo"
    config[:env]
  end

  def target_bucket
    # "localorbit-demo"
    config[:bucket]
  end

  def target_database
    # "HEROKU_POSTGRESQL_IVORY"
    config[:database]
  end

  def source_app
    "localorbit-production"
  end

  def prod_copy_name
    "localorbit-production-copy"
  end

  def dump_file
    "latest.prod.dump"
  end

  def cleansed_dump_file
    "cleansed.prod.dump"
  end

  def local_development_db
    configs = YAML.load_file('config/database.yml')
    configs["development"]["database"]
  end

  def production_copy_params
    {
      database: "localorbit-production-copy",
      adapter:  "postgresql",
      encoding: "unicode",
      template: "template0",
      host:     "localhost"
    }
  end

  def copy_production_to_local
    backup_and_download
    import_local_copy
  end

  def cleanse_production_copy
    clear_all_payment_provider_refs
    reset_all_passwords
    nerf_all_email_addresses
    dump_cleansed_copy
  end

  def backup_and_download
    sh "/usr/local/bin/heroku pg:backups capture -a #{source_app}"
    sh "curl -o #{dump_file} `/usr/local/bin/heroku pg:backups public-url -a #{source_app}`"
  end

  def import_local_copy
    system "createdb #{prod_copy_name}" # don't care if this fails due to already existing
    sh "pg_restore --verbose --clean --no-acl --no-owner -h localhost -d #{prod_copy_name} #{dump_file}"
  end

  def stomp_local_dev_with_cleansed_prod_copy

    if !File.exists?(cleansed_dump_file)
      puts "Can't find a production dump file at '#{cleansed_dump_file}'."
      puts "Maybe run 'rake production_copy:bring_down' first?"
      puts "Aborting."
      exit 1
    end

    sh "rake db:drop db:create RAILS_ENV=development"
    cmd =  "pg_restore --clean --no-acl --no-owner -h localhost -d #{local_development_db} #{cleansed_dump_file} > /dev/null 2>&1"
    puts "#{cmd}"
    `#{cmd}`
  end

  def sync_prod_uploads_to_local_dev
    dest_dir = "public/system/dragonfly/development"
    mkdir_p dest_dir
    source_bucket = secrets_for("production")["UPLOADS_BUCKET"]
    sh "aws s3 sync s3://#{source_bucket}/ #{dest_dir}/"
  end

  def connect_production_copy
    ActiveRecord::Base.establish_connection(production_copy_params)
  end

  def stripe_refs_to_clear
    if ENV["KEEP_STRIPE_IDS"] =~ /^(y|on|true)/i
      [ { model: ::Payment,     fields: [ :stripe_id ] } ]
    else
      [ { model: ::BankAccount, fields: [ :stripe_id ] },
        { model: ::Market     , fields: [ :stripe_customer_id, :stripe_account_id ] },
        { model: ::Organization,fields: [ :stripe_customer_id ] },
        { model: ::Payment,     fields: [ :stripe_id ] } ]
    end
  end

  def clear_all_payment_provider_refs
    refs_to_clear = []
    refs_to_clear += stripe_refs_to_clear

    refs_to_clear.each do |hash|
      hash[:fields].each do |field|
        puts "Setting all #{hash[:model].name}##{field} to nil"
        hash[:model].update_all("#{field} = NULL")
      end
    end
  end

  def reset_all_passwords
    puts "Setting all user passwords to 'password1'"
    User.update_all(encrypted_password: Devise::Encryptor.digest(User, "password1"))
  end

  def nerf_all_email_addresses
    puts "Transforming all user emails to @example.com"
    User.all.each do |user|
      email = user.email
      if email.present? && email_needs_cleansing?(email)
        new_email = user.email.gsub("@","_at_") + "@example.com"
        user.update_columns(email: new_email)
      end
    end
  end

  def email_needs_cleansing?(email)
    !(email =~ /@example\.com$/ || email =~ /atomicobject/ || email =~ /localorb/)
  end

  def dump_cleansed_copy
    sh "pg_dump -Fc --no-acl --no-owner -h localhost #{prod_copy_name} > #{cleansed_dump_file}"
  end

  def restore_cleansed_dump_to_target
    WebMock.disable!
    # Step 1: Upload to S3
    puts "Connecting to S3"
    config = secrets_for(target_env)
    s3 = AWS::S3.new(
      :access_key_id => config["UPLOADS_ACCESS_KEY_ID"],
      :secret_access_key => config["UPLOADS_SECRET_ACCESS_KEY"])
    object = s3.buckets[config["UPLOADS_BUCKET"]].objects['backup/cleansed.prod.dump']
    puts "Uploading cleansed production copy to S3"
    object.write(Pathname.new(cleansed_dump_file))
    dump_url = object.url_for(:get, { :expires => 20.minutes.from_now, :secure => true }).to_s
    puts "Done.  #{dump_url}"

    # Step 2: Restore
    puts "Restoring db from backup on S3"
    sh "/usr/local/bin/heroku pg:backups restore '#{dump_url}' #{target_database} -a #{target_app} --confirm #{target_app}"
  end

  def secrets_for(key)
    secrets = YAML.load(File.read("../secrets/secrets.yml"))
    secrets[key] || raise("No secrets found for #{key}")
  end

  def replicate_s3_bucket
    source_bucket = secrets_for("production")["UPLOADS_BUCKET"]
    dest_bucket = secrets_for(target_env)["UPLOADS_BUCKET"]
    everyone_uri = "http://acs.amazonaws.com/groups/global/AllUsers"
    blockworkaws_id = "7462d205c2b14829eaa79c77b6eaae2e4166a2b30d06e9d261db44a3e27c0d1f" # Ericka's canonical Amazon ID
    grants="--grants read=uri=#{everyone_uri} full=id=#{blockworkaws_id}"
    sh "aws s3 sync s3://#{source_bucket}/ s3://#{dest_bucket}/ #{grants}"
  end

  def console
    connect_production_copy
    binding.pry
  end
end
