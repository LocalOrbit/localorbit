<?php

class core_model_v_invoices extends core_model_base_v_invoices
{
	/*
	function get_buyer_grouped_invoices()
	{
		$sql = '
			select sum(amount_due),
			to_org_id,to_org_name,from_org_id,from_org_name,
			GROUP_CONCAT(invoice_id) as invoices,
			GROUP_CONCAT(invoice_id) as invoices,
			GROUP_CONCAT(invoice_id) as invoices
			from v_invoices
		';
		$col = new core_collection($sql);
		$col->group("concat_ws('-',from_org_id,to_org_id)");
		
		return $col;
	}
	*/
}

?>