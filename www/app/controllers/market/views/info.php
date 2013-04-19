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
	core::ensure_navstate(array('left'=>'left_hub_info'), 'market-info');
	core_ui::showLeftNav();
	core::hide_dashboard();
	
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
		$address_string = $address['address'].', '.$address['city'].', '.$address['code'].', '.$address['postal_code'];
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

	$sellers = core::model('domains')->load_sellers();
		

?>

<div class="row">
	<div class="span9">
		<h1><i class="icon-home"/><?=$market['name']?></h1>
	</div>
</div>

<div class="row">
	<div class="span9">
		<hr class="tight"/>
	</div>
</div>

<? if(trim($market['market_profile']) != '' || trim($market['market_policies']) != ''){?>
<div class="row">
	<div class="span5">
		
		<? if(trim($market['market_profile']) != ''){?>
			<h3><i class="icon-book"/>About</h3>
			<p class="note"><?=core_format::plaintext2html($market['market_profile'])?></p>
		<?}?>

	</div>

	<div class="span4">

		
		<? if (trim($market['market_policies']) != ''): ?>
			<h3><i class="icon-clipboard"/>Policies</h3>
			<p class="note"><?=core_format::plaintext2html($market['market_policies'])?></p>
		<? endif; ?>

	

		
	</div>
</div>
<hr>
<?}?>

<div class="row">
	
	<div class="span5">
		
		
		
		<h3><i class="icon-direction"/>Where</h3>
	<? if($has_address):
			echo(core_ui::map('hubmap','100%','300px',6));
			core_ui::map_center('hubmap',$lat,$long);
			
			foreach($sellers as $seller)
			{
				if(is_numeric($seller['latitude']) && is_numeric($seller['longitude']))
				{
					$seller_address = $seller['address'].', '.$seller['city'].', '.$seller['code'].', '.$seller['postal_code'];
					core_ui::map_add_point('hubmap',$seller['latitude'],$seller['longitude'],'<strong><small>'.$seller['name'].'</small></strong><br><small>'.$seller_address.'</small>',image('farm_map_marker'));
				}
			}
			
			core_ui::map_add_point('hubmap',$lat,$long,'<strong>'.$market['name'].'</strong><br>'.$address,image('farmstand_map_marker'));
			?>
		<? endif; ?>	
	</div>
	
	<div class="span4">
		<h3><i class="icon-users"/>Sellers</h3>
		<? foreach($sellers as $seller): ?>
			<a href="#!sellers-oursellers--org_id-<?=$seller['org_id']?>"><?= $seller['name'] ?></a><br />
		<? endforeach; ?>
	</div>
	
</div>

<? /*
<div class="row">
	<div class="span9">
		<? if($market_news->__num_rows > 0 ){?>
			<div class="header_1">Latest News</div>
			<? foreach($market_news as $market_newsitem){?>
				<h4><?=$market_news['title']?></h4>
				<?=$market_news['content']?>  <br />
				<div class="market_news_date">Published on <?=core_format::date($market_news['creation_date'],'short')?> </div>
				<div class="market_news_divider">&nbsp;</div>
			<?}?>
		<?}?>
	</div>
</div>
*/?>


<? } ?>

<?
	if ($core->config['domain']['social_option_id'] == 1 && !empty($core->config['domain']['facebook'])) {
		core::js('core.ui.facebookfeed("' . $core->config['domain']['facebook'] .'");'); //$(\'facebook > div\').facebookfeed({access_token : \'e95944096d2ca36ae56593f509625cdd\', id : \'' . $core->config['domain']['facebook'] .'\'});');
	} else if ($market['social_option_id'] == 2 && !empty($market['twitter'])) {
		core::js('var tweets = new jqTweet("'.$market['twitter'].'", "#tweets div.twitter-feed", 10);			
		tweets.loadTweets(function() { $("#tweets").fadeIn(); 
			$("#tweets div.twitter-header").append(\'<iframe allowtransparency="true" frameborder="0" scrolling="no" src="//platform.twitter.com/widgets/follow_button.html?show_screen_name=false&show_count=false&screen_name='.$market['twitter'].'" style="width:60px; height:20px;"></iframe>\');
		});');
	}
?>