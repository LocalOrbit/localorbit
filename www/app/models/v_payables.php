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
	
	function get_invoice_payables($ids,$invoice_status=null)
	{
		$sql = '
			select p.from_org_id,p.from_org_name,p.to_org_id,p.to_org_name,p.domain_id,
			sum(p.amount) - sum(p.amount_paid) as amount,p.invoiced,p.invoice_id,
			group_concat(p.payable_info SEPARATOR \'$$\') as payable_info,
			group_concat(p.parent_obj_id SEPARATOR \',\') as lo_liids,
			group_concat(p.delivery_status SEPARATOR \',\') as delivery_status,
			group_concat(p.payable_id SEPARATOR \',\') as payable_ids,
			o.po_due_within_days,p.payable_type,
			p.po_terms,
			concat_ws(\'-\',p.domain_id,REPLACE(p.payable_type,\' \',\'_\'),p.invoice_id,p.invoiced,from_org_id,to_org_id) as group_key
			from v_payables p
			inner join organizations o on (p.from_org_id=o.org_id)
			where p.payable_id in ('.implode(',',$ids).')
		';
		
		if(!is_null($invoice_status))
		{
			$sql .= ' and p.invoiced='.$invoice_status;
		}
		
		$sql .= '
			group by concat_ws(\'-\',p.domain_id,REPLACE(p.payable_type,\' \',\'_\'),p.invoice_id,p.invoiced,from_org_id,to_org_id)
			order by p.invoiced,p.from_org_name,p.payable_info
		';
		$payables = new core_collection($sql);
		#echo '<pre>';
		#print_r($payables->to_array());
		#echo('</pre>');
		return $payables->add_formatter('format_payable_info')->to_array();
	}
	
	function get_payables_for_payment($ids)
	{
		$sql = "
			select p.*,
			concat_ws('-',if(((p.amount - p.amount_paid)>0),0,1),p.from_org_id,p.to_org_id) as group_key
			from v_payables p
			where p.payable_id in (".implode(',',$ids).")
			order by if(((p.amount - p.amount_paid)>0),0,1),concat_ws('-',p.from_org_name,p.to_org_name)
		";
		$payables = new core_collection($sql);
		return $payables->add_formatter('format_payable_info')->to_hash('group_key');
	}
	
	function get_domains_options_for_org($org_id,$role)
	{
		if($role == 'admin')
		{
			$filter = new core_collection('
				select domain_id as id,name
				from domains
				order by name
			');
		}
		else if($role == 'market')
		{
			$filter = new core_collection('
				select domain_id as id,name
				from domains
				where domain_id in (
					select domain_id 
					from organizations_to_domains
					where (
						org_id in (
							select to_org_id
							from payables
							where from_org_id = '.$org_id.'
						) 
						or org_id in (
							select from_org_id
							from payables
							where to_org_id = '.$org_id.'
						)
					)
					and is_home = 1
				) or domain_id in (
					select distinct domain_id from payables where (from_org_id='.$org_id.' or to_org_id='.$org_id.')
				)
				order by name
			');
		}
		else
		{
			$filter = new core_collection('
				select domain_id as id,name
				from domains
				where domain_id in (
					select domain_id
					from delivery_days
					where delivery_days.dd_id in (
						select dd_id 
						from organization_delivery_cross_sells
						where org_id='.$org_id.'
					)
				) or domain_id in (
					select count(distinct domain_id) from payables where (from_org_id='.$org_id.' or to_org_id='.$org_id.')
				)
				order by name
			');
		}
		return $filter;
	}
	

	function get_orgs_options_for_org($org_id,$role)
	{
		if($role == 'admin')
		{
			$filter = new core_collection('
				select distinct org_id as id,name
				from organizations
				where org_id in (select distinct from_org_id from payables)
				or org_id in (select distinct to_org_id from payables)
				order by name
			');
		}
		else if($role == 'market')
		{
			$filter = new core_collection('
				select distinct org_id as id,name
				from organizations
				where org_id in (
					select org_id from organizations_to_domains
					where domain_id in (
						select domain_id 
						from organizations_to_domains
						where org_id ='.$org_id.'
						and orgtype_id=2
					)
				) or org_id in (
					select distinct to_org_id from payables where from_org_id='.$org_id.'
				) or org_id in (
					select distinct from_org_id from payables where to_org_id='.$org_id.'
				)
				order by name
			');
		}
		
		return $filter;
	}
}
?>