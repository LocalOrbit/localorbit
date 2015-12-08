module API  
  class Base < Grape::API
    mount API::V2::Base
  end
end  