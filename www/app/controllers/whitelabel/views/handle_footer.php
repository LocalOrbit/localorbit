<?php 
$opts = core::model('template_options')->get_options(array('footer'));

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

?>

<div class="container">
	<div class="row" style="margin-top: 30px;">
	
		<div class="span6">
			<div class="row">
				<!--
						
				<div class="span1">
					<a href="#!misc-home">
						<img src="/img/misc/poweredby_lo.png" />
						<img src="/img/misc/footer_logo.png" />
						
					</a>
				</div>
				-->
				<div class="span6">
					<a href="http://<?=$core->config['hostname_prefix']?><?=$core->config['default_hostname']?>">
                        <h4 style="margin: 10px 0 0 0;">Powered by Local Orbit</h4>
                        <small>Copyright Copyright <?=date('Y')?>, All Rights Reserved</small>
               		</a>
				</div>
			</div>
		</div>

		

		<div class="span6 tos">
			<?if(trim($core->config['domain']['secondary_contact_name']) != ''){?>
				<p class="note"><a href="mailTo:<?=$core->config['domain']['secondary_contact_email']?>"><i class="icon-envelope" /> <?=$core->config['domain']['secondary_contact_name']?></a><br />
				<?if(trim($core->config['domain']['secondary_contact_phone']) != ''){?>
					T: <?=$core->config['domain']['secondary_contact_phone']?><br>
				<?}?>

				<? if ($address): ?>
				<?= $address['address'] ?><br>
				<?= $address['city'] ?>, <?= $address['code'] ?> <?= $address['postal_code'] ?>
				<? endif; ?>
				
				</p>
			<?}?>
		</div>
	
	</div>
</div>

<? core::replace('footer'); ?>