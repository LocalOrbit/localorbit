<?php

core::ensure_navstate(array('left'=>'left_dashboard'),'weekly_specials-list','marketing');
core_ui::fullWidth();
core::head('Buy and Sell Local Food on Local Orbit - Specials','This page is used to view specials');
lo3::require_permission();
lo3::require_login();

function handle_set_special_link($data)
{
	global $core;
	
	$data['special_link'] = core_ui::radiodiv(
		'special_'.$data['spec_id'],
		(count($core->session['domains_by_orgtype_id'][2])>1 || lo3::is_admin())?'Set as promotion for '.$data['domain_name']:'Set as promotion',
		($data['is_active'] == 1),
		'special_group_'.$data['domain_id'],
		true,
		'core.doRequest(\'/weekly_specials/toggle_special\',{\'refresh_table\':1,\'domain_id\':'.$data['domain_id'].',\'spec_id\':'.$data['spec_id'].'});'
	);
		
	return $data;
}

$col = core::model('weekly_specials')->collection();
$col->add_formatter('handle_set_special_link');
if(lo3::is_market()) {
	$col->filter('weekly_specials.domain_id','in', $core->session['domains_by_orgtype_id'][2]);
}

$weekly_specials = new core_datatable('weekly_specials','weekly_specials/list',$col);

if(lo3::is_admin() || lo3::is_market() && count($core->session['domains_by_orgtype_id'][2])>1)
{
	$hubs = core::model('domains')->collection()->sort('name');						
	if (lo3::is_market())
		$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
	
	$weekly_specials->add_filter(new core_datatable_filter('weekly_specials.domain_id'));
	echo(core_datatable_filter::make_select(
		'weekly_specials',
		'weekly_specials.domain_id',
		$weekly_specials->filter_states['weekly_specials__filter__weekly_specials_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all hubs'
	));
	core::replace('datatable_filters');
	$weekly_specials->filter_html .= core::getclear_position('datatable_filters');
}


# $weekly_specials->add(new core_datacolumn('radio_select','radio_select',true,'10%','radio'));
$weekly_specials->add(new core_datacolumn('creation_date','Created On',true,'15%'));
$weekly_specials->add(new core_datacolumn('name','Name',true,'35%','<a href="#!weekly_specials-edit--spec_id-{spec_id}">{name}</a>','{name}','{name}'));
#$weekly_specials->add(new core_datacolumn('domain_name','Hub',true,'25%'));
$weekly_specials->add(new core_datacolumn('domain_name','Action',false,'38%','{special_link}','{domain_name}','{domain_name}'));
$weekly_specials->add(new core_datacolumn('domain_name','Action',false,'12%','<a class="btn btn-small btn-danger" href="#!weekly_specials-list" onclick="if(confirm(\'Are you sure you want to delete this special?\')){core.doRequest(\'/weekly_specials/delete\',\'&spec_id={spec_id}\');return false;}"><i class="icon-minus" /> Delete</a>','{domain_name}','{domain_name}'));
$weekly_specials->columns[0]->autoformat='date-short';


page_header('Featured Promotions','#!weekly_specials-edit','Create new promotion', 'button',null, 'star');
$weekly_specials->render();
?>