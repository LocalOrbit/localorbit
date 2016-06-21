class CreateRoleActionsTable < ActiveRecord::Migration
  def change
    create_table :role_actions do |t|
      t.string :description
      t.string :org_types, array: true, using: 'gin', default: '{}'
      t.string :section
      t.string :action
      t.string :plan_ids, array: true, using: 'gin', default: '{}'
    end
  end

  def data
    RoleAction.create("description"=>"Dashboard:Index", "org_types"=>["A", "M", "B", "S"], "section"=>"dashboard", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market:Index", "org_types"=>["A", "M"], "section"=>"market", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Organization:Index", "org_types"=>["A", "M"], "section"=>"organization", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"User:Index", "org_types"=>["A", "M"], "section"=>"user", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Role:Index", "org_types"=>["A"], "section"=>"role", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Unit:Index", "org_types"=>["A"], "section"=>"unit", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Event:Index", "org_types"=>["A"], "section"=>"event", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Taxonomy:Index", "org_types"=>["A"], "section"=>"taxonomy", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Internal_Financial:Index", "org_types"=>["A"], "section"=>"internal_financial", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Financial:Index", "org_types"=>["A", "M", "B", "S"], "section"=>"financial", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Order:Index", "org_types"=>["A", "M", "S"], "section"=>"order", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Template:Index", "org_types"=>["A", "M"], "section"=>"template", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Delivery:Index", "org_types"=>["A", "M", "S"], "section"=>"delivery", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Order_Item:Index", "org_types"=>["A", "M", "S"], "section"=>"order_item", "action"=>"index", "plan_ids"=>["1", "2", "3", "8"])
    RoleAction.create("description"=>"Delivery_Schedule:Index", "org_types"=>["A", "M", "S"], "section"=>"delivery_schedule", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Product:Index", "org_types"=>["M", "S"], "section"=>"product", "action"=>"index", "plan_ids"=>["1", "2", "3", "8"])
    RoleAction.create("description"=>"Fresh_Sheet:Index", "org_types"=>["A", "M"], "section"=>"fresh_sheet", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Newsletter:Index", "org_types"=>["A", "M"], "section"=>"newsletter", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Promotion:Index", "org_types"=>["A", "M"], "section"=>"promotion", "action"=>"index", "plan_ids"=>["2", "3"])
    RoleAction.create("description"=>"Discount_Code:Index", "org_types"=>["A", "M"], "section"=>"discount_code", "action"=>"index", "plan_ids"=>["2", "3"])
    RoleAction.create("description"=>"Sent_Email:Index", "org_types"=>["A"], "section"=>"sent_email", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Email_Test:Index", "org_types"=>["A"], "section"=>"email_test", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Report:Index", "org_types"=>["A", "M", "B", "S"], "section"=>"report", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Referral:Index", "org_types"=>["A"], "section"=>"referral", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Metric:Index", "org_types"=>["A"], "section"=>"metric", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Purchase_History:Index", "org_types"=>["B"], "section"=>"purchase_history", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"All_Supplier:Index", "org_types"=>["A", "M", "B", "S"], "section"=>"all_supplier", "action"=>"index", "plan_ids"=>["1", "2", "3", "4"])
    RoleAction.create("description"=>"Market_Profile:Index", "org_types"=>["A", "M"], "section"=>"market_profile", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market_Manager:Index", "org_types"=>["A", "M"], "section"=>"market_manager", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market_Address:Index", "org_types"=>["A", "M"], "section"=>"market_address", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market_Deliveries:Index", "org_types"=>["A", "M"], "section"=>"market_deliveries", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market_Payment_Methods:Index", "org_types"=>["A", "M"], "section"=>"market_payment_methods", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market_Deposit_Accounts:Index", "org_types"=>["A", "M"], "section"=>"market_deposit_accounts", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market_Fees:Index", "org_types"=>["A", "M"], "section"=>"market_fees", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market_Custom_Branding:Index", "org_types"=>["A", "M"], "section"=>"market_custom_branding", "action"=>"index", "plan_ids"=>["2", "3", "4"])
    RoleAction.create("description"=>"Market_Cross_Selling:Index", "org_types"=>["A", "M"], "section"=>"market_cross_selling", "action"=>"index", "plan_ids"=>["2", "3", "4"])
    RoleAction.create("description"=>"Financial_Overview:index", "org_types"=>["M", "B", "S"], "section"=>"financial_overview", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Send_Invoices:Index", "org_types"=>["A", "M"], "section"=>"send_invoices", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Enter_Receipts:Index", "org_types"=>["A", "M"], "section"=>"enter_receipts", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Record_Payments:Index", "org_types"=>["A", "M"], "section"=>"record_payments", "action"=>"index", "plan_ids"=>["1", "2", "3", "4"])
    RoleAction.create("description"=>"Payment_History:Index", "org_types"=>["A", "M", "B", "S"], "section"=>"payment_history", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Review_Invoices:Index", "org_types"=>["B"], "section"=>"review_invoices", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Organization_Cross_Selling:Index", "org_types"=>["S"], "section"=>"organization_cross_selling", "action"=>"index", "plan_ids"=>["2", "3", "4"])
    RoleAction.create("description"=>"Market_Stripe:Index", "org_types"=>["A", "M"], "section"=>"market_stripe", "action"=>"index", "plan_ids"=>["1", "2", "3", "4", "8"])
    RoleAction.create("description"=>"Market_Fees:Index", "org_types"=>["A", "M"], "section"=>"market_fees", "action"=>"index", "plan_ids"=>["2", "3", "4"])
    RoleAction.create("description"=>"Advanced_Inventory:Index", "org_types"=>["A", "M"], "section"=>"advanced_inventory", "action"=>"index", "plan_ids"=>["2", "3", "4"])
    RoleAction.create("description"=>"Advanced_Pricing:Index", "org_types"=>["A", "M"], "section"=>"advanced_pricing", "action"=>"index", "plan_ids"=>["2", "3", "4"])
  end
end
