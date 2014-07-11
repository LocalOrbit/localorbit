class Admin::CategoriesController < AdminController
  before_action :require_admin

  def index
    @root = Category.root

    respond_to do |format|
      format.html
      format.csv { @filename = "taxonomy.csv" }
    end
  end

  def show
    @category = Category.preload(products: :organization).find(params[:id])
  end
end
