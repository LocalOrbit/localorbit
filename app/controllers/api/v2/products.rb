module API
	module V2
		class Products < Grape::API 
			include API::V2::Defaults

			resource :products do # TODO Q: Should we allow this endpoint?
				# get requests
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
					Product.where(name: permitted_params[:name]) # all that come up with that name search
				end

				desc "Return products by category"
				params do 
					requires :category, type: String, desc: "Name of category"
				end
				get ":category", root: "product" do # This one does not really work that well, eg category "carrots" gets all the cat "Vegetables", TODO examine priorities
					category_id = Category.find_by_name(permitted_params[:category]).id
					Product.where(category_id: category_id)
				end

				# post requests

				desc "Create a product"
				params do
					requires :name, :unit, :category_id, :unit_description,
				end

				# singular in post request
				post '/add-product' do
					product = Product.create(params(:go,:here))
				end

				desc "Upload json"
				params do
					requires :param1, :param2
				end
				post '/add-products' do
					# do stuff with posted json file here
					# should be normal way of parsing it and then it will add by row
					# sending responses in the order with the route redirections as mentioned in plan
				end


			end


		end
	end
end
