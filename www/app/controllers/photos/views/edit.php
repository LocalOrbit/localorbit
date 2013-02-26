<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit Photos','This page is used to edit photos');
lo3::require_permission();

?>
<h1>Edit Photos</h1>
<a href="#!photos-list" onclick="core.go(this.href);">View Photos</a> <br />
<?
$data = core::model('photos')->load();
$data->dump();
?>