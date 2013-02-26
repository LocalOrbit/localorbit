<?php 
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('User Management','This page is used to manage users');
lo3::require_permission();

$users = core::model('customer_entity')->collection();
$users->filter('group_id','in',array(1,2,3));


# this is placeholder functionality until data tables are up.
# foreach($users as $user)
# {
	
# 	echo($user['email'].'/'.$user['first_name'].'/'.$user['last_name']);
# 	echo('<a href="#auth-loginas--user_id-'.$user['entity_id'].'">Login</a>');
# 	echo('<br />');
# }
?>
<h1>Users</h1>
<a href="#!profiles-list" onclick="core.go(this.href);">Link to *other* profile Page following LO2 layout</a></li>


