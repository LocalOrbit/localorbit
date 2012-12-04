select lo_order.org_id, domains.payable_org_id, sum(adjusted_total - amount_paid), customer_entity.email
from lo_order 
inner join domains on lo_order.domain_id = domains.domain_id 
inner join payables on lo_order.lo_oid = payables.parent_obj_id and payables.payable_type_id = 1
inner join invoices on payables.invoice_id = invoices.invoice_id
inner join organizations on domains.payable_org_id = organizations.org_id
inner join customer_entity on organizations.payment_entity_id = customer_entity.entity_id
where amount_paid < adjusted_total and now() > due_date
group by org_id, domains.payable_org_id;