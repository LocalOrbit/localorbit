# A sample Guardfile
# More info at https://github.com/guard/guard#readme

### Guard::Konacha
#  available options:
#  - :run_all_on_start, defaults to true
#  - :notification, defaults to true
#  - :rails_environment_file, location of rails environment file,
#    should be able to find it automatically
guard :konacha do
  watch(%r{^app/assets/javascripts/(.*)\.js(\.coffee)?$}) { |m| "spec/javascripts/#{m[1]}_spec.js#{m[2]}" }
  watch(%r{^spec/javascripts/.+_spec(\.js|\.js\.coffee)$})
end
