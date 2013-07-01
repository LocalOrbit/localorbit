<?php

# the csv download from the payment history tab is radically different
# branch here, and the render function will exit/deinit.

if($core->data['format'] == 'csv')
{
	function csv_formatter($data)
	{
		if($data['payable_type'] == 'service fee')
		{
			$data['buyer_order_nbr'] = '';
			$data['seller_order_nbr'] = '';
		}
		if($data['payable_type'] == 'delivery fee')
		{
			$data['seller_order_nbr'] = '';
		}
		return $data;
		
	}
	
	$v_payments = new core_collection('select * from v_payments_export');
	$v_payments->add_formatter('format_payable_info');
	$v_payments->add_formatter('csv_formatter');
	
	$offset = 0;
	$payments = new core_datatable('payments','payments/payment_history',$v_payments);
	payments__add_standard_filters($payments,'transactions');
	$payments->add(new core_datacolumn('payment_date','Date Paid',true,'15%',			'{payment_date}','{payment_date}','{payment_date}'));
	if(lo3::is_admin() || lo3::is_market())
	{
		$payments->add(new core_datacolumn('order_date','From',false,'15%',	'{from_org_name}','{from_org_name}','{from_org_name}'));
		$payments->add(new core_datacolumn('order_date','To',false,'15%',	'{to_org_name}','{to_org_name}','{to_org_name}'));
		$offset+=2;
	}
	if(lo3::is_admin() || lo3::is_market())
	{
		$payments->add(new core_datacolumn('order_date','Buyer Order Nbr',false,'15%',	'{buyer_order_nbr}','{buyer_order_nbr}','{buyer_order_nbr}'));
		$payments->add(new core_datacolumn('order_date','Seller Order Nbr',false,'15%',	'{seller_order_nbr}','{seller_order_nbr}','{seller_order_nbr}'));
		$offset+=2;
	}
	else if (lo3::is_seller())
	{
		$payments->add(new core_datacolumn('order_date','Seller Order Nbr',false,'15%',	'{seller_order_nbr}','{seller_order_nbr}','{seller_order_nbr}'));
		$offset++;
	}
	else
	{
		$payments->add(new core_datacolumn('order_date','Buyer Order Nbr',false,'15%',	'{buyer_order_nbr}','{buyer_order_nbr}','{buyer_order_nbr}'));
		$offset++;
	}
	$payments->add(new core_datacolumn('order_date','Type',false,'15%',	'{payable_type}','{payable_type}','{payable_type}'));
	$payments->add(new core_datacolumn('order_date','Description',false,'15%',	'{payable_info}','{payable_info}','{payable_info}'));
	$payments->add(new core_datacolumn('order_date','Payment Method',false,'15%',	'{payment_method_html}','{payment_method_html}','{payment_method_html}'));
	$payments->add(new core_datacolumn('payable_amount','Amount',false,'15%',	'{payable_amount}','{payable_amount}','{payable_amount}'));
	$payments->columns[0]->autoformat='date-long';
	$payments->columns[4+$offset]->autoformat='price';
	$payments->render();
	
}


if(lo3::is_admin())
{
	$v_payments = new core_collection('
		select * 
		from v_payments
		where (from_org_id='.$core->session['org_id'].' or to_org_id='.$core->session['org_id'].')
	');
}
else if(lo3::is_market())
{
	
	$v_payments = new core_collection('
		select * 
		from v_payments
		where payment_id in (
			select payment_id
			from x_payables_payments
			where payable_id in (
				select payable_id
				from payables
				where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
			)
		)
		
	');
}
else
{
	$v_payments = new core_collection('
		select * 
		from v_payments
		where (from_org_id='.$core->session['org_id'].' or to_org_id='.$core->session['org_id'].')
	');
}
$v_payments->add_formatter('format_payable_info');

$payments = new core_datatable('payments','payments/payment_history',$v_payments);
payments__add_standard_filters($payments,'transactions');

core::log(print_r($core->data,true));

if($core->data['format'] == 'csv')
{
	$payments->add(new core_datacolumn('payment_date','Date Paid',true,'15%',			'{payment_date}','{payment_date}','{payment_date}'));
	$autoformat_offset = 3;
	if(lo3::is_admin() || lo3::is_market())
	{
		$payments->add(new core_datacolumn('concat_ws(\' \',from_org_name,to_org_name)','From',true,'13%',			'{from_org_name}','{from_org_name}','{from_org_name}'));
		$payments->add(new core_datacolumn('concat_ws(\' \',from_org_name,to_org_name)','To',true,'13%',			'{to_org_name}','{to_org_name}','{to_org_name}'));
		$autoformat_offset+=2;
	}

	$payments->add(new core_datacolumn('order_date','Description',false,'15%','{description_html}','{description_unformatted}','{description_unformatted}'));
	$payments->add(new core_datacolumn('payment_method','Payment Method',true,'10%','{payment_method_html}','{payment_method_html}','{payment_method_html}'));
	$payments->add(new core_datacolumn('amount','Amount',true,'10%','{amount}','{amount}','{amount}'));
	$payments->columns[0]->autoformat='date-short';
	$payments->columns[($autoformat_offset)]->autoformat='price';
	$payments->sort_column = 0;
	$payments->sort_direction = 'desc';
}
else
{
	$payments->add(new core_datacolumn('payment_date','Date Paid',true,'15%',			'{payment_date}','{payment_date}','{payment_date}'));
	$autoformat_offset = 4;
	if(lo3::is_admin() || lo3::is_market())
	{
		$payments->add(new core_datacolumn('concat_ws(\' \',from_org_name,to_org_name)','From/To',true,'13%',			'{direction_html}','{direction}','{direction}'));
		$autoformat_offset++;
	}

	$payments->add(new core_datacolumn('order_date','Ref #',false,'15%',			'{ref_nbr_html}','{ref_nbr_unformatted}','{ref_nbr_unformatted}'));
	$payments->add(new core_datacolumn('order_date','Description',false,'15%','{description_html}','{description_unformatted}','{description_unformatted}'));
	$payments->add(new core_datacolumn('payment_method','Payment Method',true,'10%','{payment_method_html}','{payment_method_html}','{payment_method_html}'));
	$payments->add(new core_datacolumn('amount','Amount',true,'10%','{amount}','{amount}','{amount}'));
	$payments->columns[0]->autoformat='date-short';
	$payments->columns[($autoformat_offset)]->autoformat='price';
	$payments->sort_column = 0;
	$payments->sort_direction = 'desc';
	
	if(lo3::is_admin())
	{
		$payments->add(new core_datacolumn('payment_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payment_id'),' ',' '));
	}
}

?>
<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<?php
	$payments->render();
	?>
	<?if(lo3::is_admin()){?>
	<div class="pull-right" id="create_payment_button">
		<input type="button" onclick="core.payments.resendPaymentNotification();" class="btn btn-primary" value="Re-send Notification E-mail" />
	</div>
	<?}?>
</div>