#!/usr/bin/php
<?php

# basic sectup
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'max'=>5, # pass max:# to stop after a certain # of errors. 0 for unlimited.
	'do-deletes'=>0, # pass do-deletes:1 to make this actually perform deletes
	'report-sql'=>0, # pass report-sql:1 to make this actually echo sql
);

# parse the arguments
array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

# this query finds all of the item payables and determines how many seller payables there are.
$sql = "
	select loi.lo_liid,(select count(payable_id) from payables p where loi.lo_liid=p.parent_obj_id and p.payable_type='seller order') as total_payables
	from lo_order_line_item loi
";
$items = new core_collection($sql);

echo("looping through items\n");
$error_count = 0;
foreach($items as $item)
{
	# loop through all of the items
	
	if($item['total_payables'] > 2)
	{
		# No item should have more than 2 seller payable items, so this is a problem.
		echo("\tfound dupe payables for item ".$item['lo_liid']."\n\n");
		
		# query for all the dupes and examine them.
		$payables = core::model('v_payables')->collection()->filter('parent_obj_id','=',$item['lo_liid'])->filter('payable_type','seller order');
		$grouped_by_to_from_amount = array();
		
		# group the payables by common to/from/amount. The dupes have all of these in common.
		foreach($payables as $payable)
		{
			$key = $payable['from_org_id'] .'-'.$payable['to_org_id'] .'-'.$payable['amount'];
			if(!isset($grouped_by_to_from_amount[$key]))
			{
				$grouped_by_to_from_amount[$key] = array();
			}
			$grouped_by_to_from_amount[$key][] = $payable->__data;
		}
		
		# loop through the groupings
		foreach($grouped_by_to_from_amount as $group)
		{
			# figure out which one to delete. If one of them already has a payment against it, DO NOT delete that one.
			$to_delete = -1;
			if(floatval($group[0]['amount_paid']) == 0 and floatval($group[1]['amount_paid']) == 0)
			{
				# if neither one has been paid,just delete the second one
				$to_delete = 1;
			}
			else if(floatval($group[0]['amount_paid']) > 0 and floatval($group[1]['amount_paid']) == 0)
			{
				$to_delete = 1;
			}
			else if(floatval($group[0]['amount_paid']) == 0 and floatval($group[1]['amount_paid']) > 0)
			{
				$to_delete = 0;
			}
			else
			{
				# if we could not find a solution, then exit immediately and report the information necessary
				# to debug the reason.
				echo("\t\tcannot determine solution for set: ".print_r($group,true)."\n");
				exit();
			}
			
			
			if($to_delete >= 0)
			{
				# if we found a solution, then prepare it
				echo("\t\tneed to delete payable ".$group[$to_delete]['payable_id']);
				echo(", it is a dupe of ".$group[(($to_delete == 0)?1:0)]['payable_id']."\n");
				$sql = 'delete from payables where payable_id='.$group[$to_delete]['payable_id'];
				
				if($config['report-sql'] == 1)
				{
					echo("\t\t\t".$sql."\n");
				}
				
				if($config['do-deletes'] == 1)
				{
					mysql_query($sql);
				}	
			}
		}
		
		
		#print_r($grouped_by_to_from_amount);
		$error_count++;
		
		# only run until we reach the max. If the max was 0, process ALL of the payables (700 or so)
		if($config['max'] != 0 && $error_count == $config['max'])
		{
			exit();
		}
	}
}

echo("found $error_count errors :(\n");
?>
