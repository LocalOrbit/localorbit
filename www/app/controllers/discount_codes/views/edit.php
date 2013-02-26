<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'discount_codes-list','marketing');
core_ui::fullWidth();
core::head('Edit Discount Code','This page is to edit Discount Code Information');
lo3::require_permission();
lo3::require_login();
lo3::require_orgtype('market');

# get a set of collections used for select lists in the page
$hubs = core::model('domains')->collection()->sort('name');
$seller_restrict = core::model('organizations')->collection()->filter('allow_sell',1)->sort('full_org_name');
$buyer_restrict  = core::model('organizations')->collection()->sort('full_org_name');
$prod_sql = '
	select prod_id,concat_ws(\': \',domains.name,organizations.name,products.name) as prod_name
	from products 
	inner join organizations on (products.org_id=organizations.org_id)
	inner join organizations_to_domains on (organizations_to_domains.org_id=organizations.org_id and organizations_to_domains.is_home=1)
	inner join domains on (organizations_to_domains.domain_id=domains.domain_id)
	where products.is_deleted=0
	and   organizations.is_deleted=0
';

# apply some MM specific rules
if(lo3::is_market())
{
	$hubs->filter('domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$prod_sql .= '
		and domains.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
	';
	$buyer_restrict->filter('domains.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$seller_restrict->filter('domains.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
}

# finish loading the products
$prod_sql .= 'order by domains.name,organizations.name,products.name';
$products = new core_collection($prod_sql);

# load the code data and javascript rules
$data = (is_numeric($core->data['disc_id']))?core::model('discount_codes')->load():array();
$this->rules()->js();

# render the form
echo(
	core_form::page_header('Editing '.$data['name']).
	core_form::form('discForm','/discount_codes/update',null,
		core_form::tab_switchers('discounttabs',array('Discounts')),
		core_form::tab('discounttabs',
			core_form::table_nv(
				core_form::input_text('Discount Name','name',$data),
				core_form::input_text('Code','code',$data),
				(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)?
					core_form::input_select('Market','domain_id',$data,$hubs,array(
						'default_show'=>(lo3::is_admin()),
						'default_text'=>'All Markets',
						'text_column'=>'name',
						'value_column'=>'domain_id',
					))
				:'',
				core_form::input_datepicker('Start Date','start_date',$data['start_date']),
				core_form::input_datepicker('End Date','end_date',$data),
				core_form::input_select('Type','discount_type',$data,array('Fixed'=>'Dollar Amount','Percent'=>'Percentage')),
				core_form::input_text('Discount','discount_amount',lo3_display_negative($data['discount_amount'])),
				core_form::input_select('Restrict to Product','restrict_to_product_id',$data,$products,array(
					'default_show'=>true,
					'default_text'=>'All Products',
					'text_column'=>'prod_name',
					'value_column'=>'prod_id',
					'select_style'=>'width:300px;',
				)),
				core_form::input_select('Restrict to Buyer Org','restrict_to_buyer_org_id',$data,$buyer_restrict,array(
					'default_show'=>true,
					'default_text'=>'All Buyers',
					'text_column'=>'full_org_name',
					'value_column'=>'org_id',
					'select_style'=>'width:300px;',
				)),
				core_form::input_select('Restrict to Seller Org','restrict_to_seller_org_id',$data,$seller_restrict,array(
					'default_show'=>true,
					'default_text'=>'All Sellers',
					'text_column'=>'full_org_name',
					'value_column'=>'org_id',
					'select_style'=>'width:300px;',
				)),
				core_form::input_text('Minimum order total','min_order',lo3_display_negative($data['min_order']),array('sublabel'=>'0 for no min')),
				core_form::input_text('Maximum order total','max_order',lo3_display_negative($data['max_order']),array('sublabel'=>'0 for no min')),
				core_form::input_text('Max global uses','nbr_uses_global',$data,array('sublabel'=>'0 for no min')),
				core_form::input_text('Max per org uses','nbr_uses_org',$data,array('sublabel'=>'0 for no min'))
			)
		),
		core_form::input_hidden('disc_id',$data),
		core_form::save_buttons(array('cancel_button' => true, 'on_cancel' => 'location.href=\'#!discount_codes-list\';core.go(\'#!discount_codes-list\');'))
	)
);

?>