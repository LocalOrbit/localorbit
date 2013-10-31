<?
$prod = $core->view[0];
$days = $core->view[1];
$dd_id = $core->view[2];
$dd_ids = $core->view[3];
$qty = $core->view[4];

$qty = ($qty===0)?'':$qty;
$total = floatval($core->view[5]);
$addresses = $core->view[6];



#echo('<h1>/'.$qty.': '.$dd_id.'/</h1>');
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
			$selected_dd_id  = null;
			
			$validDays = array();
			$first = isset($dd_id) ? false : true;
			
			
			# loop through the list of days and only choose ones that are valid for this product
			foreach($days as $key => $day)
			{
				if (count(array_intersect($dd_ids, array_keys($day))) > 0) {
					$validDays[$key] = $day;
				}
			}
			
			
			
			# determine which one is already selected
			foreach($validDays as $key => $day)
			{
				$this_dd_id = array_keys($day);
				$this_dd_id = $this_dd_id[0];
				
				if($prod['inventory_by_dd'][$this_dd_id] > 0)
				{
					
					# if there's no selected key, use this one
					if (!isset($selected_dd_key)) {
						$selected_dd_key = $key;
						$selected_dd_id  = $this_dd_id;
					}
					
					# override if you've selected this key from the shopping filters
					if($core->session['dd_id'] == $this_dd_id && intval($dd_id) == 0)
					{
						$selected_dd_key = $key;
						$selected_dd_id  = $this_dd_id;
					}
					
					
					# do a final override if you've already added this product to your
					# cart for this delivery day
					if($dd_id == $this_dd_id)
					{
						$selected_dd_key = $key;
						$selected_dd_id  = $this_dd_id;
					}
				}
				
			}
		#echo('<pre>');
		#print_r($validDays);
		#echo('</pre>');
		if (count($validDays) > 1)
		{
			$dd_ids_id = implode('_', array_keys($days));
			list($type, $time,$deliv_address_id,$pickup_address_id) = explode('-', $selected_dd_key);
			
			$final_address = ($deliv_address_id == 0)?$deliv_address_id:$pickup_address_id;
			$final_address = ($final_address == 0)?'directly to you':' at ' .$addresses[$final_address][0]['formatted_address'];
			?>
			<span class="prod_dd_display content prod_dd_single_display_<?=$prod['prod_id']?>" style="font-size: 11px;display: none;">
				
			</span>
			<div class="prod_dd_selector prod_dd_selector_<?=$prod['prod_id']?>">
				<a class="dropdown-toggle dd_selector" data-toggle="dropdown">
					<span class="content" id="prod_dd_display_<?=$prod['prod_id']?>">
						<?=$type?> <?=core_format::date($time, 'shorter-weekday',true)?>
						<br /><?=$final_address?></span>
					<span class="caret"></span>
				</a>
				<input class="prodDd" type="hidden" name="prodDd_<?=$prod['prod_id']?>" id="prodDd_<?=$prod['prod_id']?>" value="<?=$selected_dd_id?>"/>
				<ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
			<?
			
			if($prod['prod_id'] == 4818)
			{
				#core::log(print_r($prod['inventory_by_dd'],true));
				#exit();
			}
			foreach($validDays as $key => $day)
			{
				if (count(array_intersect($dd_ids, array_keys($day))) > 0) {
					$this_dd_id = array_keys($day);
					$this_dd_id = $this_dd_id[0];
					
					if($prod['inventory_by_dd'][$this_dd_id] > 0)
					{
						list($type, $time,$deliv_address_id,$pickup_address_id) = explode('-', $key);
						$final_address = ($deliv_address_id == 0)?$deliv_address_id:$pickup_address_id;
						$final_address = ($final_address == 0)?'directly to you':' at ' .$addresses[$final_address][0]['formatted_address'];
						?>
						<li class="filter dd prod_dd dd_<?=$this_dd_id?> proddd_<?=$prod['prod_id']?>" id="filter_dd_<?=$this_dd_id?>"><a href="<?=($hashUrl?'#!catalog-shop#dd='.$dd_ids_id:'#')?>" onclick="core.catalog.updateRow(<?=$prod['prod_id']?>,$('#prodQty_<?=$prod['prod_id']?>').val(),<?=$this_dd_id?>);return false;">
						<?=$type?> <?=core_format::date($time, 'shorter-weekday',true)?>
						<br /><?=$final_address?></a>
						</li>
					<?
					}
				}
			}
			?>
				</ul>
			</div>
			<?
		}
		else
		{
			reset($validDays);
			list($key, $day) = each($validDays);
			list($type, $time,$deliv_address_id,$pickup_address_id) = explode('-', $key);
			$final_address = ($deliv_address_id == 0)?$deliv_address_id:$pickup_address_id;
			$final_address = ($final_address == 0)?'directly to you':' at ' .$addresses[$final_address][0]['formatted_address'];
			$dd_ids_id = implode('_', array_keys($day));
			?>
			<input class="prodDd" type="hidden" name="prodDd_<?=$prod['prod_id']?>" id="prodDd_<?=$prod['prod_id']?>" value="<?=$dd_ids_id?>"/>
			<span class="dd_selector">
				<?=$type?> <?=core_format::date($time, 'shortest-weekday',true)?>
				<br /><?=$final_address?></a>
			</span>
			<?
		}
		?>
	</ul>
		</div>
	</div>
</div>