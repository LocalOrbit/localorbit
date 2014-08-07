class Admin::ActivitiesController < AdminController
  before_action :require_admin

  def index
    @activities = Audit.reorder("created_at DESC").page(params[:page]).per(params[:per_page])
  end
end