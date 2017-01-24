module Quickbooks
  class Invoice
    class << self
      def create_invoice (order, session, config)

        # Create buyer org if necessary
        if order.organization.qb_org_id.nil?
          retry_cnt = 0
          loop do
            begin
              org = order.organization
              result = Quickbooks::Customer.create_customer(org, session)
              org.qb_org_id = result.id
              org.save!(validate: false)
              failed = false
            rescue => e
              puts e
              failed = true
              retry_cnt = retry_cnt + 1
            end
            break if !failed || retry_cnt > 10
          end
        end

        invoice = Quickbooks::Model::Invoice.new
        invoice.customer_id = order.organization.qb_org_id
        invoice.txn_date = Date
        invoice.doc_number = config.prefix.empty? ? order.id : "#{config.prefix}-#{order.id}"

        order.items.each do |item|

          # Create items if necessary
          itm_result = nil
          if item.product.qb_item_id.nil?
            retry_cnt = 0
            loop do
              begin
                prd = item.product
                itm_result = Quickbooks::Item.create_item(prd, session, config)
                if !itm_result.nil?
                  prd.qb_item_id = itm_result.id
                  prd.skip_validation = true
                  prd.save!(validate: false)
                  failed = false
                end
              rescue => e
                puts e
                failed = true
                retry_cnt = retry_cnt + 1
              end
              break if !failed || retry_cnt > 10
            end
          end

          line_item = Quickbooks::Model::InvoiceLineItem.new
          line_item.amount = item.unit_price * item.quantity_delivered
          line_item.description = item.name
          line_item.detail_type = "SalesItemLineDetail"
          line_item.sales_item! do |detail|
            detail.unit_price = item.unit_price
            detail.quantity = item.quantity_delivered
            detail.item_id = item.product.qb_item_id # Item ID here
          end
          invoice.line_items << line_item
        end

        # Add shipping/service fee to line items
        if !order.delivery_fees.nil? && order.delivery_fees > 0
          line_item = Quickbooks::Model::InvoiceLineItem.new
          line_item.detail_type = "SalesItemLineDetail"
          line_item.description = "Delivery Fee"
          line_item.amount = order.delivery_fees

          line_item.sales_item! do |detail|
            detail.unit_price = order.delivery_fees
            detail.quantity = 1
            detail.item_id = config.delivery_fee_item_id # Item ID here
          end
          invoice.line_items << line_item
        end

        service = Quickbooks::Service::Invoice.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.create(invoice)
      end
    end
  end
end