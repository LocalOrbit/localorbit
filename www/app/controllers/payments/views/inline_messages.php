<?php


function get_inline_message($tab_name, $width=350) {
	if(lo3::is_admin()) {	
		switch(strtolower($tab_name)) {
			case 'overview':
				return core_ui::inline_message($width, "Overview", "This is a snapshot of all money currently owed to your organization and that you owe to other organizations.");
				break;
			case 'purchase_orders':			
				return core_ui::inline_message($width,"Purchase Orders", "These are unpaid orders from buyers who have the ability to purchase on credit. The orders have not been invoiced. Once an invoice has been sent, it moves to the Receivables tab.");
				break;
			case 'receivables':
				return core_ui::inline_message($width,"Receivables", "These are outstanding invoices that are current or overdue. You can re-issue overdue invoices from this tab, and record payments received off-line.  Once an invoice has been payed, the transaction moves to the Transaction Journal tab.");
				break;
			case 'payables':
				return core_ui::inline_message($width,"Payables", "All money Local Orbit currently owes to Markets and sellers: Market fees, Sales Revenue (for self-managed markets that use LO's credit card or ACH services, and payments owed to sellers on markets where Local Orbit manages seller payments.)");
				break;
			case 'payments':
				return core_ui::inline_message($width,"Review Payment History", "All completed payments to and from Local Orbit.  Download a csv file from the Payment History to import into your accounting system.");
				break;
			case 'systemwide':
				return core_ui::inline_message($width,"System Wide Payables/Receivables", "All outstanding payments and receivables for all live markets, including outstanding Local Orbit's outstanding payments and receivables Local Orbit admin market.");
				break;
		}
	} else if(lo3::is_market()) {	
		switch(strtolower($tab_name)) {
			case 'overview':
				return core_ui::inline_message($width, "Overview", "This section is a snapshot of all money currently owed to your organization and that you owe to other organizations.");
				break;
			case 'purchase_orders':			
				return core_ui::inline_message($width,"Purchase Orders", "These are open orders from buyers who have the ability to purchase on credit. The orders have not been delivered or invoiced.  When you create invoices from this tab, they will move to the Receivables tab. (If your market is on Managed Payments Services Plan, you won't have the option to create invoices.)");
				break;
			case 'receivables':
				return core_ui::inline_message($width,"Receivables", "These are outstanding invoices that are current or overdue. You can re-issue overdue invoices from this tab, and record payments received off-line.  Once an invoice has been paid, receivables become receipts and move to the Transaction Journal tab. (If your market is on Managed Payments Services Plan, you won't have the option to enter receipts.)");
				break;
			case 'payables':
				return core_ui::inline_message($width,"Payables", "All money your Market currently owes to sellers and Local Orbit.   You can make payments from this section. Please note: if you are signed up for the Automate Plan, Local Orbit will pay your sellers on all credit card and e-check orders.  You must pay your sellers on Purchase Orders. (If you are on a Managed Services Plan, you won't have the option to make payments.)");
				break;
			case 'payments':
				return core_ui::inline_message($width,"Review Payment History", "All completed payments to and from your market.  You can download a csv file from the Payment History to import into your accounting system.");
				break;
		}
	} else if(lo3::is_seller()) {	
		switch(strtolower($tab_name)) {
			case 'overview':
				return core_ui::inline_message($width, "Overview", "This is a snapshot of all money currently owed to your organization. (If you're allowed to purchase on your market and pay by Purchase Order, it will also show what you owe to other organizations.)");
				break;
			case 'purchase_orders':			
				return core_ui::inline_message($width,"Purchase Orders", "These are open orders from buyers who have the ability to purchase on credit. The orders have not been delivered or invoiced.  Once an invoice has been sent, it moves to the Receivables tab.");
				break;
			case 'receivables':
				return core_ui::inline_message($width,"Receivables", "These are outstanding payments owed to you from your Market.  Once an invoice has been paid, receivables move to the Transaction Journal tab and become receipts.");
				break;
			case 'systemwide':
				return core_ui::inline_message($width,"System Wide Payables/Receivables", "All completed payments to and from your organization.  You can download a csv file from the Transaction Journal to import into your accounting system.");
				break;
			case 'payments':
				return core_ui::inline_message($width,"Review Payment History", "A complete history of all payments you've made.  You can download a csv file from the Payment History to import into your accounting system.");
				break;
		}
	} else if(lo3::is_buyer()) {	
		switch(strtolower($tab_name)) {
			case 'overview':
				return core_ui::inline_message($width, "Overview", "This is a snapshot of all money you currently owed to your Market.");
				break;
			case 'purchase_orders':			
				return core_ui::inline_message($width,"Purchase Orders", "These are unpaid orders from buyers who have the ability to purchase on credit. The orders have not been invoiced. Once an invoice has been sent, it moves to the Receivables tab.");
				break;
			case 'payables':
				return core_ui::inline_message($width,"Payables", "Make or view payments on this tab.");
				break;
			case 'payments':
				return core_ui::inline_message($width,"Review Payment History", "A complete history of all payments you've made.  You can download a csv file from the Payment History to import into your accounting system.");
				break;
		}
	}
}

?>