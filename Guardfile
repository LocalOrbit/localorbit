# A sample Guardfile
# More info at https://github.com/guard/guard#readme

### Guard::KonachaRails
#  available options:
#  - :run_all_on_start, defaults to true
#  - :notification, defaults to true
#  - :rails_environment_file, location of rails environment file,
#    should be able to find it automatically
guard 'konacha-rails' do
  watch(%r{^app/assets/javascripts/(.+)\.js\.coffee$}) { |m| "spec/javascripts/#{m[1]}_spec.js.coffee" }
  watch(%r{^(test|spec)/javascripts/.+_spec\.js\.coffee$})
  watch('spec/javascripts/spec_helper.js.coffee') { 'spec/javascripts' }
end
