<?php

core::ensure_navstate(array('left'=>'left_cart'));
core::head('View a product','View a product.');
lo3::require_permission();

$data = core::model('products')->join_address()->load();
$all_products = $data->get_catalog()->to_hash('prod_id');

if (count($all_products[$data['prod_id']]) <= 0) {
?>
<div class="error">This product is not currently available for ordering.</div>
<?
} else {
$inv = $data->get_inventory();
$prices = core::model('product_prices')->load_for_product($data['prod_id'],$core->config['domain']['domain_id'],intval($core->session['org_id']));
$img = $data->get_image();
$org = core::model('organizations')->load($data['org_id']);

$cart_item = array('qty_ordered'=>0);
$cart = core::model('lo_order')->get_cart();
$cart->load_items();
foreach($cart->items as $item)
{
	core::log("chekcing item: ".$item['prod_id']);
	if($item['prod_id'] == $data['prod_id'])
		$cart_item = $item->to_array();
		
}

?>
<form name="prodForm">
	<table style="width: 500px;">
		<col width="200" />
		<col width="30" />
		<col width="700" />
		<tr>
			<td style="text-align: left;vertical-align: top;">
				<?if($img){?>
					<img class="homepage" src="/img/products/cache/<?=$img['pimg_id']?>.<?=$img['width']?>.<?=$img['height']?>.200.150.<?=$img['extension']?>" />
				<?}else{?>
					<img src="<?=image('product_placeholder')?>" />
				<?}?>
			</td>
			<td>&nbsp;</td>
			<td style="text-align: left;vertical-align: top;">
				<span class="product_name"><?=$data['name']?></span><br />
				<span class="farm_name"><?=$data['org_name']?></span><br />
				<table class="form">
					<tr>
						<td class="label">Price</td>
						<td class="value" style="width: 280px;">
							<?foreach($prices as $price){?>
							<?=core_format::price($price['price'])?><?if($data['single_unit'] != ''){?>/<?=$data['single_unit']?><?}?>
							<?if($price['min_qty'] > 1){?> - mininum <?=intval($price['min_qty'])?><?}?>
							<br />
							
							<?}?>
						</td>
					</tr>
					<? if( $inv > 0){?>
					<tr>
						<td class="label">Quantity in your cart</td>
						<td class="value">
							<input type="text" name="qty" id="qty" style="width: 55px;" value="<?=$cart_item['qty_ordered']?>" />
							<div class="error" id="not_enough_inv" style="display: none;"></div>
						</td>
					</tr>
					<?}else{?>
					<tr>
						<td class="value" colspan="2">
							<div class="error">This product is not currently available for ordering.</div>
						</td>
					</tr>
					<?}?>
				</table>
			</td>
		</tr>
	</table>
	<?if($inv > 0){?>
	<div class="buttonset">
		<input type="button" class="button_secondary" onclick="$('#not_enough_inv').hide();core.doRequest('/cart/update_item',{'prod_id':<?=$data['prod_id']?>,'qty':document.prodForm.qty.value});" value="update cart" />
		<input type="button" class="button_secondary" onclick="location.href='#!catalog-shop';core.go('#!catalog-shop');" value="continue shopping" />
	</div>
	<?}else{?><br />&nbsp;<br /><?}?>
</form>

<h1>What</h1>
<?=$data['description']?>
<br />&nbsp;<br />

<h1>Who</h1>
<?=(($data['who']=='')?$org['profile']:$data['who'])?>
<br />&nbsp;<br />

<h1>How</h1>
<?=(($data['how']=='')?$org['product_how']:$data['how'])?>
<br />&nbsp;<br />

<h1>Where</h1>
<?
$addr = $data['address'].', '.$data['city'].', '.$data['code'].', '.$data['postal_code'];
echo(core_ui::map('prodmap','600px','400px',8));
core_ui::map_center('prodmap',$addr);
core_ui::map_add_point('prodmap',$addr,'<h1>'.$data['org_name'].'</h1>'.$addr);
}
?>
