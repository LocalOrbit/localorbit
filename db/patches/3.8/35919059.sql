

-- create buyer payments
INSERT INTO payments
(
`from_org_id`,
`to_org_id`,
`amount`,
`payment_method_id`,
`ref_nbr`,
`admin_note`,
`is_imported`,
`creation_date`)
select org_id, 
	case lo_order.payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	amount_paid,
    payment_method_id,
payment_ref,
admin_notes, 
1 as is_imported,
GREATEST(DATE_ADD(order_date, INTERVAL domains.po_due_within_days day), last_status_date) as creation_date
	from lo_order 
	inner join domains on lo_order.domain_id = domains.domain_id
    inner join payment_methods on lo_order.payment_method = payment_methods.payment_method
	where ldstat_id != 1 and ldstat_id != 3 and ldstat_id != 6 and 
    (lbps_id = 2 or lbps_id = 4)
	and adjusted_total > 0;

-- create buyer invoices
INSERT INTO invoices
(
`due_date`,
`from_org_id`,
`to_org_id`,
`amount`,
`is_imported`,
`creation_date`)
select DATE_ADD(order_date, INTERVAL domains.po_due_within_days day), org_id, 
	case payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	adjusted_total, 1 as is_imported, order_date
	from lo_order 
	inner join domains on lo_order.domain_id = domains.domain_id
	where ldstat_id != 1 and ldstat_id != 3 and ldstat_id != 6 and 
    (lbps_id = 2 or lbps_id = 4 or lbps_id = 3)
	and adjusted_total > 0;

-- create buyer payables
INSERT INTO payables
(`domain_id`,
`payable_type_id`,
`parent_obj_id`,
`description`,
`from_org_id`,
`to_org_id`,
`amount`,
`invoice_id`,
`invoicable`,
`is_imported`,
`creation_date`)
select lo_order.domain_id, 1 as payable_type_id, lo_oid, org_id, 
	case payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	adjusted_total, (select invoice_id from invoices where lo_order.order_date = invoices.creation_date and invoices.is_imported != 0) as invoice_id, 1 as invoicable, 1 as is_imported,
    order_date
	from lo_order 
	inner join domains on lo_order.domain_id = domains.domain_id
	where ldstat_id != 1 and ldstat_id != 3 and ldstat_id != 6 
	and lbps_id != 5 and lbps_id != 6 
	and adjusted_total > 0;

-- create seller payments
select GREATEST(DATE_ADD(lo_fulfillment_order.order_date, INTERVAL domains.po_due_within_days day), lo_fulfillment_order.last_status_date) as creation_date, 
    lo_fulfillment_order.org_id, 
	case lo_order.payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	lo_fulfillment_order.adjusted_total* (100 - lo_order.fee_percen_hub)/100,
    payment_method_id,
payment_ref,
admin_notes, 1 as is_imported
	from lo_fulfillment_order 
	inner join domains on lo_fulfillment_order.domain_id = domains.domain_id
    left join lo_order_line_item on lo_fulfillment_order.lo_foid = lo_order_line_item.lo_foid
    left join lo_order on lo_order_line_item.lo_oid = lo_order.lo_oid
    inner join payment_methods on lo_order.payment_method = payment_methods.payment_method
    -- not cart or cancelled or contested
	where lo_fulfillment_order.ldstat_id != 1 and lo_fulfillment_order.ldstat_id != 3 and lo_fulfillment_order.ldstat_id != 6 
	-- buyer paid or partially paid
    and (lo_order.lbps_id = 2)
    -- seller paid
    and lo_fulfillment_order.lsps_id = 2
	and lo_fulfillment_order.adjusted_total > 0;

-- create seller invoices
select DATE_ADD(lo_fulfillment_order.order_date, INTERVAL domains.po_due_within_days day), 
    lo_fulfillment_order.org_id, 
	case lo_order.payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	lo_fulfillment_order.adjusted_total* (100 - lo_order.fee_percen_hub)/100, 1 as is_imported,
    2 as payable_type_id
	from lo_fulfillment_order 
	inner join domains on lo_fulfillment_order.domain_id = domains.domain_id
    left join lo_order_line_item on lo_fulfillment_order.lo_foid = lo_order_line_item.lo_foid
    left join lo_order on lo_order_line_item.lo_oid = lo_order.lo_oid
    -- not cart or cancelled or contested
	where lo_fulfillment_order.ldstat_id != 1 and lo_fulfillment_order.ldstat_id != 3 and lo_fulfillment_order.ldstat_id != 6
	-- buyer invoice issued or paid or partially paid
    and (lo_order.lbps_id = 2 or lo_order.lbps_id = 4 or lo_order.lbps_id = 3)
	and lo_fulfillment_order.adjusted_total > 0
	order by lo_order.lo_oid desc;

-- create seller payables
select lo_fulfillment_order.domain_id, 2 as payable_type_id, lo_fulfillment_order.lo_foid, lo_fulfillment_order.org_id, 
	case payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	lo_fulfillment_order.adjusted_total * (100 - lo_order.fee_percen_hub)/100, (lo_order.lbps_id = 2) as invoicable,
    lo_fulfillment_order.order_date, 1 as is_imported
	from lo_fulfillment_order 
	inner join domains on lo_fulfillment_order.domain_id = domains.domain_id
    left join lo_order_line_item on lo_fulfillment_order.lo_foid = lo_order_line_item.lo_foid
    left join lo_order on lo_order_line_item.lo_oid = lo_order.lo_oid
	where 
    lo_fulfillment_order.ldstat_id != 1 and lo_fulfillment_order.ldstat_id != 3 and lo_fulfillment_order.ldstat_id != 6 
    and (lo_order.lbps_id = 2 or lo_order.lbps_id = 4 or lo_order.lbps_id = 3)
    and lo_fulfillment_order.adjusted_total > 0 limit 3000;
    
    
    
alter table domains add feature_paymentsportal_enable tinyint default 0;
alter table domains add feature_paymentsportal_bankaccounts tinyint default 0;
alter table domains add payment_default_ach tinyint default 0;
alter table domains add payment_allow_ach tinyint default 0;
alter table organizations add payment_allow_ach tinyint default 0;