#!/usr/bin/php
<?php

# basic sectup
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'seller-org-id'=>0,  # allows you to restrict the query to a single vendor
	'report-payables'=>0, # prints out info on all the payables covered by the payment
	'report-sql'=>0,
	'do-adjust'=>0,
	'domains'=>'14,19,30',
	'check-limit'=>0,
	'exit-on-error'=>0,
	'lo-oid'=>0,
	'lo-liid'=>0,
	'start-lo-oid'=>6400,
	'report-good'=>0,
);


array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

$sql = "
	select loi.*,lo.fee_percen_lo,lo.fee_percen_hub,d.paypal_processing_fee,lo.payment_method,
	lo.domain_id
	from lo_order_line_item loi
	inner join lo_order lo on (lo.lo_oid=loi.lo_oid)
	inner join payables p on (p.parent_obj_id=loi.lo_liid and p.payable_type='buyer order')
	left join x_payables_payments xpp on (p.payable_id=xpp.payable_id)
	left join payments py on (py.payment_id=xpp.payment_id)
	inner join domains d on (d.domain_id=lo.domain_id)
	where lo.domain_id in (".$config['domains'].")
";


if($config['seller-org-id'] != 0)
{
	$sql .= ' and loi.seller_org_id='.$config['seller-org-id'].' ';

}

if($config['lo-oid'] != 0)
{
	$sql .= ' and loi.lo_oid='.$config['lo-oid'].' ';

}

if($config['lo-liid'] != 0)
{
	$sql .= ' and loi.lo_liid='.$config['lo-liid'].' ';

}
$sql .= ' and loi.lo_oid >='.$config['start-lo-oid'].' ';

$sql .= ' order by lo_liid desc';

if($config['report-sql'] == 1)	echo($sql)."\n\n";
$items = new core_collection($sql);

$sellers = array();
$checked = 0;
foreach($items as $item)
{
	ob_start();
	
	# processing here
	echo("checking item ".$item['lo_liid']." in order ".$item['lo_oid'].": ".$item['product_name']."\n");
	
	$sql = '
		select sum(amount) as amount,sum(amount_paid) as amount_paid
		from v_payables 
		where parent_obj_id='.$item['lo_liid'].'
		and payable_type=\'seller order\'
		and from_org_id=1
	';
	if($config['report-sql'] == 1)	echo("\t".$sql."\n");
	$payments = mysql_query($sql);
	$payments = mysql_fetch_assoc($payments);
	
	$fee = ((100 - (($item['payment_method'] == 'paypal')?$item['paypal_processing_fee']:0)) / 100);
	$bad = false;
	$current_paid   = round(floatval($payments['amount_paid']),2);
	$current_amount = round(floatval($payments['amount']),2);
	$correct_amount = round(floatval($item['row_adjusted_total'] * $fee),2);
	
	echo("\tCurrent Amount: ".$current_amount."\n");
	echo("\tCorrect Amount: ".$correct_amount."\n");
	
	if($correct_amount != $current_amount)
	{
		$bad = true;
		echo("\twe need to add an additional payable for  ".($correct_amount - $current_amount)."\n");
		if($config['exit-on-error'] == 1)
		{
			exit();
		}
		
		if(($correct_amount - $current_amount) < 0)
		{
			echo("\tSerious problem: The payments to the seller are HIGHER than they should be :(\n");
		}
		else
		{
		
			$sql = '
				insert into payables 
					(domain_id,from_org_id,to_org_id,payable_type,parent_obj_id,amount,creation_date)
				values
					('.$item['domain_id'].',1,'.$item['seller_org_id'].',\'seller order\','.$item['lo_liid'].','.($correct_amount - $current_amount).','.time().');
			';
			if($config['report-sql'] == 1)	echo("\t".$sql."\n");
			if($config['do-adjust'] == 1)
			{
				mysql_query($sql);
			}
		}
		
	}
	else
	{
		echo("\tYAY\n\n");
	}
	
	$out = ob_get_clean();
	if($bad || $config['report-good'] == 1)
	{
		echo($out);
	}
	
	
	$checked++;
	if($config['check-limit'] != 0 && $checked >= $config['check-limit'])
		break;
}


exit("complete\n");
?>