<?

	$market = $core->config['domain'];	
	$address = $market->get_addresses();
	$address->__source .= ' and default_shipping=1';
	$address = $address->load()->row();
	
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
		<? if ($address): ?>
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


<div class="row">
<div class="span3">
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
</div>
</div>

<?
	core::js('!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");');
	core::replace('left'); 
 ?>
