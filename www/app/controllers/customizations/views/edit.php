<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
core::head('Edit Customizations','This page is used to customize a site');
lo3::require_permission();

?>
<h2>Edit Customization Settings</h2>
<p><a href="#!customizations-list" onclick="core.go(this.href);">View current customizations</a></p>