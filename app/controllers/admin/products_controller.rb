module Admin
  class ProductsController < AdminController
    include StickyFilters

    before_filter :process_filter_clear_requests
    before_action :ensure_selling_organization

    def index
      @query_params = sticky_parameters(request.query_parameters)
      @products = current_user.managed_products.periscope(@query_params).page(params[:page]).per(params[:per_page])

      find_organizations_for_filtering
      find_markets_for_filtering
    end

    def new
      @product = Product.new.decorate
      find_selling_organizations
      find_delivery_schedules
      find_selected_delivery_schedule_ids
    end

    def create
      @product = Product.new(product_params).decorate
      @product.organization = current_user.managed_organizations.selling.find_by_id(@product.organization_id)

      if @product.save
        redirect_to after_create_page, notice: "Added #{@product.name}"
      else
        find_selling_organizations
        find_delivery_schedules
        find_selected_delivery_schedule_ids
        render :new
      end
    end

    def show
      @product = current_user.managed_products.find(params[:id]).decorate
      @organizations = [@product.organization]

      find_delivery_schedules(@product)
      find_selected_delivery_schedule_ids(@product)
    end

    def update
      @product = current_user.managed_products.find(params[:id]).decorate

      if @product.update_attributes(product_params)
        redirect_to after_create_page, notice: "Saved #{@product.name}"
      else
        @organizations = [@product.organization]
        find_delivery_schedules(@product)
        find_selected_delivery_schedule_ids
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
      results = params.require(:product).permit(
        :name, :image, :category_id, :unit_id, :location_id, :organization_id,
        :short_description, :long_description,
        :who_story, :how_story,
        :use_simple_inventory, :simple_inventory, :use_all_deliveries,
        delivery_schedule_ids: []
      )

      results.merge!(delivery_schedule_ids:[] ) unless results[:delivery_schedule_ids]
      results
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
        order(:name).inject([]) do |result, org|
        result << [org.name, org.id]
      end
    end

    def find_markets_for_filtering
      markets = current_user.admin? ? current_user.markets : current_user.managed_markets
      @selling_markets = markets.order(:name).inject([]) {|result, market| result << [market.name, market.id] }
    end

    def find_delivery_schedules(product=nil)
      @delivery_schedules = if params.try(:[], :product)
        organization = Organization.where(id: params[:product][:organization_id])
        organization.empty? ? {} : organization.first.decorate.delivery_schedules
      elsif product.try(:organization)
        product.organization.decorate.delivery_schedules
      elsif current_user.organizations.count == 1
        current_user.organizations.first.decorate.delivery_schedules
      else
        {}
      end
    end

    def find_selected_delivery_schedule_ids(product=nil)
      @selected_delivery_schedule_ids = if params.try(:[], :product).try(:[], :delivery_schedule_ids)
        product_params[:delivery_schedule_ids]
      elsif product
        product.delivery_schedule_ids.map {|id| id.to_s }
      else
        @delivery_schedules.map {|market, schedules| schedules.map{|ds| ds.id.to_s} }.flatten
      end
    end
  end
end
