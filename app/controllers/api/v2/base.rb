require 'grape-swagger'

module API	
	module V2
		class Base < Grape::API
			version 'v2'
			# mount Products
			#mount Api::V2::Products
			#mount Products
			mount API::V2::Products

			add_swagger_documentation(
        api_version: "v1",
        hide_documentation_path: true,
        mount_path: "/api/v2/swagger_doc",
        hide_format: true
      )
		end
	end
end