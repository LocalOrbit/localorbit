<?php
global $data,$seller;
$prices  = core::model('product_prices')->collection()->filter('prod_id',$core->data['prod_id'])->sort('min_qty');
$prices->add_formatter('pricing_qty_fixup');

if(!isset($data['org_id']))
{
	$data = core::model('products')->load();
}
$seller = core::model('organizations')->load($data['org_id']);
$seller['total_fees'] = $seller['fee_percen_lo'] + $seller['fee_percen_hub'] + $seller['paypal_processing_fee'];

function pricing_qty_fixup($price_data)
{
	global $data,$seller;
	core::log('here');
	core::log('seller data: '.print_r($seller->__data,true));
	
	$price_data['min_qty'] = floatval($price_data['min_qty']);
	
	if(!lo3::is_admin() && $seller['feature_sellers_enter_price_without_fees'] == 1)
	{
		$price_data['display_price'] = $price_data['price'] - ($price_data['price'] * ($seller['total_fees']/100));
	}
	else
	{
		$price_data['display_price'] = $price_data['price'];
	}
	
	$price_data['display_price'] = core_format::price($price_data['display_price']);
	
	return $price_data;
}


$aprices = $prices->to_array();

$mode = 'basic';
if(count($aprices) == 0)
{
	array_unshift($aprices,array('price_id'=>0,'min_qty'=>0,'org_id'=>0,'domain_id'=>0));
	array_unshift($aprices,array('price_id'=>0,'min_qty'=>0,'org_id'=>0,'domain_id'=>0));
	core::log('pricing condition 1');
}
else if(count($aprices) == 1)
{
	# if the only price has no minimum, add to the end
	if(intval($aprices[0]['min_qty']) == 0)
	{
		core::log('pricing condition 2');
		$aprices[] = array('price_id'=>0,'min_qty'=>0,'org_id'=>0,'domain_id'=>0);
	}
	# else add to the front
	else
	{
		core::log('pricing condition 3');

		array_unshift($aprices,array('price_id'=>0,'min_qty'=>0,'domain_id'=>0));
	}
}
else if(count($aprices) == 2)
{
		core::log('pricing condition 4a');

	
	# check if both prices have no min, or if both do
	if((intval($aprices[0]['min_qty']) > 0 && intval($aprices[1]['min_qty']) > 0) || (intval($aprices[0]['min_qty']) == 0 && intval($aprices[1]['min_qty']) == 0))
	{
		core::log('pricing condition 4b');
		$mode = 'advanced';
	}
}
else
{
	core::log('pricing condition 5');
	$mode = 'advanced';
}

# finally, check to see if we're in basic mode but one of our prices is customer or domain specific pricing
if($mode == 'basic' && ($aprices[0]['domain_id'] != 0 || $aprices[1]['domain_id'] != 0 || $aprices[0]['org_id'] != 0 || $aprices[1]['org_id'] != 0 ))
{
	core::log('pricing condition 6');
	$mode = 'advanced';
}

# do some final formatting
if($aprices[1]['price_id'] == 0)
{
	$aprices[1]['min_qty'] = '';
}
else
{
	$aprices[1]['min_qty'] = floatval($aprices[1]['min_qty']);
}

# see if we can do just basic pricing
$style = '';

#print_r($aprices);
if($mode == 'basic')
{
	$style = ' style="display: none;"';
?>
<input type="hidden" name="pricing_mode" value="basic" />
<input type="hidden" name="total_fees" value="<?=$seller['total_fees']?>" />
<div id="pricing_basic">
	<table class="form">
		<?if(!lo3::is_admin() && $seller['feature_sellers_enter_price_without_fees'] == 1){?>
		<tr>
			<td class="label">Retail Net Price</td>
			<td class="value"><input type="text" onkeyup="product.syncPrices(this,'retail');" name="retail_minus_fees" value="<?=core_format::price($aprices[0]['price'] - ($aprices[0]['price'] * ($seller['total_fees']/100)))?>" /></td>
		</tr>
		<tr>
			<td class="label">Retail Sales Price</td>
			<td class="value"><input type="text" onkeyup="product.syncPrices(this,'retail_minus_fees');" name="retail" value="<?=core_format::price($aprices[0]['price'])?>" /></td>
		</tr>
		<tr>
			<td class="label">Wholesale Net Price</td>
			<td class="value"><input type="text" onkeyup="product.syncPrices(this,'wholesale');" name="wholesale_minus_fees" value="<?=core_format::price($aprices[1]['price'] - ($aprices[1]['price'] * ($seller['total_fees']/100)))?>" /></td>
		</tr>
		<tr>
			<td class="label">Wholesale Sales Price</td>
			<td class="value"><input type="text" onkeyup="product.syncPrices(this,'wholesale_minus_fees');" name="wholesale" value="<?=core_format::price($aprices[1]['price'])?>" /></td>
		</tr>
		<?}else{?>
		<tr>
			<td class="label">Retail</td>
			<td class="value"><input type="text" name="retail" value="<?=core_format::price($aprices[0]['price'])?>" /></td>
		</tr>
		<tr>
			<td class="label">Wholesale</td>
			<td class="value"><input type="text" name="wholesale" value="<?=core_format::price($aprices[1]['price'])?>" /></td>
		</tr>		
		<?}?>
		<tr>
			<td class="label">Wholesale Min</td>
			<td class="value"><input type="text" name="basic_wholesale_qty" value="<?=$aprices[1]['min_qty']?>" /></td>
		</tr>
	</table>
	<?if(!lo3::is_admin() && $seller['feature_sellers_enter_price_without_fees'] == 1){?>
	
	<?}?>	
	<input type="hidden" id="retail_price_id" name="retail_price_id" value="<?=$aprices[0]['price_id']?>" />
	<input type="hidden" id="wholesale_price_id" name="wholesale_price_id" value="<?=$aprices[1]['price_id']?>" />
	<br />
	<a href="Javascript:product.switchToAdvancedPricing();">&raquo; Switch to advanced pricing mode.</a>
	<br /><?=$core->i18n['note:pricingmode']?>
</div>
<?
}
else
{
	?>
	<input type="hidden" name="pricing_mode" value="advanced" />
	<?
}


