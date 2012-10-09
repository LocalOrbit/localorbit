<?
# the parameters for views called as functions are stored in $core->view. 
global $core;
$cats = $core->view[0];
$sellers = $core->view[1];
?>
<br />
<a href="#!catalog-shop" onmouseover="$('#catalog_note').fadeIn(300);" onmouseout="$('#catalog_note').fadeOut(300);"><img src="/img/misc/ellipsis_bubble.png" /></a><br />
<div id="catalog_note"><div>To view a single category, click once, then click again to view all!</div></div>
<div class="header_4 filter catalog_showall" onclick="core.catalog.resetFilters();">Show All</div>
<div class="header_3 filter"><input type="checkbox" class="filtercheck" disabled="disabled" checked="checked" /> Filter by Sellers</div>

<?php
foreach($sellers as $seller)
{
	if($seller[0]['name'] != '')
	{
	?>
	<div id="filter_org_<?=$seller[0]['org_id']?>" class="subheader_3 filter_subcat filter_org filter" onclick="core.catalog.setFilter('seller',<?=$seller[0]['org_id']?>);"><?=$seller[0]['name']?></div>
	<?
	}
}
echo('<br />');
$style=1;
foreach($cats->roots as $root)
{
	$cat = $cats->by_id[$root]; 
?>
<div onclick="core.catalog.setFilter('cat1',<?=$cat[0]['cat_id']?>);" class="filter filter_cat_<?=$cat[0]['cat_id']?> header_<?=$style?>">
	<input type="checkbox" id="filtercheck_<?=$cat[0]['cat_id']?>" class="filtercheck" checked="checked" />
	<?=$cat[0]['cat_name']?>
</div>
	<? 
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
	$style=($style == 1)?2:1;
}
?>
<? core::replace('left'); ?>