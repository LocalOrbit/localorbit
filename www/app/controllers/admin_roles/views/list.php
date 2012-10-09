<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Admin Roles','This page is to view admin role information');
lo3::require_permission();

?>
<h1>Admin Roles</h1>
<a href="#!admin_roles-edit" onclick="core.go(this.href);">Edit admin roles</a> <br />


