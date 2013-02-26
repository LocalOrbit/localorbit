<?php

global $core;
$col = new core_collection('
	select products.*,Unit.PLURAL as plural_unit,organizations.name as org_name,
	(select sum(qty) from product_inventory where product_inventory.prod_id=products.prod_id) as inventory
	from products
	left join Unit on (Unit.UNIT_ID=products.unit_id)
	left join organizations on (organizations.org_id=products.org_id)
	where products.org_id in (select org_id from organizations_to_domains where domain_id in ('. implode(',', $core->session['domains_by_orgtype_id'][2]).'))
	and products.is_deleted=0
');
$col->add_formatter('product_pricing');
core_ui::load_library('js','product.js');

function product_pricing($data)
{
	global $core;
	$out = '';
	$prices = core::model('product_prices')->collection()->filter('prod_id',$data['prod_id']);
	foreach($prices as $price)
	{
		core::log('adding price to table: '.$price['price']);
		if(core_format::parse_price($price['price']) > 0)
		{
			core::log('lets try to make a popup :D');
			$html_out .= '<a href="#!dashboard-home" onclick="product.editPopupPrice('.$price['prod_id'].','.$price['price_id'].',this);">';
			$html_out .= ($out=='')?'':', ';
			$out .= ($out=='')?'':', ';
			if(!lo3::is_admin() && $core->config['domain']['feature_sellers_enter_price_without_fees'] == 1)
			{
				$total_fees = $core->config['domain']['fee_percen_lo'] + $core->config['domain']['fee_percen_hub'] + $core->config['domain']['paypal_processing_fee']; 

				$final_price = core_format::price(core_format::parse_price($price['price']) - (core_format::parse_price($price['price']) * ($total_fees/100)));
				$out .= $final_price;
				$html_out .= $final_price;
			}
			else
			{
				$out .= $price['price'];
				$html_out .= $price['price'];
			}
			if($price['min_qty'] > 1)
			{
				$out .= ' (min '.floatval($price['min_qty']).')';
				$html_out .= ' (min '.floatval($price['min_qty']).')';
			}
			$html_out .= '</a>';
		}
	}
	$data['pricing'] = $out;
	$data['pricing_html'] = $html_out;
	
	
	$data['inventory'] = floatval($data['inventory']);
	
	# fix up the unit a bit
	if($data['plural_unit'] != '')
		$data['plural_unit'] = '('.$data['plural_unit'].')';
		
	return $data;
}
$products = new core_datatable('market_products','dashboard/market_products',$col);
$products->add(new core_datacolumn('organizations.name','Seller',true,'24%','<a href="#!products-edit--prod_id-{prod_id}">{org_name}</a>','{org_name}','{org_name}'));
$products->add(new core_datacolumn('name','Name',true,'40%','<a href="#!products-edit--prod_id-{prod_id}">{name} {plural_unit}</a>','{name} {plural_unit}','{name} {plural_unit}'));
$products->add(new core_datacolumn('name','Pricing',false,'24%','{pricing_html}','{pricing}','{pricing}'));
$products->add(new core_datacolumn('name','In Stock',false,'12%','<a href="#!dashboard-home" onclick="product.editPopupInventory({prod_id},this);">{inventory}</a>','{inventory}','{inventory}'));

$products->size=5;
$products->render_resizer = false;
page_header('Products','#!products-select_cat','Create new product');
$products->render();
?>
