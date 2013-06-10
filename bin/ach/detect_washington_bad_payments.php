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
	'do-create'=>0,
);


array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

$sql = "
	select p.*,lo.payment_method,loi.row_adjusted_total,lo.domain_id
	from v_payables p
	inner join lo_order_line_item loi on (p.parent_obj_id=loi.lo_liid)
	inner join lo_order lo on (lo.lo_oid=loi.lo_oid)
	inner join domains d on (d.domain_id=lo.domain_id)
	where payable_type = 'seller order' 
	and p.amount_paid = p.amount
	and from_org_id=1
	and d.seller_payer = 'lo'
	and lo.domain_id in (14,19,30)
";
if($config['seller-org-id'] != 0)
{
	$sql .= ' and p.to_org_id='.$config['seller-org-id'].' ';
}

if($config['report-sql'] == 1)	echo($sql)."\n\n";
$payables = new core_collection($sql);

$sellers = array();

foreach($payables as $payable)
{
	if(!isset($sellers[$payable['to_org_id']]))
	{
		$sellers[$payable['to_org_id']] = array(
			'name'=>$payable['to_org_name'].' ('.$payable['to_org_id'].')',
			'org_id'=>$payable['to_org_id'],
			'domain_id'=>$payable['domain_id'],
			'broken_total'=>0,
			'correct_total'=>0,
			'items'=>array(),
		);
	}
	
	$fee = ($payable['payment_method'] == 'paypal')?3:0;
	
	$sellers[$payable['to_org_id']]['broken_total'] += $payable['amount'];
	$sellers[$payable['to_org_id']]['correct_total'] += round($payable['row_adjusted_total'] * ((100 - $fee) / 100),2);
	$sellers[$payable['to_org_id']]['items'][$payable['parent_obj_id']] = round((($payable['row_adjusted_total'] * ((100 - $fee) / 100)) - $payable['amount']),2);
}

$found = false;
foreach($sellers as $seller)
{
	$found = true;
	echo("checking ".$seller['name'].":");
	if($seller['broken_total'] == $seller['correct_total'])
	{
		echo(" paid correctly!\n\n");
	}
	else
	{
		echo("\n\tWe paid them:            ".core_format::price($seller['broken_total']));
		echo("\n\tWe should've paid them:  ".core_format::price($seller['correct_total']));
		echo("\n\tWe should now send them: ".core_format::price($seller['correct_total'] - $seller['broken_total']));
		if($config['report-payables'] == 1)
		{
			echo("\n\tThis covers items:    ".implode(',',array_keys($seller['items'])));
		}
		
		
		foreach($seller['items'] as $lo_liid=>$amount)
		{
			$sql = '
				insert into payables 
					(domain_id,from_org_id,to_org_id,payable_type,parent_obj_id,amount,creation_date)
				values
					('.$seller['domain_id'].',1,'.$seller['org_id'].',\'seller order\','.$lo_liid.','.$amount.',UNIX_TIMESTAMP(CURRENT_TIMESTAMP));
				';
			if($config['report-sql'] == 1)	echo("\n".$sql);
			
			if($config['do-create'] == 1)
			{
				core_db::query($sql);
			}
		}
		
		echo("\n\n");
		
	}
}
if(!$found)
{
	echo("no sellers needed adjustments\n");
}
exit("complete\n");
?>