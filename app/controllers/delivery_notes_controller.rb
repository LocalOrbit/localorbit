class DeliveryNotesController < ApplicationController

	before_action :find_cart

	def index
		# TODO decide if there is an indexed display, and if so where (at first no)
		#@delivery_notes = @cart.delivery_notes.visible.alphabetical_by_supplier_org
	end

	def new
		dn = DeliveryNote.where(cart_id:find_cart,supplier_org:params[:supplier])
		if dn.any?
			redirect_to edit_delivery_note_path(dn.first.id)
		end
	end

	def create
		@cart = Cart.find(find_cart)
		@buyer_org = current_organization

		@delivery_note = DeliveryNote.create(delivery_note_params)
		if @delivery_note.persisted?
			redirect_to "/cart" # cart path
		else
			render :new 
			# with error flash? This should never happen.
		end

	end

	def edit
		@delivery_note = DeliveryNote.find(params[:id])
	end

	def update
		@delivery_note = DeliveryNote.find(params[:id])
		if @delivery_note.update_attributes(note:params[:delivery_note][:note])
			redirect_to "/cart" # Each cart has only one buyer org. This is fine.
		# else 
		# 	redirect_to "/delivery_notes" # Should not happen.
		end
	end

	def destroy
		DeliveryNote.soft_delete(params[:id]) # TODO warning flash?
		redirect_to "/cart"
	end

	private

	def delivery_note_params
		params.require(:delivery_note).permit(:note,:supplier_org,:buyer_org,:cart_id)
	end

	def find_cart
		@cart_id = current_cart.id # this should exist in valid session for notes.
	end
end