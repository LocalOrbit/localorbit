require 'aws_config'

set :stage, :production
set :branch, :CHANGEME
set :rails_env, :production

set :deploy_to, '/srv/www/localorbit.com'
set :release_path, deploy_path.join('localorbit')

Aws.config.update(
  credentials: Aws::Credentials.new(
    AWSConfig.lo_production.aws_access_key_id,
    AWSConfig.lo_production.aws_secret_access_key
  )
)

# AWS regions
set :aws_ec2_regions, [AWSConfig.lo_production.region]

# Application name to match application tag.
# set :aws_ec2_application, (proc { fetch(:application) })
set :aws_ec2_application, 'localorbit'

# Stage to match stage tag.
set :aws_ec2_stage, (proc { fetch(:stage) })

# Tag to be used for Capistrano stage.
set :aws_ec2_stage_tag, 'env'

# Tag to be used to match the application.
set :aws_ec2_application_tag, 'app'

# Tag to be used for Capistrano roles of the server (the tag value can be a comma separated list).
set :aws_ec2_roles_tag, 'roles'

# Extra filters to be used to retrieve the instances. See the README.md for more information.
set :aws_ec2_extra_filters, []
# NOTE: Can use this to upgrade ruby on an instance by instance basis
# set :aws_ec2_extra_filters, [
#   {
#     name: "tag:roles",
#     values: ["web,app,worker,migrator,upgrade"],
#   },
# ]

# Tag to be used as the instance name in the instances table (aws:ec2:instances task).
set :aws_ec2_name_tag, 'Name'

# How to contact the instance (:public_ip, :public_dns, :private_ip).
set :aws_ec2_contact_point, :public_dns

# register
aws_ec2_register user: 'localorbit'
