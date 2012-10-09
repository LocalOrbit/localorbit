<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Customizations','This page is used to customize a site');
lo3::require_permission();

?>
<h1>Customization Settings</h1>
<a href="#!customizations-edit" onclick="core.go(this.href);">Edit these customizations</a> <br />


