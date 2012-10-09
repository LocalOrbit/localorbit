<?php
/*
Plugin Name: RSS Icon Widget
Plugin URI: http://www.think-press.com/widgets/rss-icon-widget
Donate link: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3497105
Description: It seems like a feature that just got overlooked in WordPress core. The idea is to have a widget to display a link to any rss feed with a <a href="http://www.feedicons.com">standard feed icon</a>.
Author: Pixel Jar
Version: 2.2
Author URI: http://www.think-press.com


Copyright 2009  Pixel jar  (email : info@pixeljar.net)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

// check WP version to see which version of the plugin is needed.

	global $wp_version;
	$legacy = (version_compare($wp_version, "2.8", ">=")) ? false : true;
	if ( $legacy ) {
		include ('wp-legacy.php');
	} else {
		include ('wp-28.php');
	}
	
	add_action('wp_head', 'wp_head_intercept');
	function wp_head_intercept() {
		echo '<meta name="generator" content="Think-Press RSS Icon Widget v2.2" />';
	}
?>