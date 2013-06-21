#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('crypto');
ob_end_flush();

mysql_query('SET SESSION group_concat_max_len = 1000000;');
$config = array(
	'do-ach'=>0,
	'domain-ids'=>0,
	'exclude-domain-ids'=>'2,3,25,26,6',
	'from-org-ids'=>0,
	'to-org-ids'=>0,
	'exclude-payable-ids'=>0,
	'report-payable-ids'=>0,
	'report-payable-details'=>0,
	'report-sql'=>0,
);

array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

echo("\nbeginning processing. using the following config:\n\n".print_r($config,true)."\n\n");

echo("NOTE: If the amount is NEGATIVE, this means Local Orbit will send that amount of money to the organization\n");
echo("      If the amount is POSITIVE, then we will pull that amount of money from the organization.\n\n");

global $payments_by_recip;
$payments_by_recip = array();

function handle_payment($payment)
{
	global $payments_by_recip;
	
	$dest = ($payment['from_org_id'] == 1)?$payment['to_org_id']:$payment['from_org_id'];
	
	# setup the payment by recip hash
	if(!isset($payments_by_recip[$dest]))
	{
		$payments_by_recip[$dest] = array(
			'org_id'=>$dest,
			'amount'=>0,
			'name'=>($payment['from_org_id'] == $dest)?$payment['from_org_name']:$payment['to_org_name'],
			'opm_id'=>$payment['opm_id'],
			'amounts'=>array(),
			'payable_ids'=>array(),
			'details'=>array(),
		
		);
	}
	
	$amount = floatval($payment['amount']);
	
	# if the amount is FROM local orbit, record the amount as a negative.
	$inverter = 1;
	if($payment['from_org_id'] == 1)
	{
		$inverter = -1;
	}
	$payments_by_recip[$dest]['amount'] += ($inverter * $amount);
	
	# explode/append the individual payable amounts. Invert if necessary
	$amounts = explode(',',$payment['amounts']);
	foreach($amounts as $line_item)
	{
		$payments_by_recip[$dest]['amounts'][] = ($inverter * $line_item);
	}
	
	# also append the ids and details.
	$payments_by_recip[$dest]['payable_ids'] = array_merge($payments_by_recip[$dest]['payable_ids'],explode(',',$payment['payable_ids']));
	$payments_by_recip[$dest]['details'] = array_merge($payments_by_recip[$dest]['details'],explode('$$',$payment['payable_info']));
}

# get the delivery fees
# this is the base SQL used to pull the payables covered by the payment
mysql_query('SET SESSION group_concat_max_len = 1000000;');
$sql = "
	select 
		sum(p.amount - p.amount_paid) as amount,p.domain_id,d.name as domain_name,
		group_concat(p.payable_info separator '$$') as payable_info,
		p.from_org_id,p.to_org_id,p.from_org_name,p.to_org_name,
		group_concat(p.payable_id separator ',') as payable_ids,
		group_concat((p.amount - p.amount_paid) separator ',') as amounts,
		d.opm_id
	from v_payables p
	inner join domains d on (p.domain_id=d.domain_id)
	inner join lo_order lo on (p.parent_obj_id=lo.lo_oid)
	where p.payable_type in ('delivery fee')
	and (
		(from_org_id=1 and to_org_id in (select org_id from organizations_to_domains where orgtype_id=2))
		or
		(to_org_id=1 and from_org_id in (select org_id from organizations_to_domains where orgtype_id=2))
	)
	and (p.amount - p.amount_paid) > 0
	and lo.lbps_id = 2
";

# add on any clauses based on the command line parameters
# domain-ids is *probably* the most useful
if($config['domain-ids'] != 0)
{
	$sql .= ' and p.domain_id in ('.$config['domain-ids'].') ';
}
if($config['exclude-domain-ids'] != 0)
{
	$sql .= ' and p.domain_id not in ('.$config['exclude-domain-ids'].') ';
}
if($config['from-org-ids'] != 0)
{
	$sql .= ' and p.from_org_id in ('.$config['from-org-ids'].') ';
}
if($config['to-org-ids'] != 0)
{
	$sql .= ' and p.to_org_id in ('.$config['to-org-ids'].') ';
}
if($config['exclude-payable-ids'] != 0)
{
	$sql .= ' and p.payable_id not in ('.$config['exclude-payable-ids'].') ';
}
$sql .= " group by concat_ws('-',p.domain_id,p.from_org_id,p.to_org_id) ";
if($config['report-sql'] == 1)	echo($sql."\n\n");

$payments = new core_collection($sql);
foreach($payments as $payment)
{
	handle_payment($payment);
}


