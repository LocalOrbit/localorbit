<?php
class core_model_v_payables extends core_model_base_v_payables
{
	function get_buyer_grouped_payables($payable_ids=array())
	{
		$sql = '
			select count(payable_id) as payable_count,
			sum(p.payable_amount) as receivable_total,
			group_concat(\',\',p.payable_id) as payables,
			group_concat(\'$$\',p.payable_info) as payable_info,
			p.from_org_id,p.to_org_id,
			p.from_org_name,p.to_org_name,
			UNIX_TIMESTAMP(CURRENT_TIMESTAMP) as invoice_date,
			o1.po_due_within_days,
			(UNIX_TIMESTAMP(CURRENT_TIMESTAMP) + (o1.po_due_within_days * 86400))  as due_date
			from v_payables p
			inner join organizations o1 on (p.from_org_id=o1.org_id)
			
			
		';
		$col = new core_collection($sql);
	
		#$col->filter('p.invoice_id','is null');
		#$col->group("concat_ws('-',p.from_org_id,p.to_org_id)");
		
		
		
		return $col;
	}
}
?>