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

load_theme_textdomain('carrington-mobile');

define('CFCT_DEBUG', false);
define('CFCT_PATH', trailingslashit(TEMPLATEPATH));
define('CFCT_HOME_LIST_LENGTH', 5);
define('CFCT_HOME_LATEST_LENGTH', 250);

$cfct_options = array(
	'cfct_about_text'
	, 'cfct_credit'
	, 'cfct_posts_per_archive_page'
	, 'cfct_wp_footer'
);

function cfct_blog_init() {
	if (cfct_get_option('cfct_ajax_load') == 'yes') {
		cfct_ajax_load();
	}
}
add_action('init', 'cfct_blog_init');

function cfct_archive_title() {
	if(is_author()) {
		$output = __('Posts by:');
	} elseif(is_category()) {
		$output = __('Category Archives:');
	} elseif(is_tag()) {
		$output = __('Tag Archives:');
	} elseif(is_archive()) {
		$output = __('Archives:');
	}
	$output .= ' ';
	echo $output;
}

function cfct_mobile_post_gallery_columns($columns) {
	return 1;
}
add_filter('cfct_post_gallery_columns', 'cfct_mobile_post_gallery_columns');

if (!is_admin()) {
	wp_enqueue_script('jquery');
	wp_enqueue_script('carrington-mobile', get_bloginfo('template_directory').'/js/mobile.js', array('jquery'), '1.0');
}

include_once(CFCT_PATH.'carrington-core/carrington.php');

?>