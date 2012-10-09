<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Translation Dictionary List','This page is used to view the translation dictionary');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

?>
<h1>Translation Dictionary List</h1>
<a href="#!translations-edit" onclick="core.go(this.href);">Edit Translation Dictionary</a>
