module API
	module V2
		class Products < Grape::API 
			include API::V2::Defaults

			resource :products do # TODO Q: Should we allow this endpoint?
				# get requests
				desc "Return all products"
				get "", root: :products do 
					GeneralProduct.all # if you're actually looking for all products, this is what you want (how will it deal with units?)
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
					Product.where(category_id: category_id) # possible this should be genprod
				end

				### post requests

				desc "Create a product"
				params do
					requires :name, :organization_name, :market_name, :unit, :category, :unit_description, :short_description, :long_description
				end

				# singular in post request
				post '/add-product' do
					product_name = permitted_params[:name]
					possible_orgs = Organization.find_by_name(permitted_params[:organization_name])
					

					product = Product.create!(
						        name: #product_name,
						        organization_id: #seller_id,
						        market_id: #market_id from code..
						        unit_id: #unit_id,
						        category_id: #category_id,
						        code: #code,
						        short_description: #short_description,
						        long_description: #long_description,
						        unit_description: #unit_description
						      	)
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
