#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('crypto');

$actually_do_fix = $argv[1] == 'do-fix';

$sql = '
	select p.payable_amount,p.to_org_id,o1.name,lfo.lo_foid,
	lfosc.creation_date as delivery_date,
	p2.payable_amount as seller_amount
	from v_payables p
	inner join organizations o1 on p.to_org_id=o1.org_id
	inner join lo_fulfillment_order lfo on lfo.lo_foid=p.parent_obj_id
	inner join domains d on lfo.domain_id=d.domain_id
	inner join lo_fulfillment_order_status_changes lfosc on (lfosc.lo_foid=lfo.lo_foid and lfosc.ldstat_id=4)
	inner join v_payables p2 on (p2.parent_obj_id=p.parent_obj_id and p2.payable_type=\'seller order\' and p2.from_org_id<>1)
	where p.amount_due > 0
	and   p.payable_type=\'seller order\'
	and   p.from_org_id=1

	and lfosc.creation_date > \'2013-05-05 00:00:00\'
	and lfosc.creation_date < \'2013-05-15 00:00:00\'
	order by lfo.lo_foid
';

$orgs = array();
$results = new core_collection($sql);
foreach($results as $result)
{
	$sql = '
		select sum(qty_ordered * unit_price) as item_total
		from lo_order_line_item
		where lo_foid='.$result['lo_foid'];
	$total = mysql_query($sql);
	$total = mysql_fetch_assoc($total);
	$total = $total['item_total'];
	
	$key = $result['to_org_id'].'-'.$result['name'];
	if(!array_key_exists($result['to_org_id'],$orgs))
	{
		$orgs[$result['to_org_id']] = array(
			'name'=>$result['name'],
			'to_mm_amount'=>0,
			'to_seller_amount'=>0,
			'adjusted_amount'=>0,
			'orders'=>array(),
		);
	}
	$orgs[$result['to_org_id']]['to_mm_amount'] += $result['payable_amount'];
	$orgs[$result['to_org_id']]['to_seller_amount'] += $result['seller_amount'];
	$orgs[$result['to_org_id']]['adjusted_amount'] += round(($total * 0.93),2);
	$orgs[$result['to_org_id']]['orders'][] = $result['lo_foid'].':'.$result['payable_amount'].':'.($total).':'.round(($total * 0.93),2);
}

foreach($orgs as $org)
{
	if($org['to_mm_amount'] != $org['adjusted_amount'])
	{
		echo("need to fix orders for ".$org['name'].". New total: ".$org['adjusted_amount'].":\n");
		foreach($org['orders'] as $order)
		{
			$order = explode(':',$order);
			echo("\tpayable for ".$order[0]." currently ".$order[2].", should be ".$order[3].",\n");
			$sql = 'update payables set amount='.$order[3].' 
			where payable_type_id=2
			and from_org_id=1
			and parent_obj_id='.$order[0];
			
			if($actually_do_fix)
			{
				mysql_query($sql);
			}
			#print_r($order);
		}
	}
}
#print_r($orgs);



exit("complete!\n");

?>