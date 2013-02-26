<?

$market = $core->config['domain'];	
$address = $market->get_addresses();
$address->__source .= ' and default_shipping=1';
$address = $address->load()->row();

$delivs = core::model('delivery_days')->collection()->filter('domain_id',$market['domain_id']);

?>
<h3>&nbsp;</h3>
<img src="<?= image('profile') ?>?_time_=<?=$core->config['time']?>" />
<?
core::replace('hub_image');
?>
<span class="span3">
<?if(trim($core->config['domain']['secondary_contact_name']) != ''){?>
	<h3>Contact</h3>
<strong><?=$core->config['domain']['secondary_contact_name']?>
</strong><br />

	<a href="mailTo:<?=$core->config['domain']['secondary_contact_email']?>">
		<?=$core->config['domain']['secondary_contact_email']?>
	</a>
	<br/>

	<? if ($address): ?>
	<address>
	<?= $address['address'] ?><br>
	<?= $address['city'] ?>, <?= $address['code'] ?> <?= $address['postal_code'] ?>
	<? endif; ?>

	<?if(trim($core->config['domain']['secondary_contact_phone']) != ''){?>
		<br/><?=$core->config['domain']['secondary_contact_phone']?>
	<?}?>
	</address>
<?}?>
</span>

<? if($core->config['domain']['domain_id'] > 1){?>
<span class="span3">
<h3>Pickup/Delivery</h3>
</span>
<?
$delivs = core::model('delivery_days')->collection()->filter('domain_id',$core->config['domain']['domain_id']);
foreach($delivs as $deliv)
{
	echo('<p class="span3">'.$deliv['buyer_formatted_cycle'].'</p>');
}
?>
<?}?>
<p>&nbsp;</p>

<div class="row">
<div id="tweets" class="span3">
	<span>
	<h3>Tweets</h3>
	</span>
	<div>
	</div>
</div>
</div>
<?
core::js('!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");');
core::replace('left'); 
 
 ?>