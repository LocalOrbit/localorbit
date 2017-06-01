module Quickbooks
  class JournalEntry
    class << self
      def create_journal_entry (order, session, config)

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

        jentry = Quickbooks::Model::JournalEntry.new
        jentry.doc_number = order.id
        jentry.txn_date = order.items.map(&:delivered_at).max.strftime("%m/%d/%Y")


        # Sales Order

        ar_acct = Quickbooks::Model::BaseReference.new
        ar_acct.name = config.ar_account_name
        ar_acct.value = config.ar_account_id

        customer = Quickbooks::Model::BaseReference.new
        customer.value = order.organization.qb_org_id.to_s

        entity = Quickbooks::Model::Entity.new
        entity.type = 'Customer'
        entity.entity_ref = customer

        jentry_so = Quickbooks::Model::Line.new
        jentry_so.amount = order.total_cost
        jentry_so.description = order.id

        puts "SO: #{jentry_so.amount}"

        jentry_so.journal_entry! do |entry|
          entry.posting_type = 'Credit'
          entry.entity = entity
          entry.account_ref = ar_acct
        end

        jentry.line_items << jentry_so

        # Purchase Orders

        ap_acct = Quickbooks::Model::BaseReference.new
        ap_acct.name = config.ap_account_name
        ap_acct.value = config.ap_account_id

        profit_sum = 0
        po_orders = Inventory::Utils.get_supplier_net(order)
        po_orders.each do |po|
          o = Order.find(po.order_id)
          profit_sum = profit_sum + po.profit

          result = nil
          if o.products.first.organization.qb_org_id.nil?
            retry_cnt = 0
            loop do
              begin
                org = o.products.first.organization
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

          vendor = Quickbooks::Model::BaseReference.new
          vendor.value = result.nil? ? o.products.first.organization.qb_org_id.to_s : result.id.to_s

          entity = Quickbooks::Model::Entity.new
          entity.type = 'Vendor'
          entity.entity_ref = vendor

          jentry_po = Quickbooks::Model::Line.new
          jentry_po.amount = po.amt
          jentry_po.description = po.order_id

          puts "PO: #{jentry_po.amount}"

          jentry_po.journal_entry! do |entry|
            entry.posting_type = 'Debit'
            entry.entity = entity
            entry.account_ref = ap_acct
          end
          jentry.line_items << jentry_po

        end

        # Market Fees

        income_acct = Quickbooks::Model::BaseReference.new
        income_acct.name = config.fee_income_account_name
        income_acct.value = config.fee_income_account_id

        jentry_income = Quickbooks::Model::Line.new
        jentry_income.amount = profit_sum
        jentry_income.description = order.id

        puts "Income: #{jentry_income.amount}"

        jentry_income.journal_entry! do |entry|
          entry.posting_type = 'Debit'
          entry.account_ref = income_acct
        end

        jentry.line_items << jentry_income

        # Shipping

        dlvy_acct = Quickbooks::Model::BaseReference.new
        dlvy_acct.name = config.delivery_fee_account_name
        dlvy_acct.value = config.delivery_fee_account_id

        jentry_dlvy = Quickbooks::Model::Line.new
        jentry_dlvy.amount = order.delivery_fees
        jentry_dlvy.description = order.id

        puts "Delivery: #{jentry_dlvy.amount}"

        jentry_dlvy.journal_entry! do |entry|
          entry.posting_type = 'Debit'
          entry.account_ref = dlvy_acct
        end

        jentry.line_items << jentry_dlvy

        service = Quickbooks::Service::JournalEntry.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        service.create(jentry)
      end
    end
  end
end