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
$mode = 'advanced';
if($mode == 'basic')
{
	$style = ' style="display: none;"';
?>
<input type="hidden" name="pricing_mode" value="basic" />

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
<div id="pricing_advanced">
You can set a single universal price, or individual prices for certain Markets 
(if applicable), certain Buyers, as well as prices for certain quantities.
<br />&nbsp;<br />
<?
	$prc = new core_datatable('pricing','products/pricing_form?prod_id='.$core->data['prod_id'],$prices);
	$prc->add(new core_datacolumn('domain_id','Markets',true,'26%','<a href="Javascript:product.editPrice(\'{price_id}\',\'{domain_id}\',\'{org_id}\',\'{price}\',\'{min_qty}\',\''.$seller['total_fees'].'\',\''.$seller['feature_sellers_enter_price_without_fees'].'\');">{domain}</a>'));
	$prc->add(new core_datacolumn('org_id','Buyer',true,'30%','<a href="Javascript:product.editPrice(\'{price_id}\',\'{domain_id}\',\'{org_id}\',\'{price}\',\'{min_qty}\',\''.$seller['total_fees'].'\',\''.$seller['feature_sellers_enter_price_without_fees'].'\');">{org_name}</a>'));
	$prc->add(new core_datacolumn('price','Price',true,'20%','<a href="Javascript:product.editPrice(\'{price_id}\',\'{domain_id}\',\'{org_id}\',\'{price}\',\'{min_qty}\',\''.$seller['total_fees'].'\',\''.$seller['feature_sellers_enter_price_without_fees'].'\');">{display_price}</a>'));
	$prc->add(new core_datacolumn('min_qty','Minimum Qty',true,'20%','<a href="Javascript:product.editPrice(\'{price_id}\',\'{domain_id}\',\'{org_id}\',\'{price}\',\'{min_qty}\',\''.$seller['total_fees'].'\',\''.$seller['feature_sellers_enter_price_without_fees'].'\');">{min_qty}</a>'));
	$prc->add(new core_datacolumn('price_id',core_ui::check_all('pricing'),false,'4%',core_ui::check_all('pricing','price_id')));
	
	$prc->size = (-1);
	$prc->display_filter_resizer = false;
	$prc->render_page_select = false;
	$prc->render_page_arrows = false;
	$prc->display_filter_resizer = false;
	$prc->display_exporter_pager = false;
	$prc->render();
?>
	<!--
	<br />
	<?=$core->i18n['note:pricingadvanced']?>
	-->
	<div class="pull-right" id="addPriceButton">
		<a class="btn btn-small btn-info" onclick="product.editPrice(0);"><i class="icon-plus" />  Add New Price</a>
		<a class="btn btn-small btn-danger" onclick="product.removeCheckedPrices(document.prodForm);"><i class="icon-trash" /> Remove Checked</a>
	</div>
	<br />&nbsp;<br />
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
	
	
</div>
<br />
<div class="row">
	<div class="span3">&nbsp;</div>
	<fieldset id="editPrice" class="span6" style="display: none;">

	<legend>Price Info</legend>
	<?=core_form::input_select(
		'Market','domain_id',0,$domains,array(
			'text_column'=>'name',
			'value_column'=>'domain_id',
			'default_show'=>true,
			'default_text'=>'All Markets',
			'default_value'=>0,
		)
	)?>
	<?=core_form::input_select(
		'Buyer','org_id',0,$orgs,array(
			'text_column'=>'name',
			'value_column'=>'org_id',
			'default_show'=>true,
			'default_text'=>'All Buyers',
			'default_value'=>0,
		)
	)?>
	<?if(lo3::is_admin() || $core->config['domain']['feature_sellers_enter_price_without_fees'] == 1){?>	
		<?=core_form::input_text('Net Price','seller_net_price',$data['seller_net_price'],array('onkeyup'=>"product.syncPrices(this,'price');"))?>
		<?=core_form::input_text('Sales Price','price',$data['price'],array('onkeyup'=>"product.syncPrices(this,'seller_net_price');"))?>
	<?}else{?>
		<?=core_form::input_text('Price','price',$data['price'])?>		
	<?}?>
	<?=core_form::input_text('Minimum Quantity','min_qty',$data['min_qty'])?>
	<?=core_form::input_hidden('price_id',0)?>
	<?=core_form::input_hidden('total_fees',$seller['total_fees'])?>
	<?=core_form::input_hidden('feature_sellers_enter_price_without_fees',0)?>
	<? subform_buttons('product.savePrice();','Save This Price','product.cancelPriceChanges();'); ?>
		</fieldset>
	<div class="span3">&nbsp;</div>
	<div class="clear-both"></div>
</div>
