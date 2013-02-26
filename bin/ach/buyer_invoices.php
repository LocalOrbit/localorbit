#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('crypto');
ob_end_flush();


$actually_send = $argv[1] == 'do-send';

if($actually_send)
	echo("REALLY DOING IT\n");

echo("-------------------\n");

$sql = '
	select 
	p.payable_id,p.amount,o.name,o.org_id,d.domain_id,p.description
	from payables p
	inner join lo_order lo on (lo.lo_oid=p.parent_obj_id and p.payable_type_id=1)
	inner join domains d on (lo.domain_id=d.domain_id)
	inner join organizations o on (o.org_id=lo.org_id)
	where p.invoice_id is null
	and   d.buyer_invoicer = \'lo\'
	and   lo.ldstat_id=4

';

$payables = new core_collection($sql);
$buyers = array();

# first build a structure that groups all the payables by seller in order to create invoices
# we also need to total up things by domain.payable_org_id to send the money to the hub
foreach($payables as $payable)
{
	if(!is_array($buyers[$payable['org_id']]))
	{
		$buyers[$payable['org_id']] = array(
			'total'=>0,
			'org_id'=>$payable['org_id'],
			'name'=>$payable['name'],
			'emails'=>$payable['emails'],
			'domain_id'=>$payable['domain_id'],
			'payables'=>array(),
		);
	}
	$buyers[$payable['org_id']]['total'] += $payable['amount'];
	$buyers[$payable['org_id']]['payables'][] = $payable;
}

# output the payment structure
echo("Buyer Payables: \n");
foreach($buyers as $org_id=>$buyer)
{
	echo('we need to invoice '.$buyer['name'] .' '.$buyer['total'].' for payables: ');
	foreach($buyer['payables'] as $payable)
	{
		echo($payable['payable_id'].' ');
	}
	echo("\n");
}


echo("-------------------\n");


if($actually_send)
{
	foreach($buyers as $org_id=>$buyer)
	{
		$invoice = core::model('invoices');
		$invoice['from_org_id'] = $org_id;
		$invoice['to_org_id']   = 1;
		$invoice['amount']      = $buyer['total'];
		$invoice['due_date']    = date('Y-m-d H:i:s',time() + (7 * 86400));
		$invoice->save();
		
		foreach($buyer['payables'] as $payable)
		{
			$payable_obj = core::model('payables');
			$payable_obj->load($payable['payable_id']);
			$payable_obj['invoice_id'] = $invoice['invoice_id'];
			$payable_obj->save();
		}
		
		core::process_command('emails/payments_portal__invoice',false,
			$invoice,$buyer['payables'] ,$buyer['domain_id'],core_format::date(time() + (7 * 86400),'short')
		);
	}
}

exit("complete!\n");
?>