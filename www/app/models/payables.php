<?php
class core_model_payables extends core_model_base_payables
{
	function get_buyer_grouped_payables($payable_ids=array())
	{
		$sql = '
			select 1 as payable_count,
			p.amount as receivable_total,
			p.payable_id as payables,
			p.from_org_id,p.to_org_id,
			o1.name as from_org_name,
			o2.name as to_org_name,
			UNIX_TIMESTAMP(CURRENT_TIMESTAMP) as invoice_date,
			o2.po_due_within_days,
			(UNIX_TIMESTAMP(CURRENT_TIMESTAMP) + (o2.po_due_within_days * 86400))  as due_date
			from payables p
			inner join organizations o1 on (p.from_org_id=o1.org_id)
			inner join organizations o2 on (p.to_org_id=o2.org_id)

			
		';
		$col = new core_collection($sql);
	
		$col->filter('p.invoice_id','is null');
		#$col->group("concat_ws('-',p.from_org_id,p.to_org_id)");
		
		
		
		return $col;
	}
}
?>