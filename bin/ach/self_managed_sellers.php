#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('crypto');
ob_end_flush();

$config = array(
	'do-ach'=>0,
	'do-email'=>0,
	'seller-org-id'=>0,
	'mm-org-id'=>0,
	'domain-id'=>0,
	'report-payables'=>0,
	'report-sql'=>0,
	'exclude-foids'=>0,
	'exclude-liids'=>0,
	'start-from-date'=>'2013-04-04 00:00:00',
	'start-delivery-date'=>'2013-05-01 00:00',
	'amount-operator'=>'>',
);

array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}
if($config['do-ach'] == 1)
{
	$config['do-email'] = 1;
}


mysql_query('SET SESSION group_concat_max_len = 1000000;');
$sql = "

select p.to_org_id,p.to_org_name,sum((p.amount - p.amount_paid)) as amount,opm.*,
group_concat(p.payable_id) as payables
from v_payables p
inner join lo_order_line_item loi on (p.parent_obj_id=loi.lo_liid and loi.ldstat_id=4)
inner join lo_order_item_status_changes loisc on (loisc.lo_liid = loi.lo_liid and loisc.ldstat_id=4)
inner join lo_order lo on (lo.lo_oid=loi.lo_oid)
inner join domains d on (d.domain_id=lo.domain_id and d.seller_payer = 'hub')
left join organization_payment_methods opm on (d.opm_id=opm.opm_id )
where (p.amount - p.amount_paid) ".$config['amount-operator']." 0
and p.payable_type = 'seller order'
and p.payment_processing_statuses='confirmed'
and p.from_org_id=1
and loi.lbps_id=2
and loi.ldstat_id=4
";

if($config['start-delivery-date'] != 0)
{
	$sql .= " and loisc.creation_date > '".$config['start-delivery-date']."'\n";
}
if($config['start-from-date'] != 0)
{
	$sql .= " and p.creation_date > UNIX_TIMESTAMP('".$config['start-from-date']."')\n";
}
if($config['exclude-payables'] != 0)
{
	$sql .= " and p.payable_id not in (".$config['exclude-payables'].")\n";
}
if($config['exclude-foids'] != 0)
{
	$sql .= " and loi.lo_foid not in (".$config['exclude-foids'].")\n";
}
if($config['exclude-liids'] != 0)
{
	$sql .= " and loi.lo_liid not in (".$config['exclude-liids'].")\n";
}
if($config['seller-org-id'] != 0)
{
	$sql .= " and loi.seller_org_id= ".$config['seller-org-id']." \n";
}
if($config['mm-org-id'] != 0)
{
	$sql .= " and p.to_org_id= ".$config['mm-org-id']." \n";
}
if($config['domain-id'] != 0)
{
	$sql .= " and lo.domain_id= ".$config['domain-id']."\n ";
}


$sql .= "
group by concat_ws('-',p.to_org_id,p.from_org_id,p.payable_type)
order by p.creation_date;
";

if($config['report-sql'] == 1)	echo($sql);

$payments = new core_collection($sql);
$payments = $payments->to_array();
$cannot_process = array();
$no_payments = true;

foreach($payments as $payment)
{
	#print_r($payment);
	$no_payments = false;
	# get the list of payables so we can mark them as paid to seller
	$sql = 'select *,FROM_UNIXTIME(creation_date) as item_date from v_payables where payable_id in ('.$payment['payables'].');';
	if($config['report-sql'] == 1)	echo($sql);
	$payables = new core_collection($sql);
		
	# write some logging
	echo("Paying ".$payment['to_org_name']." (".$payment['to_org_id'].") ".core_format::price($payment['amount'])." ");
	if($config['report-payables'] == 1)
	{
		echo("for payables: \n");
		foreach($payables as $payable)
		{
			
			echo("\tpayment:".$payable['payment_processing_statuses']."|".$payable['item_date']."|".$payable['payable_info'].'|'.core_format::price((round(floatval($payable['amount']),2) - round(floatval($payable['amount_paid']),2)))."\n");
		}
	}
	else
	{
		echo(" \n");
	}
	
	# only do this if they actually have an account setup
	$opm_id = intval($payment['opm_id']);
	if($opm_id == 0)
	{
		echo("\tSeller has no payment method setup\n");
		$cannot_process[] = $payment;
	}
	else
	{
		$record = core::model('payments');
		$record['amount'] = $payment['amount'];
		$record['payment_method'] = 'ACH';
		$record['creation_date'] = time();
		$record->save();
		$trace   = 'P-'.str_pad($record['payment_id'],6,'0',STR_PAD_LEFT);
		
		
		if($config['do-ach'] == 1)
		{
			
		
			echo("\tprocessing payment: ".$trace."\n");
					
			$account = core::model('organization_payment_methods')->load($opm_id);
			$result = $account->make_payment($trace,'Orders',((-1) * $payment['amount']));
			
			if($result)
			{
				echo("\tPayment success!\n");
				
				# send emails of payment to both parties
				
				# update the payment record with the trace
				$record['ref_nbr'] = $trace;
				$record->save();
				
				# update payables
				foreach($payables as $payable)
				{
					$xpp = core::model('x_payables_payments');
					$xpp['payable_id'] = $payable['payable_id'];
					$xpp['payment_id'] = $record['payment_id'];
					$xpp['amount'] = (round(floatval($payable['amount']),2) - round(floatval($payable['amount_paid']),2));
					$xpp->save();
				}
				
				# create invoice for all seller payables
				# find all the seller payable ids:
				
				$invoice = core::model('invoices');
				$invoices['creation_date'] = time();
				$invoices['due_date'] = (time() + ( 7 * 86400 ));
				$invoice->save();
				foreach($payables as $payable)
				{
					$seller_payables = core::model('payables')
						->collection()
						->filter('payable_type','=','seller order')
						->filter('from_org_id','<>','1')
						->filter('parent_obj_id','=',$payable['parent_obj_id']);
					foreach($seller_payables as $seller_payable)
					{
						$seller_payable['invoice_id'] = $invoice['invoice_id'];
						$seller_payable->save();
					}
				}
				if($config['do-email'] == 1)
				{
					core::process_command('emails/payment_received',false,
						1,$payment['to_org_id'],$payment['amount'],$payables
					);
				}
			}
			else
			{
				$record->delete();
				echo("\tPAYMENT FAIL\n");
			}
			
			
		}
		else
		{
			if($config['do-email'] == 1)
			{
				core::process_command('emails/payment_received',false,
					1,$payment['to_org_id'],$payment['amount'],$payables
				);
			}
			$record->delete();
		}
	}
}

if($no_payments)
{
	echo("No payments due to sellers\n");
}


exit();
?>