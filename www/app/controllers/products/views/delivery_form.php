<?php
global $data, $core, $all_dds;



$active = array();
$active_dds = core::model('product_delivery_cross_sells')->collection()->filter('prod_id',$data['prod_id']);
foreach($active_dds as $dd)
{
	$active[$dd['dd_id']] = true;
}

$domain_id = 0;
$dd_list = array();
foreach($all_dds as $dd)
{
	$dd_list[] = $dd['dd_id'];
	if($domain_id != $dd['domain_id'])
	{
		echo('<br /><h3>'.$dd['domain_name'].'</h3>');
		$domain_id = $dd['domain_id'];
	}

	#print_r($dd);

	# the last paramter is necessary because if 
	# the hub configuration option feature_require_seller_all_delivery_opts is set,
	# then the user should NOT be able to uncheck delivery days
	echo(core_ui::checkdiv(
		'dd_'.$dd['dd_id'],
		$dd['seller_formatted_cycle'],
		$active[$dd['dd_id']],
		'product.setDD('.$dd['dd_id'].');',
		($dd['feature_require_seller_all_delivery_opts'] != 1)
	).'<br />');
}
echo('<input type="hidden" name="dd_list" value="'.implode(',',$dd_list).'" />');


#echo('rule: /'.$core->config['domain']['feature_force_items_to_soonest_delivery'].'/');
?>