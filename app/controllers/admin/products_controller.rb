module Admin
  class ProductsController < AdminController
    def index
      @products = current_user.managed_products
    end

    def new
      @product = Product.new.decorate
    end

    def create
      @organization = current_user.managed_organizations.find_by_id(params[:product][:organization_id])
      @product = Product.new(product_params.merge(organization_id: @organization.try(:id))).decorate

      if @product.save
        redirect_to after_create_page, notice: "Added #{@product.name}"
      else
        render :new
      end
    end

    def show
      @product = current_user.managed_products.find(params[:id]).decorate
    end

    def update
      @product = current_user.managed_products.find(params[:id]).decorate

      if @product.update_attributes(product_params)
        redirect_to [:admin, @product], notice: "Saved #{@product.name}"
      else
        render :show
      end
    end

    private

    def product_params
      params.require(:product).permit([
        :name, :category_id, :who_story, :how_story, :location_id, :use_simple_inventory, :simple_inventory
      ])
    end

    def after_create_page
      @product.use_simple_inventory? ? [:admin, @product] : [:admin, @product, :lots]
    end
  end
end
