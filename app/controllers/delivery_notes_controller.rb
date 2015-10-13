class DeliveryNotesController < ApplicationController

	before_action :find_cart

	def index
		# TODO decide if there is an indexed display, and if so where
		#@delivery_notes = @cart.delivery_notes.visible.alphabetical_by_supplier_org
	end

	def new
		@delivery_note = DeliveryNote.new(cart_id: find_cart)
	end

	def create
		@cart = Cart.find(find_cart)
		@buyer_org = current_organization
		#@delivery_note = @cart.delivery_notes.build(delivery_note_params)
		@delivery_note = DeliveryNote.build(delivery_note_params)
		if @delivery_note.save
			redirect_to cart_path(@cart) # hm
		else
			render :new
		end

	end

	def edit
	end

	def update
		if @delivery_note.update_attributes(delivery_note_params) # does that exist here
			redirect_to delivery_notes_path(@cart.id) # each cart has only one buyer org.
		else
			render :edit
		end
	end

	def destroy
		DeliveryNote.soft_delete(params[:id])
		redirect_to delivery_notes_path(@cart.id)
	end

	private

	def delivery_note_params
		params.require("delivery_note").permit(
      :supplier_org,
      :buyer_org,
      :note,
      :cart_id
    )
	end

	def find_cart
		@cart_id = current_cart.id # this exists, right?
	end

end