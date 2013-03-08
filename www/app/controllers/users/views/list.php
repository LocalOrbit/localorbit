<?php 
core::ensure_navstate(array('left'=>'left_dashboard'),'users-list','market-admin');
core_ui::fullWidth();
core::head('User Management','This page is used to manage users');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','org.js');

$col = core::model('v_users')->collection();

$col->filter('org_is_deleted','=',0);
$col->filter('is_deleted','=',0);

if(lo3::is_market())
{
	$col->filter('domain_id','in', $core->session['domains_by_orgtype_id'][2]);
}
else
{
	lo3::require_orgtype('admin');
}


/* function user_role_formatter($data)
{
	global $core;
	$data['role'] = ($data['allow_sell'] == 1)?'Seller':'Buyer';
	#core::log('orgtype id : '.$data['orgtype_id']);
	if($data['composite_role'] == '2')
	{
		$data['role'] = 'Market Manager';
	}
	if($data['composite_role'] == '1')
	{
		$data['role'] = 'Admin';
	}

	if($data['composite_role'] == '3-0')
	{
		$data['role'] = 'Buyer';
	}


	if($data['composite_role'] == '3-1')
	{
		$data['role'] = 'Seller';
	}

	#core::log('role: '.$data['role']);
	return $data;
}
 */

$col->add_formatter('enable_suspend_links');
//$col->add_formatter('user_role_formatter');



$users = new core_datatable('customer_entity','users/list',$col);


# filter by domains
if(lo3::is_admin() || lo3::is_market() && count($core->session['domains_by_orgtype_id'][2])>1)
{
	$hubs = core::model('domains')->collection()->sort('name');						
	if (lo3::is_market()) 
		$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							

	$users->add_filter(new core_datatable_filter('domain_id'));
	echo(core_datatable_filter::make_select(
		'customer_entity',
		'domain_id',
		$users->filter_states['customer_entity__filter__domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 230px;'
	));
}

if(lo3::is_admin())
{
	# filter by org type
	$users->add_filter(new core_datatable_filter('composite_role'));
	echo(core_datatable_filter::make_select(
		'customer_entity',
		'composite_role',
		$users->filter_states['customer_entity__filter__composite_role'],
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


$users->add_filter(new core_datatable_filter('name','concat(first_name,last_name,email)','~','search'));
echo(core_datatable_filter::make_text('customer_entity','name',$users->filter_states['customer_entity__filter__name'],'Search by name'));



core::replace('datatable_filters');
$users->filter_html .= core::getclear_position('datatable_filters');

$actions = '
	<a class="btn btn-primary btn-small" href="#!auth-loginas--entity_id-{entity_id}"><i class="icon-arrow-right" /> Log in</a>
	<a class="btn btn-warning btn-small" href="javascript:core.doRequest(\'/users/{enable_action}\',{\'entity_id\':{entity_id},\'table\':\'customer_entity\'});" style="width:64px;"><i class="icon-{enable_icon}" /> {enable_action}</a>
	<a class="btn btn-danger btn-small" href="#!users-list" onclick="org.deleteUser({entity_id},\'{first_name} {last_name}\',this,'.$core->session['user_id'].');"><i class="icon-ban-circle" /> Delete</a>
';

#$users->add_filter(new core_datatable_filter('org_id'));
$users->add(new core_datacolumn('first_name','Name',true,'25%','<a href="#!users-edit--entity_id-{entity_id}"><b>{first_name} {last_name}</b></a><br /><small><i class="icon-envelope"></i> <a href="mailTo:{email}">{email}</a></small>','{first_name} {last_name}','{first_name} {last_name}'));
$users->add(new core_datacolumn('org_name','Organization',true,'20%','<b>{org_name}</b><br /><small>{domain_name}</small>','{org_name}','{org_name}'));
$users->add(new core_datacolumn('created_at','Registered On',true,'15%','{created_at}','{created_at}','{created_at}'));
$users->add(new core_datacolumn('role_label','Role',true,'10%','{role_label}','{role_label}','{role_label}'));
$users->add(new core_datacolumn('entity_id',' ',false,'30%',$actions,'  ','  '));

$users->sort_column = 2;
$users->sort_direction = 'desc';

$users->columns[2]->autoformat='date-short';


page_header('Users','#!users-add_new','Add new user','button','icon-plus','users');
$users->render();
?>