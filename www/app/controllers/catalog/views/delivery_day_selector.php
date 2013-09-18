<?php
$days = $core->view[0];
$hashUrl = $core->view[1];
$addresses = $core->view[2];

?>
<div id="ddSelectorContinue"></div>
<div id="ddSelectorModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-header">
		<!-- <button type="button" class="close" data-dismiss="modal" aria-hidden="true">x</button> -->
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h3 id="myModalLabel">Please select your order date and delivery location</h3>
	</div>
		 
	<div class="modal-body"> 
		<p>
			
			<ul class="nav nav-list">
			<?php
			foreach($days as $key => $day)
			{
				list($type, $time,$deliv_address_id,$pickup_address_id) = explode('-', $key);
				$name = core_format::date($time, 'shortest-weekday');
				$dd_ids = implode('_',array_unique(array_keys($day)));
				$final_address = ($deliv_address_id == 0)?$deliv_address_id:$pickup_address_id;
				$final_address = ($final_address == 0)?'directly to you':' at ' .$addresses[$final_address][0]['formatted_address'];
				?>
				<li class="filter dd"><a style="padding: 10px 5px 10px 5px;" href="<?=$left_url?>" onclick="core.catalog.setFilter('dd','<?=$dd_ids?>',true,true,true);core.doRequest('/catalog/set_dd_session',{'dd_id':<?=$dd_ids?>}); $('#shop_button').show(300);return false;" id="filter_ddpopup_<?=$dd_ids?>">
				<?=$type?> <?=core_format::date($time,'l, M jS',true)?>, <?=$final_address?>
				</a>
				<?
			}
			?>
			</ul>
		</p>
	</div>
	<div class="modal-footer">
		<button id="shop_button" class="btn btn-large btn-primary" onclick="$('#ddSelectorModal').modal('hide');" style="display:none;">Shop</button>
	</div>
</div>
<?php
core::js('$("#ddSelectorModal").modal();');
?>