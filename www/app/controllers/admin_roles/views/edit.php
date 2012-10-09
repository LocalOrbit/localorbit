<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit Admin Roles','This page is to edit admin roles');
lo3::require_permission();

?>
<h1>Edit Admin Roles</h1>
<a href="#!admin_roles-list" onclick="core.go(this.href);">View admin roles</a> <br />


