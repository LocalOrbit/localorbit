<?php
// Outputs tweaked styles as a CSS file
$wordpressRealPath = str_replace('\\', '/', dirname(dirname(dirname(dirname(__FILE__)))));
if (file_exists($wordpressRealPath.'/wp-load.php')) {
	require_once($wordpressRealPath.'/wp-load.php');
} else {
	require_once($wordpressRealPath.'/wp-config.php');
}

// Prints the required style
function mbst_print_style ($style_name) {
	$style = get_option($style_name);
	if ($style != '')
		echo stripcslashes(base64_decode($style)."\r");	
}

// Sets correct HTTP headers
header('Content-Type: text/css');
$lastModifiedDate = get_option('mbst_style_update_timestamp');
if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) >= $lastModifiedDate) {
	if (php_sapi_name()=='CGI') {
		Header("Status: 304 Not Modified");
	} else {
		Header("HTTP/1.0 304 Not Modified");
	}
} else {
	$gmtDate = gmdate("D, d M Y H:i:s\G\M\T",$lastModifiedDate);
	header('Last-Modified: '.$gmtDate);
}

// Prints the three styles when necessary
remove_action('shutdown', 'mbst_add_custom_warning');
mbst_print_style('mbst_style_generic');
if (get_option(mbst_option_name(TRUE)) == '')
	mbst_print_style(mbst_option_name());
else
	mbst_print_style(mbst_option_name(TRUE));
?>