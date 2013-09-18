<?php  

if(
	(
		$core->session['is_active'] != 1 || 
		$core->session['org_is_active'] != 1
	)
	&&
	$core->config['domain']['feature_allow_anonymous_shopping'] != 1
)
{
	core::process_command('catalog/not_activated',false);
}
else
{
		
	lo3::require_permission();
	
	global $core;
	core::head('Our Sellers','','');

	core::ensure_navstate(array('left'=>'left_seller_list'),'sellers-oursellers'); 
	core_ui::showLeftNav();
	core::hide_dashboard();

	# figure out which seller to load
	$seller = core::model('domains')->load_sellers()->limit(1);
	
	
	if(intval($core->data['org_id']) == 0)
	{
		# we need to choose a random one to display
		$seller->sort('rand()');
	}
	else
	{
		# one is specified in teh url
		$seller->filter('o.org_id',$core->data['org_id']);
	}
	
	$seller = $seller->row();
	#core::log(print_r($seller,true));
	/*
	
*/
	# get their address and photo
	if(intval($seller['org_id']) == 0) 
	{
		page_header('No sellers yet!');
		?>
		<div class="alert alert-error">There are no sellers on this market yet. Please check back once some have registered.</div>
		<?
		#core::replace('left','&nbsp;');
	}
	else
	{
		$address = core::model('addresses')
			->add_formatter('simple_formatter')
			->collection()
			->filter('org_id',$seller['org_id'])
			->filter('default_shipping',1)
			->limit(1);
		$address = $address->row();
		core::log('address: '.$address['latitude'].'/'.$address['longitude']);
		
		$map = core_ui::map('mymap','100%','240px',8);
		if(is_numeric($address['latitude'])  && is_numeric($address['longitude']))
		{
			core_ui::map_center('mymap',$address['latitude'],$address['longitude']);
			core_ui::map_add_point('mymap',$address['latitude'],$address['longitude'],'<h1>'.$seller['name'].'</h1>'.$address['formatted_address'],image('farm_map_marker'));
		} 
		else 
		{
			core_ui::map_center('mymap',$address['postal_code']);
			core_ui::map_add_point('mymap',$address['postal_code'],$address['longitude'],null,image('farm_map_marker'));
		}
		list($has_image,$web_path) = $seller->get_image();

		# get a list of their products
		$catalog = core::model('products')->get_final_catalog(null,$seller['org_id']);
		
		
		if(count($catalog['products']) > 0)
		{
			$has_products = true;
		}
		core::js('core.lo4.initRemoveSigns();');
?>

<div class="row">
	<div class="span5">

		<h3><?=$seller['name']?></h3>
		<?if($has_image){?><img src="<?=$web_path?>" /><?}?>
	
	</div>
	<?//if(is_numeric($address['latitude'])  && is_numeric($address['longitude'])){?> 
	<div class="span4">
		<h3><?= $address['city'] ?>, <?= $address['code'] ?></h3>
		<?=$map?>

	</div>
	<?//}?>
</div> <!-- /row-->

<div class="row">
	<div class="span9">&nbsp;</div>
</div>

<div class="row">
	<div class="span5">
		
		<?if(trim($seller['profile']) != ''){?>
			<h3>Who We Are</h3>
			<p><?=core_format::plaintext2html($seller['profile'])?></p>
		<?}?>
	
	</div>
	<div class="span4">

		<?if(trim($seller['product_how']) != ''){?>
			<h3>How We Do It</h3>
			<p><?=core_format::plaintext2html($seller['product_how'])?></p>
		<?}?>

	</div>
</div>

<div class="row">
	<div class="span9">
		<hr/>
	</div>
</div>
<? if( $has_products){?>

<div class="row">
	<div class="span9">
		<h3>Currently Selling</h3>
	</div>
</div>

<!--
<div class="row">
	<div class="span9">
		<hr class="tight"/>
	</div>
</div>
-->
<?php

#echo('<pre>');
#print_r($catalog['deliveries']);
#echo('</pre>');

?>

<div class="row">
	<div class="span9">
		<? foreach($catalog['products'] as $prod){?>
		<div class="subheader_1">
			<a href="#!catalog-view_product--prod_id-<?=$prod['prod_id']?>"> <?
				core::process_command('catalog/render_product', true,
					$prod,
					$catalog['categories']->by_id,
					$catalog['sellers'][$prod['org_id']][0],
					$catalog['prices'][$prod['prod_id']],
					$catalog['deliveries'],
					$styles[0],
					$styles[1],
					$catalog['item_hash'][$prod['prod_id']][0]['qty_ordered'],
					$catalog['item_hash'][$prod['prod_id']][0]['row_total'],
					$catalog['days'],
					$catalog['item_hash'][$prod['prod_id']][0]['dd_id'],
					$catalog['addresses']
				);
		?>	</a>
		</div>
		<?}?>
	</div>
</div>
<?}?>	
<?}?>
<?}?>
<?
	core::js('core.ui.hidesocial();');
	if ($seller['social_option_id'] == 1 && !empty($seller['facebook'])) {
		core::js('core.ui.facebookfeed("' . $seller['facebook'] .'");'); //$(\'facebook > div\').facebookfeed({access_token : \'e95944096d2ca36ae56593f509625cdd\', id : \'' . $core->config['domain']['facebook'] .'\'});');
	} else if ($seller['social_option_id'] == 2 && !empty($seller['twitter'])) {
		core::js('core.ui.twitterfeed("'.$seller['twitter'].'");');
		/*
		core::js('var tweets = new jqTweet("'.$seller['twitter'].'", "#tweets div.twitter-feed", 10);			
		tweets.loadTweets(function() { $("#tweets").fadeIn(); 
			$("#tweets div.twitter-header").append(\'<iframe allowtransparency="true" frameborder="0" scrolling="no" src="//platform.twitter.com/widgets/follow_button.html?show_screen_name=false&show_count=false&screen_name='.$seller['twitter'].'" style="width:60px; height:20px;"></iframe>\');
		});');
		*/
	}
?>