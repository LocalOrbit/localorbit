<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'newsletters-list','marketing');
core_ui::fullWidth();
core::head('Newsletters','Newsletters.');
lo3::require_permission();
lo3::require_login();



$col = core::model('newsletter_content')->collection();
$newsletters = new core_datatable('newsletters','newsletters/list',$col);



# can do anything, needs a domain filter
if(lo3::is_admin() || lo3::is_market() && count($core->session['domains_by_orgtype_id'][2])>1)
{
	$hubs = core::model('domains')->collection()->sort('name');						
	if (lo3::is_market())
		$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
	
	$newsletters->add_filter(new core_datatable_filter('newsletter_content.domain_id'));
	echo(core_datatable_filter::make_select(
		'newsletters',
		'newsletter_content.domain_id',
		$newsletters->filter_states['newsletters__filter__newsletter_content_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all hubs'
	));
}

core::replace('datatable_filters');
$newsletters->filter_html .= core::getclear_position('datatable_filters');

if(lo3::is_market())
{
	# if this is a market manager, only show specials for their own hub
	$col->filter('newsletter_content.domain_id','in', $core->session['domains_by_orgtype_id'][2]);
}
else if(!lo3::is_admin())
{
	# kick them out.
	lo3::require_orgtype('market');
}

$newsletters->add(new core_datacolumn('domain_name','Hub',true,'33%','<a href="#!newsletters-edit--cont_id-{cont_id}">{domain_name}</a>','{domain_name}','{domain_name}'));
$newsletters->add(new core_datacolumn('title','Title',true,'55%','<a href="#!newsletters-edit--cont_id-{cont_id}">{title}</a>','{title}','{title}'));
$newsletters->add(new core_datacolumn('title','Action',false,'12%','<a class="btn btn-small btn-danger" href="#!newsletters-list" onclick="if(confirm(\'Are you sure you want to delete this newsletter?\')){core.doRequest(\'/newsletters/delete\',\'&cont_id={cont_id}\');return false;}"><i class="icon-minus" /> Delete</a>','',''));

page_header('Newsletters','#!newsletters-edit','Create new newsletter','button', null, 'profile');
$newsletters->render();
?>