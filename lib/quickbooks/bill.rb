module Quickbooks
  class Bill
    class << self
      def create_bill (order, session, config)

        # Create buyer org if necessary
        if order.organization.qb_org_id.nil?
          retry_cnt = 0
          loop do
            begin
              org = order.organization
              result = Quickbooks::Vendor.create_vendor(org, session)
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

        bill = Quickbooks::Model::Bill.new
        bill.vendor_id = order.organization.qb_org_id
        bill.txn_date = Date
        bill.doc_number = order.order_number

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

          if item.delivery_status == 'delivered'
            line_item = Quickbooks::Model::BillLineItem.new
            line_item.amount = item.unit_price * item.quantity
            line_item.description = item.name
            line_item.sales_item! do |detail|
              detail.unit_price = item.unit_price
              detail.quantity = item.quantity
              detail.item_id = order.item.qb_item_id # Item ID here
            end
            bill.line_items << line_item
          end
        end

        service = Quickbooks::Service::Bill.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        created_invoice = service.create(bill)
      end
    end
  end
end