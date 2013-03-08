<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'events-list','market-admin');
core_ui::fullWidth();
core::head('User Event Log','User Event Log.');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');


$col = core::model('events')->collection();
$events = new core_datatable('events','events/list',$col);

$events->add_filter(new core_datatable_filter('name','concat_ws(\' \',customer_entity.first_name,customer_entity.last_name,organizations.name)','~','search'));
$events->filter_html .= core_datatable_filter::make_text('events','name',$domains->filter_states['events__filter__name'],'Search by name');


$events->add(new core_datacolumn('creation_date','Event Date',true,'16%','<a href="#!events-view--event_id-{event_id}">{creation_date}</a>','{creation_date}','{creation_date}'));
$events->add(new core_datacolumn('domains.name','Hub',true,'20%','<a href="#!market-edit--domain_id-{domain_id}">{domain_name}</a>','{domain_name}','{domain_name}'));
$events->add(new core_datacolumn('event_type','Event Type',true,'15%','<a href="#!events-view--event_id-{event_id}">{event_type}</a>','{event_type}','{event_type}'));
$events->add(new core_datacolumn('first_name','User',true,'35%','<a href="#!users-edit--entity_id-{customer_id}">{first_name} {last_name}</a> (<a href="mailTo:{email}">E-mail</a>)<br /><a href="#!organizations-edit--org_id-{org_id}" onclick="core.go(this.href);">{org_name}</a>','{first_name} {last_name} - {org_name}','{first_name} {last_name} - {org_name}'));
$events->add(new core_datacolumn('ip_address','IP Address',true,'10%','<a href="http://www.geobytes.com/IpLocator.htm?GetLocation&IpAddress={ip_address}" target="_blank">{ip_address}</a>','{ip_address}','{ip_address}'));
$events->columns[0]->autoformat='date-long';
$events->sort_direction = 'desc';
page_header('User Event Log', null, null, null, null, 'cog');

$events->render();
?> 