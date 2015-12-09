module API  
  class Base < Grape::API
  	prefix 'api'
    mount API::V2::Base
  end
end  