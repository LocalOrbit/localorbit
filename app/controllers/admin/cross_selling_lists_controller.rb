class Admin::CrossSellingListsController < AdminController
  # This coordinates the association of entity and cross sell list
  # The before_action method defines @entity, seen in use below...
  include CrossSellingListEntity

  before_action :require_self_enabled_cross_selling, except: :index

  def index
    @cross_selling_lists = @entity.cross_selling_lists.creator.order(:name)
  end

  def subscriptions
    # This processing path will be very similar to, but different from index
    @cross_selling_subscriptions = @entity.cross_selling_lists.subscriptions.order(:name)
  end

  def show
    # Get the list in question
    @cross_selling_list = CrossSellingList.includes(:children, :products, :cross_selling_list_products).find(params[:id])

    @scoped_products = get_scoped_products(@cross_selling_list, @entity)
    @selected_products = @cross_selling_list.products.active.includes(:cross_selling_list_products).order(:name)

    @suppliers = Organization.for_products(@scoped_products).includes(:products).order(:name)
    @selected_suppliers = get_selected_suppliers(@suppliers, @selected_products, @scoped_products)

    @categories = build_category_array(@scoped_products)
    @selected_categories = get_selected_categories(@categories, @selected_products, @cross_selling_list.creator, @scoped_products)

    # Since adding 'distinct' to get_scoped_products, ordering in the original definition of scoped_products (above) was
    # borking things up when also ordering by supplier or category name.  Avoid the problem by ordering products here
    @scoped_products = @scoped_products.order(:name)

    @selected_list_prods = @cross_selling_list.cross_selling_list_products.includes(product: [:organization, :category]).order("products.name")
  end

  def new
    @cross_selling_list = @entity.cross_selling_lists.build
  end

  def create
    @cross_selling_list = @entity.cross_selling_lists.build(cross_selling_list_params)
    @cross_selling_list.creator = true


    if @cross_selling_list.save
      @cross_selling_list.manage_publication!(cross_selling_list_params)

      if @cross_selling_list.published? || @cross_selling_list.draft? then
        selected_subscribers = cross_selling_list_params.fetch(:children_ids, []).map { |submitted_id| {parent_id: @cross_selling_list.id, entity_id: submitted_id.to_i} }

        # Published lists should propogate completely while Draft lists should only create
        # the child lists, sans items.  List items will be added once the list is published
        submitted_products = @cross_selling_list.published? ? {'product_ids' => cross_selling_list_params.fetch(:product_ids, [])} : {}

        selected_subscribers.each do |list_ids|
          create_list(@cross_selling_list, list_ids, submitted_products)
        end
      end

      redirect_to [:admin, @entity, @cross_selling_list], notice: "Successfully created '#{@cross_selling_list.name}'"
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
      # Make active products implicitly selected via the Suppliers and Categories tabs
      cross_selling_list_params["cross_selling_list_products_attributes"] = manage_active_products(params, @scoped_products)
      # Subscribers ought not modify products at all save for marking them active or not... this removes the offending data
      params_with_defaults = cross_selling_list_params.except(:product_ids)
    end

    if @cross_selling_list.update_attributes(params_with_defaults)
      @cross_selling_list.manage_publication!(params_with_defaults)

      # Upsert children (if required)
      if @cross_selling_list.cascade_update? # Only possible for Publishers

        # This serves to update all child product lists
        submitted_products = {'product_ids' => cross_selling_list_params[:product_ids]}

        # If the edits are saved successfully then cascade through the related cross selling lists and products...
             all_subscribers = @cross_selling_list.children.map { |l| {parent_id: l.parent_id, entity_id: l.entity_id} }
        existing_subscribers = @cross_selling_list.children.active.map { |l| {parent_id: l.parent_id, entity_id: l.entity_id} }
        selected_subscribers = cross_selling_list_params.fetch(:children_ids, []).map { |submitted_id| {parent_id: @cross_selling_list.id, entity_id: submitted_id.to_i} }
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
      else
        # Subscribers
        update_list(@cross_selling_list)
      end

      redirect_to [:admin, @entity, @cross_selling_list], notice: "Sucessfully updated '#{@cross_selling_list.name}'"
    else
      flash.now.alert = "Could not update Cross Selling List"
      render :show
    end
  end

  def cross_selling_list_params
    # The "||=" below forces lazy caching, allow for the programatic modification of cross_selling_list_params
    @cross_selling_list_params ||= params.require(:cross_selling_list).permit(
      :name,
      :status,
      :published_date, # ToDo published_date attribute anticipates future publication (not yet implemented)
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

  def create_list(parent_list, id_hash, params)
    subscriber_list = get_subscribing_list(parent_list, id_hash)
    if subscriber_list.blank?
      subscriber_list = parent_list.dup
      subscriber_list.entity_id = id_hash[:entity_id]
      subscriber_list.entity_type = "Market"
      subscriber_list.creator = false
      subscriber_list.status = parent_list.status == "Draft" ? "Draft" : "Pending"
      subscriber_list.published_at = nil
      subscriber_list.parent_id = id_hash[:parent_id]
      subscriber_list.save
      subscriber_list.update_attributes(params)
    else
      subscriber_list.update_attribute(:deleted_at, nil)
      subscriber_list.manage_status(parent_list.status)
      subscriber_list.update_attributes(params)
    end

    SendCrossSellMessages.perform({:publisher => parent_list.entity, :subscriber_list => subscriber_list})
  end

  def delete_list(parent_list, id_hash, params)
    subscriber_list = get_subscribing_list(parent_list, id_hash)
    subscriber_list.manage_status("Inactive") # This triggers 'Revoked' on subscriber_list
    subscriber_list.manage_dates(status)
    subscriber_list.update_attributes(params)
    subscriber_list.soft_delete

    SendCrossSellMessages.perform({:publisher => parent_list.entity, :subscriber_list => subscriber_list})
  end

  def update_list(cross_selling_list, id_hash = {}, params = {})
    if cross_selling_list.creator
      update_parent_list(cross_selling_list, id_hash, params)
    else
      update_subscribing_list(cross_selling_list)
    end
  end

  protected

  def update_parent_list(parent_list, id_hash, params)
    subscriber_list = get_subscribing_list(parent_list, id_hash)
    starting_status = subscriber_list.status

    # This updates the list
    subscriber_list.update_attribute(:name, parent_list.name) if subscriber_list.pending?
    subscriber_list.manage_status(parent_list.status)
    subscriber_list.manage_dates(status)

    # This updates the products
    subscriber_list.update_attributes(params)

    SendCrossSellMessages.perform({:publisher => parent_list.entity, :subscriber_list => subscriber_list, :starting_status => starting_status})
  end

  def update_subscribing_list(subscriber_list)
    SendCrossSellMessages.perform({:publisher => subscriber_list.parent.entity, :subscriber_list => subscriber_list})
  end

  def get_subscribing_list(parent_list, id_hash)
    parent_list.children.where("parent_id = ? AND entity_id = ?", id_hash[:parent_id], id_hash[:entity_id]).first
  end

  def get_scoped_products(cross_selling_list, entity)
    if cross_selling_list.creator then
      scoped_products = entity.supplier_products.visible.distinct.includes(:top_level_category, :second_level_category)
    else
      scoped_products = cross_selling_list.products.includes(:top_level_category, :second_level_category)
    end
    scoped_products
  end

  def manage_selected_products(params, scoped_products)
    # fetch the submitted ids
    submitted_supplier_prods = get_prods_from_suppliers(params.fetch(:suppliers, []))
    submitted_category_prods = get_prods_from_categories(params.fetch(:categories, []), scoped_products)

    # fetch the ids of those previously selected
    selected_supplier_prods  = get_prods_from_suppliers(params.fetch(:selected_suppliers, []))
    selected_category_prods  = get_prods_from_categories(params.fetch(:selected_categories, []), scoped_products)

    selected_prods = (cross_selling_list_params["product_ids"] || [])

    # Modify based on submitted vs pre-selected suppliers
    to_add = (submitted_supplier_prods - selected_supplier_prods) + (submitted_category_prods - selected_category_prods)
    remove = (selected_supplier_prods - submitted_supplier_prods) + (selected_category_prods - submitted_category_prods)

    (selected_prods |= to_add) - remove
  end

  def manage_active_products(params, cross_selling_list_products)
    submitted_supplier_prods = get_prods_from_suppliers(params.fetch(:suppliers, []))
    submitted_category_prods = get_prods_from_categories(params.fetch(:categories, []), cross_selling_list_products)

    selected_supplier_prods  = get_prods_from_suppliers(params.fetch(:selected_suppliers, []))
    selected_category_prods  = get_prods_from_categories(params.fetch(:selected_categories, []), cross_selling_list_products)

    make_active = (submitted_supplier_prods - selected_supplier_prods) | (submitted_category_prods - selected_category_prods)
    deactivate  = (selected_supplier_prods - submitted_supplier_prods) | (selected_category_prods - submitted_category_prods)

    cross_selling_list_prods = (cross_selling_list_params["cross_selling_list_products_attributes"] || [])

    # Update "active" where appropriate
    cross_selling_list_prods.each do |key, cslp|
      # due to structural anomolies, 'key' is invoked but disregarded
      cslp["active"] = "1" if make_active.include?(cslp["product_id"])
      cslp["active"] = "0" if deactivate.include?(cslp["product_id"])
    end

    cross_selling_list_prods
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

  def get_prods_from_categories(category_ids, scoped_products)
    category_prods = []
    # The overlap between top-level and second level is making this a nightmare.
    # I'm disabling the static processing of top and implementing some 'select all
    # subcategories' JavaScript instead...
    top = []
    second = category_ids.to_h.fetch("second", []).map{|c| c.to_i}

    scoped_products.each do |p|
      category_prods.push(p.id.to_s) if (top.include?(p.top_level_category_id) || second.include?(p.second_level_category_id))
    end

    category_prods
  end

  def get_selected_suppliers(suppliers, selected_products, scoped_products)
    selected_suppliers = []
    suppliers.each do |s|
      supplier_products = scoped_products.where("products.organization_id = ?", s)
      selected_suppliers.push(s.id) if supplier_products.any? && (supplier_products - selected_products).empty?
    end

    selected_suppliers || []
  end

  def get_selected_categories(categories, selected_products, creator, scoped_products)
    selected_categories = {}
    category_prods = []


    categories.each do |c|
      case c.get_level
      when 'top'
        category_prods = scoped_products.select{|p| p.top_level_category_id == c.id}
      when 'second'
        category_prods = scoped_products.select{|p| p.second_level_category_id == c.id}
      end

      if creator then
        candidate = (category_prods - ( category_prods - scoped_products )) - selected_products
      else
        candidate = (category_prods - selected_products)
      end

      selected_categories[c.get_level] = [] if selected_categories.fetch(c.get_level, nil).nil?
      selected_categories[c.get_level].push(c.id) if candidate.empty?
    end

    selected_categories.to_a
  end

  def build_category_array(scoped_products)
    # First get the top-level categories - this provides the structure
    categories = scoped_products.map{|p| p.top_level_category}.sort_by{|c| c[:name]}.uniq{|x| x.id}
    second_categories = scoped_products.map{|p| p.second_level_category}.sort_by{|c| c[:name]}.uniq{|x| x.id}

    # Then cycle through the second categories...
    second_categories.reverse.each do |second|
      # ...grabbing the parent index...
      parent_index = categories.index(categories.select{|c| c[:id] == second.parent_id}.first)

      # ... and slipping it in right behind
      categories.insert(parent_index+1, second) unless  parent_index.nil?
    end
    categories
  end

end
