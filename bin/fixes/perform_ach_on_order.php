<?php

global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();
core::load_library('crypto');

$config = array(
	'do-ach'=>0,
	'report-sql'=>0,
	'oid'=>9000,
);
array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

echo("Executing with config: \n");
print_r($config);
echo("\n");


$order = core::model('lo_order')->load($config['oid']);

if($order['payment_method'] == 'ach' and $order['payment_ref'] == '')
{
	$account = core::model('organization_payment_methods')
		->load(
		core_db::col('
			select opm_id from organization_payment_methods
			where org_id='.$order['org_id'].'
		','opm_id')
	);
	
	echo("Account details:");
	print_r($account->__data);
	
	$amount = 0;
	
	$sql = '
		select payable_id,amount
		from payables
		where from_org_id='.$order['org_id'].'
		and (
			(
				payable_type=\'delivery fee\'
				and parent_obj_id='.$order['lo_oid'].'
			)
			or
			(
			payable_type=\'buyer order\'
				and parent_obj_id in (
					select lo_liid from lo_order_line_item where lo_oid='.$order['lo_oid'].'
				)
			)
		)
	';
	if($config['report-sql'] == 1)
		echo($sql."\n");
	
	$payables = new core_collection($sql);
	$payable_ids = array();
	foreach($payables as $payable)
	{
		$payable_ids[$payable['payable_id']] = $payable['amount'];
		$amount += floatval($payable['amount']);
	}
	
	echo('Final payment amount '.$amount);
	if($config['do-ach'] == 1)
	{
		$payment = core::model('payments');
		$payment['from_org_id'] = $order['org_id'];
		$payment['to_org_id'] = 1;
		$payment['amount'] = $amount;
		$payment['payment_method'] = 'ACH';
		$payment['creation_date'] = time();
		$payment->save();
		
		
		
		
		$result = $account->make_payment('P-'.str_pad($payment['payment_id'],6,'0',STR_PAD_LEFT),'Order',$payment['amount']);
		
		if($result)
		{
			$order['payment_ref'] = 'P-'.str_pad($payment['payment_id'],6,'0',STR_PAD_LEFT);
			$order['lbps_id'] = 2;
			$order['amount_paid'] = $amount;
			$order->save();
			
			foreach($payable_ids as $payable_id=>$payable_amount)
			{
				$xpp = core::model('x_payables_payments');
				$xpp['payment_id'] = $payment['payment_id'];
				$xpp['payable_id'] = $payable_id;
				$xpp['amount'] = $payable_amount;
				$xpp->save();
			}
			
			exit('Payment succeeded: '.$payment['payment_id']);
		}
		else
		{
			exit("PAYMENT DID NOT SUCCEED\n".print_r($result,true));
		}
				
	}
}
else
{
	exit("This order already has been processed.");
}

?>