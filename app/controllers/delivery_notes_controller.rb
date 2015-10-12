class DeliveryNotesController < ApplicationController

	before_action :find_cart # what is this

	def index
		#@delivery_notes = @cart.delivery_notes.visible.alphabetical_by_supplier_org
	end

	def new
		@delivery_note = DeliveryNote.new(cart_id: @cart.id)
	end

	def create
		@delivery_note = @cart.delivery_notes.build(delivery_note_params)

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
	end

	def find_cart
	end

end