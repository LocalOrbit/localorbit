#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('crypto');
ob_end_flush();

mysql_query('SET SESSION group_concat_max_len = 1000000;');
$config = array(
	'payment-type'=>0,
	'from-org'=>0,
	'to-org'=>0,
	'amount'=>0,
	'domain-id'=>0,
	'parent-obj-id'=>0,
	'do-ach'=>0,
	'report-details'=>0,
	'memo'=>'',
);

array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

if($config['payment-type'] == 'service')
{
	$config['parent-obj-id'] = $config['domain-id'];
}




echo("\nbeginning processing. using the following config:\n\n".print_r($config,true)."\n\n");


if($config['from-org'] == 0 || $config['to-org'] == 0 || $config['amount'] <= 0 || $config['payment-type'] === 0 ||  $config['domain-id'] == 0)
{
	exit("you must pass from-org, to-org, amount, domain-id, and payment-type [seller,buyer,lo,market,delivery,service]\n");
}

$opms = core::model("organization_payment_methods")
	->collection()
	->filter('org_id','=',($config['from-org'] == 1)?$config['to-org']:$config['from-org']);
$opms->load();
$opms->next();
$method = $opms->current();
if($config['report-details'] == 1)
	echo('account: '.print_r($method->__data,true));

$types = array(
	'buyer'=>'buyer order',
	'seller'=>'seller order',
	'hub'=>'hub fees',
	'lo'=>'lo fees',
	'service'=>'service fee',
	'delivery'=>'delivery fee',
);

$payable = core::model('payables');

$payable['domain_id']   = $config['domain-id'];
$payable['payable_type']   = $types[$config['payment-type']];
$payable['from_org_id'] = $config['from-org'];
$payable['to_org_id']   = $config['to-org'];
$payable['amount']      = $config['amount'];
$payable['parent_obj_id'] = $config['parent-obj-id'];
$payable['creation_date'] = time();

if($config['do-ach'] == 1)
	$payable->save();
if($config['report-details'] == 1)
	echo('payable: '.print_r($payable->__data,true));
	
$payment = core::model('payments');
$payment['amount'] = $config['amount'];
$payment['payment_method'] = 'ACH';
$payment['creation_date'] = time();

$final_amount = $config['amount'];
if($config['from-org'] == 1)
{
	$final_amount = (-1) * $final_amount;
}

if($config['report-details'] == 1)
{
	echo("final amount: $final_amount \n");
	echo('payment: '.print_r($payment->__data,true));
}

if($config['do-ach'] == 1)
{
	$payment->save();
	$payment['ref_nbr'] = 'P-'.str_pad($payment['payment_id'],6,0,STR_PAD_LEFT);
	$payment->save();

	$result = $method->make_payment($payment['ref_nbr'],(($config['memo'] === '')?'Fees':$config['memo']),$final_amount);
	if($result)
	{
		echo("Payment success\n");
		$xpp = core::model('x_payables_payments');
		$xpp['payable_id'] = $payable['payable_id'];
		$xpp['payment_id'] = $payment['payment_id'];
		$xpp['amount'] = $config['amount'];
		$xpp->save();
		if($config['report-details'] == 1)
			echo('xpp: '.print_r($xpp->__data,true));
	}
	else
	{
		echo("payment failed\n");
		$payment->delete();
		$payable->delete();
		
	}
}



$account_org = ($config['from-org'] == 1)?$config['to-org']:$config['from-org'];


exit("\ncomplete!\n");
?>
