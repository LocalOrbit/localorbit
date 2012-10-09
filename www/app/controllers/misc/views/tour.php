<? 
core::head('Tour');
lo3::require_permission();

core::clear_response('replace','left');
core::clear_response('replace','center');
core::replace('left','&nbsp;&nbsp;');
core::ensure_navstate(array('left'=>'left_blank'));
core_ui::load_library('js','jquery.lightbox_me.js');

?>
<table>
	<col width="300" />
	<col width="680" />
	<tr>
		<td class="left_col">
			<img src="img/misc/tour.jpg" class="public_content_photo"  />
			<? $this->solutions_call_to_action(); ?>
			<br />
			Get started now by <a href="http://localorbit.wufoo.com/forms/r7x2x3/" target="_blank">telling us about your organization</a>.
			<br />&nbsp;<br />
		</td>
		<td class="center_col">
			<div class="public_content">
				<h1>The Top‭ ‬5‭ Reasons to Choose Local Orbit‭ </h1>
				Software is how food businesses scale. Choosing the right  software is a matter of matching your needs with an available platform. To make it easier, here are the top reasons our customers choose Local Orbit:
				<br />&nbsp;<br />
				<h2 style="border-width: 0px;color: #555;">
					<b>#1:</b> <a href="Javascript:core.lo3.tourPopup(1);">Quick &amp; easy setup; low or no upfront fees</a>
				</h2>
				<h2 style="border-width: 0px;color: #555;">
					<b>#2:</b> <a href="Javascript:core.lo3.tourPopup(2);">Customized branding</a>
				</h2>
				<h2 style="border-width: 0px;color: #555;">
					<b>#3:</b> <a href="Javascript:core.lo3.tourPopup(3);">Multi-channel sales & marketing from one place</a>
				</h2>
				<h2 style="border-width: 0px;color: #555;">
					<b>#4:</b> <a href="Javascript:core.lo3.tourPopup(4);">Easy e-commerce &amp; payment management services</a>
				</h2>
				<h2 style="border-width: 0px;color: #555;">
					<b>#5:</b> <a href="Javascript:core.lo3.tourPopup(5);">Business management tools; your back office in a box</a>
				</h2>
			</div>
		</td>
	</tr>
</table>

<div id="tour_div_1" class="tour_div" style="display: none;">
	<img class="tour_close" src="/img/default/deal_close.png" onclick="$('#tour_div_1').trigger('close');" />
	<div class="slides" id="slides_tour_1">
		<div class="slides_container" style="width:824px;height: 578px;">
			<div class="slide tour_slide">
				<div class="tour_slide_text">
					Local Orbit can have you collecting orders quickly, <br />with very low - or no - upfront fees.
				</div>
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Get started today!</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/1-1.jpg" width="824" height="498" alt="Start with the details about your farm, business, market, or hub..." />
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Start wtih the details about your farm, business, market, or hub...</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/1-2.jpg" width="824" height="498" alt="Add details about your suppliers..." />
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Add details about your suppliers...</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/1-3.jpg" width="824" height="498" alt="... and your products." />
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>... and your products.</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/1-4.jpg" width="824" height="498" alt="You'll have a password protected site for your approved customers in no time!" />
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>You'll have a password protected site <br />for your approved customers in no time!</div>
			</div>
		</div>
		<a href="#!misc-tour" class="slideshow_prev slideshow_prev_tour"><img src="img/slideshow/library/arrow-prev_new.png" alt="Arrow Prev"></a>
		<a href="#!misc-tour" class="slideshow_next slideshow_next_tour"><img src="img/slideshow/library/arrow-next_new.png" alt="Arrow Next"></a>
	</div>
</div>

