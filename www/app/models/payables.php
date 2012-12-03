<?php
class core_model_payables extends core_model_base_payables
{
	function get_buyer_grouped_payables($payable_ids=array())
	{
		$sql = '
			select count(p.payable_id) as payable_count,
			sum(p.amount) as receivable_total,
			GROUP_CONCAT(p.payable_id) as payables,
			p.from_org_id,p.to_org_id,
			o.name as org_name,
			UNIX_TIMESTAMP(CURRENT_TIMESTAMP) as invoice_date,
			o.po_due_within_days,
			(UNIX_TIMESTAMP(CURRENT_TIMESTAMP) + (o.po_due_within_days * 86400))  as due_date
			from payables p
			inner join organizations o on (p.to_org_id=o.org_id)

			
		';
		$col = new core_collection($sql);
	
		$col->filter('p.invoice_id','is null');
		$col->group("concat_ws('-',p.from_org_id,p.to_org_id)");
		
		
		
		return $col;
	}
}
?>