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

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to [:admin, :categories]
    else
      render "new"
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :parent_id)
  end
end
