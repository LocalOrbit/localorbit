module Admin
  class ProductsController < AdminController
    before_action :ensure_selling_organization

    def index
      @products = current_user.managed_products.periscope(request.query_parameters).page(params[:page]).per(params[:per_page])
      find_organizations_for_filtering
      find_markets_for_filtering
    end

    def new
      @product = Product.new.decorate
      find_selling_organizations
      find_delivery_schedules
    end

    def create
      @organization = current_user.managed_organizations.selling.find_by_id(params[:product][:organization_id])
      @product = Product.new(product_params.merge(organization: @organization)).decorate

      if @product.save
        redirect_to after_create_page, notice: "Added #{@product.name}"
      else
        find_selling_organizations
        find_delivery_schedules
        render :new
      end
    end

    def show
      @product = current_user.managed_products.find(params[:id]).decorate
      @organizations = [@product.organization]

      find_delivery_schedules(@product)
    end

    def update
      @product = current_user.managed_products.find(params[:id]).decorate

      if @product.update_attributes(product_params)
        redirect_to after_create_page, notice: "Saved #{@product.name}"
      else
        @organizations = [@product.organization]
        find_delivery_schedules(@product)
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
        :use_simple_inventory, :simple_inventory, :use_all_deliveries,
        delivery_schedule_ids: []
      )
    end

    def after_create_page
      @product.use_simple_inventory? ? [:admin, @product, :prices] : [:admin, @product, :lots]
    end

    def ensure_selling_organization
      unless current_user.managed_organizations.selling.any?
        flash[:alert] = "You must add an organization that can sell before adding any products"
        redirect_to new_admin_organization_path
      end
    end

    def find_selling_organizations
      @organizations = current_user.managed_organizations.selling.order(:name).includes(:locations)
    end

    def find_organizations_for_filtering
      @selling_organizations = current_user.managed_organizations.selling.periscope(request.query_parameters).
        order(:name).inject([["Show from all Sellers", 0]]) do |result, org|
        result << [org.name, org.id]
      end
    end

    def find_markets_for_filtering
      markets = current_user.admin? ? current_user.markets : current_user.managed_markets
      @selling_markets = markets.order(:name).inject([["Show from all Markets", 0]]) {|result, market| result << [market.name, market.id] }
    end

    def find_delivery_schedules(product=nil)
      @delivery_schedules = if product.try(:organization)
        product.organization.decorate.delivery_schedules
      elsif current_user.organizations.count == 1
        current_user.organizations.first.decorate.delivery_schedules
      else
        {}
      end
    end
  end
end
