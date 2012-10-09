<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit Customizations','This page is used to customize a site');
lo3::require_permission();

?>
<h1>Edit Customization Settings</h1>
<a href="#!customizations-list" onclick="core.go(this.href);">View current customizations</a> <br />

