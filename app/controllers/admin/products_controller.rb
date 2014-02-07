module Admin
  class ProductsController < AdminController
    def index
      @products = current_user.managed_products
    end

    def new
      @product = Product.new
    end

    def create
      @organization = current_user.managed_organizations.find_by_id(params[:product][:organization_id])
      @product = Product.new(product_params.merge(organization_id: @organization.try(:id)))

      if @product.save
        redirect_to [:admin, @product, :lots], notice: "Added #{@product.name}"
      else
        render :new
      end
    end

    def show
      @product = current_user.managed_products.find(params[:id])
    end

    def update
      @product = current_user.managed_products.find(params[:id])

      if @product.update_attributes(product_params)
        redirect_to [:admin, @product], notice: "Saved #{@product.name}"
      else
        render :show
      end
    end

    private

    def product_params
      params.require(:product).permit(:name, :category_id)
    end
  end
end
