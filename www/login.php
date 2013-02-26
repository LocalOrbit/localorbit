<?php

session_start();

if(in_array(strtolower($_SERVER['HTTP_HOST']),array('localorbit.com','localorbit.org','www.localorbit.com','www.localorbit.org')))
{
	header('Location: http://www.localorb.it/');
	exit();
}

$prtcl = ($_SERVER['SERVER_PORT'] == 80) ? 'http://' : 'https://';

if(isset($_REQUEST['_escaped_fragment_']))
{
	define('__CORE_AJAX_OUTPUT__',false);
	include('app/index.php');
	exit();
}

if(isset($_REQUEST['type']) && trim($_REQUEST['type']) != '')
{
	$url = 'http://'.$_SERVER['SERVER_NAME'].str_replace('index.php','',$_SERVER['SCRIPT_NAME']);
	switch($_REQUEST['type'])
	{
		# use this to auto redirect to a hash-based url
		# just use header(location) and exit.
	}
}

$stage = 'www';
$stage = (strpos($_SERVER['HTTP_HOST'],'testing') !== false)?'testing':$stage;
$stage = (strpos($_SERVER['HTTP_HOST'],'qa') !== false)?'qa':$stage;

?>
<!DOCTYPE html>
<html>
<head>
	<title>Local Orbit</title>
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	<meta charset="utf-8" />
	<!--<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" />-->
	<base href="<?=$prtcl?><?=$_SERVER['SERVER_NAME']?><?=str_replace('app.php','',str_replace('index.php','',$_SERVER['SCRIPT_NAME']))?>" />

	<!-- <link rel="stylesheet" type="text/css" href="css/reset.css" /> -->
	<link rel="stylesheet" type="text/css" href="css/loader.php?time=<?php echo time();?>" media="all" /> <? # Loads forms.css, datatable.css, popups.css, rte.css ?>
	<link rel="alternate stylesheet" type="text/css" href="css/less.php?which=style3" title="styles3" media="all" />

	<link rel="stylesheet" type="text/css" href="css/less.php" title="styles1" media="all" />

	<!--<link rel="stylesheet" type="text/css" href="css/responsive.css" />-->

	<!--<script language="Javascript" type="text/javascript" src="app/core/js/console.min.js"></script>-->
	<script language="Javascript" type="text/javascript" src="js/jquery.min.js"></script>
	<script language="Javascript" type="text/javascript" src="js/jquery.jqtweets.js"></script>
	<script language="Javascript" type="text/javascript" src="app/core/js/core.js?time=<?php echo time();?>"></script>
	<script language="Javascript" type="text/javascript" src="app/core/js/core.validator.js?time=<?php echo time();?>"></script>
	<script language="Javascript" type="text/javascript" src="app/core/js/core.format.js?time=<?php echo time();?>"></script>
	<script language="Javascript" type="text/javascript" src="app/core/js/core.ui.js?time=<?php echo time();?>"></script>
	<script language="Javascript" type="text/javascript" src="app/core/js/jquery.datePicker.js?time=<?php echo time();?>"></script>
	<!--<script language="Javascript" type="text/javascript" src="app/core/js/jquery.tabset.js?time=<?php echo time();?>"></script>-->
	<script language="Javascript" type="text/javascript" src="js/jquery.rte.js?time=<?php echo time();?>"></script>
	<script language="Javascript" type="text/javascript" src="js/lo3.js?time=<?php echo time();?>"></script>
	<script language="Javascript" type="text/javascript" src="js/slides.jquery.js"></script>
	<script language="Javascript" type="text/javascript" src="js/chosen.jquery.min.js"></script>

	<script language="Javascript" type="text/javascript" src="js/stylesheetToggle.js"></script>

	<script type="text/javascript" src="js/jquery.autocomplete.pack.js"></script>
	<script type="text/javascript" src="js/jquery.select-autocomplete.js"></script>
	<!--<script language="Javascript" type="text/javascript" src="js/jquery.jqplot.min.js"></script>-->
	<script language="Javascript" type="text/javascript" src="<?=$prtcl?>maps.googleapis.com/maps/api/js?key=AIzaSyAMekmlIkMHfj2m5G4lgWrwgZyrgM6rhgU&sensor=false"></script>

	<script language="Javascript" type="text/javascript">
	<!--
	//
	core.hostname = '<?php echo($_SERVER['SERVER_NAME'])?>';
	core.appPage  = 'app.php';
	core.baseUrl  = '<?php echo($_SERVER['REQUEST_URI'])?>';
	core.user_id  = '<?php echo (array_key_exists('core', $_SESSION) && array_key_exists('user_id', $_SESSION['core'])) ? (intval($_SESSION['core']['user_id'])) : ''; ?>';
	core.unauth_controller = '#!misc-home';
	core.authed_controller = '#!dashboard-view';
	$.fn.datePicker.format = 'M d,y';
	//-->
	</script>

	<script language="Javascript" type="text/javascript" src="js/bootstrap.min.js"></script>
	<script language="Javascript" type="text/javascript" src="js/bootbox.min.js"></script>
	<script language="Javascript" type="text/javascript" src="js/bootstrapx-clickover.js"></script>

