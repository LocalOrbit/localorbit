INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('022', '');

drop view  if exists v_invoices;

CREATE VIEW v_invoices AS 
	select iv.invoice_id,
	iv.due_date,
	iv.amount,
	iv.creation_date,
 	CASE WHEN DATEDIFF(NOW(),iv.due_date) < 0
	THEN 'Current' 
	ELSE DATEDIFF(NOW(),iv.due_date) 
	END AS aging,
	iv.from_org_id,
	o1.name as from_org_name,
	iv.to_org_id,
	o2.name as to_org_name,
	from_org_domains.domain_id as from_domain_id,
	from_org_domains.name as from_domain_name,
	to_org_domains.domain_id as to_domain_id,
	to_org_domains.name as to_domain_name,
	
	(
		select if(sum(xip.amount_paid) is null,0,sum(xip.amount_paid))
		from x_invoices_payments xip
		where xip.invoice_id=iv.invoice_id
	) as amount_paid,
	
	
	iv.amount - (
		select if(sum(xip.amount_paid) is null,0,sum(xip.amount_paid))
		from x_invoices_payments xip
		where xip.invoice_id=iv.invoice_id
	)  as amount_due,
	
	(
		select GROUP_CONCAT(UNIX_TIMESTAMP(isd.send_date)  ORDER BY isd.send_date desc SEPARATOR ',')
		from invoice_send_dates isd
		where isd.invoice_id=iv.invoice_id
	) as send_dates,
	
	(
		select group_concat(concat_ws('|',p.description,pt.payable_type,p.parent_obj_id) SEPARATOR '$$')
		from payables p 
		inner join payable_types pt on pt.payable_type_id=p.payable_type_id
		where p.invoice_id=iv.invoice_id
	
	) as payable_info
	
	from invoices iv
	
	inner join organizations o1 on iv.from_org_id=o1.org_id
	inner join organizations o2 on iv.to_org_id=o2.org_id
    left join organizations_to_domains from_otd on iv.from_org_id = from_otd.org_id and from_otd.is_home = 1
    left join organizations_to_domains to_otd on iv.to_org_id = to_otd.org_id and to_otd.is_home = 1
    left join domains from_org_domains on from_otd.domain_id = from_org_domains.domain_id
    left join domains to_org_domains on to_otd.domain_id = to_org_domains.domain_id;
