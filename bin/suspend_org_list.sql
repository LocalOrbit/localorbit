select org_id
from lo_order 
inner join domains on lo_order.domain_id = domains.domain_id 
inner join payables on lo_order.lo_oid = payables.parent_obj_id and payables.payable_type_id = 1
inner join invoices on payables.invoice_id = invoices.invoice_id
where amount_paid < adjusted_total and datediff(now(), due_date) > po_due_within_days
group by org_id;