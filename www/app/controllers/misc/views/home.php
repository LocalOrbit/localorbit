<?php
if($core->config['domain']['domain_id'] != 1)
{
	core::process_command('auth/form',false);
}
else
{
	core::clear_response('replace','left');
	core::clear_response('replace','center');
	core::replace('left','&nbsp;&nbsp;');
	core::ensure_navstate(array('left'=>'left_blank'));
	core::head('Buy and Sell Food on Local Orbit','Local Orbit provides customized software solutions for every link in the local food chain ');
	lo3::require_permission();
?>
<table>
	<col width="300" />
	<col width="20" /> 
	<col width="680" /> 
	<tr>
		<td style="vertical-align: top;padding-left: 20px;">
			<div class="homepage_message">
				<br />&nbsp;<br />
				Local Orbit <br />
				provides customized <br />
				software solutions <br />
				for every link in<br />
				 the local food chain
				<br />&nbsp;<br />
				<a href="http://localorbit.wufoo.com/forms/z7x3k1/" class="homepage_learnmore" target="_blank">learn more</a>
			</div>
		</td>
		<td>&nbsp;</td>
		<td>
			<div id="slides_homepage" class="slides">
				<div class="slides_container">
					<div class="slide">
						<img src="img/slideshow/slideshow-new-01.jpg" width="740" height="350" alt="[Local Orbit surpasses anything out there]" />
						<div class="caption"><div style="height:10px;overflow:hidden;"><br /></div>Local Orbit surpasses anything out there.<br /><span class="caption_who">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Lucy Norris, Puget Sound Food Network</span></div>
					</div>
					<div class="slide">
						<img src="img/slideshow/slideshow-new-02.jpg" width="740" height="350" alt="Slide 2" />
						<div class="caption">
							The site is amazing!!! I really think your company has a  shot at <br />
							changing the way food is sold 
							on a local level, which is so cool!<br />
							<span class="caption_who">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Brian Bruno, Apple Ridge Farm</span>
						</div>
					</div>
					<div class="slide">
						<img src="img/slideshow/slideshow-new-03.jpg" width="740" height="350" alt="Slide 2" />
						<div class="caption">
							I was impressed with Local Orbit's capacity; the flexibility is 
							<br />essential as we seek to build food hubs across the country<br />
							<span class="caption_who">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Rich Pirog, MSU Center for Regional Food Systems</span>
						</div>
					</div>
					<div class="slide">
						<img src="img/slideshow/slideshow-new-04.jpg" width="740" height="350" alt="Slide 2" />
						<div class="caption">
							Local Orbit enables me to work on my business' growth <br />rather than focus on the day to day functions.
							<!--   I have always fantasized about a system with live inventory for my customers, that keeps producers up to date on market needs & simplifies bookkeeping & logistics. Local Orbit enables me to work on my business' growth.-->
							<br />
							<span class="caption_who">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Gina Riccobono, FRESH</span>
						</div>
					</div>				
					<div class="slide">
						<img src="img/slideshow/slideshow-new-05.jpg" width="740" height="350" alt="Slide 2" />
						<div class="caption">
							I'm living for the day that someone <br />
							starts a Local Orbit hub in Park Slope.
							<br />
							<span class="caption_who">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Park Slope Parents Blog</span>
						</div>
					</div>				
					<div class="slide">
						<img src="img/slideshow/slideshow-new-06.jpg" width="740" height="350" alt="Slide 2" />
						<div class="caption">
							We chose Local Orbit because of the individual support, <br />
							the friendly staff and the user-friendly interfaces.
							<br />
							<span class="caption_who">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Maya Kosok, Food Alliance of Baltimore City</span>
						</div>
					</div>				
					<div class="slide">
						<img src="img/slideshow/slideshow-new-07.jpg" width="740" height="350" alt="Slide 2" />
						<div class="caption">
							<div style="height:10px;overflow:hidden;"><br /></div>
							Local Orbit provides the information I need to minimize costs.
							<br />
							<span class="caption_who">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Christine Quane, Detroit Eastern Market</span>
						</div>
					</div>				
					
					
					
						<!--



					<div class="slide">
						<img src="img/slideshow/slideshow-03.jpg" height="350" width="525" alt="Slide 3" />
						<div class="caption">Message #3</div>
					</div>
					<div class="slide">
						<img src="img/slideshow/slideshow-04.jpg" height="350" width="525" alt="Slide 4" />
						<div class="caption">Message #4</div>
					</div>
					<div class="slide">
						<img src="img/slideshow/slideshow-05.jpg" height="350" width="525" alt="Slide 5" />
						<div class="caption">Message #5</div>
					</div>
					<div class="slide">
						<img src="img/slideshow/slideshow-06.jpg" height="350" width="525" alt="Slide 6" />
						<div class="caption">Message #6</div>
					</div>
					<div class="slide">
						<img src="img/slideshow/slideshow-07.jpg" height="350" width="525" alt="Slide 7" />
						<div class="caption">Message #7</div>
					</div>
					-->
				</div>
				<a href="#!misc-home" class="slideshow_prev"><img src="img/slideshow/library/arrow-prev_new.png" alt="Arrow Prev"></a>
				<a href="#!misc-home" class="slideshow_next"><img src="img/slideshow/library/arrow-next_new.png" alt="Arrow Next"></a>
			</div>
		</td>
	</tr>
</table>
<br />&nbsp;<br />
<table width="980" style="table-layout:fixed;">
	<col width="42" />
	<col width="304" />
	<col width="42" />
	<col width="304" />
	<col width="42" />
	<col width="304" />
	<col width="42" />
	<tr>
		<td>&nbsp;</td>
		<td class="homepage">
			<h1 class="homepage">What is Local Orbit?</h1>
			Local Orbit is a software company focused on building the online tools people need 
			to build healthier communities.      
			<br />&nbsp;<br />
			We provide services to businesses &amp; individuals who sell local food, source local 
			food or connect buyers &amp; sellers to create new markets.
		</td>
		<td>&nbsp;</td>
		<td class="homepage">
			<h1 class="homepage">Who uses Local Orbit?</h1>
			<ul>
				<li>Farmers, ranchers &amp; specialty products makers</li>
				<li>Distributors, hospitals, universities, schools &amp; restaurants</li>
				<li>Food hubs, farmers markets &amp; producer co-ops</li>
				<li>Entrepreneurs re-building local food chains across the country</li>
			</ul>
		</td>
		<td>&nbsp;</td>
		<td class="homepage">
			<h1 class="homepage">Why choose Local Orbit?</h1>
			Local Orbit is the only platform offering:
			<ul>
				<li>Multi-channel sales from a single dashboard </li>
				<li>Quick setup with low or no upfront fees</li>
				<li>Easy vendor management with streamlined purchasing from multiple sellers, and a direct, traceable supply chain</li>
				<li>A smarter, integrated platform for cross-market sourcing &amp; selling that grows with your business </li>
				<li>An end to online silos</li>
			</ul>
		</td>
		<td>&nbsp;</td>
	</tr>
</table>


	<?php core::replace('full_width');?>
	<? core::js('core.lo3.homepageStartup();'); ?>
<?}?>