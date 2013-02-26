<?
$prod = $core->view[0];
$days = $core->view[1];
$dd_id = $core->view[2];
$dd_ids = $core->view[3];
$qty = $core->view[4];

$qty = ($qty===0)?'':$qty;
$total = floatval($core->view[5]);

#echo('<h1>/'.$qty.'/</h1>');
?>
<div class="row">
	<div class="span1 product-quantity">
		<input class="span1 prodQty prodQty_<?=$prod['prod_id']?> natural-num-only" type="text" name="prodQty_<?=$prod['prod_id']?>" id="prodQty_<?=$prod['prod_id']?>" onkeyup="core.catalog.updateRow(<?=$prod['prod_id']?>,this.value);" value="<?=$qty?>" placeholder="Qty" />
	</div>

	<div class="span1 prodTotal_text prodTotal_<?=$prod['prod_id']?>_text" id="prodTotal_<?=$prod['prod_id']?>_text"<?=(($qty == 0 || $qty == '')?' style="display:none;"':'')?>>
		<span class="value"><?=core_format::price($total)?></span> <i class="icon-close"/>
	</div>
</div>
<div class="row">
	<div class="span2">
		<div class="dropdown">
		<input class="prodDdSet" type="hidden" name="prodDdSet_<?=$prod['prod_id']?>" id="prodDdSet_<?=$prod['prod_id']?>" value="<?=implode('_', $dd_ids)?>"/>
		<?

			$selected_dd_key = null;

			$validDays = array();
			$first = isset($dd_id) ? false : true;
			//$count = 0;
			foreach($days as $key => $day)
			{
				if (count(array_intersect($dd_ids, array_keys($day))) > 0) {
					$validDays[$key] = $day;
				}
			}
			foreach($validDays as $key => $day)
			{
				//if (count(array_intersect($dd_ids, array_keys($day))) > 0) {
					if (!isset($dd_id) || array_key_exists($dd_id, $day)) {
						$selected_dd_key = $key;
						break;
					}
				//}
			}
		#echo('<pre>');
		#print_r($validDays);
		#echo('</pre>');
		if (count($validDays) > 1)
		{
			$dd_ids_id = implode('_', array_keys($day));
			list($type, $time) = explode('-', $key);
			?>
			<a class="dropdown-toggle dd_selector" data-toggle="dropdown">
				<span class="content"><?=$type?> <?=core_format::date($time, 'shortest-weekday',false)?></span>
				<span class="caret"></span>
			</a>
			<input class="prodDd" type="hidden" name="prodDd_<?=$prod['prod_id']?>" id="prodDd_<?=$prod['prod_id']?>" value="<?=$dd_ids_id?>"/>
			<ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
			<?
			foreach($validDays as $key => $day)
			{
				if (count(array_intersect($dd_ids, array_keys($day))) > 0) {
					$dd_ids_id = implode('_', array_keys($day));
					list($type, $time) = explode('-', $key);
					?>
					<li class="filter dd" id="filter_dd_<?=$dd_ids_id?>"><a href="<?=($hashUrl?'#!catalog-shop#dd='.$dd_ids_id:'#')?>" onclick="return core.catalog.changeProductDeliveryDay(event, <?=$prod['prod_id']?>,'<?=$dd_ids_id?>');">
					<?=$type?> <?=core_format::date($time, 'shorter-weekday',false)?></a>
					</li>
					<?
				}
			}
		}
		else
		{
			reset($validDays);
			list($key, $day) = each($validDays);
			list($type, $time) = explode('-', $key);
			$dd_ids_id = implode('_', array_keys($day));
			?>
			<input class="prodDd" type="hidden" name="prodDd_<?=$prod['prod_id']?>" id="prodDd_<?=$prod['prod_id']?>" value="<?=$dd_ids_id?>"/>
			<span class="dd_selector"><?=$type?> <?=core_format::date($time, 'shortest-weekday',false)?></span>
			<?
		}
		?>
	</ul>
		</div>
	</div>
</div>