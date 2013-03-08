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
	$data['allow_sell_printable'] = ($data['allow_sell'] == 1)?'True':'False';
	
	$data['activate_action'] = ($data['is_active'] == 1)?'deactivate':'activate';
	$data['enable_action']   = ($data['is_enabled'] == 1)?'suspend':'enable';
	
	/* switch($data['composite_role'])
	{
		case 1: $data['role'] = 'Admin';	break;
		case 2: $data['role'] = 'Market Manager';	break;
		case '3-0': $data['role'] = 'Buyer'; break;
		case '3-1': $data['role'] = 'Seller'; break;
	} */
	
	
	return $data;
}

$col = core::model('v_organizations')->collection()->filter('is_deleted','=',0);
$col->add_formatter('org_col_formatter');

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

$orgs->add_filter(new core_datatable_filter('name','name','~'));
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

$orgs->columns[2]->autoformat='date-short';
$orgs->sort_column = 2;
$orgs->sort_direction = 'desc';

core::replace('datatable_filters');
$orgs->filter_html .= core::getclear_position('datatable_filters');
page_header('Organizations','#!organizations-add','New organization', null, 'plus', 'grid');
$orgs->render();
?>