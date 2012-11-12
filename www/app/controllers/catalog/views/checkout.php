<?
# basics
global $core;

core::head('Checkout','go mike');
lo3::require_permission();
core::clear_response('replace','left');
core::clear_response('replace','center');
core::replace('left','&nbsp;&nbsp;');
core_ui::load_library('js','checkout.js');
$this->paypal_rules()->js();
$this->authorize_rules()->js();
$this->purchaseorder_rules()->js();

$all_addrs = core::model('addresses')
	->collection()
	->add_formatter('address_formatter')
	->filter('org_id',$core->session['org_id'])
	->filter('is_deleted',0);

# load up the order and arrange it for rendering
$cart = core::model('lo_order')->get_cart();
$cart->load_items(true);
$cart->load_codes_fees();
$cart->discount_codes = $cart->discount_codes->to_array();
#print_r($cart->discount_codes);
if(count($cart->discount_codes) == 0)
{
	$cart->discount_codes = array(array('code'=>''));
}
# if there are no items in the cart, send the user back to the shopping page
if(count($cart->items->to_array()) == 0)
{
	core::js('location.href="#!catalog-shop";');
	core_ui::notification('You have no items in your cart');
	core::deinit();
}
else if ($cart['grand_total'] < $core->config['domain']['order_minimum'])
{
	core::js('location.href="#!catalog-shop";');
	core_ui::notification('You have not met the minimum order requirement of ' . core_format::price($core->config['domain']['order_minimum']));
	core::deinit();
}
core::ensure_navstate(array('left'=>'left_blank'));

$cart->items_by_delivery = array();

?>
<pre>
<?
# rearrange the items so that they're grouped by delivery options.
$cart->arrange_by_next_delivery();
?>
</pre>
<form name="checkoutForm" class="checkout" method="post" action="app/catalog/order_confirmation">
	<table>
		<col width="670" /><col width="3" /><col width="300" />
		<tr>
			<td>
				<?php
				foreach($cart->items_by_delivery as $delivery_opt_key=>$items){
				?>
				<table>
					<col width="400" /><col width="10" /><col width="260" />
					<tr>
						<td>
							<?php $this->checkout_items_header($items[0]['lodeliv_id']);?>
						</td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
						<td>
							<h1>Location</h1>
						</td>
					</tr>
					<tr>
						<td>
							<?php $this->checkout_items($items); ?>
						</td>
						<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
						<td class="delivery_area">
							<?php
							$options = $this->determine_options($delivery_opt_key,$cart->delivery_options,$all_addrs);
							$this->checkout_render_delivery_options($options,$delivery_opt_key);
							?>
						</td>
					</tr>
				</table>
				<div class="dashed_divider">&nbsp;</div>
				<?}?>
				Enter your discount code here: <input type="text" id="discount_code" name="discount_code" value="<?=$cart->discount_codes[0]['code']?>" />
				<input type="button" class="button_secondary" value="apply code" onclick="core.checkout.requestUpdatedFees();" />
			</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
			<td style="vertical-align: top;">
				<?php
				$this->checkout_totals($cart);
				$this->checkout_payment_info();
				?>
			</td>
		</tr>
	</table>
</form>
<?
# this is used to dynamically update the fees and such.
core::js('window.setTimeout("core.checkout.requestUpdatedFees();",1000);');
core::replace('full_width');
?>