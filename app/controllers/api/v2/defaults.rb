module API
	module V2
		module Defaults
			extend ActiveSupport::Concern

			included do
				prefix "api"
				version "v2", using: :path 
				default_format :json
				format :json
				formatter :json,
					Grape::Formatter::ActiveModelSerializers 

				helpers do 
					def permitted_params
						@permitted_params ||= declared(params, 
               include_missing: false)
					end

					def logger
						Rails.logger
					end
				end

				rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end

	      # global exception handler, used for error notifications
	      rescue_from :all do |e|
	        if Rails.env.development?
	          raise e
	        else
	          Raven.capture_exception(e)
	          error_response(message: "Internal server error", status: 500)
	        end
	      end

			end
		end
	end
end