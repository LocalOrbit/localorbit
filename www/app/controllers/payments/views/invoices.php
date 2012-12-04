<?php
$invoices = core::model('v_invoices')->collection()->filter('to_org_id' , $core->session['org_id'])->filter('amount_due', '>', 0);
$invoices->add_formatter('payable_info');
$invoices_table = new core_datatable('invoices','payments/invoices',$invoices);
$invoices_table->add(new core_datacolumn('invoice_id',array(core_ui::check_all('invoices '),'',''),false,'4%',core_ui::check_all('invoices','invoice_id'),' ',' '));
$invoices_table->add(new core_datacolumn('creation_date','Date',true,'19%','{creation_date}','{creation_date}','{creation_date}'));
$invoices_table->add(new core_datacolumn('from_domain_name','Market',true,'19%','{from_domain_name}','{from_domain_name}','{from_domain_name}'));
$invoices_table->add(new core_datacolumn('from_org_name','Organization',true,'19%','{from_org_name}','{from_org_name}','{from_org_name}'));
$invoices_table->add(new core_datacolumn('description_html','Description',true,'19%',			'{description_html}','{description}','{description}'));
$invoices_table->add(new core_datacolumn('amount','Amount',true,'19%',							'{amount}','{amount}','{amount}'));
$invoices_table->add(new core_datacolumn('amount_due','Amount Due',true,'19%',			'{amount_due}','{amount_due}','{amount_due}'));
$invoices_table->columns[1]->autoformat='date-short';
$invoices_table->columns[5]->autoformat='price';
$invoices_table->columns[6]->autoformat='price';

$invoices_table->add_filter(new core_datatable_filter('from_domain_id'));
$invoices_table->filter_html .= core_datatable_filter::make_select(
	'invoices',
	'from_domain_id',
	$items->filter_states['invoices__filter__from_domain_id'],
	new core_collection('select distinct from_domain_id, from_domain_name from v_invoices where to_org_id = ' . $core->session['org_id']),
	'from_domain_id',
	'from_domain_name',
	'Show from all markets',
	'width: 270px;'
);

$org_sql = 'select distinct from_org_id, from_org_name from v_invoices where to_org_id = ' . $core->session['org_id'];

$domain_id = $invoices_table->filter_states['invoices__filter__from_domain_id'];
if(is_numeric($domain_id) && $domain_id > 0)
{
   $org_sql .= ' and from_domain_id='.$invoices_table->filter_states['invoices__filter__from_domain_id'];
}

$invoices_table->add_filter(new core_datatable_filter('from_org_id'));
$invoices_table->filter_html .= core_datatable_filter::make_select(
	'invoices',
	'from_org_id',
	$items->filter_states['invoices__filter__from_org_id'],
	new core_collection($org_sql),
	'from_org_id',
	'from_org_name',
	'Show from all organizations',
	'width: 270px;'
);

?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<?
	$invoices_table->render();
	?>
	<div class="buttonset" id="create_payment_form_toggler">
		<input type="button" onclick="$('#create_payment_form_here,#create_payment_form_toggler').toggle();" class="button_primary" value="Record Payments" />
	</div>
	<br />&nbsp;<br />
	<? $this->invoices__record_payment()?>
</div>