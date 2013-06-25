<?
# handle redirect to login page if on subdomain
# if the current http host is a hub-specific subdomain, redirect them to login page
/*
if(!in_array(strtolower($_SERVER['HTTP_HOST']),array('testing.localorb.it','qa.localorb.it','www.localorb.it','localorb.it')))
{
	header('Location: /login.php');
	exit();
}
* */
global $core;
include(dirname(__FILE__).'/../../app/core/core.php');
core::init(__FILE__);
$core->config['domain'] = core::model('domains')->loadrow_by_hostname(strtolower($_SERVER['HTTP_HOST']));
if($core->config['domain']['feature_allow_anonymous_shopping'] == 1)
{
	switch($core->config['domain']['default_homepage'])
	{
		case 'Login':
			header('Location: /login.php');
			exit();
			break;
		case 'Market Info':
			header('Location: /app.php#!market-info');
			exit();
			break;
		case 'Our Sellers':
			header('Location: /app.php#!oursellers-form');
			exit();
			break;
		case 'Shop':
			header('Location: /app.php#!catalog-shop');
			exit();
			break;
	}
}
else
{
	if($core->config['domain']['domain_id'] != 1)
	{
		#echo('redirect to login');
		header('Location: /login.php');
		exit();
	}
}
?>
<!doctype html>
<html>
	<head>
		<title>Local Orbit: Re-linking the Food Chain<?=((isset($title))?' - '.$title:'')?></title>
		<meta name="description" content="Local Orbit provides sales & business management tools for the entrepreneurs building the New Food Economy." />
		<meta name="keywords" content="wholesale, food hub, institutional buying, local economies, technology, management tools, local food systems, transparency, supply chain, farm-to-school, local food, local food distribution, New Food Economy, software, business management, e-commerce, sales" />
		<meta charset="utf-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" />
		<link rel="stylesheet" type="text/css" href="/css/reset.css" />
		<link rel="stylesheet" type="text/css" href="/homepage/includes/homepage.css?_v=4.0.6.1" />
		<link rel="stylesheet" type="text/css" href="/homepage/includes/footer.css?_v=4.0.6.1" />
		<link rel="stylesheet" type="text/css" href="/homepage/includes/popup.css?_v=4.0.6.1" />
		<link rel="stylesheet" type="text/css" href="/homepage/includes/nav.css?_v=4.0.6.1" />
		<link rel="stylesheet" type="text/css" href="/homepage/includes/tour.css?_v=4.0.6.1" />
		<script language="Javascript" type="text/javascript" src="/js/jquery.min.js"></script>
		<script language="Javascript" type="text/javascript" src="/js/wysihtml5-0.3.0.min.js"></script>
		<script language="Javascript" type="text/javascript" src="js/bootstrap-wysihtml5.js"></script>
		
		<script language="Javascript" type="text/javascript" src="/app/core/js/core.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/core.validator.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/core.format.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/core.ui.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/jquery.datePicker.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/jquery.tabset.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="/js/jquery.rte.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="/js/lo3.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="/js/slides.jquery.js"></script>
		<script language="Javascript" type="text/javascript" src="/homepage/includes/features.js?_v=4.0.6.1"></script>
		<script language="Javascript" type="text/javascript">
		<!--
		//
		core.hostname = '<?php echo($_SERVER['SERVER_NAME'])?>';
		core.baseUrl  = '<?php echo($_SERVER['REQUEST_URI'])?>';
		core.user_id  = '<?php echo(intval($_SESSION['core']['user_id'])); ?>';
		core.unauth_controller = '#!misc-home';
		core.authed_controller = '#!dashboard-view';
		$.fn.datePicker.format = 'M d,y';
		//-->
		</script>
		<style type="text/css" media="screen, projection">
			@import url(//assets.zendesk.com/external/zenbox/v2.5/zenbox.css); 
		</style>
<script type="text/javascript">
var fb_param = {};
fb_param.pixel_id = '6008232512301';
fb_param.value = '0.00';
(function(){
  var fpw = document.createElement('script');
  fpw.async = true;
  fpw.src = '//connect.facebook.net/en_US/fp.js';
  var ref = document.getElementsByTagName('script')[0];
  ref.parentNode.insertBefore(fpw, ref);
})();
</script>
<noscript><img height="1" width="1" alt="" style="display:none" src="https://www.facebook.com/offsite_event.php?id=6008232512301&amp;value=0" /></noscript>

	</head>
	<body>
		<div style="position: fixed;top:0px;left:0px;right:0px;z-index:1001;background-image: url(/homepage/includes/header_bg.png);background-repeat: repeat-x;">
			<table id="main_layout_homepage" width="100%">
				<col />
				<col width="1100" />
				<col />
				<tr>
					<td><img src="/img/blank.png" width="1" height="120" /></td>
					<td style="position: relative;">
						<div style="position: relative;width:1100px;height: 120px;">
							<a href="/" class="logo"><img width="112" height="111" src="/homepage/includes/logo5.png" /></a>
							<div id="nav1">
								<a class="nav1" style="font-size: 125%;" href="/homepage/features.php">Features</a>
								<a class="nav1" style="font-size: 125%;" href="/homepage/customers.php">Customers</a>
								<a class="nav1" style="font-size: 125%;" href="/homepage/pricing.php">Pricing</a>
								<a class="nav1" style="font-size: 125%;" href="/homepage/company.php">About</a>
								<a class="nav1" style="font-size: 125%;" href="/field-notes/">Field Notes</a>
							</div>
							<div id="nav2">
								<a href="/homepage/contact.php" class="nav2" >contact</a>
								&nbsp;&nbsp;|&nbsp;&nbsp;
								<? if($core->session['user_id'] == 0){?>
								<a class="nav2" href="/login.php">log in</a>
								<?}else{?>
								<a class="nav2" href="/app.php#!dashboard-home">dashboard</a>
								<?}?>
							</div>
							
							<div id="tagline">
								re-linking the food chain&#153;
							</div>
						</div>
					</td>
					<td><img src="/img/blank.png" width="1" height="120" /></td>
				</tr>
			</table>
		</div>
		
		<table id="main_layout_homepage" width="100%" style="margin-top: 120px;">
			<col />
			<col width="1100" />
			<col />
			
			<tr>
				<td><img src="/img/blank.png" width="1" height="400" /></td>
				<td id="main_content_homepage">
					<div id="popup_closer"><a href="#" onclick="$('#overlay,.popup,#popup_closer').fadeOut(100);"><img src="/homepage/img/icon_popup_close.png" /></a></div>
					<div id="overlay"></div>
					<div class="popup" id="popup3">
						<div class="popup_content">
							<iframe height="942" allowTransparency="true" frameborder="0" scrolling="no" style="width:100%;border:none" src="http://localorbit.wufoo.com/embed/z7x3k1/"><a href="http://localorbit.wufoo.com/forms/z7x3k1/">Submit</a></iframe>
						</div>
					</div>