module Admin
  class ProductsController < AdminController
    include StickyFilters
    include ::Financials::Pricing

    before_action :ensure_selling_organization
    before_action :find_product, only: [:show, :update, :destroy]
    before_action :find_sticky_params, only: :index

    def index
      if params["clear"]
        redirect_to url_for(params.except(:clear))
      else
        products = current_user.managed_products.periscope(@query_params).includes(:lots, :unit, :prices=>[:market], :organization => [:all_markets])
        respond_to do |format|
          format.html do
            @products = products.page(params[:page]).per(@query_params[:per_page])
            find_organizations_for_filtering
            find_markets_for_filtering

            markets = @products.flat_map {|prod| prod.organization.all_markets }
            @net_percents_by_market_id = ::Financials::Pricing.seller_net_percents_by_market(markets)
          end
          format.csv do
            @filename = 'products.csv'
            @products = products
          end
        end
      end
    end

    def new
      @product = Product.new(use_simple_inventory: true).decorate
      setup_new_form
    end

    def create
      @product = Product.new(product_params).decorate
      find_selling_organizations
      @product.organization = @organizations.detect {|o| o.id == @product.organization_id }

      if @product.save
        update_sibling_units(@product)
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
      find_sibling_units(@product)
    end

    def update
      updated = update_product
      update_sibling_units(@product)

      find_sibling_units(@product)

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
        :code,
        :short_description, :long_description,
        :who_story, :how_story,
        :use_simple_inventory, :simple_inventory, :use_all_deliveries,
        :unit_description,
        delivery_schedule_ids: [],
        sibling_id: [],
        sibling_unit_id: [],
        sibling_unit_description: [],
        sibling_product_code: []
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
      elsif @product.lots.count > 0
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
      orgs = current_user.managed_organizations.selling.periscope(request.query_parameters).order(:name)
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

    def find_sibling_units(product)
      @sibling_units = []
      if product && product.general_product
        @sibling_units = product.general_product.product.visible.all
                           .reject { |sibling| sibling.id == product.id }
                           .sort { |a, b| a.unit.plural <=> b.unit.plural }
      end
    end

    def update_sibling_units(product)
      if product && product.sibling_id
        product.sibling_id.each_with_index do |sibling_id, i|
          sibling_unit_id = product.sibling_unit_id[i]
          sibling_unit_description = product.sibling_unit_description[i]
          sibling_product_code = product.sibling_product_code[i]
          if sibling_unit_id && sibling_unit_id != ""
            if sibling_id == "0"
              sibling = product.model.dup
              sibling.unit_id = sibling_unit_id
              sibling.unit_description = sibling_unit_description
              sibling.code = sibling_product_code
              sibling.save
            else
              sibling = Product.find_by(id: sibling_id)
              if sibling
                sibling.update(unit_id: sibling_unit_id, unit_description: sibling_unit_description,
                               code: sibling_product_code)
              end
            end
          end
        end
      end
    end

    def setup_new_form
      @sibling_units ||= []
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
