		<div class="clear"></div>
		</div> <!-- /#content-wrap -->

	<div class="clear"></div>
	</div> <!-- /#main-wrap -->

	

	<div class="clear"></div>

</div> <!-- /#page-wrap -->
<div id="footer" style="background-color: #f3f3f3;">
		<br>
		<table width="100%">
			<colgroup>
				<col width="4%">
				<col width="16%">
				<col width="20%">
				<col width="20%">
				<col width="20%">
				<col width="20%">
			</colgroup>
			<tbody>
				<tr>
					<td>&nbsp;</td>
					<td><a href="/index.php"><img src="/img/default/logo_gray.png"></a></td>
					<td>
						<img src="/img/default/footer/tools_gray.png"><br>
						<b class="footer">Local Orbit</b>
						<ul class="footer">
							<li class="footer"><a class="footer" href="/homepage/company.php">Company</a></li>
							<li class="footer"><a class="footer" href="/homepage/features.php">Features	</a></li>
							<li class="footer"><a class="footer" href="/field-notes/">Field Notes: Our Blog</a></li>
						<!--	<li class="footer"><a class="footer" href="#">Press</a></li> -->
							<li class="footer"><a class="footer" href="/login.php">Customer Log In</a></li>
						</ul>
					</td>
					<td>
						<img src="/img/default/footer/scarecrow_gray.png"><br>
						<b class="footer">Dig Deeper</b>
						<ul class="footer">
							<li class="footer"><a class="footer" href="/homepage/features.php">Features	</a></li>
								<li class="footer"><a class="footer" href="/homepage/pricing.php">Pricing</a></li>
								<li class="footer"><a class="footer" href="http://www.localorb.it/field-notes/schedule-a-demo/">Sign Up for a Demo</a></li>
								<li class="footer"><a class="footer" href="https://docs.google.com/a/localorb.it/spreadsheet/viewform?formkey=dEg5eU5PWm1WTDlxa2ZaVEg1UnRzamc6MA">Get Started</a></li>

						</ul>
					</td>
					<td>
						<img src="/img/default/footer/thumbsup_gray.png"><br>
						
						<b class="footer">Connect</b>
						<ul class="footer">
							<li class="footer"><a class="footer" target="_blank" href="http://localorb.us6.list-manage.com/subscribe?u=e0dc0b51636060c0278e6c377&amp;id=bad2d7741d">Newsletter Sign Up </a></li>
							<li class="footer"><a class="footer" target="_blank" href="http://www.facebook.com/localorbit">Facebook</a></li>
							<li class="footer"><a class="footer" target="_blank" href="http://www.twitter.com/localorbit">Twitter</a></li>
							<li class="footer"><a class="footer" target="_blank" href="http://www.linkedin.com/company/local-orbit">LinkedIn</a></li>
						</ul>
					</td>
				
					<td>
					<img src="/img/default/footer/phone_gray.png"><br>
					<b class="footer">Contact</b>
					<ul class="footer">
						<li class="footer" style="font-size: 80%;"> Call 734.545.8100</li>
	
						<li class="footer"><a class="footer" href="https://localorbit.zendesk.com/anonymous_requests/new" onclick="script: Zenbox.show(); return false;">Ask us a question</a></li>
					</ul>
				</td>
			</tr>
		</tbody>
	</table>
	<br>
	<div class="footer">&nbsp; &nbsp; &nbsp; © 2013 | 
	<a class="footer" style="font-size: 100%;" href="/homepage/tos.php" onclick="core.go(this.href);">Terms of Service</a> | 
	<a style="font-size: 100%;" class="footer" href="/homepage/privacy.php" onclick="core.go(this.href);">Privacy</a> | 
	<a class="footer" style="font-size: 100%;" href="https://localorbit.zendesk.com/anonymous_requests/new" onclick="script: Zenbox.show(); return false;">Help</a>
	<br>&nbsp; &nbsp; &nbsp;
	<a class="footer" style="font-size: 80%;" href="http://jasonhouston.com" onclick="core.go(this.href);" target="_blank">site photos by Jason Houston</a></div>
		<?php 
if ( is_home() && $paged < 2 && option::get('featured_enable') == 'on' ) { 
	ui::js("slider");
	?>
	<script type="text/javascript">
	jQuery(document).ready(function() {
		jQuery("#navi ul").tabs("#panes > div", {
			effect: 'fade',
			rotate: true
		}).slideshow({
			clickable: false,
			autoplay: <?php echo option::get('featured_rotate') == 'on' ? "true" : "false"; ?>,
			interval: <?php echo option::get('featured_interval'); ?>
		});
	});
	</script>
	<?php 
}

wp_reset_query();
if ( is_single() ) { ?><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><?php } // Google Plus button

wp_footer();
?>
</div> <!-- /#footer -->
</body>
</html>