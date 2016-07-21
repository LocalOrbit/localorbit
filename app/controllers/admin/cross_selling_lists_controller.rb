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
    # Get the list in question
    @cross_selling_list = CrossSellingList.includes(:children, :products, :cross_selling_list_products).find(params[:id])

    # Get all the suppliers for the current entity - this may be a Market Organization (with
    # potentially many suppliers) or a Supplier Organization (with only one - themselves)
    @suppliers = @entity.suppliers.includes(:products).order(:name)

    # Get all the categories for all the products for all the suppliers[ for this Market].  Damn, what a mess.
    @categories = @entity.categories.includes(:products).order(:name)

    # Creators need all products, both need the products on the list.
    # KXM Assert Product.visible for cross_selling_list_products
           @all_products = @cross_selling_list.creator ? @entity.supplier_products.visible.order(:name) : []
    @selected_list_prods = @cross_selling_list.cross_selling_list_products.includes(product: [:organization, :category])
      @selected_products = @cross_selling_list.products.includes(:cross_selling_list_products).order(:name)

    # Get the categories and suppliers for which all items are selected
    @selected_suppliers = []
    @suppliers.map do |s|
      @selected_suppliers.push(s.id) if s.products.any? && (s.products - @selected_products).empty?
    end

    @selected_categories = []
    @categories.map do |c|
      category_prods = c.products
      candidate = (category_prods - ( category_prods - @all_products )) - @selected_products
      @selected_categories.push(c.id) if candidate.empty?
    end
  end

  def new
    @cross_selling_list = @entity.cross_selling_lists.build
  end

  def create
    @cross_selling_list = @entity.cross_selling_lists.build(cross_selling_list_params)
    @cross_selling_list.creator = true

    if @cross_selling_list.save
      @cross_selling_list.manage_publication!(cross_selling_list_params)

      if @cross_selling_list.published? then
        selected_subscribers = cross_selling_list_params[:children_ids].select(&:present?).map { |submitted_id| {parent_id: @cross_selling_list.id, entity_id: submitted_id.to_i} }

        # This creates the child lists, but it'd be cool it rails automagically did so from the supplied array of children_ids
        selected_subscribers.each do |list_ids|
          create_list(@cross_selling_list, list_ids)
        end
      end

      redirect_to [:admin, @entity, @cross_selling_list], notice: "Successfully created #{@cross_selling_list.name}"
    else
      flash.now[:alert] = "Could not create list"
      render :new
    end
  end

  def update
    @cross_selling_list = CrossSellingList.includes(:children).find(params[:id])

    if @cross_selling_list.creator
      supplier_prods = []
      supplier_ids = (params[:suppliers] ||= []).map(&:to_i)
      # Get all suppliers in the selected set...
      suppliers = Organization.includes(:products).find(supplier_ids)
      suppliers.map do |s|
        # ...and pull out their products
        supplier_prods = supplier_prods | s.products.map{|p| p.id.to_s}
      end

      # Get all products that belong to the selected categories and are also part of this entities supply chain
      category_ids = (params[:categories] ||= []).map(&:to_i)
      supplier_ids = @entity.suppliers.map{|s| s.id}
      category_prods = Product.where(category_id: category_ids, organization_id: supplier_ids).map{|p| p.id.to_s}

      # Modify product_ids to include those implicitly selected via the Suppliers and Categories tabs.
      cross_selling_list_params["product_ids"] = (cross_selling_list_params["product_ids"] || []) | supplier_prods | category_prods
      params_with_defaults = cross_selling_list_params

    else
      # Subscribers ought not submit products at all... remove 'em just in case they do
      params_with_defaults = cross_selling_list_params.except(:product_ids)
    end

    if @cross_selling_list.update_attributes(params_with_defaults)
      @cross_selling_list.manage_publication!(params_with_defaults)

      # If this is the master list then upsert any children (including product list)
      if @cross_selling_list.creator && ( !@cross_selling_list.draft? || @cross_selling_list.children.any? )

        # This serves to update all child product lists
        submitted_products = {'product_ids' => cross_selling_list_params[:product_ids]}

        # If the edits are saved successfully then cascade through the related cross selling lists and products...
             all_subscribers = @cross_selling_list.children.map { |l| {parent_id: l.parent_id, entity_id: l.entity_id} }
        existing_subscribers = @cross_selling_list.children.active.map { |l| {parent_id: l.parent_id, entity_id: l.entity_id} }
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
    # This forces lazy caching, allow for the programatic modification of cross_selling_list_params (think product_ids array)
    @cross_selling_list_params ||= params.require(:cross_selling_list).permit(
      :name,
      :status,
      :published_date, # KXM published_date anticipates future publication (not yet implemented)
      :children_ids => [],
      :product_ids => [],
      :cross_selling_list_products_attributes => [:product_id, :active, :id]
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
      new_list.published_at = nil
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
