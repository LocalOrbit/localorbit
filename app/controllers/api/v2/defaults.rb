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
					Grape::Formatter::ActiveModeSerializers 

				helpers do 
					def permitted_params
						# TODO fill in
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

			end
		end
	end
end