<?php

core::ensure_navstate(array('left'=>'left_dashboard'),'referrals-edit','reports');
core::head('Referrals','This page is to view referral information');
lo3::require_permission();

?>
<h1>Referral Information</h1>
<a href="#!referrals-edit" onclick="core.go(this.href);">Edit referral information</a> <br />


