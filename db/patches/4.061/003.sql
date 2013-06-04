DELETE FROM phrases
WHERE tags  = 'payments';


INSERT INTO phrase_categories (pcat_id, name, sort_order)
VALUES (9, 'Financials', 9);



INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.061', '003', '50939609');


insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:overview_title','Overview','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:purchase_orders_title','Purchase Orders','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:receivables_title','Receivables','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:payables_title','Payables','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:payments_title','Review Payment History','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:systemwide_title','System Wide Payables/Receivables','payments','text');

insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:overview','This is a snapshot of all money currently owed to your organization and that you owe to other organizations.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:purchase_orders','These are unpaid orders from buyers who have the ability to purchase on credit. The orders have not been invoiced. Once an invoice has been sent, it moves to the Receivables tab.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:receivables','These are outstanding invoices that are current or overdue. You can re-issue overdue invoices from this tab, and record payments received off-line.  Once an invoice has been payed, the transaction moves to the Transaction Journal tab.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:payables','All money Local Orbit currently owes to Markets and sellers: Market fees, Sales Revenue (for self-managed markets that use LO\'s credit card or ACH services, and payments owed to sellers on markets where Local Orbit manages seller payments.)','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:payments','All completed payments to and from Local Orbit.  Download a csv file from the Payment History to import into your accounting system.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_admin:systemwide','All outstanding payments and receivables for all live markets, including outstanding Local Orbit\'s outstanding payments and receivables Local Orbit admin market.','payments','text');

	
	
	
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:overview_title','Overview','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:purchase_orders_title','Purchase Orders','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:receivables_title','Receivables','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:payables_title','Payables','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:payments_title','Review Payment History','payments','text');

insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:overview','This section is a snapshot of all money currently owed to your organization and that you owe to other organizations.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:purchase_orders','These are open orders from buyers who have the ability to purchase on credit. The orders have not been delivered or invoiced.  When you create invoices from this tab, they will move to the Receivables tab. (If your market is on Managed Payments Services Plan, you won\'t have the option to create invoices.)','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:receivables','These are outstanding invoices that are current or overdue. You can re-issue overdue invoices from this tab, and record payments received off-line.  Once an invoice has been paid, receivables become receipts and move to the Transaction Journal tab. (If your market is on Managed Payments Services Plan, you won\'t have the option to enter receipts.)','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:payables','All money your Market currently owes to sellers and Local Orbit.   You can make payments from this section. Please note: if you are signed up for the Automate Plan, Local Orbit will pay your sellers on all credit card and e-check orders.  You must pay your sellers on Purchase Orders. (If you are on a Managed Services Plan, you won\'t have the option to make payments.)','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_market:payments','All completed payments to and from your market.  You can download a csv file from the Payment History to import into your accounting system.','payments','text');
	
	
	
	
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:overview_title','Overview','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:purchase_orders_title','Purchase Orders','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:receivables_title','Receivables','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:payables_title','Payables','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:payments_title','Review Payment History','payments','text');

insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:overview','This is a snapshot of all money currently owed to your organization. (If you\'re allowed to purchase on your market and pay by Purchase Order, it will also show what you owe to other organizations.)','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:purchase_orders','These are open orders from buyers who have the ability to purchase on credit. The orders have not been delivered or invoiced.  Once an invoice has been sent, it moves to the Receivables tab.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:receivables','These are outstanding payments owed to you from your Market.  Once an invoice has been paid, receivables move to the Transaction Journal tab and become receipts.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:payables','All completed payments to and from your organization.  You can download a csv file from the Transaction Journal to import into your accounting system.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_seller:payments','A complete history of all payments you\'ve made.  You can download a csv file from the Payment History to import into your accounting system.','payments','text');


				
		
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_buyer:overview_title','Overview','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_buyer:purchase_orders_title','Purchase Orders','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_buyer:payables_title','Payables','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_buyer:payments_title','Review Payment History','payments','text');

insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_buyer:overview','This is a snapshot of all money you currently owed to your Market.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_buyer:purchase_orders','These are unpaid orders from buyers who have the ability to purchase on credit. The orders have not been invoiced. Once an invoice has been sent, it moves to the Receivables tab.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_buyer:payables','Make or view payments on this tab.','payments','text');
insert into phrases (pcat_id,label,default_value,tags,edit_type) values (9,'payments:is_buyer:payments','A complete history of all payments you\'ve made.  You can download a csv file from the Payment History to import into your accounting system.','payments','text');

