<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Events','Events');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

?>
<h1>Events</h1>     
<?
$data = core::model('events')->load();
$data->dump();
?>