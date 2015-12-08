module Api	
	module V2
		class Base < Grape::API
			mount API::V2::Products
			# mount API::V2::AnotherResource
		end
	end
end