<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Pre-purchases','This page is used to manage your pre-purchases');
lo3::require_permission();

?>
<h1>List of your pre-purchases</h1>
<a href="#!prepurchases-edit" onclick="core.go(this.href);">Edit your pre-purchases</a> <br />
<a href="#!prepurchases-propose" onclick="core.go(this.href);">Propose a new pre-purchase</a>

