class Admin::CrossSellingListsController < AdminController
  # This coordinates the association of entity and cross sell list
  # The before_action method defines @entity, seen in use below...
  include CrossSellingListEntity

  before_action :require_self_enabled_cross_selling, except: :index

  def index
    @cross_selling_lists = @entity.cross_selling_lists
  end

  def show
    @cross_selling_list = CrossSellingList.find(params[:id])
  end

  # KXM I don't think this is needed...
  def edit
  end

  def new
    @cross_selling_list = @entity.cross_selling_lists.build
  end

  def create
    @cross_selling_list = @entity.cross_selling_lists.build(cross_selling_list_params)
    # KXM Some manual assignments will be required here (I'm thinking specifically 'creator').
    # Further, the subscriber array will have to be addressed after saving the list itself 
    # (the newly created id inserted as the derived list parent).

    if @cross_selling_list.save
      redirect_to [:admin, @entity, @cross_selling_list], notice: "Successfully created #{@cross_selling_list.name}"
    else
      flash.now[:alert] = "Could not create list"
      render :new
    end
  end

  def update
    @cross_selling_list = CrossSellingList.find(params[:id])
    if @cross_selling_list.update_attributes(cross_selling_list_params)
      redirect_to [:admin, @entity, @cross_selling_list]
    else
      flash.now.alert = "Could not update Cross Selling List"
      render :show
    end
  end

  # KXM Look into SoftDelete... this is likely not needed
  def destroy
  end

  def cross_selling_list_params
    params.require(:cross_selling_list).permit(
      :name,
      :status
    )
  end

  # Automatically redirect to index if the market hasn't yet enabled cross selling
  def require_self_enabled_cross_selling
    if @entity.try(:self_enabled_cross_sell) != true
      redirect_to [:admin, @entity, :cross_selling_lists]
    end
  end

end