</head>
<body onload="core.init(false);">
	<div id="wrap">
		<div id="statusnav" class="navbar navbar-inverse navbar-fixed-top">
			<div class="navbar-inner">
				<div class="container">
					<a class="btn btn-navbar" data-toggle="collapse" data-target="#statusnav .nav-collapse">
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</a>
					<div id="nav1top" class="nav-collapse collapse">
						<ul class="nav pull-right">
							<li class="divider-vertical"></li>
							<li><a href="#">Your Account</a></li>
							<li class="divider-vertical"></li>
							<li><a href="#about">Help</a></li>
							<li class="divider-vertical"></li>
							<li><a href="#contact">Your Cart</a></li>
						</ul>
						<p class="navbar-text pull-right">
							Logged in as <a href="#" class="navbar-link">Username</a>
						</p>
					</div><!--/.nav-collapse -->
				</div><!-- /.container-->
			</div><!-- /.navbar-inner-->
		</div><!--/#statusnav -->
		<div id="header" class="container">
			<div class="row">
				<div class="span5" id="logocontainer">
					<a href="http://<?=$_SERVER['HTTP_HOST']?>/index.php" onclick="core.go(this.href);" id="logo"></a>
					<h3 class="taglinecontainer"><span id="tagline"></span></h3>
				</div><!--/span-->
	
				<div id="mainnavcontainer" class="span7">
					<div id="mainnav">
					</div>
				</div><!-- /#navrow-->
			</div> <!-- /.row-->
		</div> <!-- /#header-->
		<div id="content" class="container">
			<div class="row">
				<div class="span3">
	
					<div id="loginform">
						<form class="form" name="authform" action="app/auth/process" style="margin-bottom: 0;">
	
							<h4>Log In</h4>
	
							<label style="display: none;">E-mail Address</label>
							<input type="text" class="text" tabindex="1" name="email" value="" placeholder="E-mail Address" />
	
							<label style="display: none;">Password</label>
							<input type="password" tabindex="2" class="text" name="password" value="" placeholder="Password" />
	
							<input type="submit" value="Log In" tabindex="3" class="btn btn-primary button_primary" />
							<input type="hidden" name="postauth_url" value="" />
							<ul>
								<li id="requestAccountLink" style="display: none;"><a href="app.php#!registration-form" tabindex="5" /><strong>Request an account</strong></a></li>
								<li><a href="app.php#!auth-forgot_password" tabindex="4" />Having trouble logging in?</a></li>
							</ul>
	
						</form>
					</div>
					<div id="left"></div>
	
				</div><!--/#left-->
	
				<div id="center" class="span9">
	
					<div class="row">
						<div class="span5">
							<div class="row">
								<div id="market_profile" class="span5"></div>
							</div>
							<div class="row">
								<div id="market_policies" class="span5"></div>
							</div>
						</div>
						<div class="span4" id="hub_image">
						</div>
					</div>
	
	
				</div><!--/#center-->
			</div>
		</div><!--/#content-->
		<div id="push"></div> <!-- This pushes the footer to the bottom of the window-->
	</div> <!-- /#wrap -->
	<div id="footer"></div>
	<script language="Javascript" type="text/javascript" defer="defer">
		
		core.doRequest('/market/login_info','');
		core.doRequest('/whitelabel/get_options','');
		core.doRequest('/navstate/left_hub_info','');
		
		<?if(array_key_exists('login_fail', $_REQUEST) && $_REQUEST['login_fail'] == 1){?>
			core.ui.error('Whoops! Your user name and password don\'t match. Please try again.');
		<?}?>
		<?if(array_key_exists('account_suspended', $_REQUEST) && $_REQUEST['account_suspended'] == 1){?>
			core.ui.error('Your account has been suspended. Please <a href="https://localorbit.zendesk.com/anonymous_requests/new">contact customer support</a>');
		<?}?>
	
	</script>

	<?
		/*
		<script language="Javascript" type="text/javascript" src="<?=$prtcl?>asset0.zendesk.com/external/zenbox/v2.1/zenbox.js"></script>
		<script language="Javascript" type="text/javascript" defer="defer">
		var fileref=document.createElement("link")
		fileref.setAttribute("rel", "stylesheet")
		fileref.setAttribute("type", "text/css")
		fileref.setAttribute("href", 'https://asset0.zendesk.com/external/zenbox/v2.1/zenbox.css');
		document.getElementsByTagName("head")[0].appendChild(fileref)
		if (typeof(Zenbox) !== "undefined") {
			Zenbox.init({
			dropboxID: "20013343",
			url: "https://localorbit.zendesk.com",
			tabID: "help",
			tabColor: "#912529",
			tabPosition: "Left"
			});
		}
		*/
	?>

	<script language="Javascript" type="text/javascript" defer="defer">
		var _gaq = _gaq || [];
		_gaq.push(['_setAccount', 'UA-19817823-1']);
		_gaq.push(['_setDomainName', '.localorb.it']);
		_gaq.push(['_trackPageview']);
		
		(function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
		})();
	</script>

	</body>
</html>