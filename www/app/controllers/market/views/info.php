<?

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
	core::ensure_navstate(array('left'=>'left_seller_list')); 
	core::head('Local Orbit Market Information','Local Orbit Makes it easy for chefs, consumers and institutions to buy great food direct from local producers in one convenient location');
	lo3::require_permission();


	$market = $core->config['domain'];
	$address = $market->get_addresses();
	$address->__source .= ' and default_shipping=1';
	$address = $address->load()->row();
	if($address)
	{
		$has_address = true;
		$lat = $address['latitude'];
		$long = $address['longitude'];
		$address = $address['address'].', '.$address['city'].', '.$address['code'].', '.$address['postal_code'];
	}
	else
	{
		$has_address = false;
	}

	# get a list of market news
	$market_news = core::model('market_news')
		->collection()
		->filter('market_news.domain_id',$market['domain_id'])
		->sort('creation_date','desc')
		->limit(3);
	$market_news->load();

	$sellers = core::model('organizations')
		->autojoin(
			'left',
			'addresses',
			'(addresses.org_id=organizations.org_id and addresses.default_shipping=1 and latitude is not null and latitude<>0)',
			array('address','city','postal_code','latitude','longitude')
		)
		->autojoin(
			'left',
			'directory_country_region',
			'(addresses.region_id=directory_country_region.region_id)',
			array('code')
		)
		->collection()
		->filter('latitude','is not null',true)
		->filter('organizations_to_domains.domain_id',$market['domain_id'])
		->filter('is_active',1)
		->filter('is_enabled',1)
		->filter('public_profile',1);
		
	$delivs = core::model('delivery_days')->collection()->filter('domain_id',$market['domain_id']);

?>

<table>
	<col width="600" />
	<col width="50" />
	<col width="200" />
	<tr>
		<td>
			<h1><?=$market['name']?></h1>
			<img src="<?=image('profile')?>?_time_=<?=$core->config['time']?>" />

			<h2>Who</h2>
			<? if(trim($market['market_profile']) != ''){?>
				<?=core_format::plaintext2html($market['market_profile'])?>
			<?}?><br />
			<br />
			<h2>Contact</h2><br />
			<?=$market['secondary_contact_name']?><br />
			<a href="mailTo:<?=$market['secondary_contact_email']?>"><?=$market['secondary_contact_email']?></a><br />
			<?=$market['secondary_contact_phone']?><br />

			<? if(trim($market['market_policies']) != ''){?>
			<h2>Our Policies</h2>
			<?=core_format::plaintext2html($market['market_policies'])?>
			<?}?>

			<h2>Pickup/Delivery</h2>
			<?
			foreach($delivs as $deliv)
			{
				echo($deliv['buyer_formatted_cycle'].'.<br />&nbsp;<br />');
			}
			?>

			<? if($has_address){?>
			<h2>Where</h2>
			<?
			echo(core_ui::map('hubmap','592px','380px',8).'<br />');
			core_ui::map_center('hubmap',$lat,$long);
			core_ui::map_add_point('hubmap',$lat,$long,'<h1>'.$market['name'].'</h1>'.$address,image('hub_bubble'));
			
			foreach($sellers as $seller)
			{
				if(is_numeric($seller['latitude']) && is_numeric($seller['longitude']))
				{
					$address = $seller['address'].', '.$seller['city'].', '.$seller['code'].', '.$seller['postal_code'];
					core_ui::map_add_point('hubmap',$seller['latitude'],$seller['longitude'],'<h1>'.$seller['name'].'</h1>'.$address,image('farm_bubble'));
				}
			}
			?>
			<?}?>
		</td>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td>
			<? if($market_news->__num_rows > 0 ){?>
			<div class="header_1">Latest News</div>
				<? foreach($market_news as $market_newsitem){?>
					<h4><?=$market_news['title']?></h4>
					<?=$market_news['content']?>  <br />
					<div class="market_news_date">Published on <?=core_format::date($market_news['creation_date'],'short')?> </div>
					<div class="market_news_divider">&nbsp;</div>
					
				<?}?>
			<?}?>
		</td>
	</tr>
</table>
<?

}
?>