# now, render the advanced pricing form
?>
<div id="pricing_advanced"<?=$style?>>

<?
	$prc = new core_datatable('pricing','products/pricing_form?prod_id='.$core->data['prod_id'],$prices);
	$prc->add(new core_datacolumn('price_id',core_ui::check_all('pricing'),false,'4%',core_ui::check_all('pricing','price_id')));
	$prc->add(new core_datacolumn('domain_id','Hub',true,'26%','<a href="Javascript:product.editPrice(\'{price_id}\',\'{domain_id}\',\'{org_id}\',\'{price}\',\'{min_qty}\',\''.$seller['total_fees'].'\',\''.$seller['feature_sellers_enter_price_without_fees'].'\');">{domain}</a>'));
	$prc->add(new core_datacolumn('org_id','Customer',true,'30%','<a href="Javascript:product.editPrice(\'{price_id}\',\'{domain_id}\',\'{org_id}\',\'{price}\',\'{min_qty}\',\''.$seller['total_fees'].'\',\''.$seller['feature_sellers_enter_price_without_fees'].'\');">{org_name}</a>'));
	$prc->add(new core_datacolumn('price','Price',true,'20%','<a href="Javascript:product.editPrice(\'{price_id}\',\'{domain_id}\',\'{org_id}\',\'{price}\',\'{min_qty}\',\''.$seller['total_fees'].'\',\''.$seller['feature_sellers_enter_price_without_fees'].'\');">{display_price}</a>'));
	$prc->add(new core_datacolumn('min_qty','Min Qty',true,'20%','<a href="Javascript:product.editPrice(\'{price_id}\',\'{domain_id}\',\'{org_id}\',\'{price}\',\'{min_qty}\',\''.$seller['total_fees'].'\',\''.$seller['feature_sellers_enter_price_without_fees'].'\');">{min_qty}</a>'));
	
	$prc->size = (-1);
	$prc->display_filter_resizer = false;
	$prc->render_page_select = false;
	$prc->render_page_arrows = false;
	$prc->render();
?>
	<br />
	<?=$core->i18n['note:pricingadvanced']?>
	<div class="buttonset" id="addPriceButton">
		<input type="button" class="button_secondary" value="Add New Price" onclick="product.editPrice(0);" />
		<input type="button" class="button_secondary" value="Remove Checked" onclick="product.removeCheckedPrices(this.form);" />
	</div>
	<br />
	
<?

$domains = core::model('organizations')->get_pricing_domains($data['org_id']);

/*
$domains = core::model('domains')
	->collection()
	->filter('is_live',1)
	->filter('domain_id','in','(select domain_id from domain_cross_sells where accept_from_domain_id='.$core->data['domain_id'].')')
	->sort('name');
*/

# we need a list of domains which we can sell on to filter the possible customer list
$domain_ids = array();
foreach($domains as $domain)
	$domain_ids[] = $domain['domain_id'];
$orgs    = core::model('organizations')->collection()->filter('is_active',1)->filter('domains.domain_id','in',$domain_ids)->sort('name');

?>
	<fieldset id="editPrice" style="display: none;">
		<legend>Price Info</legend>
		<table class="form">
			<tr>
				<td class="label">Hub</td>
				<td class="value">
					<select name="domain_id">
						<option value="0">Everywhere</option>
						<?=core_ui::options($domains,null,'domain_id','name')?>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label">Customer</td>
				<td class="value">
					<select name="org_id">
						<option value="0">Everyone</option>
						<?=core_ui::options($orgs,null,'org_id','name')?>
					</select>
				</td>
			</tr>
			<?if(!lo3::is_admin() && $data['feature_sellers_enter_price_without_fees'] == 1){?>
			<tr>
				<td class="label">Net Price</td>
				<td class="value"><input type="text" name="seller_net_price" onkeyup="product.syncPrices(this,'price');" value="" /></td>
			</tr>
			<tr>
				<td class="label">Sales Price</td>
				<td class="value"><input type="text" name="price" onkeyup="product.syncPrices(this,'seller_net_price');" value="" /></td>
			</tr>
			<?}else{?>
			<tr>
				<td class="label">Price</td>
				<td class="value"><input type="text" name="price" value="" /></td>
			</tr>			
			<?}?>
			<tr>
				<td class="label">Minimum Quantity</td>
				<td class="value"><input type="text" name="min_qty" value="" /></td>
			</tr>
		</table>
		<input type="hidden" name="price_id" value="" />
		
		<input type="hidden" name="feature_sellers_enter_price_without_fees" value="" />
		<div class="buttonset">
			<input type="button" class="button_secondary" value="save this price" onclick="product.savePrice();" />
			<input type="button" class="button_secondary" value="cancel" onclick="product.cancelPriceChanges();" />
		</div>
	</fieldset>
</div>
