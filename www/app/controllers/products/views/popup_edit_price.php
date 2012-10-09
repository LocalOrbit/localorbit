<?
$price = core::model('product_prices')->load();
$prod  = core::model('products')->load($price['prod_id']);
$domains = core::model('organizations')->get_pricing_domains($prod['org_id']);
$seller = core::model('organizations')->load($prod['org_id']);
$seller['total_fees'] = $seller['fee_percen_lo'] + $seller['fee_percen_hub'] + $seller['paypal_processing_fee'];

# we need a list of domains which we can sell on to filter the possible customer list
$domain_ids = array();
foreach($domains as $domain)
	$domain_ids[] = $domain['domain_id'];
	
$orgs    = core::model('organizations')->collection()->filter('is_active',1)->filter('domains.domain_id','in',$domain_ids)->sort('name');

core_ui::load_library('js','product.js');


$edit = '#!products-edit--prod_id-'.$core->data['prod_id'];
$edit .= '-tabautoswitch_producttabs-3';
$this->pricing_advanced_rules()->js();
?>
<form name="pricing_advanced_rules" action="/products/popup_save_price" onsubmit="return core.submit('/products/save_price',this);">
	<fieldset id="editPrice">
		<legend>Price Info</legend>
		<table class="form">
			<tr>
				<td class="label">Hub</td>
				<td class="value">
					<select name="domain_id">
						<option value="0">Everywhere</option>
						<?=core_ui::options($domains,$price['domain_id'],'domain_id','name')?>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label">Customer</td>
				<td class="value">
					<select name="org_id">
						<option value="0">Everyone</option>
						<?=core_ui::options($orgs,$price['org_id'],'org_id','name')?>
					</select>
				</td>
			</tr>
			<?if(!lo3::is_admin() && $seller['feature_sellers_enter_price_without_fees'] == 1){?>
			<tr>
				<td class="label">Seller Net Price</td>
				<td class="value"><input type="text" name="seller_net_price" onkeyup="product.syncPrices(this,'price');" value="<?=core_format::price(core_format::parse_price($price['price']) - (core_format::parse_price($price['price']) * ($seller['total_fees']/100)))?>" /></td>
			</tr>
			<tr>
				<td class="label">Sales Price</td>
				<td class="value"><input type="text" name="price" onkeyup="product.syncPrices(this,'seller_net_price');" value="<?=$price['price']?>" /></td>
			</tr>
			<?}else{?>
			<tr>
				<td class="label">Price</td>
				<td class="value"><input type="text" name="price" value="<?=$price['price']?>" /></td>
			</tr>
			<?}?>
			<tr>
				<td class="label">Minimum Quantity</td>
				<td class="value"><input type="text" name="min_qty" value="<?=floatval($price['min_qty'])?>" /></td>
			</tr>
		</table>
		<input type="hidden" name="price_id" value="<?=$price['price_id']?>" />
		<input type="hidden" name="prod_id" value="<?=$price['prod_id']?>" />
		<input type="hidden" name="call_method" value="popup" />
		<input type="hidden" name="total_fees" value="<?=$seller['total_fees']?>" />
		<div style="padding: 2px 5px;">
			Note: A minimum must exist before a price is created.  
			<a href="<?=$edit?>" onclick="$('#edit_popup').fadeOut('fast');core.go(this.href);">Click here</a>
			to view your pricing information.
		</div>
		
		<div class="buttonset">
			<input type="button" onclick="$('#edit_popup').fadeOut('fast');" class="button_primary" value="cancel" />
			<input type="submit" class="button_primary" value="save" />
		</div>		
	</fieldset>
</form>
<? 
core::js("$('#edit_popup').fadeIn('fast');"); 
core::replace('edit_popup'); 
?>
