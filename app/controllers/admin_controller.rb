class AdminController < ApplicationController
  before_action :require_admin

  protected

  def require_admin
    render_404 unless current_user.admin?
  end
end
