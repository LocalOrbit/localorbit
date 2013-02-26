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
<form name="pricing_advanced_rules" class="form-horizontal" action="/products/popup_save_price" onsubmit="return core.submit('/products/save_price',this);">
	<fieldset id="editPrice">
		<legend>Price Info</legend>
		<?=core_form::input_select('Market','domain_id',$price['domain_id'],$domains,array(
			'text_column'=>'name',
			'value_column'=>'domain_id',
			'default_show'=>true,
			'default_text'=>'Everywhere',
		))?>
		<?=core_form::input_select('Customer','org_id',$price['org_id'],$orgs,array(
			'text_column'=>'name',
			'value_column'=>'org_id',
			'default_show'=>true,
			'default_text'=>'Everyone',
		))?>
		
		
		<?if(!lo3::is_admin() && $seller['feature_sellers_enter_price_without_fees'] == 1){?>
			<?=core_form::input_text('Seller Net Price','seller_net_price',core_format::price(core_format::parse_price($price['price']) - (core_format::parse_price($price['price']) * ($seller['total_fees']/100))),array(
				'onkeyup'=>'product.syncPrices(this,\'price\');',
			))?>
			<?=core_form::input_text('Sales Price','price',$price['price'],array(
				'onkeyup'=>'product.syncPrices(this,\'seller_net_price\');',
			))?>
		<?}else{?>
		<?=core_form::input_text('Sales Price','price',$price['price'])?>
		<?}?>
		<?=core_form::input_text('Minimum Quantity','min_qty',floatval($price['min_qty']))?>
		
		
		<input type="hidden" name="price_id" value="<?=$price['price_id']?>" />
		<input type="hidden" name="prod_id" value="<?=$price['prod_id']?>" />
		<input type="hidden" name="call_method" value="popup" />
		<input type="hidden" name="total_fees" value="<?=$seller['total_fees']?>" />
		<div style="padding: 2px 5px;">
			Note: A minimum must exist before a price is created.  
			<a href="<?=$edit?>" onclick="$('#edit_popup').fadeOut('fast');core.go(this.href);">Click here</a>
			to view your pricing information.
		</div>
		
		<div class="form-actions pull-right">
			<input type="button" onclick="$('#edit_popup').fadeOut('fast');" class="btn btn-warning" value="cancel" />
			<input type="submit" class="btn btn-primary" value="save" />
		</div>		
	</fieldset>
</form>
<? 
core::js("$('#edit_popup').fadeIn('fast');"); 
core::replace('edit_popup'); 
?>
