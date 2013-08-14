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
	'payment-id'=>0,
);

array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

if($config['payment-id'] == 0)
{
	exit("You must specify a payment id: php -f reprocess_payment.php payment-id:222222\n");
}

echo("\nbeginning processing. using the following config:\n\n".print_r($config,true)."\n\n");

$payment = core::model('v_payments')->load($config['payment-id']);
$amount  = $payment['amount'];
$from_lo = ($payment['from_org_id'] == 1);
if($from_lo)
	$amount = (-1 * $amount);

$accounts = core::model('organization_payment_methods')
	->collection()
	->filter('org_id','=',($from_lo)?$payment['to_org_id']:$payment['from_org_id']);

$accounts->load();
$accounts->next();
$account = $accounts->__model;



if(!is_numeric($account['opm_id']))
{
	exit("could not find an account for this org :(\n");
}

echo("Final payment details: \n\n");

echo("     Trace: P-".str_pad($config['payment-id'],6,'0',STR_PAD_LEFT)."\n");
echo("    Amount: ".$amount."\n");
echo("      From: ".$payment['from_org_name']." (".$payment['from_org_id'].")\n");
echo("    Amount: ".$payment['to_org_name']." (".$payment['to_org_id'].")\n");
echo("  Acc Name: ".$account['name_on_account']."\n");
echo("   Account: ".$account->get_account_nbr()."\n");
echo("   Routing: ".$account->get_routing_nbr()."\n");
echo("      Mode: ".(($config['do-ach'] == 1)?'PROCESS':'TEST')."\n");

if($config['do-ach'] == 1)
{
	$result = $account->make_payment("P-".str_pad($config['payment-id'],6,'0',STR_PAD_LEFT),"Orders",$amount);
	
	if($result)
	{
		echo("\tPayment success!\n");
	}
	else
	{
		exit("\npayment failed. Check email for details\n");
	}
}


exit("\ncomplete!\n");
?>
