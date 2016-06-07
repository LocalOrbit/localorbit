class Admin::CrossSellingListsController < AdminController
  # This coordinates the association of entity and cross sell list
  # The before_action method defines @entity, seen in use below...
  include CrossSellingListEntity

  def index
    @cross_sell_lists = @entity.cross_selling_lists
  end

  def show
  end

  def edit
  end

  def new
    # @cross_sell_list = CrossSellingList::new(entity_id: @entity.id, entity_type: @entity.class)
    @cross_sell_list = @entity.cross_selling_lists.build
  end

  def create
    @cross_sell_list = @entity.cross_selling_lists.build(cross_selling_list_params)
    binding.pry

    if @cross_sell_list.save
      redirect_to [:admin, @entity, @cross_selling_list], notice: "Successfully created #{@cross_sell_list.name}"
    else
      flash.now[:alert] = "Could not create list"
      render :new
    end
  end

  def update
  end

  def destroy
  end

  def cross_selling_list_params
    params.require(:cross_selling_list).permit(
      :name,
      :status
    )
  end

end
