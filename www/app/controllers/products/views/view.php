<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('View a product','View a product.');
lo3::require_permission();

$data = core::model('products')->load();

?>

<h1><?=$data['name']?></h1>
