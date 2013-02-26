<?php

core::ensure_navstate(array('left'=>'left_dashboard'),'referrals-edit','reports');
core::head('Edit Referrals','This page is to edit referral information');
lo3::require_permission();

?>
<h1>Edit Referrals</h1>
<a href="#!referrals-list" onclick="core.go(this.href);">View referral information</a> <br />