<div id="tour_div_2" class="tour_div" style="display: none;">
	<img class="tour_close" src="/img/default/deal_close.png" onclick="$('#tour_div_2').trigger('close');" />
	<div class="slides" id="slides_tour_2">
		<div class="slides_container" style="width:824px;height: 578px;">
			<div class="slide tour_slide">
				<div class="tour_slide_text">
					You've worked hard to build a brand that<br /> represents you and your company; <br />don't give it up when you go online. 
					<br />&nbsp;<br />
					Local Orbit offers customized branding <br />options for all types of businesses. <br />Look like you, powered by us.
				</div>
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Get your brand online today!</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/2-1.jpg" width="824" height="498" alt="Your look, your colors, your site." />
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Your look, your colors, your site. </div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/2-2.jpg" width="824" height="498" alt="... carried through your newsletters fresh sheets, and messaging" />
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>... carried through your newsletters, fresh sheets, &amp; messaging.</div>
			</div>
		</div>
		<a href="#!misc-tour" class="slideshow_prev slideshow_prev_tour"><img src="img/slideshow/library/arrow-prev_new.png" alt="Arrow Prev"></a>
		<a href="#!misc-tour" class="slideshow_next slideshow_next_tour"><img src="img/slideshow/library/arrow-next_new.png" alt="Arrow Next"></a>
	</div>
</div>

<div id="tour_div_3" class="tour_div" style="display: none;">
	<img class="tour_close" src="/img/default/deal_close.png" onclick="$('#tour_div_3').trigger('close');" />
	<div class="slides" id="slides_tour_3">
		<div class="slides_container" style="width:824px;height: 578px;">
			<div class="slide tour_slide">
				<div class="tour_slide_text">
					<br />
					Unlike other software options, <br />
					which limit your sales to one set of customers <br />
					(consumers or restaurants or farmers markets)<br />
					or limit your purchases to one discrete set of suppliers, <br />
					using Local Orbit enables you to buy from, or sell to, <br />
					any producer or business also using the platform.
				</div>
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Local Orbit  = More flexibility, more opportunity</div>
				</div>
			<div class="slide tour_slide">
				<div class="tour_slide_text">
					Because of our uniquely open approach,<br />
					Local Orbit provides multi-channel sales opportunities for producers<br />
					and multi-channel marketing options for distributors, farmers markets and food hubs.
				</div>
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Opportunity from an open approach.</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/5-1.jpg" width="824" height="498" alt="Slide 1" />
				<div class="caption tour_caption">List your products in multiple Local Orbit<br />markets within your region.</div>
			</div>
			<div class="slide tour_slide">
				<div class="tour_slide_text">
					<br />&nbsp;<br />Other software can limit your growth. Keep your future options open with Local Orbit.
				</div>
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>&nbsp;</div>
			</div>
		</div>
		<a href="#!misc-tour" class="slideshow_prev slideshow_prev_tour"><img src="img/slideshow/library/arrow-prev_new.png" alt="Arrow Prev"></a>
		<a href="#!misc-tour" class="slideshow_next slideshow_next_tour"><img src="img/slideshow/library/arrow-next_new.png" alt="Arrow Next"></a>
	</div>
</div>

<div id="tour_div_4" class="tour_div" style="display: none;">
	<img class="tour_close" src="/img/default/deal_close.png" onclick="$('#tour_div_4').trigger('close');" />
	<div class="slides" id="slides_tour_4">
		<div class="slides_container" style="width:824px;height: 578px;">
			<div class="slide tour_slide">
				<div class="tour_slide_text">
					Local Orbit's backend tools provide critical insight <br />when and where you need it. 
					<br />&nbsp;<br />
					Track orders and deliveries from the dashboard; <br />input, edit or update inventory from the office, <br />road or field; and trace the Who, Where and How <br />of every product with detailed records.
				</div>
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Using Local Orbit brings order and efficiency to your growing business.</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/4-1.jpg" width="824" height="498" alt="Slide 1" />
				<div class="caption tour_caption">Manage your business from our simple, intuitive dashboard.
