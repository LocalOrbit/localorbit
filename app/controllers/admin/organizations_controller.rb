module Admin
  class OrganizationsController < AdminController
    include StickyFilters

    before_action :require_admin_or_market_manager, only: [:new, :create, :destroy]
    before_action :find_organization, except: [:index, :new, :create]
    before_action :find_sticky_params, only: :index

    def index
      if params["clear"]
        redirect_to url_for(params.except(:clear))
      else
        @organizations = current_user.managed_organizations.periscope(@query_params)
        find_selling_markets

        respond_to do |format|
          format.html { @organizations = @organizations.page(params[:page]).per(@query_params[:per_page]) }
          format.csv  do
            if ENV["USE_UPLOAD_QUEUE"] == "true"
              orgs = @organizations.map(&:id)
              Delayed::Job.enqueue ::CSVExport::CSVOrganizationExportJob.new(current_user, orgs)
              flash[:notice] = "Please check your email for export results."
              redirect_to admin_organizations_path
            else
              @filename = "organizations.csv"
            end
          end
        end
      end
    end

    def new
      @markets      = current_user.markets.order('name')
      first_market  = @markets.first

      @organization = Organization.new(
        allow_purchase_orders: first_market.default_allow_purchase_orders,
        allow_credit_cards: first_market.default_allow_credit_cards
      )

      @org_markets = @organization.markets.pluck(:id)
    end

    def create
      org_type = update_org_type(params[:organization][:can_sell])
      auto_activate = Market.find(params[:initial_market_id]).try(:auto_activate_organizations) unless params[:initial_market_id].empty?

      op = organization_params.merge({:org_type => org_type})
      op.merge!({active: "1"}) if (org_type == "B" && auto_activate)
      op.except!(:markets)

      result = RegisterStripeOrganization.perform(organization_params: op, user: current_user, market_id: params[:initial_market_id])

      if result.success?
        organization = result.organization
        # This updates the association through market_organizations, adding and deleting rows (rather than setting deleted_at)
        organization.markets = Market.find(params[:organization][:markets].map(&:to_i))
        redirect_to [:admin, organization], notice: "#{organization.name} has been created"
      else
        @markets = current_user.markets
        @organization = result.organization
        render action: :new
      end
    end

    def show
      @markets = current_user.markets.order('name')
      if @organization.blank?
        redirect_to action: :index, alert: "That organization is no longer available"
      else
        @org_markets = @organization.markets.pluck(:id)
      end
    end

    def update
      # This updates the association through market_organizations, adding and deleting rows (rather than setting deleted_at)
      @organization.markets = Market.find(params[:organization][:markets].map(&:to_i)) unless params[:organization][:markets].blank?

      if @organization.can_sell && organization_params[:can_sell]=="0" && (current_user.admin? || current_user.market_manager?)
        disable_supplier_inventory
      end

      org_type = update_org_type(params[:organization][:can_sell] || params[:can_sell])

      if @organization.update_attributes(organization_params.except(:markets).merge({:org_type => org_type}))
        redirect_to [:admin, @organization], notice: "Saved #{@organization.name}"
      else
        render action: :show
      end
    end

    def update_active
      @organization.update_attribute(:active, params[:active])

      NotifyOrganizationActivated.perform(organization: @organization)
      redirect_to :back, notice: "Updated #{@organization.name}"
    end

    def update_org_type(can_sell)
      if can_sell == true || can_sell == 'true' || can_sell == "1"
        "S"
      else
        "B"
      end
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

    def available_inventory
      render partial: "available_inventory", locals: { organization: @organization }
    end

    private

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
        :buyer_org_type,
        :ownership_type,
        :non_profit,
        :professional_organizations,
        :org_type,
        :plan_id,
        locations_attributes: [:name, :address, :city, :state, :zip, :phone, :fax, :country],
        markets: []
      )
    end

    def find_organization
      @organization = current_user.managed_organizations.find_by_id(params[:id])
    end

    def find_delivery_schedules
      @organization.decorate.delivery_schedules
    end

    def find_selling_markets
      @selling_markets = Market.managed_by(current_user).order(:name).inject([]) {|result, market| result << [market.name, market.id] }
    end

    def disable_supplier_inventory
      supplier_org = find_organization
      products = supplier_org.products
      products.each do |product|
        lots = product.lots
        lots.each do |lot|
          lot.quantity = 0
          lot.good_from = nil
          lot.expires_at = nil
          lot.save
        end
      end
    end
  end
end
