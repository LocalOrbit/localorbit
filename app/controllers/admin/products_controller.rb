module Admin
  class ProductsController < AdminController
    def index
      @products = current_user.managed_products.page(params[:page]).per(params[:per_page])
    end

    def new
      ensure_selling_organization!
      @product = Product.new.decorate
      find_selling_organizations
    end

    def create
      @organization = current_user.managed_organizations.find_by_id(params[:product][:organization_id])
      @product = Product.new(product_params.merge(organization_id: @organization.try(:id))).decorate

      if @product.save
        redirect_to after_create_page, notice: "Added #{@product.name}"
      else
        find_selling_organizations
        render :new
      end
    end

    def show
      @product = current_user.managed_products.find(params[:id]).decorate
      @organizations = [@product.organization]
    end

    def update
      @product = current_user.managed_products.find(params[:id]).decorate

      if @product.update_attributes(product_params)
        redirect_to [:admin, @product], notice: "Saved #{@product.name}"
      else
        @organizations = [@product.organization]
        render :show
      end
    end

    def destroy
      product = current_user.managed_products.find(params[:id])
      product.soft_delete
      redirect_to [:admin, :products], notice: "Successfully deleted #{product.name}"
    end

    private

    def product_params
      params.require(:product).permit(
        :name, :image, :category_id, :unit_id, :location_id,
        :short_description, :long_description,
        :who_story, :how_story,
        :use_simple_inventory, :simple_inventory,
      )
    end

    def after_create_page
      @product.use_simple_inventory? ? [:admin, @product, :prices] : [:admin, @product, :lots]
    end

    def ensure_selling_organization!
      unless current_user.managed_organizations.selling.any?
        flash[:alert] = "You must add an organization that can sell before adding any products"
        redirect_to new_admin_organization_path
      end
    end

    def find_selling_organizations
      @organizations = current_user.managed_organizations.selling.includes(:locations)
    end
  end
end
