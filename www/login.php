<?php

session_start();

if(in_array(strtolower($_SERVER['HTTP_HOST']),array('localorbit.com','localorbit.org','www.localorbit.com','www.localorbit.org')))
{
	header('Location: http://www.localorb.it/');
	exit();
}

$prtcl = ($_SERVER['SERVER_PORT'] == 80)?'http://':'https://';

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
<!doctype html>
<html>
	<head>
		<title>Local Orbit</title>
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		<meta charset="utf-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" />
		<base href="<?=$prtcl?><?=$_SERVER['SERVER_NAME']?><?=str_replace('app.php','',str_replace('index.php','',$_SERVER['SCRIPT_NAME']))?>" />
		<link rel="stylesheet" type="text/css" href="css/reset.css" />
		<link rel="stylesheet" type="text/css" href="css/loader.php?time=<?php echo time();?>" />
		<link rel="stylesheet" type="text/css" href="homepage/includes/popup.css" />
		<script language="Javascript" type="text/javascript" src="app/core/js/console.min.js"></script>
		<script language="Javascript" type="text/javascript" src="js/jquery.min.js"></script>
		<script language="Javascript" type="text/javascript" src="app/core/js/core.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="app/core/js/core.validator.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="app/core/js/core.format.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="app/core/js/core.ui.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="app/core/js/jquery.datePicker.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="app/core/js/jquery.tabset.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="js/jquery.rte.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="js/lo3.js?time=<?php echo time();?>"></script>
		<script language="Javascript" type="text/javascript" src="js/slides.jquery.js"></script>
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
		core.user_id  = '<?php echo(intval($_SESSION['core']['user_id'])); ?>';
		core.unauth_controller = '#!misc-home';
		core.authed_controller = '#!dashboard-view';
		$.fn.datePicker.format = 'M d,y';
		//-->
		</script>
	</head>
	<body onload="core.init(false);">
		<div id="popup_closer"><a href="#" onclick="$('#overlay,.popup,#popup_closer').fadeOut(100);"><img src="/homepage/img/icon_popup_close.png" /></a></div>
		<div id="overlay"></div>
		<div class="popup" id="popup3">
			<div class="popup_content">
				<iframe height="942" allowTransparency="true" frameborder="0" scrolling="no" style="width:100%;border:none" src="http://localorbit.wufoo.com/embed/z7x3k1/"><a href="http://localorbit.wufoo.com/forms/z7x3k1/">Fill out my Wufoo form!</a></iframe>
			</div>
		</div>
		<div id="shop_popup"><div class="shop_popup_top">&nbsp;</div><div class="shop_popup_middle">&nbsp;<div id="shop_popup_content"></div></div><div class="shop_popup_bottom">&nbsp;</div></div>
		<div id="edit_popup"></div>
		<div id="outer_frame">			
			<table id="main_layout">
				<col width="300" />
				<col width="820" />
				<tr>
					<td colspan="2" style="padding: 25px 13px 0px 10px;">
						<table width="100%">
							<col width="1%" />
							<col width="1%" />
							<col width="99%" />
							<tr>
								<td>
									<a href="http://<?=$_SERVER['HTTP_HOST']?>/index.php" onclick="core.go(this.href);" id="logo"></a><br />
									<div id="poweredby"></div>
								</td>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td style="vertical-align: top;">
									<table width="100%">
										<col width="1%" />
										<col width="99%" />
										<tr>
											<td>
												<table>
													<tr>
														<td id="tagline_left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
														<td id="tagline_center"><span id="tagline"></span></td>
													</tr>
												</table>
											</td>
											<td id="nav1top">
												&nbsp;
											</td>
										</tr>
										<tr>
											<td colspan="2" id="nav1divider"></td>
										</tr>
										<tr>
											<td colspan="2" id="nav1sub">&nbsp;</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="2" id="full_width">
						
					</td>
				</tr>
				<tr>
					<td id="left" class="left_col">
					</td>
					<td class="center_col">
						<!--[if lt IE 7]>
						<p class="warning" style="font-size: 1.5em;">
						It looks like you're using Internet Explorer 6.0.  We're unable to support this browser.
						</p>
						<p>
						You can update to <a href="http://www.microsoft.com/downloads/en/details.aspx?FamilyID=9ae91ebe-3385-447c-8a30-081805b2f90b&displaylang=en">IE 7 or 8</a> for free. We recommend a free browser such as <a href="http://www.mozilla.com/en-US/firefox/personal.html">Firefox</a> or <a href="http://www.google.com/chrome">Chrome</a>.
						</p>
						<![endif]-->
						<h1>Log in to <span id="market_title"></span></h1>

						<form name="authform" action="app/auth/process">
							<div class="tabset" id="logintabs">
								<div class="tabswitch tabswitch_on" id="logintabs-s1">
									User Info
								</div>
							</div>
							<div class="tabarea" id="logintabs-a1" style="display:block;">
								
								<table class="form">
									<colgroup>
										<col width="150" />
										<col width="200" />
										<col width="20" />
										<col width="267" />
									</colgroup>
									<tbody>
										<tr>	
											<td class="label">E-mail Address </td>
											<td class="value"><input type="text" class="text" tabindex="1" name="email" value="" /></td>
											<td rowspan="2">&nbsp;&nbsp;</td>
											<td rowspan="2">
												<ul>
													<li><a href="app.php#!registration-form" tabindex="5" />Request an account</a></li>
													<li><a href="app.php#!auth-forgot_password" tabindex="4" />Having trouble logging in?</a></li>
												</ul>
											</td>
										</tr>
										<tr>
											<td class="label">Password </td>
											<td class="value"><input type="password" tabindex="2" class="text" name="password" value="" /></td>
										</tr>
									</tbody>
								</table>
							</div>
							<div class="buttonset">
								<input type="submit" value="log me in" tabindex="3" class="button_primary" />
							</div>

							<br />&nbsp;<br />
							<input type="hidden" name="postauth_url" value="" />
						</form>


						<table>
							<colgroup>
								<col width="49%" />
								<col width="2%" />
								<col width="49%" />
							</colgroup>
							<tbody>
								<tr>
									<td id="market_profile">&nbsp;</td>
									<td>&nbsp;</td>
									<td id="market_policies">&nbsp;</td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="2" id="footer">
						<table style="table-layout: fixed;">
							<col width="145" />
							<col width="195" />
							<col width="195" />
							<col width="195" />
							<col width="195" />
							<tr>
								<td id="footer_logo">
									
								</td>
								<td id="footer_links1">
									
								</td>
								<td id="footer_links2">
									
								</td>
								<td id="footer_links3">
									
								</td>
								<td id="footer_links4">
									
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</div>
		<div id="overlay">&nbsp;</div>
		<div id="notification">
			<div id="notification_content">
			</div>
			<div id="notification_close" onclick="core.ui.notificationClose();">
			</div>
		</div>
				
		<div id="popup">
			<div>
				<div id="popup_left">
					<img src="/img/misc/exclamation.png" />
				</div>
				<div id="popup_center">
					<div id="popup_content">
					
					</div>
				</div>
				<div id="popup_foot">
				&nbsp;
				</div>
			</div>
		</div>
		<script language="Javascript" type="text/javascript" defer="defer">
		<!--
		core.doRequest('/market/login_info','');
		core.doRequest('/whitelabel/get_options','');
		core.doRequest('/navstate/left_hub_info','');
		///-->
		</script>
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
		
		var _gaq = _gaq || [];
		_gaq.push(['_setAccount', 'UA-19817823-1']);
		_gaq.push(['_setDomainName', '.localorb.it']);
		_gaq.push(['_trackPageview']);

		<?if($_REQUEST['login_fail'] == 1){?>
		core.validatePopup('Whoops! Your user name and password don\'t match. Please try again.');
		<?}?>
		<?if($_REQUEST['account_suspended'] == 1){?>
		core.validatePopup('Your account has been suspended. Please <a href="https://localorbit.zendesk.com/anonymous_requests/new">contact customer support</a>');
		<?}?>

		(function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
		})();
		</script>
	</body>
</html>
