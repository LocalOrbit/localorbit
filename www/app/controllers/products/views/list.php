<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'products-list','products-delivery');
core_ui::fullWidth();
core::head('List all products','List all products.');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','product.js');

# build the base model/collection
$col = core::model('products')
	->add_custom_field('(select sum(qty) from product_inventory WHERE product_inventory.prod_id=products.prod_id) as inventory')
	->collection()
	->filter('products.org_id','is not null',true)
	->filter('o.is_deleted','=',0)
	->filter('products.is_deleted','=',0);

$col->__model->autojoin(
	'left',
	'organizations_to_domains otd',
	'(products.org_id=otd.org_id)',
	array()
);

$col->__model->autojoin(
	'left',
	'domains d',
	'(otd.domain_id=d.domain_id)',
	array('d.name as domain_name')
);

# if viewer is a market manager, only show products from your own domain
if(lo3::is_market())
{
	$col->filter('d.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
}
# if you're a customer, only show your own products
if(lo3::is_customer())
{
	$col->filter('products.org_id',$core->session['org_id']);
}


# construct the table with slightly different columns depending on who is viewing
$products = new core_datatable('products','products/list',$col);

$actions = '<a class="btn btn-small btn-danger" href="#!products-list" class="text-error" onclick="product.deleteProduct({prod_id},\'{name}\',this);"><i class="icon-ban-circle" /> Delete</a>';

if(lo3::is_customer())
{
	$products->add(new core_datacolumn('name','Name',true,'46%','<a href="#!products-edit--prod_id-{prod_id}">{name} {plural_unit}</a>','{name} {plural_unit}','{name} {plural_unit}'));
	$products->add(new core_datacolumn('name','Pricing',false,'30%','{pricing_html}','{pricing}','{pricing}'));
	$products->add(new core_datacolumn('name','In Stock',false,'12%','<a href="#!products-list" onclick="product.editPopupInventory({prod_id},this);">{inventory}</a>','{inventory}','{inventory}'));
	//$products->add(new core_datacolumn('','&nbsp;',false,'12%','<a class="btn btn-small btn-danger" href="#!products-list" class="text-error" onclick="product.deleteProduct({prod_id},\'{name}\',this);"><i class="icon-ban-circle" /> Delete</a>',' ',' '));
	$products->add(new core_datacolumn('',' ',false,'12%',$actions,'  ','  '));
}
else
{
	$products->add(new core_datacolumn('o.name','Seller',true,'12%','<a href="#!products-edit--prod_id-{prod_id}">{org_name}</a>','{org_name}','{org_name}'));
	$products->add(new core_datacolumn('name','Hub',true,'12%','<a href="#!products-edit--prod_id-{prod_id}">{domain_name}</a>','{domain_name}','{domain_name}'));
	$products->add(new core_datacolumn('name','Name',true,'32%','<a href="#!products-edit--prod_id-{prod_id}">{name} {plural_unit}</a>','{name} {plural_unit}','{name} {plural_unit}'));
	$products->add(new core_datacolumn('name','Pricing',false,'20%','{pricing_html}','{pricing}','{pricing}'));
	$products->add(new core_datacolumn('name','In Stock',false,'12%','<a href="#!products-list" onclick="product.editPopupInventory({prod_id},this);">{inventory}</a>','{inventory}','{inventory}'));
	//$products->add(new core_datacolumn('','&nbsp;',false,'12%','<a class="btn btn-small btn-danger" href="#!products-list" class="text-error" onclick="product.deleteProduct({prod_id},\'{name}222222222222\',this);"><i class="icon-ban-circle" /> Delete</a>',' ',' '));
	$products->add(new core_datacolumn('',' ',false,'12%',$actions,'  ','  '));
	$products->sort_column = 2;
}

# Add some role-specific filters
if(lo3::is_admin() || lo3::is_market() && count($core->session['domains_by_orgtype_id'][2])>1)
{
	# get a collectio for the hub filter
	$hubs = core::model('domains')->collection()->sort('name');						
	if (lo3::is_market()){ 
		$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
	} 

	$products->add_filter(new core_datatable_filter('otd.domain_id'));
	$products->filter_html .= core_datatable_filter::make_select(
		'products',
		'otd.domain_id',
		$products->filter_states['products__filter__otd_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all hubs',
		'width: 250px;',
		'',
		'product.filterOrganizations(this.options[this.selectedIndex].value);'
	);
}		

if(lo3::is_admin() || lo3::is_market())
{
	# mms should only see sellers on their hub
	$sql = '
		select organizations.org_id,organizations.name,d.name as domain_name,
		concat_ws(\': \',d.name,organizations.name) as selector_name
		from organizations 
		left join organizations_to_domains otd on (organizations.org_id=otd.org_id and otd.is_home=1) 
		left join domains d on (otd.domain_id=d.domain_id) 
		where allow_sell=1 
		and organizations.name<>\'\' is not null
	';

	$sql .= (!lo3::is_admin())?' and d.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')':'';
	
	# if a domain id has already been selected, then
	# make sure the list only contains the appropriate orgs
	$domain_id = $products->filter_states['products__filter__otd_domain_id'];
	if(is_numeric($domain_id) && $domain_id > 0)
	{
		$sql .= ' and d.domain_id='.$products->filter_states['products__filter__otd_domain_id'];
	}
	
	$sql .= ' order by d.name,organizations.name';
	
	$products->add_filter(new core_datatable_filter('products.org_id'));
	$products->filter_html .= core_datatable_filter::make_select(
		'products',
		'products.org_id',
		$products->filter_states['products__filter__products_org_id'],
		new core_collection($sql),
		'org_id',
		(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)?'selector_name':'name',
		'Show from all organizations',
		'width: 320px;'
	);
}

# everyone gets a text filter on product name
$products->add_filter(new core_datatable_filter('name','products.name','~','search'));
$products->filter_html .= core_datatable_filter::make_text(
	'products',
	'name',
	$products->filter_states['products__filter__name'],
	'Search by product name'
);


# add the formatter that loads the pricing.
$col->add_formatter('product_pricing');

function product_pricing($data)
{
	global $core;
	$out = '';
	$html_out = '';
	$prices = core::model('product_prices')->collection()->filter('prod_id',$data['prod_id']);
	foreach($prices as $price)
	{
		core::log('adding price to table: '.$price['price']);
		if(core_format::parse_price($price['price']) > 0)
		{
			core::log('lets try to make a popup :D');
			$html_out .= '<a href="#!products-list" onclick="product.editPopupPrice('.$price['prod_id'].','.$price['price_id'].',this);">';
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
				$out .= core_format::price($price['price']);
				$html_out .= core_format::price($price['price']);
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

# render the page
page_header('Products','#!products-select_cat','Add new product', null, 'plus', 'apple-fruit');
echo('<form name="prodTable">');
$products->render();
echo('</form>');
?>
