-- create buyer payables
select lo_order.domain_id, 1, lo_oid, org_id, 
	case payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	adjusted_total, 1 as invoicable
	from lo_order 
	inner join domains on lo_order.domain_id = domains.domain_id
	where ldstat_id != 1 and ldstat_id != 3 and ldstat_id != 6 and lbps_id != 5 and lbps_id != 6 
	and adjusted_total > 0
	order by lo_oid desc;

-- create buyer invoices
select lo_order.domain_id, 1, lo_oid, org_id, 
	case payment_method when 'purchaseorder' then domains.payable_org_id else 1 end as to_org_id,
	adjusted_total, 1 as invoicable
	from lo_order 
	inner join domains on lo_order.domain_id = domains.domain_id
	where ldstat_id != 1 and ldstat_id != 3 and ldstat_id != 6 and lbps_id != 5 and lbps_id != 6 
	and adjusted_total > 0
	order by lo_oid desc;

-- create buyer payments

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