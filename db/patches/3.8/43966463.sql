
drop view  if exists v_payments;

CREATE VIEW v_payments AS 
select pv.payment_id,pv.amount,pv.creation_date,pv.ref_nbr,
pm.payment_method,
if(pv.payment_method_id=1,((3/100) * pv.amount),if(pv.payment_method_id=3,0.30,0)) as transaction_fees,
(pv.amount - if(pv.payment_method_id=1,((3/100) * pv.amount),if(pv.payment_method_id=3,0.30,0))) as net_amount,
pv.from_org_id,
o1.name as from_org_name,
pv.to_org_id,
o2.name as to_org_name,
from_org_domains.domain_id as from_domain_id,
from_org_domains.name as from_domain_name,
to_org_domains.domain_id as to_domain_id,
to_org_domains.name as to_domain_name,
(
select group_concat(concat_ws('|',p.description,pt.payable_type,p.parent_obj_id) SEPARATOR '$$')
from payables p 
inner join payable_types pt on pt.payable_type_id=p.payable_type_id
inner join x_invoices_payments on p.invoice_id = x_invoices_payments.invoice_id
where pv.payment_id=x_invoices_payments.payment_id

) as payable_info
from payments pv
inner join organizations o1 on pv.from_org_id=o1.org_id
inner join organizations o2 on pv.to_org_id=o2.org_id
left join organizations_to_domains from_otd on (pv.from_org_id = from_otd.org_id and from_otd.is_home = 1)
left join organizations_to_domains to_otd on (pv.to_org_id = to_otd.org_id and to_otd.is_home = 1)
left join domains from_org_domains on from_otd.domain_id = from_org_domains.domain_id
left join domains to_org_domains on to_otd.domain_id = to_org_domains.domain_id

inner join payment_methods pm on pm.payment_method_id=pv.payment_method_id;

select * from v_payments;