A one-stop <br />shop for managing sales, inventory, marketing &amp; communications. </div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/4-2.jpg" width="824" height="498" alt="Slide 1" />
				<div class="caption tour_caption">Easily add &amp; edit products.  Granular pricing lets you set prices <br />for all buyers or custom pricing for specific buyers &amp; delivery locations.</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/4-3.jpg" width="824" height="498" alt="Slide 1" />
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Robust reporting to track, analyze &amp; grow your business.</div>
			</div>
		</div>
		<a href="#!misc-tour" class="slideshow_prev slideshow_prev_tour"><img src="img/slideshow/library/arrow-prev_new.png" alt="Arrow Prev"></a>
		<a href="#!misc-tour" class="slideshow_next slideshow_next_tour"><img src="img/slideshow/library/arrow-next_new.png" alt="Arrow Next"></a>
	</div>
</div>
<div id="tour_div_5" class="tour_div" style="display: none;">
	<img class="tour_close" src="/img/default/deal_close.png" onclick="$('#tour_div_5').trigger('close');" />
	<div class="slides" id="slides_tour_5">
		<div class="slides_container" style="width:824px;height: 578px;">
			<div class="slide tour_slide">
				<div class="tour_slide_text">
					Accepting credit card and purchase orders online <br />
					with Local Orbit is a piece of cake. <br />
					We go one step further by also offering <br />
					complete managed payment services <br />
					for busy business &amp; market managers.<br />
		</div>
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Grow your business with online credit card or purchase orders.</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/3-1.jpg" width="824" height="498" alt="Slide 1" />
				<div class="caption tour_caption">Streamlined ordering. 24/7 convenience. Purchase from <br /> multiple vendors in a single shopping cart, with one payment.</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/3-2.jpg" width="824" height="498" alt="Slide 1" />
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>Quick access to details about a seller's story, product &amp; location</div>
			</div>
			<div class="slide tour_slide">
				<img src="img/tour/3-3.jpg" width="824" height="498" alt="Slide 1" />
				<div class="caption tour_caption">Farmers maintain their brand throughout the purchasing process. 
				<br />
				One-step checkout can be configured to accept credit cards or PO's. </div>
			</div>
			<div class="slide tour_slide">
				<div class="tour_slide_text">
					<br />
					We can take care of invoicing and collecting payments <br />from customers, as well as handling payments to producers <br />and suppliers - leaving you more time to grow your business.
				</div>
				<div class="caption tour_caption"><div style="height:14px;overflow:hidden;"><br /></div>You get to focus on growing your business.</div>
			</div>			
		</div>
		<a href="#!misc-tour" class="slideshow_prev slideshow_prev_tour"><img src="img/slideshow/library/arrow-prev_new.png" alt="Arrow Prev"></a>
		<a href="#!misc-tour" class="slideshow_next slideshow_next_tour"><img src="img/slideshow/library/arrow-next_new.png" alt="Arrow Next"></a>
	</div>
</div>
<!--

Unlike other software options, which limit your sales to one discrete set of customers (consumers or restaurants or farmers markets,for example) or limit your purchases to one discrete set of suppliers, using Local Orbit enables you to buy from, or sell to, any producer or business also using the platform. 