# handle the lo / market fees
$sql = "
	select 
		sum(p.amount - p.amount_paid) as amount,p.domain_id,d.name as domain_name,
		group_concat(p.payable_info separator '$$') as payable_info,
		p.from_org_id,p.to_org_id,p.from_org_name,p.to_org_name,
		group_concat(p.payable_id separator ',') as payable_ids,
		group_concat((p.amount - p.amount_paid) separator ',') as amounts,
		d.opm_id
	from v_payables p
	inner join domains d on (p.domain_id=d.domain_id)
	inner join lo_order_line_item loi on (p.parent_obj_id=loi.lo_liid)
	inner join lo_order lo on (loi.lo_oid=lo.lo_oid)
	
	where p.payable_type in ('hub fees','lo fees')
	
	and (
		(from_org_id=1 and to_org_id in (select org_id from organizations_to_domains where orgtype_id=2))
		or
		(to_org_id=1 and from_org_id in (select org_id from organizations_to_domains where orgtype_id=2))
	)
	and (p.amount - p.amount_paid) > 0
	and lo.lbps_id = 2
";

# add on any clauses based on the command line parameters
# domain-ids is *probably* the most useful
if($config['domain-ids'] != 0)
{
	$sql .= ' and p.domain_id in ('.$config['domain-ids'].') ';
}
if($config['exclude-domain-ids'] != 0)
{
	$sql .= ' and p.domain_id not in ('.$config['exclude-domain-ids'].') ';
}
if($config['from-org-ids'] != 0)
{
	$sql .= ' and p.from_org_id in ('.$config['from-org-ids'].') ';
}
if($config['to-org-ids'] != 0)
{
	$sql .= ' and p.to_org_id in ('.$config['to-org-ids'].') ';
}
if($config['exclude-payable-ids'] != 0)
{
	$sql .= ' and p.payable_id not in ('.$config['exclude-payable-ids'].') ';
}
$sql .= " group by concat_ws('-',p.domain_id,p.from_org_id,p.to_org_id) ";
if($config['report-sql'] == 1)	echo($sql."\n\n");

$payments = new core_collection($sql);
foreach($payments as $payment)
{
	handle_payment($payment);
}



# loop over the payments and report them
foreach($payments_by_recip as $org_id=>$payment)
{
	echo(' ' . core_format::price($payment['amount'],false)." ");
	echo(" to ".$payment['name']." (".$org_id.")\n");
	
	# report as necessary
	if($config['report-payable-ids'] == 1)
	{
		echo("\tthis covers payable_ids: ".implode(',',$payment['payable_ids'])."\n");
	}
	
	if($config['report-payable-details'] == 1)
	{
		echo("\tpayable details: \n\t------------------------------\n");
		for($i=0;$i<count($payment['details']);$i++)
		{
			echo("\t".$payment['payable_ids'][$i]." : ".core_format::price($payment['amounts'][$i],false)." : ".$payment['details'][$i]."\n");
		}
		echo("\t------------------------------\n");
	}
	echo("\n");
	
	
	# figure out if we can do the payment
	$sql = '';
	if($config['report-sql'] == 1)	echo($sql."\n\n");
	
	if(!is_numeric($payment['opm_id']))
	{
		echo("\tthis market does not have a bank acount setup\n");
	}
	else
	{
		if($config['do-ach'] == 1)
		{
			echo("\tperforming charges \n");
			
			
		}
	}
}

exit("processing complete\n");

foreach($markets as $market)
{
	$payments_found = true;
}

	if($config['do-ach'])
	{
		/*
		$record = core::model('payments');
		$record['amount'] = $payment['amount'];
		$record['payment_method'] = 'ACH';
		$record['creation_date'] = time();
		$record->save();
		$trace   = 'P-'.str_pad($record['payment_id'],6,'0',STR_PAD_LEFT);
		echo("\tprocessing payment: ".$trace."\n");
				
		$account = core::model('organization_payment_methods')->load($opm_id);
		$result = $account->make_payment($trace,'Orders',((-1) * $payment['amount']));
		
		if($result)
		{
			echo("\tPayment success!\n");
			
			# send emails of payment to both parties
			core::process_command('emails/payment_received',false,
				1,$payment['to_org_id'],$amount,$payables
			);
			
			# update the payment record with the trace
			$record['ref_nbr'] = $trace;
			$record->save();
			
			# update payables
			foreach($payables as $payable)
			{
				$xpp = core::model('x_payables_payments');
				$xpp['payable_id'] = $payable['payable_id'];
				$xpp['payment_id'] = $record['payment_id'];
				$xpp['amount'] = (round(floatval($payable['amount']),2) - round(floatval($payable['amount_due']),2));
				$xpp->save();
				
				# load the item
				$item = core::model('lo_order_line_item')->load($payable['parent_obj_id']);
				$item->change_status('lsps_id',2);
				$orders_to_check[] = $item['lo_oid'];
			}
			
			# update the items 
			$orders_to_check = core::model('lo_order')
				->collection()
				->filter('lo_oid','in',$orders_to_check);
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
		* */
	
}

if($no_payments)
{
	echo("No payments due to markets\n");
}


exit();
?>