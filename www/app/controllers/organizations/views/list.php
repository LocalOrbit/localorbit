<?php 


core::ensure_navstate(array('left'=>'left_dashboard'),'organizations-list','market-admin');
core_ui::fullWidth();
core::head('Org Management','This page is used to manage organizations');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','org.js');

function escape_names ($org) 
{
	$org['name_esc'] = str_replace('\'', '\\\'', $org['name']);
	return $org;
}

function org_col_formatter($data)
{
	global $core;
	$data['allow_sell_printable'] = ($data['allow_sell'] == 1)?'True':'False';
	
	$data['activate_action'] = ($data['is_active'] == 1)?'deactivate':'activate';
	$data['enable_action']   = ($data['is_enabled'] == 1)?'suspend':'enable';
	
	
	# handle additional csv columns
	if($core->data['format'] == 'csv')
	{
		$data['shipping_address'] .= ', '.$data['shipping_city'].' '.$data['shipping_state'].' '.$data['shipping_postal_code'];
		$data['billing_address'] .= ', '.$data['billing_city'].' '.$data['billing_state'].' '.$data['billing_postal_code'];
	}
	
	/* switch($data['composite_role'])
	{
		case 1: $data['role'] = 'Admin';	break;
		case 2: $data['role'] = 'Market Manager';	break;
		case '3-0': $data['role'] = 'Buyer'; break;
		case '3-1': $data['role'] = 'Seller'; break;
	} */
	
	
	return $data;
}

$col = core::model('v_organizations');
if($core->data['format'] == 'csv')
{
	$col->autojoin(
		'left',
		'addresses a1',
		'(v_organizations.org_id=a1.org_id and a1.default_shipping=1)',
		array('a1.address as shipping_address','a1.city as shipping_city','a1.postal_code as shipping_postal_code','a1.telephone as shipping_phone')
	)->autojoin(
		'left',
		'directory_country_region dcr1',
		'(dcr1.region_id=a1.region_id)',
		array('dcr1.code as shipping_state')
	)->autojoin(
		'left',
		'addresses a2',
		'(v_organizations.org_id=a2.org_id and a2.default_billing=1)',
		array('a2.address as billing_address','a2.city as billing_city','a2.postal_code as billing_postal_code','a2.telephone as billing_phone')
	)->autojoin(
		'left',
		'directory_country_region dcr2',
		'(dcr2.region_id=a2.region_id)',
		array('dcr2.code as billing_state')
	)->autojoin(
		'left',
		'customer_entity ce',
		'(ce.org_id=v_organizations.org_id)',
		array('group_concat(\',\',concat_ws(\' \',ce.first_name,ce.last_name)) as user_list')
	);
}
$col = $col->collection()->filter('v_organizations.is_deleted','=',0);
$col->add_formatter('org_col_formatter');
if($core->data['format'] == 'csv')
{
	$col->group('v_organizations.org_id');
}

if(!lo3::is_market() && !lo3::is_admin())
{
	# kick them out.
	lo3::require_orgtype('market');
}
if(lo3::is_market())
{
	$col->filter('domain_id','in', $core->session['domains_by_orgtype_id'][2]);
}

$col->add_formatter('escape_names');



$orgs = new core_datatable('v_organizations','organizations/list',$col);

# only show the hub filter if admin or multiple hubs
if(lo3::is_admin() || (lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) > 1))
{
	$hubs = core::model('domains')->collection();						
	if (lo3::is_market()) { 
		$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
	} 
	$hubs = $hubs->sort('name');
	$orgs->add_filter(new core_datatable_filter('domain_id'));
	echo(core_datatable_filter::make_select(
		'v_organizations',
		'domain_id',
		$orgs->filter_states['v_organizations__filter__domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 230px;'
	));
}

core::log('here');
if(lo3::is_admin())
{
	$orgs->add_filter(new core_datatable_filter('composite_role'));
	echo(core_datatable_filter::make_select(
		'v_organizations',
		'composite_role',
		$orgs->filter_states['v_organizations__filter__composite_role'],
		array(
			'3-0'=>'Buyer',
			'3-1'=>'Seller',
			'2'=>'Market Manager',
			'1'=>'Admin',
		),
		null,
		null,
		'Show all roles'
	));
}

core::log('here');

$orgs->add_filter(new core_datatable_filter('name','name','~','search'));
echo(core_datatable_filter::make_text('v_organizations','name',$orgs->filter_states['v_organizations__filter__name'],'Search by name'));


if(lo3::is_admin() || lo3::is_market())
{
	$widths = array('19%','21%','14%','10%','44%');
}
else
{
	$widths = array('31%','25%','12%','10%','20%');
}



# add the columns
$orgs->add(new core_datacolumn('name','Name',true,$widths[0],'<a href="#!organizations-edit--org_id-{org_id}">{name}</a>','{name}','{name}'));
$orgs->add(new core_datacolumn('domain_name','Market',true,$widths[1],'{domain_name}','{domain_name}','{domain_name}'));
$orgs->add(new core_datacolumn('creation_date','Registered On',true,$widths[2],'{creation_date}','{creation_date}','{creation_date}'));
$orgs->add(new core_datacolumn('role_label','Role',true,$widths[3],'{role_label}','{role_label}','{role_label}'));

# csv format needs additional columns
if($core->data['format'] == 'csv')
{
	$orgs->add(new core_datacolumn('shipping_address','Shipping Address',false,$widths[3]));
	$orgs->add(new core_datacolumn('shipping_phone','Shipping Phone',false,$widths[3]));
	$orgs->add(new core_datacolumn('billing_address','Billing Address',false,$widths[3]));
	$orgs->add(new core_datacolumn('billing_phone','Billing Phone',false,$widths[3]));
	$orgs->add(new core_datacolumn('user_list','User List',false,$widths[3]));
}
else
{

	if(lo3::is_admin() || lo3::is_market())
	{
		$orgs->add(new core_datacolumn('name',' ',false,$widths[4],'
			<a class="btn btn-wide btn-small" href="javascript:core.doRequest(\'/organizations/{activate_action}\',{\'org_id\':{org_id}});"><i class="icon-off" /> {activate_action}</a>
			<a class="btn btn-wide btn-small btn-info" href="javascript:core.doRequest(\'/organizations/{enable_action}\',{\'org_id\':{org_id}});" class="text-warning"><i class="icon-eye-close" /> {enable_action}</a>
			<a class="btn btn-wide btn-small btn-danger" href="#!organizations-list" class="text-error" onclick="org.deleteOrg({org_id},\'{name_esc}\',this);"><i class="icon-ban-circle" /> Delete</a>
		',' ',' '));
	}
	else
	{
		$orgs->add(new core_datacolumn('','&nbsp;',false,$widths[4],'<a href="#!organizations-list" onclick="org.deleteOrg({org_id},\'{name_esc}\',this);">Delete&nbsp;&raquo;</a>',' ',' '));
	}
}

$orgs->columns[2]->autoformat='date-short';
$orgs->sort_column = 2;
$orgs->sort_direction = 'desc';

core::replace('datatable_filters');
$orgs->filter_html .= core::getclear_position('datatable_filters');
page_header('Organizations','#!organizations-add','New organization', null, 'plus', 'grid');

core::log('parameters passed: '.print_r($core->data,true));

$orgs->render();
?>