<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Pre-purchases','This page is used to edit your pre-purchases');
lo3::require_permission();

?>
<h1>Editing Pre-purchases</h1>
<a href="#!prepurchases-list" onclick="core.go(this.href);">List of your pre-purchases</a> <br />
<a href="#!prepurchases-propose" onclick="core.go(this.href);">Propose a new pre-purchase</a>
