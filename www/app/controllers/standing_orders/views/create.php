<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Pre-purchases','This page is used to create new standing orders');
lo3::require_permission();

?>
<h1>Create a New Standing Order</h1>
<a href="#!standing_orders-list" onclick="core.go(this.href);">List Standing Orders</a> <br />
<a href="#!standing_orders-edit" onclick="core.go(this.href);">Edit Standing Orders</a>
