module Admin
  class ProductsController < AdminController
    include StickyFilters

    before_action :process_filter_clear_requests
    before_action :ensure_selling_organization
    before_action :find_product, only: [:show, :update, :destroy]

    def index
      @query_params = sticky_parameters(request.query_parameters)
      @products = current_user.managed_products.periscope(@query_params).page(params[:page]).per(params[:per_page])

      find_organizations_for_filtering
      find_markets_for_filtering
    end

    def new
      @product = Product.new.decorate
      setup_new_form
    end

    def create
      @product = Product.new(product_params).decorate
      @product.organization = current_user.managed_organizations.selling.find_by_id(@product.organization_id)

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
      if product_params[:simple_inventory].present? && product_params.count == 1
        @product.simple_inventory = product_params[:simple_inventory]
        update = @product.lots.last.save
      else
        update = @product.update_attributes(product_params)
      end

      if update
        respond_to do |format|
          format.html { redirect_to after_create_page, notice: "Saved #{@product.name}" }
          format.js   {
            @data = {
              message: "Saved #{@product.name}",
              params: product_params.to_a,
              toggle: @product.available_inventory
            }
            render json: @data, status: 200
          }
        end
      else
        respond_to do |format|
          format.html do
            @organizations = [@product.organization]
            find_delivery_schedules(@product)
            find_selected_delivery_schedule_ids
            render :show
          end
          format.js {
            @data = {
              errors: @product.errors.full_messages
            }
            render json: @data, status: 422
          }
        end
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
      unless current_user.managed_organizations.selling.any?
        flash[:alert] = "You must add an organization that can sell before adding any products"
        redirect_to new_admin_organization_path
      end
    end

    def find_selling_organizations
      @organizations = current_user.managed_organizations.selling.order(:name).includes(:locations)
      @organizations = @organizations.select {|o| o.markets.any? } # remove deleted orgs
      if !@product.persisted? && @organizations.size == 1
        @product.organization = @organizations.first
      end
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

    def setup_new_form
      find_selling_organizations
      find_delivery_schedules
      find_selected_delivery_schedule_ids
    end
  end
end
