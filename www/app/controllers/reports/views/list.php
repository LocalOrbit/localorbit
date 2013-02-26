<?php

core::ensure_navstate(array('left'=>'left_dashboard'),'reports-edit',
	array('reports', 'reports','sales-information','account'));
core::head('Reports','This page is to view the list of ready-to-view reports');
lo3::require_permission();

?>
<h1>Reports</h1>
<a href="#!reports-edit" onclick="core.go(this.href);">Create custom report</a> <br />


