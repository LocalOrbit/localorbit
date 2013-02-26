<?php
/** Load WordPress Bootstrap */
require_once(dirname(__FILE__) . '/../../../../../wp-load.php');
/** Load WordPress Administration Bootstrap */
require_once(dirname(__FILE__) . '/../../../../../wp-admin/admin.php');
/** UMapper main plugin class **/
require_once(dirname(__FILE__) . '/../../lib/Umapper/Plugin.php');

if (!current_user_can('manage_options'))
wp_die(__('You do not have sufficient permissions to access this page.', 'umapper'));

@header('Content-Type: ' . get_option('html_type') . '; charset=' . get_option('blog_charset'));

$mapId = isset($_GET['mapId']) ? $_GET['mapId'] : 0;
$token = isset($_GET['token']) ? $_GET['token'] : 0;
//var_dump($_GET);
//exit;
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"  dir="ltr" lang="ru-RU">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>UMapper &rsaquo; Editor</title>
<?php
wp_enqueue_style( 'global' );
wp_enqueue_style( 'wp-admin' );
wp_enqueue_style( 'colors' );
wp_enqueue_style( 'ie' );

// my own decls
wp_enqueue_script('AC_RunActiveContent', Umapper_Plugin::getPluginUri() . 'content/js/AC_RunActiveContent.js', array(), '1.0');
wp_enqueue_style('UmapperStyleAdmin', Umapper_Plugin::getPluginUri() . 'content/css/admin.compact.css', false, '1.0', 'all');

?>
<script type="text/javascript">
//<![CDATA[
addLoadEvent = function(func){if(typeof jQuery!="undefined")jQuery(document).ready(func);else if(typeof wpOnload!='function'){wpOnload=func;}else{var oldonload=wpOnload;wpOnload=function(){oldonload();func();}}};
var userSettings = {'url':'<?php echo SITECOOKIEPATH; ?>','uid':'<?php if ( ! isset($current_user) ) $current_user = wp_get_current_user(); echo $current_user->ID; ?>','time':'<?php echo time() ?>'};
//]]>
</script>
<?php
do_action('admin_print_styles');
do_action('admin_print_scripts');
do_action('admin_head');
?>
<style>
    body {font-size:10px;}
</style>
</head>
<body>

<div style="height:100%;" style="border:1px solid red;">
<script language="JavaScript" type="text/javascript">

// Major version of Flash required
var requiredMajorVersion = 9;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 28;

<!--
// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
var hasProductInstall = DetectFlashVer(6, 0, 65);

// Version check based upon the values defined in globals
var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);

if ( hasProductInstall && !hasRequestedVersion ) {
	// DO NOT MODIFY THE FOLLOWING FOUR LINES
	// Location visited after installation is complete if installation is required
	var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
	var MMredirectURL = window.location;
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var MMdoctitle = document.title;

	AC_FL_RunContent(
		"src", "http://umapper.s3.amazonaws.com/assets/swf/playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMPlayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "http://umapper.s3.amazonaws.com/assets/swf/edit",
		"quality", "high",
		"bgcolor", "#000000",
		"name", "editor",
		"allowScriptAccess","always",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
    
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
	        "FlashVars", "<?php echo 'token=' . $token . '&mapid=' . $mapId;?>",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"src", "http://umapper.s3.amazonaws.com/assets/swf/edit",
			"id", "http://umapper.s3.amazonaws.com/assets/swf/edit",
			"quality", "high",
			"wmode", "transparent",
			"bgcolor", "#000000",
			"name", "editor",
			"allowScriptAccess","always",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = 'Alternate HTML content should be placed here. '
  	+ 'This content requires the Adobe Flash Player. '
   	+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content
  }
// -->
</script>
<noscript>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="http://umapper.s3.amazonaws.com/assets/swf/edit" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="http://umapper.s3.amazonaws.com/assets/swf/edit.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#000000" />
			<param name="src" value="http://umapper.s3.amazonaws.com/assets/swf/edit" />
			<param name="name" value="editor" />
			<param name="wmode" value="transparent" />
			<param name="FlashVars" value="<?php echo 'token=' . $token . '&mapid=' . $mapId;?>" />
			<param name="allowScriptAccess" value="always" />
			<embed FlashVars="<?php echo 'token=' . $token . '&mapid=' . $mapId;?>" src="http://umapper.s3.amazonaws.com/assets/swf/edit.swf" id="http://umapper.s3.amazonaws.com/assets/swf/edit" quality="high" bgcolor="#000000"
				width="100%" height="100%" name="editor" align="middle"
				play="true"
				loop="false"
				wmode="transparent"
				quality="high"
				allowScriptAccess="always"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>
</div>
</body>
</html>