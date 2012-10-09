<?
$org = $core->view[0];
$do_buttons = ($core->view[1] === true);
$addr_seller = $core->view[2];
#$org->dump();
?>				
				</td>
				<td>&nbsp;</td>
				<td style="vertical-align: top;text-align:left;">
					<? if($addr_seller){?>
					<h4><?=$core->i18n['deliverytools:sellerlabel']?><br /><?=$org['name']?></h4>
					<?}
					else{?>
					<h4><?=$core->i18n['deliverytools:buyerlabel']?><br /><?=$org['name']?></h4>
					<?}?>
					<?=$org['address']?><br />
					<?=$org['city']?>, <?=$org['code']?> <?=$org['postal_code']?><br />
					<?if($org['telephone'] != ''){?>
					T: <?=$org['telephone']?><br />
					<?}?>
					<? if($do_buttons){?>
					<input type="button" class="button_primary" onclick="window.print();" value="print" />
					<input type="button" class="button_primary" onclick="window.close();" value="close" />
					<?}?>
				</td>
			</tr>
		</table>
		