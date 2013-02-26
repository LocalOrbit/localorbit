<?php
/*
+----------------------------------------------------------------+
|																							|
|	WordPress 2.7 Plugin: WP-EMail 2.40										|
|	Copyright (c) 2008 Lester "GaMerZ" Chan									|
|																							|
|	File Written By:																	|
|	- Lester "GaMerZ" Chan															|
|	- http://lesterchan.net															|
|																							|
|	File Information:																	|
|	- E-Mail Post/Page To A Friend (Popup Window)							|
|	- wp-content/plugins/wp-email/email-popup.php						|
|																							|
+----------------------------------------------------------------+
*/


### Session Start
#@session_start();

### Filters
add_filter('wp_title', 'email_pagetitle');
add_filter('the_title', 'email_title');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>
<head>
	<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />
	<meta name="robots" content="noindex, nofollow" />
	<title><?php bloginfo('name'); ?> <?php if ( is_single() ) { ?> &raquo; <?php _e('Blog Archive', 'wp-email'); ?> <?php } ?> <?php wp_title(); ?></title>
	<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>" type="text/css" media="screen" />
	<script type="text/javascript">
	/* <![CDATA[*/
		function repositionPopup() {
			var content = document.getElementById("wp-email-popup");
			var newWidth = content.offsetWidth + 30;
			var newHeight = content.offsetHeight + 50;
			if (/Firefox/.test(navigator.userAgent)) // Firefox doesn't hide location & status bars
			  newHeight += 50;
			window.resizeTo(newWidth, newHeight);
			window.moveTo((screen.width-newWidth) / 2, (screen.height-newHeight) / 2);
		}
	/* ]]> */
	</script>
	<?php wp_head(); ?>
</head>
<body onload="repositionPopup();">
	<div id="wp-email-popup">
		<?php email_form(true); ?>
		<p style="text-align: center; padding-top: 20px;"><a href="#" onclick="window.close();"><?php _e('Close This Window', 'wp-email'); ?></a></p>
		<?php wp_footer(); ?>
	</div>
</body>
</html>