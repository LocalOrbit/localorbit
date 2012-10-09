<?php
core::ensure_navstate(array('left'=>'left_solutions'));
core::head('Solutions for Food Hubs');
lo3::require_permission();
?>
<div class="public_content">
	<h1>Solutions for Food Hubs</h1>
	We make it easy to build &amp; manage your hub.  Whether you're just getting started or rapidly expanding, Local Orbit offers a range of service options and pricing plans to meet you where you are today - and to grow with you as you scale.
	<br />
	<div class="clear"></div>
	<div class="public_content_left">
		<ul>
			<li>Quick startup with low or no upfront fees</li>
			<li>Customized branding</li>
			<li>Marketing tools &amp; resources</li>
			<li>Automated reminders </li>
			<li>Traceability &amp; transparency</li>
			<li>E-commerce &amp; managed payments</li>
			<li>Inventory management, fulfillment &amp; delivery tools</li>
			<li>Robust reporting</li>
			<li>Cross-selling with other markets, hubs, co-ops &amp; producers</li>
			<li>And much more</li>
		</ul>
	</div>
	<div class="public_content_middle_spacer">&nbsp;</div>
	<div class="public_content_right" style="">
		<img class="public_content_photo" src="img/solutions/food_hubs.jpg" />
		<? $this->solutions_call_to_action(); ?>
	</div>
	<div class="clear"></div>
</div>
<? core::js("core.lo3.animateContentLoad('.public_content_left','.public_content_right');")?>
<? core::replace('center'); ?>