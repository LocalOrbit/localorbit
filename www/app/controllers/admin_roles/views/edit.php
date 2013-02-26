<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
core::head('Edit Admin Roles','This page is to edit admin roles');
lo3::require_permission();

?>
<h2>Edit Admin Roles</h2>
<p><a href="#!admin_roles-list" onclick="core.go(this.href);">View admin roles</a></p>