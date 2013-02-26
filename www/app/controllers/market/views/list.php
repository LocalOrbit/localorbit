<?php  
core::ensure_navstate(array('left'=>'left_dashboard'),'market-list','market-admin'); 
core_ui::fullWidth();
core::head('List Markets','asdfasdfasdfsdf');
lo3::require_permission();
lo3::require_login();


function domain_checks($data)
{	
	$data['show_on_homepage_printable'] = ($data['show_on_homepage'] == 1)?'True':'False';
	$data['is_live_printable'] = ($data['is_live'] == 1)?'True':'False';
	$data['is_closed_printable'] = ($data['is_closed'] == 1)?'True':'False';

	$data['show_on_homepage'] = ($data['show_on_homepage'] == 1)?'<i class="icon-check icon-large"></i>':'';
	$data['is_live'] = ($data['is_live'] == 1)?'<i class="icon-check icon-large"></i>':'';
	$data['is_closed'] = ($data['is_closed'] == 1)?'<i class="icon-check icon-large"></i>':'';

	return $data;
}

$col = core::model('domains')->collection();
$col->add_formatter('domain_checks');

# apply permissions
if(lo3::is_market())
{
	$col->filter(
		'domain_id',
		'in',
		$core->session['domains_by_orgtype_id'][2]
	);
}
else
{
	lo3::require_orgtype('admin');
}


$domains = new core_datatable('domains','market/list',$col);

if(lo3::is_admin())
{
	$domains->add_filter(new core_datatable_filter('domains.show_on_homepage'));
	$domains->filter_html .= core_datatable_filter::make_select(
		'domains',
		'domains.show_on_homepage',
		$orders->filter_states['domains__filter__domains_show_on_homepage'],
		array('false'=>'Secret only','1'=>'Public only'),
		null,
		null,
		'Public/Secret hubs'
	);


	$domains->add_filter(new core_datatable_filter('domains.is_live'));
	$domains->filter_html .= core_datatable_filter::make_select(
		'domains',
		'domains.is_live',
		$orders->filter_states['domains__filter__domains_is_live'],
		array('false'=>'Not live only','1'=>'Live only'),
		null,
		null,
		'Live/Not live hubs'
	);
	
	$cols = array('34%','42%','8%','8%','8%');
}
else
{
	$cols = array('42%','50%','8%','8%','8%');
}

$domains->add_filter(new core_datatable_filter('domains.is_closed'));
$domains->filter_html .= core_datatable_filter::make_select(
	'domains',
	'domains.is_closed',
	$orders->filter_states['domains__filter__domains_is_closed'],
	array('false'=>'Open only','1'=>'Closed only'),
	null,
	null,
	'Open/Closed hubs'
);

$domains->add_filter(new core_datatable_filter('name','name','~'));
$domains->filter_html .= core_datatable_filter::make_text('domains','name',$domains->filter_states['domains__filter__name'],'Search by name');

$domains->add(new core_datacolumn('name','Name',true,$cols[0],'<a href="#!market-edit--domain_id-{domain_id}"><b>{name}</b></a><br /><i class="icon-signin" /> <a href="https://{hostname}/app.php#!dashboard-home">Switch to {hostname}</a>'));
$domains->add(new core_datacolumn('secondary_contact_name','Market Contact',true,$cols[1],'{secondary_contact_name} (<a href="mailTo:{secondary_contact_email}">e-mail</a>)<br />Tel. {secondary_contact_phone} '));

if(lo3::is_admin())
{
	$domains->add(new core_datacolumn('show_on_homepage','Home',true,$cols[2],'{show_on_homepage}','{show_on_homepage_printable}','{show_on_homepage_printable}'));
	$domains->add(new core_datacolumn('is_live','Live',true,$cols[3],'{is_live}','{is_live_printable}','{is_live_printable}'));
}

$domains->add(new core_datacolumn('is_closed','Closed',true,$cols[4],'{is_closed}','{is_closed_printable}','{is_closed_printable}'));
page_header('Markets', null, null, null, null, 'home');
#,'#!market-edit','Create new hub'
$domains->render();
?>