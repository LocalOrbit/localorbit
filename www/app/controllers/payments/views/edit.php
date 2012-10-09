<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit Payments','This page is to edit payment information');
lo3::require_permission();

?>
<h1>Edit Payments</h1>
<a href="#!payments-list" onclick="core.go(this.href);">View payment information</a> <br />


