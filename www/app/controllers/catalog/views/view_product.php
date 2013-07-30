<?php

core::head('View a product','View a product.');
lo3::require_permission();
lo3::user_can_shop();

$data = core::model('products')
	->join_address()
	->load_dd_ids()
	->load($core->data['prod_id']);
#exit();

$all_products = $data->get_catalog()->to_hash('prod_id');

if (count($all_products[$data['prod_id']]) <= 0) {
?>
<div class="error">This product is not currently available for ordering.</div>
<?
} else {
$inv = $data->get_inventory();
$prices = core::model('product_prices')->load_for_product($data['prod_id'],$core->config['domain']['domain_id'],intval($core->session['org_id']));
core::js('core.prices ='.json_encode(array($data['prod_id']=>$prices)).';');

$img = $data->get_image();
$org = core::model('organizations')->load($data['org_id']);

$cart_item = array('qty_ordered'=>0);
$cart = core::model('lo_order')->get_cart();
$cart->load_items();
core_ui::load_library('js','catalog.js');
core::js('core.cart = '.$cart->write_js(true).';');
core::js('core.lo4.initRemoveSigns();');


foreach($cart->items as $item)
{
	core::log("chekcing item: ".$item['prod_id']);
	if($item['prod_id'] == $data['prod_id'])
		$cart_item = $item->to_array();

}


$prods     = core::model('products')->get_catalog()->load();
$cat_ids   = $prods->get_unique_values('category_ids',true,true);
$cats      = core::model('categories')->load_for_products($cat_ids);
$org_ids   = $prods->get_unique_values('org_id');
$sellers   = core::model('organizations')->collection()->sort('name');
$sellers   = $sellers->filter('organizations.org_id','in',$org_ids)->to_hash('org_id');

#print_r($data->__data);

$dd_ids    = explode(',',$data['dd_ids']);
$dd_ids[]  = 0;
$delivs    = core::model('delivery_days')->collection()->filter('delivery_days.dd_id','in',$dd_ids);
$deliveries = array();
foreach ($delivs as $value) {
	$value->next_time();
	$deliveries[$value['dd_id']] = array($value->__data);
}

$delivs = $deliveries;

$days = array();
foreach($delivs as $deliv)
{
	$time = ($deliv[0]['pickup_address_id'] ? 'Pick Up' : 'Delivered') . '-' . strtotime('midnight',$deliv[0]['pickup_address_id'] ? $deliv[0]['pickup_end_time'] : $deliv[0]['delivery_end_time']);
	if (!array_key_exists($time, $days)) {
		$days[$time] = array();
	}
	foreach ($deliv as $value) {
		//print_r($deliv);
		$days[$time][$value['dd_id']] = $value;
	}
}
		function day_sort($a,$b) 
		{
			list($type, $atime) = explode('-', $a);
			list($type, $btime) = explode('-', $b);
			return intval($atime) - intval($btime);
		}
		
		uksort($days,'day_sort');

core::ensure_navstate(array('left'=>'left_empty'));
core::write_navstate();
core_ui::load_library('js','catalog.js');

$cats  = core::model('categories')->load_for_products(explode(',',$data['category_ids']));//->load()->collection();
?>
<div class="row">
	<div class="span6">


		<h3 class="product_name notcaps" style="margin-bottom: 0;"><?=$data['name']?></h3>
		<small>Produced by <a href="#!sellers-oursellers--org_id-<?=$data['org_id']?>"><?=$data['org_name']?></a></small>

		<hr>
		<p class="note">
		<?
			ksort($cats->by_id);
			$categories = array_values($cats->by_id);
			$first = true;
			$second = true;
			foreach ($categories as $category) {
				if ($first) {
					$first = false;
					continue;
				}
				if ($second) {
					$second = false;
				} else {
					echo ':';
				}
				?>
				<u><?=$category[0]['cat_name']?></u>
				<?
			}
		?>
		</p>


		<!--<p><strong>Who:</strong> <?=(($data['who']=='')?$org['profile']:$data['who'])?></p>-->
		<p><strong>What:</strong> <?=$data['description']?></p>
		<p><strong>How:</strong> <?=(($data['how']=='')?$org['product_how']:$data['how'])?></p>
		<hr />

		<h3 style="margin-bottom: 0;"><a href="#!sellers-oursellers--org_id-<?=$data['org_id']?>"><?=$data['org_name']?></a></h3>
		<small><?=$data['address']?>, <?=$data['city']?>, <?=$data['code']?></small>
		<?
		$addr = $data['address'].', '.$data['city'].', '.$data['code'].', '.$data['postal_code'];
		echo(core_ui::map('prodmap','100%','400px',8));
		core_ui::map_center('prodmap',$addr);
		core_ui::map_add_point('prodmap',$addr,'<h1>'.$data['org_name'].'</h1>'.$addr);
		}
		?>


	</div>

	<div class="span3">
		<?if($img){?>
			<img class="homepage" src="/img/products/cache/<?=$img['pimg_id']?>.<?=$img['width']?>.<?=$img['height']?>.300.300.<?=$img['extension']?>" />
		<?}else{?>
			<img src="<?=image('product_placeholder')?>" />
		<?}?>
		<hr />
		<form  id="product_<?=$data['prod_id']?>" name="prodForm" class="form-inline">

			<h4>Pricing</h4>
			<ol class="priceList">
			<?$this->render_product_pricing($prices);?>
			</ol>
			<hr />
			<h4>Add To Cart</h4>
			<? if( $inv > 0): ?>
				<? $this->render_qty_delivery($data,$days,$dd_id,$dd_ids,$cart_item['qty_ordered'],$cart_item['row_total']); ?>
			<? else: ?>
				<div class="error">This product is not currently available for ordering.</div>
			<? endif; ?>
		</form>
		<a href="#!catalog-shop" class="btn btn-info btn-block"> Continue Shopping</a>
		<!--

		<h4>Other Products from this Seller</h4>
		[FIX: Add other products]

		<h4>Other Products from this Category</h4>
		[FIX: Add other products]
		-->
	</div>
</div>