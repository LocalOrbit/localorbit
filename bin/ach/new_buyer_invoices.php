#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();


$actually_send = $argv[1] == 'do-send';

if($actually_send)
	echo("REALLY DOING IT\n");

echo("-------------------\n");

$sql = "
	select 
	p.*,o.po_due_within_days
	from v_payables p
	inner join lo_order_line_item loi on (p.parent_obj_id=loi.lo_liid and loi.ldstat_id=4)
	inner join domains d on (p.domain_id=d.domain_id)
	inner join organizations o on (p.from_org_id=o.org_id)
	where p.invoice_id is null
	and   d.buyer_invoicer = 'lo'
	and   p.payable_type in ('buyer order','delivery fee');
";

$payables = new core_collection($sql);
$buyers = array();

# first build a structure that groups all the payables by seller in order to create invoices
foreach($payables as $payable)
{
	if(!isset($buyers[$payable['from_org_id']]))
	{
		$buyers[$payable['from_org_id']] = array(
			'org_id'=>$payable['from_org_id'],
			'org_name'=>$payable['from_org_name'],
			'po_terms'=>$payable['po_due_within_days'],
			'domain_id'=>$payable['domain_id'],
			'total'=>0,
			'items'=>array(),
			'fees'=>array(),
			'payables'=>array(),
		);
	}
	$buyers[$payable['from_org_id']]['total'] += floatval($payable['amount']);
	$buyers[$payable['from_org_id']][(($payable['payable_type'] == 'buyer order')?'items':'delivery fee')][] = $payable['parent_obj_id'];
	$buyers[$payable['from_org_id']]['payables'][] = $payable['payable_id'];
}


if(count($buyers) > 0)
{
	echo("found the following receivables to invoice: \n");
	
	foreach($buyers as $buyer)
	{
		echo("\t".$buyer['org_name']." owes us ".core_format::price($buyer['total'])." for: \n");
		echo("\t\titems: ".implode(',',$buyer['items'])."\n");
		echo("\t\tdelivery fees: ".implode(',',$buyer['fees'])."\n");
		echo("\t\tpayable_ids: ".implode(',',$buyer['payables'])."\n");
		echo("\n");
	}
}
else
{
	echo("no buyer orders to invoice \n");
}


echo("-------------------\n");


if($actually_send)
{
	foreach($buyers as $org_id=>$buyer)
	{
		$invoice = core::model('invoices');
		$invoice['amount']      = $buyer['total'];
		$invoice['due_date']    = (time() + ($buyer['po_terms'] * 86400));
		$invoice['first_invoice_date'] = time();
		$invoice['creation_date'] = time();
		$invoice->save();
		
		
		core_db::query('update payables set invoice_id='.$invoice['invoice_id'].' where payable_id in ('.implode(',',$buyer['payables']).');');
		
		core::process_command('emails/payments_portal__invoice',false,
			$org_id,$buyer['total'],$invoice['invoice_id'],$buyer['payables'] ,$buyer['domain_id'],core_format::date($invoice['due_date'],'short')
		);
	}
}

exit("complete!\n");
?>