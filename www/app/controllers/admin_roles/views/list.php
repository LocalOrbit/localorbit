<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
core::head('Admin Roles','This page is to view admin role information');
lo3::require_permission();

?>
<h2>Admin Roles</h2>
<p><a href="#!admin_roles-edit" onclick="core.go(this.href);">Edit admin roles</a></p>