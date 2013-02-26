<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
core::head('Customizations','This page is used to customize a site');
lo3::require_permission();

?>
<h2>Customization Settings</h2>
<p><a href="#!customizations-edit" onclick="core.go(this.href);">Edit these customizations</a></p>