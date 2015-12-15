class Admin::ActivitiesController < AdminController
  #include Users
  include StickyFilters

  before_action :require_admin
  before_action :find_users, only: :index
  before_action :find_sticky_params, only: :index

  def index
    if params["clear"]
      redirect_to url_for(params.except(:clear))
    else
      @query_params["created_at_date_gteq"] ||= 7.days.ago.to_date.to_s
      @query_params["created_at_date_lteq"] ||= Date.today.to_s

      base_scope, date_filter_attr = find_base_scope_and_date_filter_attribute

      @search_presenter = ActivitySearchPresenter.new(@query_params, current_user, date_filter_attr)
      @q = filter_and_search_orders(base_scope, @query_params, @search_presenter)

      @activities = @q.result.page(params[:page]).per(params[:per_page])
    end
  end

  private

  def find_base_scope_and_date_filter_attribute
    [Audit.reorder("created_at DESC"), :created_at]
  end

  def filter_and_search_orders(scope, params, presenter)
    query = scope.periscope(params).search(presenter.query)
    query.sorts = ["created_at desc"] if query.sorts.empty?
    query
  end

  def find_users
    scope = if current_user.admin?
              User.all
            else
              ids = current_user.managed_markets.map {|m| m.manager_ids }.flatten |
                  current_user.managed_organizations.map {|o| o.user_ids }.flatten
              User.where(id: ids)
            end
    @users = scope.includes(:managed_markets)
  end
end
