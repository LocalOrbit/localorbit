<?
# the parameters for views called as functions are stored in $core->view.
global $core;
$cats = $core->view[0];
$sellers = $core->view[1];
//$delivs = $core->view[2];
$days = $core->view[2];
$addresses = $core->view[3];
$left_url = $core->view[4];
$hashUrl = $core->view[3]?'true':'false';


#print_r($addresses);
#if($core->data['cart'] == 'yes')
#	core::js('$(\'#cartFilterCheck\').prop(\'checked\',true);core.catalog.setFilter(\'cartOnly\',true);');
?>

<!--
<a href="<?=$left_url?>" onmouseover="$('#catalog_note').fadeIn(300);" onmouseout="$('#catalog_note').fadeOut(300);"><img src="/img/misc/ellipsis_bubble.png" /></a><br />
<div id="catalog_note"><div>To view a single category, click once, then click again to view all!</div></div>
-->

<small style="position: relative; bottom: -1.6em;" class="pull-right hoverpointer" onclick="core.catalog.resetFilters();"><i class="icon-remove-sign"/>Remove Filters</small>
<h2>Filter By:</h2>
<hr class="tight">

<label>
	<input onclick="core.catalog.setFilter('cartOnly',this.checked);" id="cartFilterCheck" class="pull-right" type="checkbox" name="in_cart_only" />
	<strong>Your Cart</strong>
</label>

<hr class="tight">
<strong><input type="checkbox" class="filtercheck" disabled="disabled" checked="checked" style="display: none;" />Availability Date</strong>

<?

if (count($days) > 1)
{
?>

<ul class="nav nav-list">
<?php
	foreach($days as $key => $day)
	{
		$name = core_format::date($time, 'shortest-weekday');
		$dd_ids = implode('_', array_keys($day));
		#print_r($dd_ids );
		#print_r(explode('-', $key));
		list($type, $time,$deliv_address_id,$pickup_address_id) = explode('-', $key);
		$final_address = ($deliv_address_id == 0)?$deliv_address_id:$pickup_address_id;
		$final_address = ($final_address == 0)?'directly to you':' at ' .$addresses[$final_address][0]['formatted_address'];
		?>
		<li class="filter dd"><a href="<?=$left_url?>" onclick="core.catalog.setFilter('dd','<?=$dd_ids?>');core.doRequest('/catalog/set_dd_session',{'dd_id':<?=$dd_ids?>}); return <?=$hashUrl?>;" id="filter_dd_<?=$dd_ids?>">
		<?=$type?> <?=core_format::date($time, 'shortest-weekday',true)?>
		<br />
		<?=$final_address?>
		</a>
		<input type="hidden" id="filtercheck_<?=$dd_ids?>" class="filtercheck" checked="checked" /></li>
		<?
	}
}
?>
</ul>

<hr class="tight">
<strong><input type="checkbox" class="filtercheck" disabled="disabled" checked="checked" style="display: none;" />Seller</strong>

<ul class="nav nav-list">
<?php
foreach($sellers as $seller)
{
	if($seller[0]['name'] != '')
	{
	?>
	<li class="filter seller" id="filter_org_<?=$seller[0]['org_id']?>"><a href="<?=$left_url?>" onclick="core.catalog.setFilter('seller',<?=$seller[0]['org_id']?>); return <?=$hashUrl?>;"><?=$seller[0]['name']?></a>
	<input type="hidden" id="filtercheck_<?=$cat[0]['cat_id']?>" class="filtercheck" checked="checked" /></li>
	<?
	}
}
?>
</ul>

<hr class="tight">

<strong>Category</strong>
<ul class="nav nav-list">
<?
$style=1;
foreach($cats->roots as $root)
{
	$cat = $cats->by_id[$root];
?>
<li class="filter category" data-name="<?=$cat[0]['cat_name']?>" id="filter_cat_<?=$cat[0]['cat_id']?>">
	<a href="<?=$left_url?>" onclick="core.catalog.setFilter('cat1',<?=$cat[0]['cat_id']?>);  return <?=$hashUrl?>;">
		<!--<input type="hidden" id="filtercheck_<?=$cat[0]['cat_id']?>" class="filtercheck" checked="checked" />-->
		<?=$cat[0]['cat_name']?>
	</a>
	<input type="hidden" id="filtercheck_<?=$cat[0]['cat_id']?>" class="filtercheck" checked="checked" />
</li>


	<? /* Subcategory
	$subs = $cats->by_parent[$cat[0]['cat_id']];
	if(isset($cats->by_parent[$cat[0]['cat_id']]))
	{
		foreach($subs as $sub)
		{
		?>
		<div onclick="core.catalog.setFilter('cat2',<?=$sub['cat_id']?>,<?=$cat[0]['cat_id']?>);" id="filter_subcat_<?=$sub['cat_id']?>" class="subheader_<?=$style?> filter filter_subcat filter_subcat_of_<?=$cat[0]['cat_id']?>">
			<?=$sub['cat_name']?>
		</div>
		<?
		}
	}
	echo('<br />');
	*/
	$style=($style == 1)?2:1;
}
?>
</ul>
<? core::replace('left'); ?>