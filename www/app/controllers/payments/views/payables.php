<?php
global $core;
$payables = core::model('v_payables')->collection()->filter('from_org_id' , $core->session['org_id'])->filter('amount_due', '>', 0);
$payables->add_formatter('payable_desc');
$payables_table = new core_datatable('payables','payments/payables',$payables);
$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payment_id'),' ',' '));
$payables_table->add(new core_datacolumn('description','Description',true,'19%',			'<b>PO-0000{payable_id}</b><br />{description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'19%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn('from_domain_name','Market',true,'19%','{from_domain_name}','{from_domain_name}','{from_domain_name}'));
$payables_table->add(new core_datacolumn('to_org_name','Organization',true,'19%','{to_org_name}','{to_org_name}','{to_org_name}'));
$payables_table->add(new core_datacolumn('payable_amount','Amount',true,'19%',							'{payable_amount}','{payable_amount}','{payable_amount}'));
$payables_table->add(new core_datacolumn('amount_due','Amount Due',true,'19%',			'{amount_due}','{amount_due}','{amount_due}'));
$payables_table->columns[2]->autoformat='date-short';
$payables_table->columns[5]->autoformat='price';
$payables_table->columns[6]->autoformat='price';

$payables_table->add_filter(new core_datatable_filter('to_org_id'));
$payables_table->filter_html .= core_datatable_filter::make_select(
	'v_payables',
	'to_org_id',
	$items->filter_states['payables__filter__to_org_id'],
	new core_collection('select distinct to_org_id, to_org_name from v_payables where from_org_id = ' . $core->session['org_id'] . ';'),
	'to_org_id',
	'to_org_name',
	'Show from all organizations',
	'width: 270px;'
);

?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<?php
	$payables_table->render();
	?>
	<? if(lo3::is_admin() || lo3::is_market()){?>
	<div class="buttonset" id="create_payables_button">
		<input type="button" onclick="$('#create_payables_form,#create_payables_button').toggle();" value="Create Payment from checked" class="button_primary" />
	</div>
	<br />&nbsp;<br />
	<? $this->payables__create_payment();?>
	<?}?>
</div>
