<?php 
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('User Management','This page is used to manage users');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','org.js');

$col = core::model('customer_entity')->collection();
$col->__model->autojoin(
	'left',
	'organizations o',
	'(o.org_id=customer_entity.org_id)',
	array('o.name as org_name')
);
$col->__model->autojoin(
	'left',
	'organizations_to_domains otd',
	'(otd.org_id=o.org_id and otd.is_home=1)',
	array()
);	
$col->__model->autojoin(
	'left',
	'domains d',
	'(d.domain_id=otd.domain_id)',
	array('d.name as domain_name')
);
$col->__model->autojoin(
	'left',
	'organization_types',
	'(otd.orgtype_id=organization_types.orgtype_id)',
	array('organization_types.name as orgtype_name')
);
$col->filter('o.is_deleted',0);
$col->filter('customer_entity.is_deleted',0);

if(lo3::is_market())
{
	$col->filter('d.domain_id','in', $core->session['domains_by_orgtype_id'][2]);
}
else
{
	lo3::require_orgtype('admin');
}


$col->add_formatter('enable_suspend_links');
$users = new core_datatable('customer_entity','users/list',$col);


$users->add_filter(new core_datatable_filter('name','concat(first_name,last_name,email)','~'));
echo(core_datatable_filter::make_text('customer_entity','name',$users->filter_states['customer_entity__filter__name'],'Search by name'));


# filter by domains
if(lo3::is_admin() || lo3::is_market() && count($core->session['domains_by_orgtype_id'][2])>1)
{
	$hubs = core::model('domains')->collection()->sort('name');						
	if (lo3::is_market()) 
		$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							

	$users->add_filter(new core_datatable_filter('otd.domain_id'));
	echo(core_datatable_filter::make_select(
		'customer_entity',
		'otd.domain_id',
		$users->filter_states['customer_entity__filter__o_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all hubs',
		'width: 230px;'
	));
}

if(lo3::is_admin())
{

	# filter by org type
	$users->add_filter(new core_datatable_filter('otd.orgtype_id'));
	echo(core_datatable_filter::make_select(
		'customer_entity',
		'otd.orgtype_id',
		$users->filter_states['customer_entity__filter__otd_orgtype_id'],
		new core_collection('select orgtype_id,name from organization_types order by orgtype_id'),
		'orgtype_id',
		'name',
		'Show all org types'
	));
}

core::replace('datatable_filters');
$users->filter_html .= core::getclear_position('datatable_filters');

$actions = '
	<a href="#!auth-loginas--entity_id-{entity_id}">Login &raquo;</a>
	<br />
	<a href="javascript:core.doRequest(\'/users/{enable_action}\',{\'entity_id\':{entity_id},\'table\':\'customer_entity\'});">{enable_action}</a>
	<br />
	<a href="#!users-list" onclick="org.deleteUser({entity_id},this,'.$core->session['user_id'].');">Delete&nbsp;&raquo;</a>
';

#$users->add_filter(new core_datatable_filter('org_id'));
$users->add(new core_datacolumn('o.name','Organization',true,'30%','<a href="#!users-edit--entity_id-{entity_id}"><b>{org_name}</b><br />{domain_name}</a>','{org_name}','{org_name}'));
$users->add(new core_datacolumn('first_name','Name',true,'35%','<a href="#!users-edit--entity_id-{entity_id}"><b>{first_name} {last_name}</b><br /><a href="mailTo:{email}">{email}</a></a>','{first_name} {last_name}','{first_name} {last_name}'));
$users->add(new core_datacolumn('organization_types.name','Org Type',true,'11%','<a href="#!users-edit--entity_id-{entity_id}">{orgtype_name}</a>','{orgtype_name}','{orgtype_name}'));
$users->add(new core_datacolumn('created_at','Registered On',true,'15%','<a href="#!users-edit--entity_id-{entity_id}">{created_at}</a>','{created_at}','{created_at}'));
$users->add(new core_datacolumn('entity_id',' ',false,'10%',$actions,'  ','  '));

$users->sort_column = 3;
$users->sort_direction = 'desc';

$users->columns[3]->autoformat='date-short';


page_header('Users','#!users-add_new','Add new user');
$users->render();
?>
