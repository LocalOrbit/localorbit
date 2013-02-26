
<?php

core::ensure_navstate(array('left'=>'left_about'));
core::head('Buy Local Food','Buy local food on Local Orbit');
lo3::require_permission();

$this->left_filters();

?>
