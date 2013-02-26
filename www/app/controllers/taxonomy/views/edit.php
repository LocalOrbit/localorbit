<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Product Taxonomy','This page is used to edit the product taxonomy');
lo3::require_permission();

?>
<h1>Editing Product Taxonomy</h1>
<a href="#!taxonomy-list" onclick="core.go(this.href);">View Product Taxonomy</a>
