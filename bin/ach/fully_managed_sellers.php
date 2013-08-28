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
	'seller-org-id'=>0,  # allows you to restrict the query to a single vendor
	'report-payables'=>0, # prints out info on all the payables covered by the payment
	'exclude-domain-ids'=>'35',
	'exclude-oids'=>0,
	'exclude-foids'=>'9222,9223,9221',
	'exclude-payables'=>0,
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



$sql = "
	select p.to_org_id,p.to_org_name,sum((p.amount - p.amount_paid)) as amount,opm.*,
	group_concat(p.payable_id) as payables
	from v_payables p
	inner join lo_order_line_item loi on (p.parent_obj_id=loi.lo_liid)
	inner join lo_order lo on (loi.lo_oid = lo.lo_oid)
	inner join domains d on (d.domain_id=lo.domain_id)
	inner join organizations o on (o.org_id=loi.seller_org_id)
	left join organization_payment_methods opm on (o.opm_id=opm.opm_id )
	where (p.amount - p.amount_paid) > 0
	and p.payable_type = 'seller order'
	and p.from_org_id=1
	and loi.ldstat_id=4
	and loi.lbps_id=2
	and d.seller_payer = 'lo'";

if($config['seller-org-id'] !== 0)
{
	$sql .= ' and p.to_org_id='.$config['seller-org-id'].' ';
}
if($config['exclude-domain-ids'] !== 0)
{
	$sql .= ' and p.domain_id not in ('.$config['exclude-domain-ids'].') ';
}
if($config['exclude-oids'] !== 0)
{
	$sql .= ' and loi.lo_oid not in ('.$config['exclude-oids'].') ';
}
if($config['exclude-foids'] !== 0)
{
	$sql .= ' and loi.lo_foid not in ('.$config['exclude-foids'].') ';
}
if($config['exclude-payables'] !== 0)
{
	$sql .= ' and p.payable_id not in ('.$config['exclude-payables'].') ';
}


$sql .="
	group by concat_ws('-',p.to_org_id,p.payable_type)
";
$payments = new core_collection($sql);
$payments = $payments->to_array();
$cannot_process = array();
$no_payments = true;

foreach($payments as $payment)
{
	$no_payments = false;
	# get the list of payables so we can mark them as paid to seller
	$payables = core::model('v_payables')
		->collection()
		->filter('payable_id','in',explode(',',$payment['payables']))
		->sort('parent_obj_id');
		
	# write some logging
	echo("Paying ".$payment['to_org_name']." (".$payment['to_org_id'].") ".core_format::price($payment['amount'])." ");
	if($config['report-payables'] == 1)
	{
		echo(" for payables: \n");
		foreach($payables as $payable)
		{
			echo("\t".$payable['payable_info'].' '.core_format::price((round(floatval($payable['amount']),2) - round(floatval($payable['amount_due']),2)))."\n");
		}
	}
	else
	{
		echo("\n");
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
				if($config['do-email'] == 1)
				{
					core::process_command('emails/payment_received',false,
						1,$payment['to_org_id'],$payment['amount'],$payables
					);
				}
				
				# update the payment record with the trace
				$record['ref_nbr'] = $trace;
				$record->save();
				
				# update payables
				$orders_to_check = array();
				foreach($payables as $payable)
				{
					$xpp = core::model('x_payables_payments');
					$xpp['payable_id'] = $payable['payable_id'];
					$xpp['payment_id'] = $record['payment_id'];
					$xpp['amount'] = (round(floatval($payable['amount']),2) - round(floatval($payable['amount_paid']),2));
					$xpp->save();
					
					# load the item
					$item = core::model('lo_order_line_item')->load($payable['parent_obj_id']);
					$item->change_status('lsps_id',2);
					$orders_to_check[] = $item['lo_oid'];
				}
				
				# update the items 
				$orders_to_check = core::model('lo_order')
					->collection()
					->filter('lo_oid','in',implode(',',$orders_to_check));
				foreach($orders_to_check as $order)
				{		
					$core->config['domain']['domain_id'] = $order['domain_id'];
					$order->update_status();
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