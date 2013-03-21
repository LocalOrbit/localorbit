<?
global $core;
$prods    = $core->view[0];
$allPrices    = $core->view[1];
$all_sellers    = $core->view[2];
$delivs   = $core->view[3];
$item_hash     = $core->view[4];
$days 	 = $core->view[5];
$addresses = $core->view[6];

$special = core::model('weekly_specials')
	->collection()
	->filter('weekly_specials.domain_id',$core->config['domain']['domain_id'])
	->filter('is_active',1)
	->load()
	->row();

$prod = null;
foreach ($prods as $value) {
	if ($value['prod_id'] == $special['product_id']) {
		$prod = $value;
		$seller = $all_sellers[$prod['org_id']];
		break;
	}
}

# figure out the actual qty in the cart of hte special
$qty   = $item_hash[$prod['prod_id']][0]['qty_ordered'];
$total = $item_hash[$prod['prod_id']][0]['row_total'];
$dd_id = $item_hash[$prod['prod_id']][0]['dd_id'];
$dd_ids = explode(',',$prod['dd_ids']);

$pricing = $allPrices[$special['product_id']];
$rendered_prices = 0;
if($special && $special['product_id'] != 0)
{
	list($has_image,$webpath) = $special->get_image();


?>

<div class="row" style="font-size: 12px !important;" id="weekly_special"<?=(($core->session['weekly_special_noshow'] == 1)?' style="display:none;"':'')?>>
	

	<div class="span9 first">
		<h3 class="pull-left"><i class="icon-star"></i>Featured: <a href="#!catalog-view_product--prod_id-<?=$prod['prod_id']?>"><?=$special['title']?></a></h3>
		<!--<small class="hideit"><a class="note pull-right" href="#!catalog-shop" style="line-height: 4.5em; vertical-align: bottom;" onclick="core.catalog.hideSpecial();" ><i class="icon icon-remove-sign"/>&nbsp;Hide this special...</a></small>-->
		<a class="ws_togglers pull-right" style="margin-top: 10px;margin-right: 14px;" onclick="$('.ws_togglers').toggle();$('#weekly_special').css('height','40px').css('overflow','hidden')"><i class="icon icon-minus-circle" /></a>
		<a class="ws_togglers pull-right" style="margin-top: 10px;display: none;margin-right: 14px;" onclick="$('.ws_togglers').toggle();$('#weekly_special').css('height','auto').css('overflow','')"><i class="icon icon-plus-circle" /></a>
	</div>
	<p class="note" style="padding-bottom: 10px;">
		<?=$special['body']?>
	</p>
	<div class="clear"></div>
	<div class="span1 first">
		<? if(intval($prod['pimg_id']) > 0){?>
		<img class="img-rounded catalog" src="/img/products/cache/<?=$prod['pimg_id']?>.<?=$prod['width']?>.<?=$prod['height']?>.100.75.<?=$prod['extension']?>" />
		<?}else{?>
		<img class="img-rounded catalog_placeholder" src="<?=image('product_placeholder_small')?>" />
		<?}?>
	</div>
	<div class="span4 product-info">
		<?
		$this->render_product_description($prod,$seller);
		?>
	</div>
	<ol class="span2 priceList">
		<? $this->render_product_pricing($pricing); ?>	
	
	</ol>
	<div class="span2 cartstuff">
		<? $this->render_qty_delivery($prod,$days,$dd_id,$dd_ids,$qty,$total,$addresses); ?>
	</div>
</div>
<?
	//$core->session['weekly_special_noshow'] = 1;
}
?>