<?php
global $data,$domains;
$tab_id = $core->view[0];

if (!isset($data))
	die ("This organizations/cross_sell module can not be called directly.");


if($data['allow_sell'] == 1 and $domains->__num_rows > 0)
{
	
	# get a list of all domains that this org cross sells on
	$ocs = core::model('organization_cross_sells')->collection()->filter('org_id',$data['org_id']);
	$ocs_list = array();
	foreach($ocs as $ocs_item)
	{	
		$ocs_list[$ocs_item['sell_on_domain_id']] = true;
	}
	
	# get a list of all delivery days that this org cross sells on
	$ods = core::model('organization_delivery_cross_sells')
		->autojoin(
			'left',
			'delivery_days',
			'(delivery_days.dd_id=organization_delivery_cross_sells.dd_id)',
			array('delivery_days.domain_id')
		)->collection()->filter('org_id',$data['org_id']);
	$ods_list = array();
	foreach($ods as $ods_item)
	{	
		$ods_list[$ods_item['dd_id']] = true;
		$ocs_list[$ods_item['domain_id']] = true;
	}
	
	# build a list of every delivery day, by domain id. 
	# we need this to pass to a javascript function to check all delivery days under a 
	# domain
	$dds = core::model('delivery_days')->collection();
	$dd_list = array();
	foreach($dds as $dd)
	{
		if(!is_array($dd_list[$dd['domain_id']]))
			$dd_list[$dd['domain_id']] = array();
		$dd_list[$dd['domain_id']][] = $dd['dd_id'];
	}
	$dds = $dds->to_hash('domain_id');
	
	?>
	<div class="tabarea" id="orgtabs-a<?=$tab_id?>">

		<? foreach($domains as $domain) { ?>
			<?= core_form::input_check(
				'Also sell on '.$domain['name'],
				'sell_on_'.$domain['domain_id'],
				$ocs_list[$domain['domain_id']],
				array(
					'onclick'=>'org.setCrosssell('.$domain['domain_id'].',['.implode(',',$dd_list[$domain['domain_id']]).']);',
				)
			); ?>

			<?foreach($dds[$domain['domain_id']] as $dd) {
				if($ocs_list[$domain['domain_id']]) {
					core_form::input_check(
						$dd['formatted_cycle'].', '.$dd['formatted_address'],
						'deliver_on_'.$dd['dd_id'],
						$ods_list[$dd['dd_id']],
						array(
						
						)
					);
				}
			} 
		 }
		 ?>

	</div>
<?}?>