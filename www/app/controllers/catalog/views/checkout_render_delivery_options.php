<?php
$options = $core->view[0];
$delivery_opt_key = $core->view[1];

# render radio buttons if there is more than one delivery option 
# in this group
if(count($options) > 1)
{
	echo('<b>Your order will be delivered to:</b><br />');
	for($i=0;$i<count($options);$i++)
	{
		$label = $options[$i]['address'].' on '.core_format::date($options[$i]['start_time'],'short');
		$label .= ' between '.core_format::date($options[$i]['start_time'],'time').' and '.core_format::date($options[$i]['end_time'],'time');
		if(floatval($options[$i]['amount']) > 0)
		{
			$label .= ', '.(($options[$i]['fee_calc_type_id']==1)?'':'$').''.floatval($options[$i]['amount']).''.(($options[$i]['fee_calc_type_id']==1)?'%':'').' delivery fee';
		}

		echo(($i==0)?'Please choose one...<br />':'<hr />');
		echo(core_ui::radiodiv(
			'delivgroup-'.$options[$i]['uniqid'],
			$label,
			($i==0),
			'delivgroup-'.$delivery_opt_key,
			false,
			'core.checkout.requestUpdatedFees();'
		));
		#print_r($options[$i]);
	}
}
else
{
	# generate a fake hidden field to act like a radio button
	echo('<input type="hidden" name="delivgroup-'.$options[0]['uniqid'].'" id="radiodiv_group_delivgroup-'.$options[0]['uniqid'].'" class="radiodiv radiodiv_group_delivgroup-'.$delivery_opt_key.'" />');
	echo('<input type="hidden" name="delivgroup-'.$options[0]['uniqid'].'_value" id="radiodiv_group_delivgroup-'.$options[0]['uniqid'].'_value" value="1" />');
	echo('<b>Your order '.(($options[0]['type']=='pickup')?'can be picked up at:':'will be delivered to:').'</b><br />');
	$label = $options[0]['address'].' on '.core_format::date($options[0]['start_time'],'short').' between '.core_format::date($options[0]['start_time'],'time').' and '.core_format::date($options[0]['end_time'],'time');
	$i=0;
	if(floatval($options[$i]['amount']) > 0)
	{
		$label .= ', '.(($options[$i]['fee_calc_type_id']==1)?'':'$').''.floatval($options[$i]['amount']).''.(($options[$i]['fee_calc_type_id']==1)?'%':'').' delivery fee';
	}
	
	echo($label);

}
?>