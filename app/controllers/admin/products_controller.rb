module Admin
  class ProductsController < ApplicationController
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
        redirect_to [:admin, @product], notice: "Added #{@product.name}"
      else
        render :new
      end
    end

    def show
      @product = current_user.managed_products.find(params[:id])
    end

    private

    def product_params
      params.require(:product).permit(:name, :category_id)
    end
  end
end
