<?php
core::ensure_navstate(array('left'=>'left_solutions'));
core::head('Solutions for Distributors');
lo3::require_permission();
?>
<div class="public_content">
	<h1>Solutions for Distributors</h1>
	Are you a new local food distributor or an independent distributor trying to reach this market? Get online with Local Orbit.  We have the sales and management solutions you need at an affordable price. 
	<br />&nbsp;<br />
	Here’s what you get: 
	<br />
	<div class="clear"></div>
	<div class="public_content_left">
		<ul>
			<li>Quick startup with multiple service plans &amp; pricing options </li>
			<li>Inventory management, fulfillment &amp; delivery tools</li>
			<li>Customized branding &amp; marketing </li>
			<li>Easy online setup &amp; ordering </li>
			<li>Traceability &amp; transparency</li>
			<li>E-commerce &amp; managed payments</li>
			<li>Robust reporting</li>
			<li>Cross-selling with other markets, food hubs &amp; producer co-ops </li>
			<li>And much more</li>
		</ul>
	</div>
	<div class="public_content_middle_spacer">&nbsp;</div>
	<div class="public_content_right" style="">
		<img class="public_content_photo" src="img/solutions/distributors.jpg" />
		<? $this->solutions_call_to_action(); ?>
	</div>
	<div class="clear"></div>
</div>
<? core::js("core.lo3.animateContentLoad('.public_content_left','.public_content_right');")?>
<? core::replace('center'); ?>

