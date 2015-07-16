class PdfViewController < ActionController::Base
  
  def header
    market = header_params[:market]
    invoice = header_params[:invoice]
    render "header", locals: header_params
  end

  def footer
    render "footer"
  end

  def header_params
    params.permit(
      :logo_stored,
      :thumb_url,
      :name,
      :has_address,
      :street_address,
      :city_state_zip,
      :display_contact_phone,
      :contact_email,
      :billing_organization_name,
      :billing_address,
      :billing_city,
      :billing_state,
      :billing_zip,
      :order_number,
      :delivery_date,
      :delivery_date_present,
      :payment_note,
      :due_date,
      :date,
      :page,
      :topage
    )
  end
end