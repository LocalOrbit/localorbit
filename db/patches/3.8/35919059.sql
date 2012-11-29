-- create buyer payables
select lo_order.domain_id, 1, lo_oid, org_id, 
	case payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	adjusted_total, 1 as invoicable,
    order_date
	from lo_order 
	inner join domains on lo_order.domain_id = domains.domain_id
	where ldstat_id != 1 and ldstat_id != 3 and ldstat_id != 6 and lbps_id != 5 and lbps_id != 6 
	and adjusted_total > 0
	order by lo_oid desc;

-- create buyer invoices
select DATE_ADD(order_date, INTERVAL domains.po_due_within_days day), org_id, 
	case payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	adjusted_total
	from lo_order 
	inner join domains on lo_order.domain_id = domains.domain_id
	where ldstat_id != 1 and ldstat_id != 3 and ldstat_id != 6 and 
    (lbps_id = 2 or lbps_id = 4 or lbps_id = 3)
	and adjusted_total > 0
	order by lo_oid desc;
/*
update payables, invoices set payables.invoice_id = invoices.invoice_id where 
payables.from_org_id = invoices.from_org_id and 
payables.to_org_id = invoices.to_org_id and 
payables.amount = invoices.amount;
*/

-- create buyer payments
select GREATEST(DATE_ADD(order_date, INTERVAL domains.po_due_within_days day), last_status_date) as creation_date, org_id, 
	case lo_order.payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	amount_paid,
    payment_method_id,
payment_ref,
admin_notes
	from lo_order 
	inner join domains on lo_order.domain_id = domains.domain_id
    inner join payment_methods on lo_order.payment_method = payment_methods.payment_method
	where ldstat_id != 1 and ldstat_id != 3 and ldstat_id != 6 and 
    (lbps_id = 2 or lbps_id = 4)
	and adjusted_total > 0
	order by lo_oid desc;
/*
INSERT INTO `localorb_www_dev`.`payments`
(`payment_id`,
`from_org_id`,
`to_org_id`,
`amount`,
`payment_method_id`,
`ref_nbr`,
`admin_note`,
`creation_date`)
VALUES
(
<{payment_id: }>,
<{from_org_id: }>,
<{to_org_id: }>,
<{amount: }>,
<{payment_method_id: }>,
<{ref_nbr: }>,
<{admin_note: }>,
<{creation_date: CURRENT_TIMESTAMP}>
);
*/
-- create seller payables

-- create seller invoices

-- create seller payments

-- select * from domains;
/*
INSERT INTO `localorb_www_dev`.`payables`
(
`domain_id`,
`payable_type_id`,
`parent_obj_id`,
`description`,
`from_org_id`,
`to_org_id`,
`amount`,
`invoice_id`,
`invoicable`,
`creation_date`)
VALUES
(
<{payable_id: }>,
<{domain_id: }>,
<{payable_type_id: }>,
<{parent_obj_id: }>,
<{description: }>,
<{from_org_id: }>,
<{to_org_id: }>,
<{amount: }>,
<{invoice_id: }>,
<{invoicable: 0}>,
<{creation_date: CURRENT_TIMESTAMP}>
);
*/