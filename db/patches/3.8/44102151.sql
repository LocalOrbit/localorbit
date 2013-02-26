
drop view  if exists v_payables;

CREATE VIEW v_payables AS 
select p.payable_id,p.amount as payable_amount,p.creation_date,p.parent_obj_id,
(p.invoice_id is not null) as is_invoiced,
p.invoicable,
d.name as domain_name,
p.from_org_id,
o1.name as from_org_name,
p.to_org_id,
o2.name as to_org_name,
from_org_domains.domain_id as from_domain_id,
from_org_domains.name as from_domain_name,
to_org_domains.domain_id as to_domain_id,
to_org_domains.name as to_domain_name,
order_domains.domain_id as order_domain_id,
order_domains.name as order_domain_name,
fulfillment_order_domains.domain_id as fulfillment_order_domain_id,
fulfillment_order_domains.name as fulfillment_order_domain_name,
pt.payable_type,
lo.lo3_order_nbr as buyer_order_identifier,
lfo.lo3_order_nbr as seller_order_identifier,
p.description,
concat_ws('|',p.description,pt.payable_type,p.parent_obj_id) as payable_info,

COALESCE((
select sum(xip.amount_paid) 
from x_invoices_payments xip
where xip.invoice_id=iv.invoice_id), 0.0
) as amount_paid,

COALESCE(
(select p.amount - sum(xip.amount_paid)
from x_invoices_payments xip
where xip.invoice_id=iv.invoice_id), p.amount
) as amount_due,

(
select UNIX_TIMESTAMP(max(send_date)) from invoice_send_dates
where invoice_send_dates.invoice_id = p.invoice_id
) as last_sent

from payables p

inner join domains d on p.domain_id=d.domain_id
inner join organizations o1 on p.from_org_id=o1.org_id
inner join organizations o2 on p.to_org_id=o2.org_id
inner join payable_types pt on pt.payable_type_id = p.payable_type_id

left join invoices iv on iv.invoice_id=p.invoice_id
left join lo_order lo on p.parent_obj_id=lo.lo_oid
left join lo_fulfillment_order lfo on p.parent_obj_id=lfo.lo_foid
left join organizations_to_domains from_otd on p.from_org_id = from_otd.org_id and from_otd.is_home = 1
left join organizations_to_domains to_otd on p.to_org_id = to_otd.org_id and to_otd.is_home = 1
left join domains order_domains on lo.domain_id = order_domains.domain_id
left join domains fulfillment_order_domains on lfo.domain_id = fulfillment_order_domains.domain_id
left join domains from_org_domains on from_otd.domain_id = from_org_domains.domain_id
left join domains to_org_domains on to_otd.domain_id = to_org_domains.domain_id;
	
select * from v_payables;