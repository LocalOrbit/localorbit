class OrderSerializer < ActiveModel::Serializer
	attributes :order_number, 
						 :organization_id, 
						 :market_id, 
						 :delivery_id, 
						 :placed_at, 
						 :invoiced_at, 
						 :invoice_due_date, 
						 :delivery_fees, 
						 :total_cost, 
						 :delivery_contact,
						 :billing_contact,
						 :payment_info,
						 :notes,
						 :created_at,
						 :updated_at,
						 :placed_by_id,
						 :paid_at,
						 :legacy_id,
						 :deleted_at,
						 :discount_id,
						 :delivery_status,
						 :invoice_pdf_uid,
						 :invoice_pdf_name
end

# Helper methods

def delivery_contact
	{delivery_address:object.delivery_address, 
	delivery_city: object.delivery_city,
	delivery_state:object.delivery_state,
	delivery_zip:object.delivery_zip,
	delivery_phone:object.delivery_phone}
end

def billing_contact
	{billing_organization_name:object.billing_organization_name,
		billing_address:object.billing_address,
		billing_city:object.billing_city,
		billing_state:object.billing_state,
		billing_zip:object.billing_zip,
		billing_phone:object.billing_phone}
end

def payment_info
	{payment_status:object.payment_status, payment_method:object.payment_method, payment_provider:object.payment_provider}
end

