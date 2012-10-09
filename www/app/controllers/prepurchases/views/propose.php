<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Pre-purchases','This page is used to propose new pre-purchases');
lo3::require_permission();

?>
<h1>Propose a new pre-purchase</h1>
<a href="#!prepurchases-list" onclick="core.go(this.href);">List of your pre-purchases</a> <br />
<a href="#!prepurchases-edit" onclick="core.go(this.href);">Edit your pre-purchases</a>
