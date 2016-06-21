class Admin::CrossSellingListsController < AdminController
  # This coordinates the association of entity and cross sell list
  # The before_action method defines @entity, seen in use below...
  include CrossSellingListEntity

  before_action :require_self_enabled_cross_selling, except: :index

  def index
    @cross_selling_lists = @entity.cross_selling_lists
  end

  def subscriptions
    # KXM This is throwing a 404, not even making it to the action... permissions?
    binding.pry
    @cross_selling_lists = @entity.cross_selling_list_subscriptions
    render :index
  end

  def show
    @cross_selling_list = CrossSellingList.includes(:active_children, :products).find(params[:id])
    @suppliers = @entity.suppliers.order(:name).page(params[:page]).per(10)
    @products = @entity.supplier_products
    # binding.pry
  end

  def new
    @cross_selling_list = @entity.cross_selling_lists.build
  end

  def create
    @cross_selling_list = @entity.cross_selling_lists.build(cross_selling_list_params)
    @cross_selling_list.creator = true

    if @cross_selling_list.save
      selected = cross_selling_list_params[:shared_with].select(&:present?).map { |submitted_id| {parent_id: @cross_selling_list.id, entity_id: submitted_id.to_i} }

      selected.each do |id_hash|
        create_list(@cross_selling_list, id_hash)
      end

      redirect_to [:admin, @entity, @cross_selling_list], notice: "Successfully created #{@cross_selling_list.name}"
    else
      flash.now[:alert] = "Could not create list"
      render :new
    end
  end

  def update
    @cross_selling_list = CrossSellingList.includes(:children).find(params[:id])

    if @cross_selling_list.update_attributes(cross_selling_list_params)

      # If the edits are saved successfully then cascade through the related lists...
      existing = @cross_selling_list.active_children.map { |l| {parent_id: l.parent_id, entity_id: l.entity_id} }
      selected = cross_selling_list_params[:shared_with].select(&:present?).map { |submitted_id| {parent_id: @cross_selling_list.id, entity_id: submitted_id.to_i} }
      overlap  = existing & selected

      # Delete those that exist but aren't selected
      (existing - selected).each do |id_hash|
        delete_list(@cross_selling_list, id_hash)
      end

      # Add those that are selected but don't exist
      (selected - existing).each do |id_hash|
        create_list(@cross_selling_list, id_hash)
      end

      # Update those that appear in both
      overlap.each do |id_hash|
        update_list(@cross_selling_list, id_hash)
      end

      redirect_to [:admin, @entity, @cross_selling_list]
    else
      flash.now.alert = "Could not update Cross Selling List"
      render :show
    end
  end

  def cross_selling_list_params
    params.require(:cross_selling_list).permit(
      :name,
      :status,
      :shared_with => []
    )
  end

  # Automatically redirect to index if the market hasn't yet enabled cross selling
  def require_self_enabled_cross_selling
    if @entity.try(:self_enabled_cross_sell) != true
      redirect_to [:admin, @entity, :cross_selling_lists]
    end
  end

  def create_list(parent, id_hash)
    target = parent.children.where("parent_id = ? AND entity_id = ?", id_hash[:parent_id], id_hash[:entity_id]).first
    if target.blank?
      new_list = parent.dup
      new_list.entity_id = id_hash[:entity_id]
      new_list.entity_type = "Market"
      new_list.creator = false
      new_list.status = "Pending"
      new_list.parent_id = id_hash[:parent_id]
      new_list.save
    else
      target.update_attribute(:deleted_at, nil)
      # KXM This may not be transparent enough to be effective...
      target.update_attribute(:status, "Active") if target.status = "Revoked"
    end
  end

  def update_list(parent, id_hash)
    target = get_child(parent, id_hash)
    target.update_attribute(:name, parent.name) if target.pending?
  end

  def delete_list(parent, id_hash)
    target = get_child(parent, id_hash)
    target.update_attribute(:status, "Revoked") if target.status = "Active"
    target.soft_delete
  end

  protected

  def get_child(parent, id_hash)
    parent.children.where("parent_id = ? AND entity_id = ?", id_hash[:parent_id], id_hash[:entity_id]).first
  end
end
