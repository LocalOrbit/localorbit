#!/usr/bin/php
<?php

# basic sectup
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'payable-types'=>"'seller order'",
	'to-org-ids'=>0,
	'from-org-ids'=>0,
	'start-lo-oid'=>6400,
	'domain-ids'=>0,
	'report-sql'=>0,
	'do-adjust'=>0,
	'check-limit'=>0,
	'exit-on-error'=>0,
	'report-good'=>0,
);

array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

$sql = '
	select sum(p.amount) as amount,sum(p.amount_paid) as amount_paid,
	group_concat(p.payable_id separator \',\') as payable_ids,
	loi.lo_liid,loi.row_adjusted_total,lo.fee_percen_lo,lo.fee_percen_hub,lo.payment_method,
	d.paypal_processing_fee,p.payable_type,p.domain_id,p.from_org_id,p.to_org_id
	from v_payables p
	inner join lo_order_line_item loi on (p.parent_obj_id = loi.lo_liid)
	inner join lo_order lo on (lo.lo_oid = loi.lo_oid)
	inner join domains d on (lo.domain_id=d.domain_id)
	where p.payable_type in ('.$config['payable-types'].')
	and lo.ldstat_id<>1
	
';

if($config['to-org-id'] != 0)
	$sql .= ' and p.to_org_id='.$config['to-org-id'].' ';
if($config['to-org-id'] != 0)
	$sql .= ' and p.to_org_id='.$config['to-org-id'].' ';
if($config['from-org-id'] != 0)
	$sql .= ' and p.from_org_id='.$config['from-org-id'].' ';
if($config['domain-ids'] != 0)
	$sql .= ' and lo.domain_id in ('.$config['domain-ids'].') ';
if($config['start-lo-oid'] != 0)
	$sql .= ' and lo.lo_oid >= '.$config['start-lo-oid'].' ';

$sql .= ' group by concat_ws(\' \',p.payable_type,p.parent_obj_id,p.from_org_id,p.to_org_id) ';

if($config['report-sql'] == 1)	echo("\n$sql\n\n");

$payables = new core_collection($sql);
$checked = 0;
foreach($payables as $payable)
{
	$correct = $payable['row_adjusted_total'];
	$current = round(floatval($payable['amount']),2);
	
	$fee = 100;
	switch($payable['payable_type'])
	{
		case 'seller order':
			$fee -= ($payable['payment_method'] == 'paypal')?$payable['paypal_processing_fee']:0;
			$fee -= $payable['fee_percen_hub'];
			$fee -= $payable['fee_percen_lo'];
			$fee = ($fee / 100);
			break;
		case 'hub fees':
			$fee = $payable['fee_percen_hub'] / 100;
			break;
		case 'lo fees':
			$fee = $payable['fee_percen_lo'] / 100;
			break;
	}
	$correct = round(floatval($fee * $correct),2);
	
	if($correct == $current && $config['report-good'] == 1)
	{
		echo("Checking ".$payable['lo_liid'].": GOOD\n");
	}
	
	
	
	if($correct != $current)
	{
		$payable_ids = explode(',',$payable['payable_ids']);
		
		echo("Checking ".$payable['lo_liid'].": BAD\n");
		echo("\t     Fee % should be: ".$fee."\n");
		echo("\tPayable is/should be: ".$current.'/'.$correct."\n");
		echo("\tPayable IDs: ".implode(',',$payable_ids)."\n");
		
		
		if(count($payable_ids) != 1)
		{
			echo("\tCould not find a solution for this payable, multipe payables exist\n");
			
		}
		else
		{
			if($payable['amount_paid'] > 0 && $correct > $current)
			{
				echo("\tPayment already exists, need to create a new one\n");
				$new = core::model('payables');
				$new['domain_id'] = $payable['domain_id'];
				$new['from_org_id'] = $payable['from_org_id'];
				$new['to_org_id'] = $payable['to_org_id'];
				$new['amount'] = $correct - $current;
				$new['creation_date'] = time();
				$new->save();
			}
			else if($payable['amount_paid'] > 0 && $correct > $current)
			{
				echo("\tSerious problem. Payment has already been made for an amount greater than it should've been\n");
			}
			else
			{
			
				$sql = '
					update payables set
						amount = '.$correct.'
					where payable_id='.implode($payable_ids);
					
						
				if($config['report-sql'] == 1)	
					echo("$sql\n\n");
				if($config['do-adjust'] == 1)	
					mysql_query($sql);
			}
		}
	
		if($config['exit-on-error'] == 1)	
			exit("exiting on error \n");
	}
	
	$checked++;
	if($config['check-limit'] != 0 && $checked == $config['check-limit'])
		exit("check limit reached\n");
}


exit("complete. ".$checked." payables were checked.\n");
?>