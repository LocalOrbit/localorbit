<?php
core::ensure_navstate(array('left'=>'left_solutions'));
core::head('Solutions for Restaurants');
lo3::require_permission();
?>

<div class="public_content">
	<h1>Solutions for Restaurants</h1>
	Local Orbit saves chefs time by making sourcing from multiple farmers quick and easy. If you're near a food hub or market that's powered by Local Orbit, you can sign up as a buyer on their website. 
	<br />&nbsp;<br />
	Or, if you work directly with vendors, Local Orbit can create an online management portal that lets you order from multiple sellers with a single payment. 	
	<br />
	<div class="clear"></div>
	<div class="public_content_left">
		<ul>
			<li>Quick setup with low monthly fees</li>
			<li>Streamlined ordering</li>
			<li>Efficient communications &amp; vendor reminders</li>
			<li>Traceable, transparent purchasing</li>
			<li>Easily share with customers the story of the food on your menu</li>
			<li>Access to new vendors through other food hubs, co-ops, producers &amp; distributors </li>
			<li>And much more</li>
		</ul>
	</div>
	<div class="public_content_middle_spacer">&nbsp;</div>
	<div class="public_content_right" style="">
		<img class="public_content_photo" src="img/solutions/restaurants.jpg" />
		<? $this->solutions_call_to_action(); ?>
	</div>
	<div class="clear"></div>
</div>
<? core::js("core.lo3.animateContentLoad('.public_content_left','.public_content_right');")?>
<? core::replace('center'); ?>