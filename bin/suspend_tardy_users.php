<?
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

$results = core_db::query('
select lo_order.org_id, domains.payable_org_id, sum(adjusted_total - amount_paid) as amount_overdue, customer_entity.email, organizations.name as org_name, domains.domain_id as domain_id, domains.name as hubname
from lo_order
inner join domains on lo_order.domain_id = domains.domain_id
inner join payables on lo_order.lo_oid = payables.parent_obj_id and payables.payable_type_id = 1
inner join invoices on payables.invoice_id = invoices.invoice_id
inner join organizations payable_orgs on domains.payable_org_id = payable_orgs.org_id
inner join organizations on lo_order.org_id = organizations.org_id
inner join customer_entity on payable_orgs.payment_entity_id = customer_entity.entity_id
where amount_paid < adjusted_total and now() > due_date
and organizations.is_enabled = 1 and organizations.is_deleted = 0 and organizations.is_active = 1
group by org_id, domains.payable_org_id');

while ($info = core_db::fetch_assoc($results)) {
	print_r($info);

	core::process_command('emails/suspend_mm',false,
		$info['email'],
		$info['org_name'],
		money_format('%i',$info['amount_overdue']),
		$info['domain_id'],
		$info['hubname']
	);
	// send email
	// change to enable = 0
}
?>