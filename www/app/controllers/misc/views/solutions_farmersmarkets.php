<?php
core::ensure_navstate(array('left'=>'left_solutions'));
core::head('Solutions for Farmers Markets');
lo3::require_permission();
?>

<div class="public_content">
	<h1>Solutions for Farmers Markets</h1>
	Every market wants to increase and diversify sales for its vendors.  Local Orbit helps your market grow by making it easy for wholesale buyers to source from vendors; by offering pre-ordering for customers who don't have time to browse or need to plan ahead; and by extending sales opportunities to producers who can't attend the market. 
	<br />
	<div class="clear"></div>
	<div class="public_content_left">
		<ul>
			<li>Quick startup with low or no upfront fees</li>
			<li>Customized branding</li>
			<li>Newsletters &amp; weekly fresh sheets</li>
			<li>Traceability &amp; transparency</li>
			<li>E-commerce &amp; managed payments</li>
			<li>Aggregation &amp; delivery tools</li>
			<li>Robust Reporting</li>
			<li>Cross-selling opportunities with other markets, co-ops, producers &amp; distributors</li>
			<li>And much more</li>
		</ul>
	</div>
	<div class="public_content_middle_spacer">&nbsp;</div>
	<div class="public_content_right" style="">
		<img class="public_content_photo" src="img/solutions/farmers_markets.jpg" />
		<? $this->solutions_call_to_action(); ?>
	</div>
	<div class="clear"></div>
</div>
<? core::js("core.lo3.animateContentLoad('.public_content_left','.public_content_right');")?>
<? core::replace('center'); ?>