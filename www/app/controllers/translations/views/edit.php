<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit Translation Dictionary','This page is used to edit the translation dictionary');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

?>
<h1>Translation Dictionary List</h1>
<a href="#!translations-list" onclick="core.go(this.href);">View Translation Dictionary</a>
