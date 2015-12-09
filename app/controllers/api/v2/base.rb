module API	
	module V2
		class Base < Grape::API
			version 'v2'
			mount Products
			#mount Api::V2::Products
			#mount Products
			# mount API::V2::AnotherResource
		end
	end
end