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

    @scoped_products = get_scoped_products(@cross_selling_list, @entity)

    @selected_products = @cross_selling_list.products.active.includes(:cross_selling_list_products).order(:name)

    @suppliers = Organization.for_products(@scoped_products).includes(:products).order(:name)
    @selected_suppliers = get_selected_suppliers(@suppliers, @selected_products)

    @categories = Category.for_products(@scoped_products).includes(:products).order(:name)
    @selected_categories = get_selected_categories(@categories, @selected_products, @cross_selling_list.creator, @scoped_products)

    @selected_list_prods = @cross_selling_list.cross_selling_list_products.includes(product: [:organization, :category])

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

    @scoped_products = get_scoped_products(@cross_selling_list, @entity)

    # List creators may add items individually or en masse (via supplier or category check boxes)
    if @cross_selling_list.creator

      # Include product ids implicitly selected via the Suppliers and Categories tabs
      cross_selling_list_params["product_ids"] = manage_selected_products(params, @scoped_products)
      params_with_defaults = cross_selling_list_params

    else
      # Subscribers ought not modify products at all save for marking them active or not
      params_with_defaults = cross_selling_list_params.except(:product_ids)
    end

    if @cross_selling_list.update_attributes(params_with_defaults)
      @cross_selling_list.manage_publication!(params_with_defaults)

      # If this is the master list then upsert any children (including product list)
      if @cross_selling_list.cascade_update?

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

        # Add those that are selected_subscribers but don't yet exist
        (selected_subscribers - existing_subscribers).each do |list_ids|
          create_list(@cross_selling_list, list_ids, submitted_products)
        end

        # Update those that appear in both...
        overlap_subscribers.each do |list_ids|
          update_list(@cross_selling_list, list_ids, submitted_products)
        end

        # ...and those that were once existing - gotta keep 'em in line
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
    # The "||=" below forces lazy caching, allow for the programatic modification of cross_selling_list_params (think product_ids array)
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

  def get_scoped_products(cross_selling_list, entity)
    if cross_selling_list.creator then
      scoped_products = entity.supplier_products.visible.order(:name)
    else
      scoped_products = cross_selling_list.products
    end
  end


  ##
  # manage_selected_products
  # Compiles product list based on submitted products whether individually or via supplier or category
  # param params (Array) The post payload
  # param scoped_products (Array) The full set of available products
  # return (Array) product ids
  ##
  def manage_selected_products(params, scoped_products)
    # fetch the submitted ids
    submitted_supplier_prods = get_prods_from_suppliers(params.fetch(:suppliers, []))
    selected_supplier_prods  = get_prods_from_suppliers(params.fetch(:selected_suppliers, []))

    submitted_category_prods = get_prods_from_categories(params.fetch(:categories, []).map(&:to_i), scoped_products)
    selected_category_prods  = get_prods_from_categories(params.fetch(:selected_categories, []), scoped_products)

    # binding.pry
    selected_prods = (cross_selling_list_params["product_ids"] || [])

    # Modify based on submitted vs pre-selected suppliers
    selected_prods = selected_prods - (selected_supplier_prods - submitted_supplier_prods)
    selected_prods = selected_prods | (submitted_supplier_prods - selected_supplier_prods)

    # Modify based on submitted vs pre-selected categories
    selected_prods = selected_prods - (selected_category_prods - submitted_category_prods)
    selected_prods = selected_prods | (submitted_category_prods - selected_category_prods)

    # supplier_prods | category_prods | selected_prods
    selected_prods
  end

  def get_prods_from_suppliers(supplier_id_array)
    supplier_prods = []

    # Get all suppliers in the selected set...
    suppliers = Organization.includes(:products).find(supplier_id_array.map(&:to_i))
    suppliers.map do |s|
      # ...and pull out their visible products
      supplier_prods = supplier_prods | s.products.visible.map{|p| p.id.to_s}
    end

    supplier_prods
  end

  def get_prods_from_categories(category_id_array, scoped_products)
    category_prods = Product.visible.where(category_id: category_id_array.map(&:to_i), id: scoped_products).map{|p| p.id.to_s}
  end

  def get_selected_suppliers(suppliers, selected_products)
    selected_suppliers = []
    suppliers.each do |s|
      selected_suppliers.push(s.id) if s.products.visible.any? && (s.products.visible - selected_products).empty?
    end

    selected_suppliers || []
  end

  def get_selected_categories(categories, selected_products, creator, scoped_products)
    # KXM get_selected_categories seems to be working... confirm
    # binding.pry
    selected_categories = []
    categories.each do |c|
      category_prods = c.products
      if creator then
        candidate = (category_prods - ( category_prods - scoped_products )) - selected_products
      else
        candidate = (category_prods - selected_products)
      end

      selected_categories.push(c.id) if candidate.empty?
    end

    selected_categories || []
  end

end
