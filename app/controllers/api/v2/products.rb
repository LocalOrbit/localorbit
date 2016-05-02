module API
	module V2
		#extend self


		## API routes to mount

		class Products < Grape::API 
			include API::V2::Defaults
			include Imports 

			resource :products do 
				## get requests
				## comment out until we determine auth access

				# desc "Return all products"
				# get "", root: :products do 
				# 	GeneralProduct.all # if you're actually looking for all products, this is what you want (TODO address issue: how should this GET deal with units?)
				# end

				# desc "Return a product"
				# params do 
				# 	requires :id, type: String, desc: "ID of the product"
				# end
				# get ":id", root: "product" do 
				# 	Product.where(id: permitted_params[:id]).first!
				# end

				# desc "Return a product by name"
				# params do 
				# 	requires :name, type: String, desc: "Name of the product"
				# end
				# get ":name", root: "product" do 
				# 	Product.where(name: permitted_params[:name]) # all that come up with that name search
				# end

				# desc "Return products by category"
				# params do 
				# 	requires :category, type: String, desc: "Name of category"
				# end
				# get ":category", root: "product" do # This one does not really work that well, eg category "carrots" gets all the cat "Vegetables", TODO examine priorities
				# 	category_id = Category.find_by_name(permitted_params[:category]).id
				# 	GeneralProduct.where(category_id: category_id) # I think this should be genprod, since that's ~products~ as we generally represent, so for now it is.
				# end


				### POST ROUTES

				desc "Create a product"
				params do
					requires :name, :organization_name, :unit, :category, :unit_description, :short_description, :long_description, :price
				end

				# singular in post request
				post '/add-product' do
					product_name = permitted_params[:name]
					possible_org = Organization.find_by_name(permitted_params[:organization_name])
					supplier_id = possible_org.id # TODO what are we doing with organizations in add products, is it the same?
					unit_id = Unit.find_by_singular(permitted_params[:unit]).id
					category_id = Category.find_by_name(permitted_params[:category]).id
					product_code = ""
					if permitted_params[:code]
						product_code = permitted_params[:code]
					end
					
					gp_id_or_false = ::Imports::ProductHelpers.identify_product_uniqueness(permitted_params)
					if !gp_id_or_false
						product = Product.create!(
							        name: product_name,
							        organization_id: supplier_id,
							        #TODO check: is market association being handled via organization? how should it be?
							        unit_id: unit_id,
							        category_id: category_id,
							        code: product_code,
							        short_description: permitted_params[:short_description],
							        long_description: permitted_params[:long_description],
							        unit_description: permitted_params[:unit_description]
							      	)
						## To create inventory and price(s). -- probably no inventory, yes 1 sale price, yes?
						# product.lots.create!(quantity: 999_999)
	     			product.prices.create!(sale_price: permitted_params[:price], min_quantity: 1) ## TODO: Should we add min quantity default or option in API, if so how?
	     		else
	     			product = Product.create!(
							        name:product_name,
							        organization_id:supplier_id,
							        #Same mkt assoc question, market name attr needed / how?
							        unit_id:unit_id,
							        category_id:category_id,
							        code:product_code,
							        short_description:permitted_params[:short_description],
							        long_description: permitted_params[:long_description],
							        unit_description: permitted_params[:unit_description],
							        general_product_id: gp_id_or_false
							      	)
						## To create inventory and price(s). probably no inventory, yes 1 sale price
						# product.lots.create!(quantity: 999_999)
	     			product.prices.create!(sale_price: permitted_params[:price], min_quantity: 1) ## TODO: min quantity default or option?
	     		end
	     		{"result"=>"product successfully created"} # TODO what should this actually be though
				end

				desc "Upload json"
				params do
					requires type: JSON # expects properly formatted JSON data
				end
				post '/add-products' do
	
					if params.class == Hashie::Mash # this should be the alternative case
						prod_hashes = params
					else
						# this should be the 'normal' thing when you post a JSON /file/ as body per convention, Rails will put file in tempfile 
						prod_hashes = JSON.parse(File.read(params[:body][:tempfile]))
					end

					prod_hashes["products"].each do |p|
						::Imports::ProductHelpers.create_product_from_hash(p,Figaro.env.api_admin_user_id.to_i) 
					end

					{"result"=>"#{prod_hashes["products_total"]} products successfully created","errors"=>$row_errors} 
				end 

			end

		end
	end
end