<table>
	<col width="680" />
	<col width="300" />
	<tr>
		<td class="left_col">
			<h1>The Top 5 reasons people choose Local Orbit</h1>
			Local Orbit makes selling and sourcing local food easy, through streamlined online ordering 
			and generous backend tools for managing your business efficiently. 
			<br />&nbsp;<br />
		</td>
		<td style="padding: 0px 10px 7px 0px;">
		</td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr style="background-color: #f4f6f4;">
		<td class="left_col">
			<h2>Reason #5: Quick &amp; easy setup, with low or no upfront fees</h2>
			Why wait months and pay thousands of dollars to get your co-op, store, hub, market 
			or catalog online? Local Orbit can have you collecting orders quickly, 
			with very low - or no - upfront fees, depending on your business type and choice of service. 
		</td>
		<td class="center_col" style="text-align: center;">
			<div class="tour_description">
				<img src="/img/tour/1_thumb.png?update=20120404" class="tour_thumb" onclick="core.lo3.tourPopup(1);" />
				<br />Click to view more
			</div>
		</td>
	</tr>
	<tr>
		<td class="left_col">
			<h2>Reason #4: Customized branding</h2>
			You've worked hard to build a brand that represents you and your fantastic company; 
			don't give that up when you go online. Local Orbit offers multiple customized branding 
			options for all types of businesses. Look like you, powered by us.
		</td>
		<td class="center_col" style="text-align: center;">
			<div class="tour_description">
				<img src="/img/tour/2_thumb.png?update=20120404" class="tour_thumb" onclick="core.lo3.tourPopup(2);" />
				<br />Click to view more
			</div>
		</td>
	</tr>
	<tr style="background-color: #f4f6f4;">
		<td class="left_col">
			<h2>Reason #3: Easy e-commerce &amp; payment management services</h2>
			Accepting credit card and purchase orders online with Local Orbit is a piece of cake 
			(sourced with local ingredients, of course), but we go one step further by offering complete 
			managed payment services as an option to busy business operators. We can take care of invoicing 
			and collecting payments from customers, as well as handling payments to producers and 
			suppliers - leaving you more time to grow your business. 
		</td>
		<td class="center_col" style="text-align: center;">
			<div class="tour_description">
				<img src="/img/tour/3_thumb.png?update=20120404" class="tour_thumb" onclick="core.lo3.tourPopup(3);" />
				<br />Click to view more
			</div>
		</td>
	</tr>
	<tr>
		<td class="left_col">
			<h2>Reason #2: Business Management Tools: Your back office in a box</h2>
			Local Orbit’s backend tools provide critical insight when and where you need it. 
			Track orders and deliveries from the dashboard; input, edit or update inventory 
			from the office, road or field; and trace the Who, Where and How of every product 
			with detailed records. 
		</td>
		<td class="center_col" style="text-align: center;">
			<div class="tour_description">
				<img src="/img/tour/4_thumb.png?update=20120404" class="tour_thumb" onclick="core.lo3.tourPopup(4);" />
				<br />Click to view more
			</div>
		</td>
	</tr>
	<tr style="background-color: #f4f6f4;">
		<td class="left_col">
			<h2>And, the #1 Reason People Choose Local Orbit: A networked customer base!</h2>
			Unlike other software options, which limit your sales to one discrete set of customers 
			(consumers or restaurants or farmers markets, for example) or limit your purchases to 
			one discrete set of suppliers, using Local Orbit enables you to buy from, or sell to, 
			any producer or business also using the platform. Because of this uniquely open approach, 
			Local Orbit is a multi-channel sales platform for producers, providing a powerful set of 
			tools to create and connect independent local and regional food distribution systems.
			<br />&nbsp;<br />
			Don’t build an online silo - open your options with Local Orbit.
		</td>
		<td class="center_col" style="text-align: center;">
			<div class="tour_description">
				<img src="/img/tour/5_thumb.png?update=20120404" class="tour_thumb" onclick="core.lo3.tourPopup(5);" />
				<br />Click to view more
			</div>
		</td>
	</tr>

	<tr>
		<td class="left_col">&nbsp; </td>
		<td class="center_col">
			<br />&nbsp;<br />
			<? $this->solutions_call_to_action(); ?>
		</td>
	</tr>
	
</table>
-->
<? 
core::js('core.lo3.tours = {};'); 
core::js('window.clearInterval(core.ui.playInterval);');
#core::js('$(".tour_description").mouseover(function(){$(this).children("div").css({"display":"inline"});}).mouseleave(function(){$(this).children("div").css({"display":"none"});});');
?>
<?php core::replace('full_width');?>
