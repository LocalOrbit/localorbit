<?php
core::ensure_navstate(array('left'=>'left_solutions'));
core::head('Solutions for Producer Co-cops');
lo3::require_permission();
?>
<div class="public_content">
	<h1>Solutions for Producers &amp; Co-ops</h1>
	Everyone wants your products, but selling efficiently to different kinds of customers can be a monumental management challenge. Local Orbit is the only online service that lets you manage everything &ndash; marketing, inventory, sales, logistics and delivery &ndash; to everyone &ndash; restaurants, distributors, farmers markets, food hubs and consumers &ndash; from a single account, with one easy-to-read dashboard. 
	<br />
	<div class="clear"></div>
	<div class="public_content_left">
		<ul>
			<li>Quick startup with low or no upfront fees  </li>
			<li>Customized branding &amp; marketing</li>
			<li>Easy ordering &amp; e-commerce setup </li>
			<li>Automated fresh sheets </li>
			<li>E-commerce &amp; managed payments</li>
			<li>Inventory management, fulfillment &amp; delivery tools</li>
			<li>Robust Reporting</li>
			<li>Cross-selling with other markets, co-ops &amp; producers</li>
			<li>And much more</li>
		</ul>
	</div>
	<div class="public_content_middle_spacer">&nbsp;</div>
	<div class="public_content_right" style="">
		<img class="public_content_photo" src="img/solutions/co-ops.jpg" />
		<? $this->solutions_call_to_action(); ?>
	</div>
	<div class="clear"></div>
</div>	
<? core::js("core.lo3.animateContentLoad('.public_content_left','.public_content_right');")?>
<? core::replace('center'); ?>


