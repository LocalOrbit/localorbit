<?php

	
if(lo3::is_admin())
{
	$invoices = new core_collection('
		select *,
		UNIX_TIMESTAMP(creation_date) as creation_date,
		UNIX_TIMESTAMP(due_date) as due_date,
		DATEDIFF(CURRENT_TIMESTAMP,due_date) as age
		from v_invoices vi
		where vi.invoice_id > 0
		and vi.amount_due >0
	');
}
else if (lo3::is_market())
{
	$invoices = new core_collection('
		select *,
		UNIX_TIMESTAMP(creation_date) as creation_date,
		UNIX_TIMESTAMP(due_date) as due_date,
		DATEDIFF(CURRENT_TIMESTAMP,due_date) as age
		from v_invoices vi
		where vi.amount_due >0
		and (
			vi.from_org_id in (
				select org_id
				from organizations_to_domains 
				where organizations_to_domains.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
			)
			or
			vi.to_org_id in (
				select org_id
				from organizations_to_domains 
				where organizations_to_domains.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
			)
		)
	');

}
else
{
	$invoices = new core_collection('
		select *,
		UNIX_TIMESTAMP(creation_date) as creation_date,
		UNIX_TIMESTAMP(due_date) as due_date,
		DATEDIFF(CURRENT_TIMESTAMP,due_date) as age
		from v_invoices vi
		where (
			vi.from_org_id = '.$core->session['org_id'].'
			or
			vi.to_org_id = '.$core->session['org_id'].'
		)
		and vi.amount_due >0
	');
}


function systemwide_age_formatter($data)
{
	if($data['age'] <= 0)
	{
		$data['age'] = 'Current';
	}
	else
	{
		$data['age'] = '<span class="text-error">'.$data['age'].'</span>';
	}
	return $data;
}
	
$invoices->add_formatter('payable_info');
$invoices->add_formatter('payment_link_formatter');
$invoices->add_formatter('payment_direction_formatter');
$invoices->add_formatter('systemwide_age_formatter');
$systemwide_table = new core_datatable('systemwide','payments/systemwide_payablesreceivables',$invoices);
$systemwide_table = payments__add_standard_filters($systemwide_table,'systemwide');
$systemwide_table->add(new core_datacolumn('invoice_id','Reference',true,'20%',			'{description_html}','{description}','{description}'));
$systemwide_table->add(new core_datacolumn('from_org_name','Description',false,'40%','{direction_info}','{from_org_name}','{from_org_name}'));
$systemwide_table->add(new core_datacolumn('creation_date','Invoice Date',true,'10%','{creation_date}','{creation_date}','{creation_date}'));
$systemwide_table->add(new core_datacolumn('due_date','Due Date',true,'10%','{due_date}','{due_date}','{due_date}'));
$systemwide_table->add(new core_datacolumn('DATEDIFF(due_date,CURRENT_TIMESTAMP)','Aging',true,'10%',			'{age}','{age}','{age}'));
$systemwide_table->add(new core_datacolumn('amount_due','Amount Due',true,'10%',			'{amount_due}','{amount_due}','{amount_due}'));
#$systemwide_table->add(new core_datacolumn('invoice_id',array(core_ui::check_all('systemwide'),'',''),false,'4%',core_ui::check_all('systemwide','invoice_id'),' ',' '));
$systemwide_table->columns[2]->autoformat='date-short';
$systemwide_table->columns[3]->autoformat='date-short';
$systemwide_table->sort_direction='desc';


?>

<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_all_systemwide">
		<?
		$systemwide_table->render();
		?>		
	</div>
</div>
