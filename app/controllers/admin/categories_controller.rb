class Admin::CategoriesController < AdminController
  before_action :require_admin

  def index
    @root = Category.root
  end
end
