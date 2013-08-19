<?

	$market = $core->config['domain'];	
	$address = false;
	if(is_numeric($market['address_id']) && intval($market['address_id']) != 0)
	{
		$address = core::model('addresses')->load($market['address_id']);
		if($address['is_deleted'] == 1)
		{
			$address = false;
		}
	}
	
	$delivs = core::model('delivery_days')->collection()->filter('domain_id',$market['domain_id']);

?>

<img src="<?= image('profile') ?>?_time_=<?=$core->config['time']?>" />

<?
	core::replace('hub_image');
?>

<? if(trim($core->config['domain']['secondary_contact_name']) != '') : ?>
	<div class="left-hub-info-contact">
		<h3>Contact</h3>
		<br />
		<strong>
			<?=$core->config['domain']['secondary_contact_name']?>
		</strong>
		<br />
		<a href="mailTo:<?=$core->config['domain']['secondary_contact_email']?>">
			<?=$core->config['domain']['secondary_contact_email']?>
		</a>
		<br />
		<? if ($address !== false): ?>
			<div class="left-hub-info-address">
				<?= $address['address'] ?>
				<br />
				<?= $address['city'] ?>, <?= $address['code'] ?> <?= $address['postal_code'] ?>
			</div>
		<? endif; ?>
	
		<? if(trim($core->config['domain']['secondary_contact_phone']) != '') : ?>
			<br />
			<?=$core->config['domain']['secondary_contact_phone']?>
		<? endif; ?>
	</div>
<? endif;?>

<? if($core->config['domain']['domain_id'] > 1){?>
	<div>
		<h3>Pickup/Delivery</h3>
	
		<?
			$delivs = core::model('delivery_days')->collection()->filter('domain_id',$core->config['domain']['domain_id']);
			foreach($delivs as $deliv)
			{
				echo('<p>'.$deliv['buyer_formatted_cycle'].'</p>');
			}
		?>
	
	</div>
<?}?>


<div id="tweets">
	<div class="twitter-header">
		<h3>Tweets</h3>
	</div>
	<div class="twitter-feed"></div>
</div>
<div id="facebook" class="span3">
	<div class="facebook-header">
	<h3>Facebook</h3>
	<div class="fb-follow" data-href="https://www.facebook.com/localorbit" data-layout="button_count" data-show-faces="false" data-width="100"></div>
	</div>
	<ol class="facebook-feed">
	</ol>
</div>

<?
	core::js('!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");');
	core::replace('left'); 
 ?>
