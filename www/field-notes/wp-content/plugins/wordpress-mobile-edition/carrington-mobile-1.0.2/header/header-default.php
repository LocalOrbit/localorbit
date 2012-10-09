<?php

// This file is part of the Carrington Mobile Theme for WordPress
// http://carringtontheme.com
//
// Copyright (c) 2008-2009 Crowd Favorite, Ltd. All rights reserved.
// http://crowdfavorite.com
//
// Released under the GPL license
// http://www.opensource.org/licenses/gpl-license.php
//
// **********************************************************************
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
// **********************************************************************

if (__FILE__ == $_SERVER['SCRIPT_FILENAME']) { die(); }
if (CFCT_DEBUG) { cfct_banner(__FILE__); }

?>
<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN"
"http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title><?php wp_title('&laquo;', true, 'right'); bloginfo('name'); ?></title>
	<meta http-equiv="content-type" content="<?php bloginfo('html_type') ?>; charset=<?php bloginfo('charset') ?>" />
	<meta name="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;"/>
	<link rel="stylesheet" href="<?php echo get_stylesheet_uri(); ?>" type="text/css" media="screen" charset="utf-8" />
	<style type="text/css">
		@import url(<?php echo trailingslashit(get_bloginfo('template_url')).'css/advanced.css'; ?>);
	</style>
	<script type="text/javascript">
	<!--
<?php

is_page() ? $page = 'true' : $page = 'false';
echo '	CFMOBI_IS_PAGE = '.$page.';';
echo "	CFMOBI_PAGES_TAB = '".str_replace("'", "\'", __('Pages', 'carrington-mobile'))."';";
echo "	CFMOBI_POSTS_TAB = '".str_replace("'", "\'", __('Recent Posts', 'carrington-mobile'))."';";

global $cfmobi_touch_browsers;
if (!isset($cfmobi_touch_browsers) || !is_array($cfmobi_touch_browsers)) {
	$cfmobi_touch_browsers = array(
		'iPhone',
		'iPod',
		'Android',
		'BlackBerry9530',
		'LG-TU915 Obigo', // LG touch browser
		'LGE VX',
		'webOS', // Palm Pre, etc.
	);
}
if (count($cfmobi_touch_browsers)) {
	$touch = array();
	foreach ($cfmobi_touch_browsers as $browser) {
		$touch[] = str_replace('"', '\"', trim($browser));
	}

?>
	var CFMOBI_TOUCH = ["<?php echo implode('","', $touch); ?>"];
	for (var i = 0; i < CFMOBI_TOUCH.length; i++) {
		if (navigator.userAgent.indexOf(CFMOBI_TOUCH[i]) != -1) {
			document.write('<?php echo str_replace('/', '\/', '<link rel="stylesheet" href="'.trailingslashit(get_bloginfo('template_url')).'css/touch.css" type="text/css" media="screen" charset="utf-8" />'); ?>');
			break;
		}
	}
<?php

}

?> 
	document.write('<?php

ob_start();
wp_print_scripts();
$wp_scripts = ob_get_contents();
ob_end_clean();

echo trim(str_replace(
	array("'", "\n", '/'), 
	array("\'", '', '\/'),
	$wp_scripts
));

?>');
	//--></script>
</head>
<body<?php if(is_single() || is_page()) {echo '';} else { echo ' id="is-list"';} ?>>

<h1 id="site-name"><a rel="home" href="<?php bloginfo('url'); ?>"><?php bloginfo('name'); ?></a></h1>

<hr />

<p id="navigation-top" class="navigation">
	<?php cfct_misc('main-nav'); ?>
</p>

<hr />