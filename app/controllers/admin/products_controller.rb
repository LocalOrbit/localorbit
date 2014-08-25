module Admin
  class ProductsController < AdminController
    include StickyFilters

    before_action :ensure_selling_organization
    before_action :find_product, only: [:show, :update, :destroy]
    before_action :find_sticky_params, only: :index

    def index
      @products = current_user.managed_products.periscope(@query_params).preload(:prices, :lots, :organization).page(params[:page]).per(@query_params[:per_page])

      find_organizations_for_filtering
      find_markets_for_filtering
    end

    def new
      @product = Product.new.decorate
      setup_new_form
    end

    def create
      @product = Product.new(product_params).decorate
      find_selling_organizations
      @product.organization = @organizations.detect {|o| o.id == @product.organization_id }

      if @product.save
        redirect_to after_create_page, notice: "Added #{@product.name}"
      else
        setup_new_form
        render :new
      end
    end

    def show
      @organizations = [@product.organization]

      find_delivery_schedules(@product)
      find_selected_delivery_schedule_ids(@product)
    end

    def update
      updated = update_product

      message = updated ? "Saved #{@product.name}" : nil
      respond_to do |format|
        format.html { html_for_update(updated, message) }
        format.js   { json_for_update(updated, message) }
      end
    end

    def destroy
      @product.soft_delete
      redirect_to [:admin, :products], notice: "Successfully deleted #{@product.name}"
    end

    private

    def find_product
      @product = current_user.managed_products.find(params[:id]).decorate
    end

    def update_product
      if product_params[:simple_inventory].present? && product_params.count == 1
        @product.simple_inventory = product_params[:simple_inventory]
        @product.lots.last.save
      else
        @product.update_attributes(product_params)
      end
    end

    def product_params
      results = params.require(:product).permit(
        :name, :image, :category_id, :unit_id, :location_id, :organization_id,
        :short_description, :long_description,
        :who_story, :how_story,
        :use_simple_inventory, :simple_inventory, :use_all_deliveries,
        :unit_description,
        delivery_schedule_ids: []
      )

      unless results.count == 1 && results["simple_inventory"].present?
        results[:delivery_schedule_ids] ||= []
      end

      results
    end

    def query_params
      params.fetch(:query_params, {})
    end

    def after_create_page
      if params[:after_save]
        params[:after_save]
      elsif @product.use_simple_inventory?
        [:admin, @product, :prices]
      else
        [:admin, @product, :lots]
      end
    end

    def ensure_selling_organization
      return if current_user.managed_organizations.selling.any?
      flash[:alert] = "You must add an organization that can sell before adding any products"
      redirect_to new_admin_organization_path
    end

    def find_selling_organizations
      @organizations = current_user.managed_organizations.active.selling.order(:name).preload(:locations).to_a
    end

    def find_organizations_for_filtering
      orgs = current_user.managed_organizations.selling.periscope(request.query_parameters).
        order(:name)
      @selling_organizations = orgs.inject([]) do |result, org|
        result << [org.name, org.id]
      end
    end

    def find_markets_for_filtering
      @selling_markets = Market.managed_by(current_user).order(:name).inject([]) {|result, market| result << [market.name, market.id] }
    end

    def find_delivery_schedules(product=nil)
      organization = if params.try(:[], :product)
        Organization.find_by(id: params[:product][:organization_id])
      elsif product.try(:organization)
        product.organization
      elsif current_user.organizations.count == 1
        current_user.organizations.first
      else
        nil
      end

      @delivery_schedules = if organization
        organization.decorate.delivery_schedules
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
        @delivery_schedules.values.flatten.map {|ds| ds.id.to_s }
      end
    end

    def setup_new_form
      find_selling_organizations
      if !@product.persisted? && @organizations.size == 1
        @product.organization = @organizations.first
      end
      find_delivery_schedules
      find_selected_delivery_schedule_ids
    end

    def html_for_update(updated, message)
      if updated
        redirect_to after_create_page, notice: message
      else
        @organizations = [@product.organization]
        find_delivery_schedules(@product)
        find_selected_delivery_schedule_ids
        render :show
      end
    end

    def json_for_update(updated, message)
      @data = if updated
        {
          message: message,
          params: product_params.to_a,
          toggle: @product.available_inventory
        }
      else
        {
          errors: @product.errors.full_messages
        }
      end

      status_code = updated ? 200 : 422
      render json: @data, status: status_code
    end
  end
end
