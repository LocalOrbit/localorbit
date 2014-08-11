module Admin
  class OrganizationsController < AdminController
    include StickyFilters

    before_action :require_admin_or_market_manager, only: [:new, :create, :destroy]
    before_action :find_organization, only: [:show, :edit, :update, :update_active, :delivery_schedules, :market_memberships, :destroy]

    def index
      @query_params = sticky_parameters(request.query_parameters)
      @organizations = current_user.managed_organizations.periscope(@query_params)
      find_selling_markets

      respond_to do |format|
        format.html { @organizations = @organizations.page(params[:page]).per(@query_params[:per_page]) }
        format.csv  { @filename = "organizations.csv" }
      end
    end

    def new
      @markets      = current_user.markets
      first_market  = @markets.first

      @organization = Organization.new(
        allow_purchase_orders: first_market.default_allow_purchase_orders,
        allow_credit_cards: first_market.default_allow_credit_cards
      )
    end

    def create
      result = RegisterOrganization.perform(organization_params: organization_params, user: current_user, market_id: params[:initial_market_id])

      if result.success?
        organization = result.organization
        redirect_to [:admin, organization], notice: "#{organization.name} has been created"
      else
        @markets = current_user.markets
        @organization = result.organization
        render action: :new
      end
    end

    def show
    end

    def update
      if @organization.update_attributes(organization_params)
        redirect_to [:admin, @organization], notice: "Saved #{@organization.name}"
      else
        render action: :show
      end
    end

    def update_active
      @organization.update_attributes(update_active_params)
      redirect_to :back, notice: "Updated #{@organization.name}"
    end

    def destroy
      market_ids  = Array.wrap(params[:ids]).map(&:to_i)
      market_ids &= Market.managed_by(current_user).pluck(:id)

      remove_organization_from_markets = RemoveOrganizationFromMarkets.perform(
        organization: @organization,
        market_ids:   market_ids
      )

      if remove_organization_from_markets.success?
        redirect_to [:admin, :organizations], notice: remove_organization_from_markets.message
      else
        redirect_to [:admin, :organizations], alert: remove_organization_from_markets.error
      end
    end

    def delivery_schedules
      schedules = find_delivery_schedules
      ids = schedules.values.flatten.map {|schedule| schedule.id.to_s }

      render partial: "delivery_schedules", locals: {delivery_schedules: schedules, selected_ids: ids, product: nil, organization: @organization}
    end

    def market_memberships
      render partial: "market_memberships"
    end

    private

    def update_active_params
      params.require(:organization).permit(
        :active
      )
    end

    def organization_params
      params.require(:organization).permit(
        :name,
        :can_sell,
        :show_profile,
        :facebook,
        :twitter,
        :display_facebook,
        :display_twitter,
        :who_story,
        :how_story,
        :photo,
        :allow_purchase_orders,
        :allow_credit_cards,
        :allow_ach,
        :active,
        locations_attributes: [:name, :address, :city, :state, :zip, :phone, :fax]
      )
    end

    def find_organization
      @organization = current_user.managed_organizations.find(params[:id])
    end

    def find_delivery_schedules
      @organization.decorate.delivery_schedules
    end

    def find_selling_markets
      @selling_markets = Market.managed_by(current_user).order(:name).inject([["All", 0]]) {|result, market| result << [market.name, market.id] }
    end
  end
end
