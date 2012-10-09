<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Standing Orders','This page is used to manage your standing orders');
lo3::require_permission();

?>
<h1>Listing Standing Orders</h1>
<a href="#!standing_orders-edit" onclick="core.go(this.href);">Edit an order</a> <br />
<a href="#!standing_orders-create" onclick="core.go(this.href);">Create Standing Orders</a>
