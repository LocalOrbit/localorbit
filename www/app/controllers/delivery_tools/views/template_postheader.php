<?
$org = $core->view[0];
$do_buttons = ($core->view[1] === true);
$addr_seller = $core->view[2];
$override_address = $core->view[3];

$final_address = (is_array($override_address))?$override_address:$org;

#$org->dump();
?>				
<div class="span4">
					<address>
					<? if($addr_seller){?>
					<strong><?=$core->i18n['deliverytools:sellerlabel']?><br /><?=$org['name']?></strong>
					<?}
					else{?>
					<strong><?=$core->i18n['deliverytools:buyerlabel']?><br /><?=$org['name']?></strong>
					<?}?>
					<br/>
					<?=$final_address['address']?><br />
					<?=$final_address['city']?>, <?=$final_address['code']?> <?=$final_address['postal_code']?><br />
					<?if($final_address['telephone'] != ''){?>
					T: <?=$final_address['telephone']?><br />
					</address>
					<?}?>
					<? if($do_buttons){?>
					<input type="button" class="btn btn-primary" onclick="window.print();" value="print" />
					<input type="button" class="btn" onclick="window.close();" value="close" />
					<?}?>
</div>