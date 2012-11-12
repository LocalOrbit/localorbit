<?php 
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Org Management','This page is used to manage organizations');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','org.js');

function org_col_formatter($data)
{
	$data['allow_sell_printable'] = ($data['allow_sell'] == 1)?'True':'False';
	
	$data['activate_action'] = ($data['is_active'] == 1)?'deactivate':'activate';
	$data['enable_action']   = ($data['is_enabled'] == 1)?'suspend':'enable';
	
	switch($data['orgtype_id'])
	{
		case 1: $data['role'] = 'Admin';	break;
		case 2: $data['role'] = 'Market Manager';	break;
		case 3: $data['role'] = ($data['allow_sell'] == 1)?'Seller':'Buyer';	break;
	}
	
	
	return $data;
}

$col = core::model('organizations')->collection()->filter('is_deleted','=',0);
$col->add_formatter('org_col_formatter');

if(!lo3::is_market() && !lo3::is_admin())
{
	# kick them out.
	lo3::require_orgtype('market');
}
if(lo3::is_market())
{
	$col->filter('domains.domain_id','in', $core->session['domains_by_orgtype_id'][2]);
}



$orgs = new core_datatable('organizations','organizations/list',$col);

# only show the hub filter if admin or multiple hubs
if(lo3::is_admin() || (lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) > 1))
{
	$hubs = core::model('domains')->collection();						
	if (lo3::is_market()) { 
		$hubs = $hubs->filter('domains.domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
	} 
	$hubs = $hubs->sort('name');
	$orgs->add_filter(new core_datatable_filter('domains.domain_id'));
	echo(core_datatable_filter::make_select(
		'organizations',
		'domains.domain_id',
		$orgs->filter_states['organizations__filter__domains_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all hubs',
		'width: 230px;'
	));
}

if(lo3::is_admin())
{
	$orgs->add_filter(new core_datatable_filter('organizations_to_domains.orgtype_id'));
	echo(core_datatable_filter::make_select(
		'organizations',
		'organizations_to_domains.orgtype_id',
		$orgs->filter_states['organizations__filter__organizations_to_domains_orgtype_id'],
		array(1=>'Admin',2=>'Market Management',3=>'Customer'),
		'orgtype_id',
		'name',
		'Show all org types'
	));
}

$orgs->add_filter(new core_datatable_filter('name','organizations.name','~'));
echo(core_datatable_filter::make_text('organizations','name',$orgs->filter_states['organizations__filter__name'],'Search by name'));

$orgs->add_filter(new core_datatable_filter('allow_sell','organizations.allow_sell'));
echo(core_datatable_filter::make_checkbox('organizations','allow_sell',($orgs->filter_states['organizations__filter__allow_sell'] == 1),'Only show sellers'));

# add the columns
$orgs->add(new core_datacolumn('name','Name',true,'40%','<a href="#!organizations-edit--org_id-{org_id}">{name}</a>','{name}','{name}'));
$orgs->add(new core_datacolumn('domains.name','Domain',true,'25%','<a href="#!organizations-edit--org_id-{org_id}">{domain_name}</a>','{domain_name}','{domain_name}'));
$orgs->add(new core_datacolumn('creation_date','Registered On',true,'15%','<a href="#!organizations-edit--org_id-{org_id}">{creation_date}</a>','{creation_date}','{creation_date}'));
$orgs->add(new core_datacolumn('orgtype_id','Role',true,'10%','<a href="#!organizations-edit--org_id-{org_id}">{role}</a>','{role}','{role}'));
$orgs->add(new core_datacolumn('name',' ',false,'10%','<a href="javascript:core.doRequest(\'/organizations/{activate_action}\',{\'org_id\':{org_id}});">{activate_action}</a><br /><a href="javascript:core.doRequest(\'/organizations/{enable_action}\',{\'org_id\':{org_id}});">{enable_action}</a>',' ',' '));

if(lo3::is_admin() || lo3::is_market())
{
	$orgs->add(new core_datacolumn('','&nbsp;',false,'12%','<a href="#!organizations-list" onclick="org.deleteOrg({org_id},\'{name}\',this);">Delete&nbsp;&raquo;</a>',' ',' '));
}

$orgs->columns[2]->autoformat='date-short';
$orgs->sort_column = 2;
$orgs->sort_direction = 'desc';

core::replace('datatable_filters');
$orgs->filter_html .= core::getclear_position('datatable_filters');
page_header('Organizations','#!organizations-add','Add new organization');
$orgs->render();
?>