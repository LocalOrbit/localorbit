module API
	module V2
		class Products < Grape::API 
			include API::V2::Defaults

			resource :products do # TODO Q: Should we allow this endpoint?
				desc "Return all products"
				get "", root: :products do 
					Product.all
				end

				desc "Return a product"
				params do 
					requires :id, type: String, desc: "ID of the product"
				end
				get ":id", root: "product" do 
					Product.where(id: permitted_params[:id]).first!
				end

				desc "Return a product by name"
				params do 
					requires :name, type: String, desc: "Name of the product"
				end
				get ":name", root: "product" do 
					Product.where(name: permitted_params[:name])
				end


			end


		end
	end
end
