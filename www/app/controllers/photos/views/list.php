<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('View Photos','This page is used to view photos');
lo3::require_permission();

?>
<h1>View Photos</h1>
<?
$col = core::model('photos')->collection();
$photos = new core_datatable('photos','photos/list',$col);
$photos->add(new core_datacolumn('photo_id','photo_id',true,'15%','<a href="#!photos-edit--photo_id-{photo_id}">{photo_id}</a>'));
$photos->add(new core_datacolumn('name','name',true,'85%','<a href="#!photos-edit--photo_id-{photo_id}">{name}</a>'));
$photos->render();
?>