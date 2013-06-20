#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

core::load_library('crypto');

global $config;
$config = array(
	'do-ach'=>0,
	'do-email'=>0,
	'is-live'=>1,
	'domain-ids'=>0,  # allows you to restrict the query to a single domain
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


$sql = '
	select * 
	from domains
	where service_fee > 0
';

if($config['domain-ids'] != 0)
{
	$sql .= ' and domain_id in ('.$config['domain-ids'].') ';
}


if($config['is-live'] == 1)
{
	$sql .= ' and is_live=1 	';
}


	


# loop through the domains and calculate the fee
$domains = new core_collection($sql);
foreach($domains as $domain)
{
	
	echo('checking '.$domain['name']." (".$domain['domain_id'].") \n");
	echo("\tservice fee is:      ".$domain['service_fee']."\n");
	echo("\tservice schedule is: ".$domain['sfs_id']."\n");
	echo("\tlast paid is:        ".$domain['service_fee_last_paid']."\n");   
	
	# get some date info
	$do_fee = false;
	$last = explode('-',date('Y-m',$domain['service_fee_last_paid']));
	$now  = explode('-',date('Y-m',time()));
	
	# if the year has changed, adjust the number of months accordingly.
	if($now[0] != $last[0])
	{
		$now[1] + 12;
	}
	$last_paid_difference  = $now[1] - $last[1];

	#echo("\tdifference between last paid is: ".$last_paid_difference."\n");
	switch($domain['sfs_id'])
	{
		case 1:
			$min_diff = 1;
			break;
		case 2:
			$min_diff = 6;
			break;
		case 3:
			$min_diff = 12;
			break;
	}
	
	#echo('months: '.intval($now[1]).' / '.intval($last[1])."\n");
	
	# check if we need to charge the client
	if((intval($now[1]) - intval($last[1])) >= $min_diff)
	{
		echo("\tneed to do payment for ".$domain['service_fee']."\n");
		if(!is_numeric($domain['opm_id']) || $domain['opm_id'] == 0)
		{
			echo("\tthis market does NOT have an account setup\n");
		}
		else
		{
			do_monthly_payment($domain);
		}
	}
	else
	{
		echo("\tno need to do payment for this market\n");
	}
}



function do_monthly_payment($domain)
{
	global $core,$config;
	#echo("called\n");

	if($config['do-ach'] == 1)
	{
		$payment = core::model('payments');
		$payment['amount'] = $domain['service_fee'];
		$payment['payment_method'] = 'ACH';
		$payment['creation_date'] = time();
		$payment->save();
		$trace   = 'P-'.str_pad($payment['payment_id'],6,'0',STR_PAD_LEFT);
		$payment['ref_nbr'] = $trace;
		
		
		
		$account = core::model('organization_payment_methods')->load($domain['opm_id']);
		$result = $account->make_payment($trace,'Services',round(floatval($payment['amount']),2));
		
		
		if($result)
		{
			echo("\tPayment success!\n");
			
			# now we need to create the paayble for it.
			$payable = core::model('payables');
			$payable['domain_id'] = $domain['domain_id'];
			$payable['from_org_id'] = 1;
			$payable['to_org_id'] = $domain['payable_org_id'];
			$payable['payable_type'] = 'service fee';
			$payable['parent_obj_id'] = $domain['domain_id'];
			$payable['amount'] = $payment['amount'];
			$payable['creation_date'] = time();
			$payable->save();
			
			$xpp = core::model('x_payables_payments');
			$xpp['payable_id'] = $payable['payable_id'];
			$xpp['payment_id'] = $payment['payment_id'];
			$xpp['amount'] = (round(floatval($payable['amount']),2));
			$xpp->save();
			
			
			core_db::query('update domains set service_fee_last_paid=CURRENT_TIMESTAMP where domain_id='.$domain['domain_id']);
			
			
			if($config['do-email'] == 1)
			{
				core::process_command('emails/payment_received',false,
					1,$domain['payable_org_id'],$payment['amount'],array()
				);
			}
			
		}
		else
		{
			$payment->save();
		}
		
	}
}

exit("done\n");

?>