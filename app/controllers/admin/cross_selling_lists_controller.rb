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
    submitted_products = {'product_ids' => cross_selling_list_params[:product_ids] || []}


    if @cross_selling_list.save
      @cross_selling_list.manage_publication!(cross_selling_list_params)

      if @cross_selling_list.published? || @cross_selling_list.draft? then
        selected_subscribers = cross_selling_list_params[:children_ids].select(&:present?).map { |submitted_id| {parent_id: @cross_selling_list.id, entity_id: submitted_id.to_i} }

        if @cross_selling_list.published? then
          # Published lists should propogate completely
          selected_subscribers.each do |list_ids|
            create_list(@cross_selling_list, list_ids, submitted_products)
          end
        end

        if @cross_selling_list.draft? then
          # Draft lists should only create the child lists.  List items will be added once the list is published
          selected_subscribers.each do |list_ids|
            create_list(@cross_selling_list, list_ids, {})
          end
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

  def create_list(parent, id_hash, params)
    target = parent.children.where("parent_id = ? AND entity_id = ?", id_hash[:parent_id], id_hash[:entity_id]).first
    if target.blank?
      new_list = parent.dup
      new_list.entity_id = id_hash[:entity_id]
      new_list.entity_type = "Market"
      new_list.creator = false
      new_list.status = parent.status == "Draft" ? "Draft" : "Pending"
      new_list.published_at = nil
      new_list.parent_id = id_hash[:parent_id]
      new_list.save
      new_list.update_attributes(params)
      MarketMailer.delay.cross_selling_list(parent.entity, new_list) if new_list.status == "Pending"
    else
      target.update_attribute(:deleted_at, nil)
      target.manage_status(parent.status)
      target.update_attributes(params)
      MarketMailer.delay.cross_selling_list(parent.entity, new_list) if new_list.status == "Pending"
    end
  end

  def update_list(parent, id_hash, params)
    target = get_child(parent, id_hash)
    starting_status = target.status

    target.update_attribute(:name, parent.name) if target.pending?
    target.manage_status(parent.status)
    target.manage_dates(status)
    target.update_attributes(params)

    MarketMailer.delay.cross_selling_list(parent.entity, target) if target.status == "Pending" && starting_status == "Draft"
  end

  def delete_list(parent, id_hash, params)
    target = get_child(parent, id_hash)
    target.manage_status("Inactive") # This triggers 'Revoked' on target
    target.manage_dates(status)
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

  def manage_selected_products(params, scoped_products)
    # fetch the submitted ids
    submitted_supplier_prods = get_prods_from_suppliers(params.fetch(:suppliers, []))
    submitted_category_prods = get_prods_from_categories(params.fetch(:categories, []).map(&:to_i), scoped_products)

    # fetch the ids of those previously selected
    selected_supplier_prods  = get_prods_from_suppliers(params.fetch(:selected_suppliers, []))
    selected_category_prods  = get_prods_from_categories(params.fetch(:selected_categories, []), scoped_products)

    selected_prods = (cross_selling_list_params["product_ids"] || [])
    # binding.pry

    # Modify based on submitted vs pre-selected suppliers
    to_add = (submitted_supplier_prods - selected_supplier_prods) + (submitted_category_prods - selected_category_prods)
    remove = (selected_supplier_prods - submitted_supplier_prods) + (selected_category_prods - submitted_category_prods)

    (selected_prods |= to_add) - remove
  end

  def manage_active_products(params, cross_selling_list_products)
    submitted_supplier_prods = get_prods_from_suppliers(params.fetch(:suppliers, []))
    selected_supplier_prods  = get_prods_from_suppliers(params.fetch(:selected_suppliers, []))

    submitted_category_prods = get_prods_from_categories(params.fetch(:categories, []).map(&:to_i), cross_selling_list_products)
    selected_category_prods  = get_prods_from_categories(params.fetch(:selected_categories, []), cross_selling_list_products)

    make_active = (submitted_supplier_prods - selected_supplier_prods) | (submitted_category_prods - selected_category_prods)
    deactivate  = (selected_supplier_prods - submitted_supplier_prods) | (selected_category_prods - submitted_category_prods)

    cross_selling_list_prods = (cross_selling_list_params["cross_selling_list_products_attributes"] || [])

    # Update "active" where appropriate
    cross_selling_list_prods.each do |key, value|
      value["active"] = "1" if make_active.include?(value["product_id"])
      value["active"] = "0" if deactivate.include?(value["product_id"])
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

  def get_prods_from_categories(category_id_array, scoped_products)
    category_prods = Product.visible.where(category_id: category_id_array.map(&:to_i), id: scoped_products).map{|p| p.id.to_s}
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