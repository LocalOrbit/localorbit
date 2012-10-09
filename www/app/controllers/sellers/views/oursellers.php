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

	core::ensure_navstate(array('left'=>'left_seller_list')); 

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
	
	

	# get their address and photo
	if(intval($seller['org_id']) == 0) 
	{
		page_header('No sellers yet!');
		?>
		There are no sellers on this hub yet. Please check back once some have registered.
		<br />&nbsp;<br />&nbsp;<br />&nbsp;<br />&nbsp;<br />&nbsp;<br />&nbsp;
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
		$map = '';
		if(is_numeric($address['latitude'])  && is_numeric($address['longitude']))
		{
			$map = core_ui::map('mymap','592px','400px',8);
			core_ui::map_center('mymap',$address['latitude'],$address['longitude']);
			core_ui::map_add_point('mymap',$address['latitude'],$address['longitude'],'<h1>'.$seller['name'].'</h1>'.$address['formatted_address'],image('farm_bubble'));
		}
		list($has_image,$web_path) = $seller->get_image();

		# get a list of their products
		$products = core::model('products')->get_catalog_for_seller($seller['org_id']);

		$products->load();
?>
<table>
	<col width="600" />
	<col width="10" />
	<col width="200" />
	<tr>
		<td>
			<h1><?=$seller['name']?></h1>
			<?if($has_image){?>
			<img src="<?=$web_path?>" />
			<?}?>

			<?if(trim($seller['profile']) != ''){?>
			<h2>Who</h2>
			<?=core_format::plaintext2html($seller['profile'])?>
			<?}?>

			<?if(trim($seller['product_how']) != ''){?>
			<h2>How</h2>
			<?=core_format::plaintext2html($seller['product_how'])?>
			<?}?>
			<h2>Our Location</h2>
			<?=$address['formatted_address']?>
			<?=$map?>
			<br />
		</td>
		<td>&nbsp;</td>
		<td>
			<? if($products->__num_rows > 0 ){?>
			<div class="header_1">Currently Selling</div>
			<? foreach($products as $prod){?>
			<div class="subheader_1">
				<a href="#!catalog-view_product--prod_id-<?=$prod['prod_id']?>">
					<?=$prod['name']?> (<?=$prod['plural_unit']?>)
				</a>
			</div>
			<?}?>
			<?}?>
		</td>
	</tr>
</table>
<?}?>
<?}?>