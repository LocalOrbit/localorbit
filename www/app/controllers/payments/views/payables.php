<?php
global $core;
$payables = core::model('v_payables')
	->collection()
	->filter('amount_due', '>', 0)
	->filter('is_invoiced','=',0);
	

if(lo3::is_market())
{	
	$payables->filter(
		'from_org_id' ,
		'in',
		'(
			select org_id
			 from organizations_to_domains 
			where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
		)'
	);
}
else if (!lo3::is_admin())
{
	$payables->filter('from_org_id','=',$core->session['org_id']);
}	
	
	#->filter('from_org_id' , $core->session['org_id'])
	
$payables->add_formatter('payable_info');
$payables->add_formatter('payment_link_formatter');
$payables->add_formatter('payment_direction_formatter');
$payables_table = new core_datatable('payables','payments/payables',$payables);
$payables_table = payments__add_standard_filters($payables_table,'payables');
$payables_table->add(new core_datacolumn('payable_id','Description',true,'22%',			'<b>P-{payable_id}</b><br />{description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn('from_org_name','Payment Info',false,'40%','{direction_info}','{to_org_name}','{to_org_name}'));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'20%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn('payable_amount','Amount',true,'14%',							'{payable_amount}','{payable_amount}','{payable_amount}'));
#$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payment_id'),' ',' '));
$payables_table->columns[2]->autoformat='date-long';
//$payables_table->columns[3]->autoformat='price';
$payables_table->sort_direction='desc';


?>

<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>">
	<?php
	$payables_table->render();
	?>
	<? if(lo3::is_admin() || lo3::is_market()){?>
	<!--
	<div class="buttonset" id="create_payables_button">
		<input type="button" onclick="$('#create_payables_form,#create_payables_button').toggle();" value="Create Payment from checked" class="button_primary" />
	</div>
	-->
	<br />&nbsp;<br />
	<? $this->payables__create_payment();?>
	<?}?>
</div>
