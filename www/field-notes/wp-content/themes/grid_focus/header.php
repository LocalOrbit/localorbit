<?php
#echo('<!--'.file_get_contents(dirname(__FILE__)."/../../../../scripts/navigation.php").'-->');
?>
<?php
/**
 *	@package WordPress
 *	@subpackage Grid_Focus
 */
 
# load up the core framework so we can get all the session stuffs :D
global $core;
include(dirname(__FILE__).'/../../../../app/core/core.php');
define('__CORE_DB_NOCONNECT__',true);
core::init(__FILE__);
$prtcl = ($_SERVER['SERVER_PORT'] == 80)?'http://':'https://';
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
	<head profile="http://gmpg.org/xfn/11">
		<title><?php if (function_exists('is_tag') && is_tag()) { echo 'Posts tagged &quot;'.$tag.'&quot; - '; } elseif (is_archive()) { wp_title(''); echo ' Archive - '; } elseif (is_search()) { echo 'Search for &quot;'.wp_specialchars($s).'&quot; - '; } elseif (!(is_404()) && (is_single()) || (is_page())) { wp_title(''); echo ' - '; } elseif (is_404()) { echo 'Not Found - '; } bloginfo('name'); ?></title>
		<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" />
		<meta name="generator" content="WordPress <?php bloginfo('version'); ?>" />
		<link rel="stylesheet" type="text/css" href="/css/reset.css" />
		<link rel="stylesheet" type="text/css" href="/field-notes/wp-content/themes/grid_focus/legacy.css" />
		<link rel="stylesheet" type="text/css" href="/css/wordpress.css" />
		<link rel="stylesheet" type="text/css" href="/homepage/includes/popup.css" />
	<link rel="stylesheet" type="text/css" href="css/less.php" title="styles1" media="all" />
		<script language="Javascript" type="text/javascript" src="/js/jquery.min.js"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/core.js?time=0.07943900 1331674046"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/core.validator.js?time=0.07944100 1331674046"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/core.format.js?time=0.07944200 1331674046"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/core.ui.js?time=0.07944300 1331674046"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/jquery.datePicker.js?time=0.07944500 1331674046"></script>
		<script language="Javascript" type="text/javascript" src="/app/core/js/jquery.tabset.js?time=0.07944600 1331674046"></script>
		<script language="Javascript" type="text/javascript" src="/js/jquery.rte.js?time=0.07944800 1331674046"></script>
		<script language="Javascript" type="text/javascript" src="/js/lo3.js?time=0.07945000 1331674046"></script>
		<script type="text/javascript"src="<?=$prtcl?>maps.googleapis.com/maps/api/js?key=AIzaSyAMekmlIkMHfj2m5G4lgWrwgZyrgM6rhgU&sensor=false"></script>

		<script language="Javascript" type="text/javascript">
		<!--
		core.hostname = 'www.localorb.it';
		core.baseUrl  = '/';
		core.user_id  = '0';
		core.unauth_controller = '#!misc-home';
		core.authed_controller = '#!dashboard-view';
		$.fn.datePicker.format = 'M d,y';
		//-->
		</script>
	</head>
	<body>
		<div id="popup_closer"><a href="#" onclick="$('#overlay,.popup,#popup_closer').fadeOut(100);"><img src="/homepage/img/icon_popup_close.png" /></a></div>
		<div id="overlay"></div>
		<div class="popup" id="popup3">
			<div class="popup_content">
				<iframe height="942" allowTransparency="true" frameborder="0" scrolling="no" style="width:100%;border:none" src="http://localorbit.wufoo.com/embed/z7x3k1/"><a href="http://localorbit.wufoo.com/forms/z7x3k1/">Fill out my Wufoo form!</a></iframe>
			</div>
		</div>
		<div id="outer_frame">
			
			<table id="main_layout">
				<col width="820" />
				<col width="300" />
				<tr>
					<td colspan="2">
						<div id="logo_area">
							<table width="100%">
								<col width="1%" />
								<col width="1%" />
								<col width="99%" />
								<tr>
									<td style="padding: 10px;">
										<a href="https://<?=$_SERVER['HTTP_HOST']?>/" onclick="core.go(this.href);" id="logo"><img src="/homepage/includes/logo5.png" /></a>
									</td>
									<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
									<td style="vertical-align: top;padding: 10px 15px 0px 0px;">
										<table width="100%">
											<col width="1%" />
											<col width="99%" />
											<tr>
												<td>
												</td>
												<td id="nav1top">
													<? if($core->session['user_id'] > 0){?>
													Welcome <?=$core->session['first_name']?>
													&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
													<a href="https://localorbit.zendesk.com/forums" target="_blank">help</a>
													&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
													<a href="<?=$prtcl?><?=$_SERVER['HTTP_HOST']?>/#!auth-logout">log out</a>
													
													<?}else{?>
													<a href="#" onclick="$('#overlay,#popup3,#popup_closer').fadeIn(150);">contact</a>
													&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
													<a href="https://<?=$_SERVER['HTTP_HOST']?>/app.php#!auth-form" style="color: #555;">log in</a>
									 
													<?}?>
												</td>
											</tr>
											<tr>
												<td colspan="2" id="nav1divider"></td>
											</tr>
											<tr>
												<td colspan="2" id="nav1sub">
													<? if($core->session['user_id'] > 0){?>
													<a href="<?=$prtcl?><?=$_SERVER['HTTP_HOST']?>/app.php#!dashboard-home" onclick="core.go(this.href);" class="main">dashboard</a>
													<a href="<?=$prtcl?><?=$_SERVER['HTTP_HOST']?>/app.php#!news-list" onclick="core.go(this.href);" class="main">market info</a>
													<a href="<?=$prtcl?><?=$_SERVER['HTTP_HOST']?>/app.php#!sellers-oursellers" onclick="core.go(this.href);" class="main">our sellers</a>
													<a href="<?=$prtcl?><?=$_SERVER['HTTP_HOST']?>/app.php#!catalog-shop" onclick="core.go(this.href);" class="main">shop</a>
													<?}?>
												</td>
											</tr>
										</table>
										
									</td>
								</tr>
							</table>
						</div>
					</td>
				</tr>

	
                        