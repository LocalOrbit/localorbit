<?
$org = $core->view[0];
$do_buttons = ($core->view[1] === true);
$addr_seller = $core->view[2];
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
					<?=$org['address']?><br />
					<?=$org['city']?>, <?=$org['code']?> <?=$org['postal_code']?><br />
					<?if($org['telephone'] != ''){?>
					T: <?=$org['telephone']?><br />
					</address>
					<?}?>
					<? if($do_buttons){?>
					<input type="button" class="btn btn-primary" onclick="window.print();" value="print" />
					<input type="button" class="btn" onclick="window.close();" value="close" />
					<?}?>
</div>