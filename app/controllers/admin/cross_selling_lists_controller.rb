class Admin::CrossSellingListsController < AdminController
  # This coordinates the association of entity and cross sell list
  # The before_action method defines @entity, seen in use below...
  include CrossSellingListEntity

  before_action :require_self_enabled_cross_selling, except: :index

  def index
    @cross_selling_lists = @entity.cross_selling_lists
  end

  def subscriptions
    # This processing path will be very similar to, but different from index
    @cross_selling_subscriptions = @entity.cross_selling_list_subscriptions
  end

  def show
    @cross_selling_list = CrossSellingList.includes(:active_children, :products).find(params[:id])
    # KXM Pagination is a bigger problem than it's really worth, but here is the code that enables it.  Delete this crap once the scales fall from their eyes
    # @suppliers = @entity.suppliers.order(:name).page(params[:page]).per(3)
    # @products = @entity.supplier_products.order(:name).page(params[:page]).per(12)

    @suppliers = @entity.suppliers.order(:name)
    @products = @entity.supplier_products.order(:name)
  end

  def new
    @cross_selling_list = @entity.cross_selling_lists.build
  end

  def create
    @cross_selling_list = @entity.cross_selling_lists.build(cross_selling_list_params)
    @cross_selling_list.creator = true

    if @cross_selling_list.save
      selected_subscribers = cross_selling_list_params[:children_ids].select(&:present?).map { |submitted_id| {parent_id: @cross_selling_list.id, entity_id: submitted_id.to_i} }

      # This creates the child lists, but it'd be cool it rails automagically did so from the supplied array of children_ids
      selected_subscribers.each do |list_ids|
        create_list(@cross_selling_list, list_ids)
      end

      redirect_to [:admin, @entity, @cross_selling_list], notice: "Successfully created #{@cross_selling_list.name}"
    else
      flash.now[:alert] = "Could not create list"
      render :new
    end
  end

  def update
    @cross_selling_list = CrossSellingList.includes(:children).find(params[:id])

    # The merge here forces a product update when all products are removed via the UI
    params_with_defaults  = {'product_ids' => []}.merge(cross_selling_list_params || {})

    # The merge here does the same but with the extracted product ids only
    submitted_products = {'product_ids' => []}.merge('product_ids' => cross_selling_list_params[:product_ids] || {})

    if @cross_selling_list.update_attributes(params_with_defaults)

      if @cross_selling_list.creator
        # If the edits are saved successfully then cascade through the related cross selling lists and products...
             all_subscribers = @cross_selling_list.children.map { |l| {parent_id: l.parent_id, entity_id: l.entity_id} }
        existing_subscribers = @cross_selling_list.active_children.map { |l| {parent_id: l.parent_id, entity_id: l.entity_id} }
        selected_subscribers = cross_selling_list_params[:children_ids].select(&:present?).map { |submitted_id| {parent_id: @cross_selling_list.id, entity_id: submitted_id.to_i} }
         overlap_subscribers = existing_subscribers & selected_subscribers

        # Delete those that exist but aren't selected
        (existing_subscribers - selected_subscribers).each do |list_ids|
          delete_list(@cross_selling_list, list_ids, submitted_products)
        end

        # Add those that are selected_subscribers but don't exist
        (selected_subscribers - existing_subscribers).each do |list_ids|
          create_list(@cross_selling_list, list_ids, submitted_products)
        end

        # Update those that appear in both
        overlap_subscribers.each do |list_ids|
          update_list(@cross_selling_list, list_ids, submitted_products)
        end

        # Also update those that were once existing - gotta keep 'em in line
        (all_subscribers - existing_subscribers).each do |list_ids|
          update_list(@cross_selling_list, list_ids, submitted_products)
        end
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
      :children_ids => [],
      :product_ids => []
    )
  end

  # Automatically redirect to index if the market hasn't yet enabled cross selling
  def require_self_enabled_cross_selling
    if @entity.try(:self_enabled_cross_sell) != true
      redirect_to [:admin, @entity, :cross_selling_lists]
    end
  end

  def create_list(parent, id_hash, params)
    target = parent.children.where("parent_id = ? AND entity_id = ?", id_hash[:parent_id], id_hash[:entity_id]).first
    if target.blank?
      new_list = parent.dup
      new_list.entity_id = id_hash[:entity_id]
      new_list.entity_type = "Market"
      new_list.creator = false
      new_list.status = "Pending"
      new_list.parent_id = id_hash[:parent_id]
      new_list.save
      new_list.update_attributes(params)
    else
      target.update_attribute(:deleted_at, nil)
      # KXM This is likely not transparent enough to be effective...
      target.update_attribute(:status, "Active") if target.status = "Revoked"
      target.update_attributes(params)
    end
  end

  def update_list(parent, id_hash, params)
    target = get_child(parent, id_hash)
    target.update_attribute(:name, parent.name) if target.pending?
    target.update_attributes(params)
  end

  def delete_list(parent, id_hash, params)
    # binding.pry
    target = get_child(parent, id_hash)
    target.update_attribute(:status, "Revoked") if target.status = "Active"
    target.update_attributes(params)
    target.soft_delete
  end

  protected

  def get_child(parent, id_hash)
    parent.children.where("parent_id = ? AND entity_id = ?", id_hash[:parent_id], id_hash[:entity_id]).first
  end
end
