#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('crypto');

$actually_do_payment = $argv[1] == 'do-ach';

if($actually_do_payment)
	echo("REALLY DOING IT\n");

echo("-------------------\n");

$sql = '
	select 
	p.payable_id,p.amount,p.payable_type_id,p.invoice_id,
	lfo.org_id as seller_org_id,o.name,
	opm.*,d1.payable_org_id,lo.domain_id,
	sp.payable_id as seller_payable_id,
	sp.from_org_id as seller_from_org_id,
	sp.to_org_id as seller_to_org_id
	from payables p
	inner join payables sp on (sp.parent_obj_id=p.parent_obj_id and sp.payable_type_id=2 and sp.from_org_id=p.to_org_id)
	inner join lo_fulfillment_order lfo on (lfo.lo_foid=p.parent_obj_id)
	inner join lo_order_line_item loi on (lfo.lo_foid=loi.lo_foid)
	inner join lo_order lo on (lo.lo_oid=loi.lo_oid)
	inner join organizations o on (lfo.org_id=o.org_id)
	inner join domains d1 on (lo.domain_id=d1.domain_id)
	inner join organization_payment_methods opm on (d1.opm_id = opm.opm_id)
		
	where p.payable_type_id=2
	and   p.invoice_id is null
	and   p.from_org_id=1
	and   lo.ldstat_id=4
	and   lo.payment_method in (\'ach\',\'paypal\')
	and   d1.seller_payer = \'hub\'
	group by lfo.lo_foid
';

$payables = new core_collection($sql);
$sellers = array();
$domains = array();

# first build a structure that groups all the payables by seller in order to create invoices
# we also need to total up things by domain.payable_org_id to send the money to the hub
foreach($payables as $payable)
{
	if(!is_array($sellers[$payable['seller_org_id']]))
	{
		$sellers[$payable['seller_org_id']] = array(
			'total'=>0,
			'name'=>$payable['name'],
			'payables'=>array(),
		);
	}
	
	if(!is_array($domains[$payable['payable_org_id']]))
	{
		$domains[$payable['payable_org_id']] = array(
			'total'=>0,
			'account'=>$payable,
			'payables'=>array(),
		);
	}
	
	
	$sellers[$payable['seller_org_id']]['total']  += $payable['amount'];
	$sellers[$payable['seller_org_id']]['payables'][] = $payable;
	
	$domains[$payable['payable_org_id']]['total'] += $payable['amount'];
	$domains[$payable['payable_org_id']]['payables'][] = $payable;
	
}

# output the payment structure
echo("Seller invoices: \n");
foreach($sellers as $org_id=>$seller)
{
	echo('we need to invoice '.$seller['name'] .' '.$seller['total'].' for payables: ');
	foreach($seller['payables'] as $payable)
	{
		echo($payable['seller_payable_id'].' ');
	}
	echo("\n");
}

echo("-------------------\n");
echo("Payments to MMs: \n");
foreach($domains as $org_id=>$info)
{
	echo("we need to pay org ".$org_id." ".$info['total']."\n");
	
	foreach($info['payables'] as $payable)
	{
		echo($payable['payable_id'].' ');
	}
	echo("\n");
}
echo("-------------------\n");


if($actually_do_payment)
{
	# pay the Market Managers for their orders
	foreach($domains as $org_id=>$info)
	{
		$opm = core::model('organization_payment_methods');
		$core->data = $info['account'];
		$opm->import_fields('opm_id','org_id','payment_method_id','label','name_on_account','nbr1','nbr2');
		
		$trace = 'LO-SMSP-'.$org_id.'-'.date('Ymd');
		$trace .= '-'.time();
		
		$result = $opm->make_payment($trace,'Seller payments on '.date('M, d Y'),$info['total']);
		
		if($result)
		{
			$invoice = core::model('invoices');
			$invoice['from_org_id'] = 1;
			$invoice['to_org_id'] = $org_id;
			$invoice['amount'] = $info['total'];
			$invoice['due_date'] = date('Y-m-d H:i:s',time());
			$invoice->save();
			
			foreach($info['payables'] as $payable)
			{
				$payable_obj = core::model('payables');
				$payable_obj->load($payable['payable_id']);
				$payable_obj['invoice_id'] = $invoice['invoice_id'];
				$payable_obj->save();
			}
			
			$payment = core::model('payments');
			$payment['from_org_id'] = 1;
			$payment['to_org_id'] = $org_id;
			$payment['amount'] = $info['total'];
			$payment['payment_method_id'] = 3;
			$payment['ref_nbr'] = $trace;
			$payment['admin_note'] = $memo;
			$payment->save();
			
			$xpi = core::model('x_invoices_payments');
			$xpi['invoice_id']  = $invoice['invoice_id'];
			$xpi['payment_id']  = $payment['payment_id'];
			$xpi['amount_paid'] = $info['total'];
			$xpi->save();
		}
		#print_r($info);
	}
	
	# now, loop through all the sellers and invoice their payables
	foreach($sellers as $org_id=>$seller)
	{
		
		if($seller['total'] > 0)
		{
			# create teh invoice
			$invoice = core::model('invoices');
			$invoice['from_org_id'] = $payable['payable_org_id'];
			$invoice['to_org_id'] = $org_id;
			$invoice['amount'] = $seller['total'];
			$invoice['due_date'] = date('Y-m-d H:i:s',time() + (7*86400));
			$invoice->save();
			
			foreach($seller['payables'] as $payable)
			{
				$payable_obj = core::model('payables');
				$payable_obj->load($payable['seller_payable_id']);
				$payable_obj['invoice_id'] = $invoice['invoice_id'];
				$payable_obj->save();
			}
		}
	}
}

exit("complete!\n");
?>