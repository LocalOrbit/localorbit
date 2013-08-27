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
	'new-id'=>1,
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

$old_payment = core::model('v_payments')->load($config['payment-id']);
$amount  = $old_payment['amount'];
$from_lo = ($old_payment['from_org_id'] == 1);
if($from_lo)
	$amount = (-1 * $amount);

$accounts = core::model('organization_payment_methods')
	->collection()
	->filter('org_id','=',($from_lo)?$old_payment['to_org_id']:$old_payment['from_org_id']);

$accounts->load();
$accounts->next();
$account = $accounts->__model;


if($config['new-id'] == 1)
{
	$new_payment = core::model('payments');
	$new_payment['amount'] = $old_payment['amount'];
	$new_payment['payment_method'] = $old_payment['payment_method'];
	$new_payment['admin_note'] = $old_payment['admin_note'];
	$new_payment['creation_date'] = time();
	$new_payment->save();
	$new_payment['ref_nbr'] = "P-".str_pad($new_payment['payment_id'],6,'0',STR_PAD_LEFT);
}
else
{
	$new_payment = $old_payment;
}


if(!is_numeric($account['opm_id']))
{
	exit("could not find an account for this org :(\n");
}

echo("Final payment details: \n\n");

echo("     Trace: ".$new_payment['ref_nbr']."\n");
echo("    Amount: ".$amount."\n");
echo("      From: ".$old_payment['from_org_name']." (".$old_payment['from_org_id'].")\n");
echo("    Amount: ".$old_payment['to_org_name']." (".$old_payment['to_org_id'].")\n");
echo("  Acc Name: ".$account['name_on_account']."\n");
echo("   Account: ".$account->get_account_nbr()."\n");
echo("   Routing: ".$account->get_routing_nbr()."\n");
echo("      Mode: ".(($config['do-ach'] == 1)?'PROCESS':'TEST')."\n");

if($config['do-ach'] == 1)
{
	$result = $account->make_payment($new_payment['ref_nbr'],"Orders",$amount);
	
	if($result)
	{
		echo("\tPayment success!\n");
		if($config['new-id'] == 1)
		{
			$query = '
				update x_payables_payments
				set payment_id='.$new_payment['payment_id'].' 
				where payment_id='.$old_payment['payment_id'].';
			';
			echo($query."\n");
			core_db::query($query);
		}
	
	}
	else
	{
		exit("\npayment failed: ".print_r($account['last_result'],true)."\n");
		
	}
}


exit("\ncomplete!\n");
?>
