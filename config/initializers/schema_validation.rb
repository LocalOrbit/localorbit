#
# Enable or disable RSchema validation (see lib/schema_validation.rb)
#
if Rails.env.production?
  SchemaValidation.validation = false
else
  SchemaValidation.validation = true
end
  
require 'rschema_ext/either'
require 'rschema_ext/regexp'
