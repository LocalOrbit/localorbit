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

echo("getting a list of delivered items\n");

$sql = "
	select 
	distinct loi.lo_liid,p.payable_id,p.invoice_id,loi.row_total,o.org_id,o.name,loi.product_name,
	opm.name_on_account,opm.nbr1,opm.nbr2,p.parent_obj_id
	from lo_fulfillment_order lfo
	inner join lo_order_line_item loi on (loi.lo_foid = lfo.lo_foid)
	inner join lo_order lo on (lo.lo_oid = loi.lo_oid and lo.payment_method in ('paypal','ach'))
	inner join lo_order_item_status_changes loisc on (loi.lo_liid=loisc.lo_liid and loisc.ldstat_id=4)
	inner join payables p on (p.payable_type_id=2 and p.parent_obj_id=lfo.lo_foid and p.from_org_id=1)
	inner join domains d on (lo.domain_id = d.domain_id)
	inner join organizations o on (d.payable_org_id=o.org_id)
	inner join organization_payment_methods opm on (d.opm_id=opm.opm_id)
	where loisc.creation_date > '2015-05-01 00:00:00' 
	and loi.lsps_id=1
	and loi.ldstat_id=4
	order by loisc.creation_date desc
";
$payments = new core_collection($sql);
$payments = $payments->to_hash('org_id');
#print_r($payments);


foreach($payments as $org_id=>$items)
{
	$amount = 0;
	$name = $items[0]['name_on_account'];
	$account = core_crypto::decrypt($items[0]['nbr1']);
	$routing = core_crypto::decrypt($items[0]['nbr2']);
	
	$trace = 'LO-SMSP-'.$org_id.'-'.date('Ymd').'-'.time();
	
	$items_to_mark      = array();
	$payables_to_update = array();
		
	echo("".$items[0]['name']."::\n");
	foreach($items as $item)
	{
		if(!isset($payables_to_update[$item['payable_id'].'-'.$item['invoice_id']]))
			$payables_to_update[$item['payable_id'].'-'.$item['invoice_id']] = 0;
		
		$payables_to_update[$item['payable_id'].'-'.$item['invoice_id']] += $item['row_total'];
		$items_to_mark[] = $item['lo_liid'];
			
		echo("\t".$item['lo_liid'].":".$item['parent_obj_id'].":".$item['product_name']."\n");
		$amount += $item['row_total'];
	}
	echo("need to pay ".core_format::price($amount)." to ".$name." / ".$account." / ".$routing."\n");
	echo("\tNeed to mark these items as paid: ".implode(',',$items_to_mark)."\n");
	echo("\tNeed to add payments for these payables:\n\t\t");
	foreach($payables_to_update as $payable_id=>$payable_amount)
	{
		echo(",".$payable_id.":".$payable_amount."\t");
	}
}


#exit("COMPLETE\n");

$sql = '
	select 
	p.payable_id,p.amount,p.payable_type_id,p.invoice_id,
	lfo.org_id as seller_org_id,o.name,
	opm.*,d1.payable_org_id,lo.domain_id,
	sp.payable_id as seller_payable_id,
	sp.from_org_id as seller_from_org_id,
	sp.to_org_id as seller_to_org_id,p.parent_obj_id
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
	and   p.creation_date > \'2013-03-21 00:00:00\'
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
		echo($payable['seller_payable_id'].'/'.$payable['parent_obj_id'].' ');
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
		
		#$result = $opm->make_payment($trace,'Seller payments on '.date('M, d Y'),$info['total']);
		$result = true;
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
			
			// send emails of payment to both parties
			core::process_command('emails/payment_received',false,
				$payment['to_org_id'], $payment['from_org_id'], $payment['amount'], array()
			);
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