module API
	module V2
		class Orders < Grape::API 
			include API::V2::Defaults

			resource :orders do
				desc "Get all orders"

				desc "Get order by order number"

				desc "Get order by supplier organization (included)"

				desc "Get order by buyer organization (placed)"

				desc "Get order within date range (optional end date)"
			end

		end
	end
end