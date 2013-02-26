<?php
/*
Plugin Name: WP-Print
Plugin URI: http://lesterchan.net/portfolio/programming/php/
Description: Displays a printable version of your WordPress blog's post/page.
Version: 2.40
Author: Lester 'GaMerZ' Chan
Author URI: http://lesterchan.net
*/


/*  
	Copyright 2008  Lester Chan  (email : lesterchan@gmail.com)

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
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/


### Create Text Domain For Translations
add_action('init', 'print_textdomain');
function print_textdomain() {
	load_plugin_textdomain('wp-print', false, 'wp-print');
}


### Function: Print Option Menu
add_action('admin_menu', 'print_menu');
function print_menu() {
	if (function_exists('add_options_page')) {
		add_options_page(__('Print', 'wp-print'), __('Print', 'wp-print'), 'manage_options', 'wp-print/print-options.php') ;
	}
}


### Function: Print htaccess ReWrite Rules
add_filter('generate_rewrite_rules', 'print_rewrite');
function print_rewrite($wp_rewrite) {
	// Print Rules For Posts
	$r_rule = '';
	$r_link = '';
	$print_link = get_permalink();
	if(substr($print_link, -1, 1) != '/' && substr($wp_rewrite->permalink_structure, -1, 1) != '/') {
		$print_link_text = '/print';
	} else {
		$print_link_text = 'print';
	}
	$rewrite_rules = $wp_rewrite->generate_rewrite_rule($wp_rewrite->permalink_structure.$print_link_text, EP_PERMALINK);
	$rewrite_rules = array_slice($rewrite_rules, 5, 1);
	$r_rule = array_keys($rewrite_rules);
	$r_rule = array_shift($r_rule);
	$r_rule = str_replace('/trackback', '',$r_rule);
	$r_link = array_values($rewrite_rules);
	$r_link = array_shift($r_link);
	$r_link = str_replace('tb=1', 'print=1', $r_link);
	$wp_rewrite->rules = array_merge(array($r_rule => $r_link), $wp_rewrite->rules);
	// Print Rules For Pages
	$page_uris = $wp_rewrite->page_uri_index();
	$uris = $page_uris[0];
	if(is_array($uris)) {
		$print_page_rules = array();
		foreach ($uris as $uri => $pagename) {			
			$wp_rewrite->add_rewrite_tag('%pagename%', "($uri)", 'pagename=');
			$rewrite_rules = $wp_rewrite->generate_rewrite_rules($wp_rewrite->get_page_permastruct().'/printpage', EP_PAGES);
			$rewrite_rules = array_slice($rewrite_rules, 5, 1);
			$r_rule = array_keys($rewrite_rules);
			$r_rule = array_shift($r_rule);
			$r_rule = str_replace('/trackback', '',$r_rule);
			$r_link = array_values($rewrite_rules);
			$r_link = array_shift($r_link);
			$r_link = str_replace('tb=1', 'print=1', $r_link);
			$print_page_rules = array_merge($print_page_rules, array($r_rule => $r_link));
		}
		$wp_rewrite->rules = array_merge($print_page_rules, $wp_rewrite->rules);
	}
}


### Function: Print Public Variables
add_filter('query_vars', 'print_variables');
function print_variables($public_query_vars) {
	$public_query_vars[] = 'print';
	$public_query_vars[] = 'printpage';
	return $public_query_vars;
}


### Function: Display Print Link
function print_link($print_post_text = '', $print_page_text = '', $echo = true) {
	global $id;
	if (function_exists('polyglot_get_lang')){
	    global $polyglot_settings;
	    $polyglot_append = $polyglot_settings['uri_helpers']['lang_view'].'/'.polyglot_get_lang().'/';
	}
	$output = '';
	$using_permalink = get_option('permalink_structure');
	$print_options = get_option('print_options');
	$print_style = intval($print_options['print_style']);
	if(empty($print_post_text)) {
		$print_text = stripslashes($print_options['post_text']);
	} else {
		$print_text  = $print_post_text;
	}
	$print_icon = plugins_url('wp-print/images/'.$print_options['print_icon']);
	$print_link = get_permalink();
	$print_html = stripslashes($print_options['print_html']);
	// Fix For Static Page
	if(get_option('show_on_front') == 'page' && is_page()) {	
		if(intval(get_option('page_on_front')) > 0) {
			$print_link = _get_page_link();
		}
	}
	if(!empty($using_permalink)) {
		if(substr($print_link, -1, 1) != '/') {
			$print_link = $print_link.'/';
		}
		if(is_page()) {
			if(empty($print_page_text)) {
				$print_text = stripslashes($print_options['page_text']);
			} else {
				$print_text = $print_page_text;
			}
			$print_link = $print_link.'printpage/'.$polyglot_append;
		} else {
			$print_link = $print_link.'print/'.$polyglot_append;
		}
	} else {
		if(is_page()) {
			if(empty($print_page_text)) {
				$print_text = stripslashes($print_options['page_text']);
			} else {
				$print_text = $print_page_text;
			}
		}
		$print_link = $print_link.'&amp;print=1';
	}
	unset($print_options);
	switch($print_style) {
		// Icon + Text Link
		case 1:
			$output = '<a href="'.$print_link.'" title="'.$print_text.'" rel="nofollow"><img class="WP-PrintIcon" src="'.$print_icon.'" alt="'.$print_text.'" title="'.$print_text.'" style="border: 0px;" /></a>&nbsp;<a href="'.$print_link.'" title="'.$print_text.'" rel="nofollow">'.$print_text.'</a>';
			break;
		// Icon Only
		case 2:
			$output = '<a href="'.$print_link.'" title="'.$print_text.'" rel="nofollow"><img class="WP-PrintIcon" src="'.$print_icon.'" alt="'.$print_text.'" title="'.$print_text.'" style="border: 0px;" /></a>';
			break;
		// Text Link Only
		case 3:
			$output = '<a href="'.$print_link.'" title="'.$print_text.'" rel="nofollow">'.$print_text.'</a>';
			break;
		case 4:
			$print_html = str_replace("%PRINT_URL%", $print_link, $print_html);
			$print_html = str_replace("%PRINT_TEXT%", $print_text, $print_html);
			$print_html = str_replace("%PRINT_ICON_URL%", $print_icon, $print_html);
			$output = $print_html;
			break;
	}
	if($echo) {
		echo $output."\n";
	} else {
		return $output;
	}
}


### Function: Short Code For Inserting Prink Links Into Posts/Pages
add_shortcode('print_link', 'print_link_shortcode');
function print_link_shortcode($atts) {
	if(!is_feed()) {
		return print_link('', '', false);
	} else {
		return __('Note: There is a print link embedded within this post, please visit this post to print it.', 'wp-print');
	}
}
function print_link_shortcode2($atts) {
	return;
}


### Function: Short Code For DO NOT PRINT Content
add_shortcode('donotprint', 'print_donotprint_shortcode');
function print_donotprint_shortcode($atts, $content = null) {
	return $content;
}
function print_donotprint_shortcode2($atts, $content = null) {
	return;
}


### Function: Print Content
function print_content($display = true) {
	global $links_text, $link_number, $max_link_number, $matched_links,  $pages, $multipage, $numpages, $post;
	if (!isset($matched_links)) {
		$matched_links = array();
	}
	if(!empty($post->post_password) && stripslashes($_COOKIE['wp-postpass_'.COOKIEHASH]) != $post->post_password) {
		$content = get_the_password_form();
	} else {
		if($multipage) {
			for($page = 0; $page < $numpages; $page++) {
				$content .= $pages[$page];
			}
		} else {
			$content = $pages[0];
		}
		remove_shortcode('donotprint', 'print_donotprint_shortcode');
		add_shortcode('donotprint', 'print_donotprint_shortcode2');
		remove_shortcode('print_link', 'print_link_shortcode');
		add_shortcode('print_link', 'print_link_shortcode2');
		$content = apply_filters('the_content', $content);
		$content = str_replace(']]>', ']]&gt;', $content);
		if(!print_can('images')) {
			$content = remove_image($content);
		}
		if(!print_can('videos')) {
			$content = remove_video($content);
		}
		if(print_can('links')) {
			preg_match_all('/<a(.+?)href=[\"\'](.+?)[\"\'](.*?)>(.+?)<\/a>/', $content, $matches);
			for ($i=0; $i < count($matches[0]); $i++) {
				$link_match = $matches[0][$i];
				$link_url = $matches[2][$i];
				if(stristr($link_url, 'https://')) {
					 $link_url =(strtolower(substr($link_url,0,8)) != 'https://') ?get_option('home') . $link_url : $link_url;
				} else if( stristr($link_url, 'mailto:')) {
					$link_url =(strtolower(substr($link_url,0,7)) != 'mailto:') ?get_option('home') . $link_url : $link_url;
				} else if( $link_url[0] == '#' ) {
					$link_url = $link_url; 
				} else {
					$link_url =(strtolower(substr($link_url,0,7)) != 'http://') ?get_option('home') . $link_url : $link_url;
				}
				$link_text = $matches[4][$i];+				
				$new_link = true;
				$link_url_hash = md5($link_url);
				if (!isset($matched_links[$link_url_hash])) {
					$link_number = ++$max_link_number;
					$matched_links[$link_url_hash] = $link_number;
				} else {
					$new_link = false;
					$link_number = $matched_links[$link_url_hash];
				}
				$content = str_replace_one($link_match, "<a href=\"$link_url\" rel=\"external\">".$link_text.'</a> <sup>['.number_format_i18n($link_number).']</sup>', $content);
				if ($new_link) {
					if(preg_match('/<img(.+?)src=[\"\'](.+?)[\"\'](.*?)>/',$link_text)) {
						$links_text .= '<p style="margin: 2px 0;">['.number_format_i18n($link_number).'] '.__('Image', 'wp-print').': <b><span dir="ltr">'.$link_url.'</span></b></p>';
					} else {
						$links_text .= '<p style="margin: 2px 0;">['.number_format_i18n($link_number).'] '.$link_text.': <b><span dir="ltr">'.$link_url.'</span></b></p>';
					}
				}
			}
		}
	}
	if($display) {
		echo $content;
	} else {
		return $content;
	}
}


### Function: Print Categories
function print_categories($before = '', $after = '') {
	$temp_cat = strip_tags(get_the_category_list(',', $parents));
	$temp_cat = explode(', ', $temp_cat);
	$temp_cat = implode($after.__(',', 'wp-print').' '.$before, $temp_cat);
	echo $before.$temp_cat.$after;
}


### Function: Print Comments Content
function print_comments_content($display = true) {
	global $links_text, $link_number, $max_link_number, $matched_links;
	if (!isset($matched_links)) {
		$matched_links = array();
	}
	$content  = get_comment_text();
	$content = apply_filters('comment_text', $content);
	if(!print_can('images')) {
		$content = remove_image($content);
	}
	if(!print_can('videos')) {
		$content = remove_video($content);
	}
	if(print_can('links')) {
		preg_match_all('/<a(.+?)href=[\"\'](.+?)[\"\'](.*?)>(.+?)<\/a>/', $content, $matches);
		for ($i=0; $i < count($matches[0]); $i++) {
			$link_match = $matches[0][$i];
			$link_url = $matches[2][$i];
			if(stristr($link_url, 'https://')) {
				 $link_url =(strtolower(substr($link_url,0,8)) != 'https://') ?get_option('home') . $link_url : $link_url;
			} else if(stristr($link_url, 'mailto:')) {
				$link_url =(strtolower(substr($link_url,0,7)) != 'mailto:') ?get_option('home') . $link_url : $link_url;
			} else if($link_url[0] == '#') {
				$link_url = $link_url; 
			} else {
				$link_url =(strtolower(substr($link_url,0,7)) != 'http://') ?get_option('home') . $link_url : $link_url;
			}
			$new_link = true;
			$link_url_hash = md5($link_url);
			if (!isset($matched_links[$link_url_hash])) {
				$link_number = ++$max_link_number;
				$matched_links[$link_url_hash] = $link_number;
			} else {
				$new_link = false;
				$link_number = $matched_links[$link_url_hash];
			}
			$content = str_replace_one($link_match, "<a href=\"$link_url\" rel=\"external\">".$link_text.'</a> <sup>['.number_format_i18n($link_number).']</sup>', $content);
			if ($new_link) {
				if(preg_match('/<img(.+?)src=[\"\'](.+?)[\"\'](.*?)>/',$link_text)) {
					$links_text .= '<p style="margin: 2px 0;">['.number_format_i18n($link_number).'] '.__('Image', 'wp-print').': <b><span dir="ltr">'.$link_url.'</span></b></p>';
				} else {
					$links_text .= '<p style="margin: 2px 0;">['.number_format_i18n($link_number).'] '.$link_text.': <b><span dir="ltr">'.$link_url.'</span></b></p>';
				}
			}
		}
	}
	if($display) {
		echo $content;
	} else {
		return $content;
	}
}


### Function: Print Comments
function print_comments_number() {
	global $post;
	$comment_text = '';
	$comment_status = $post->comment_status;
	if($comment_status == 'open') {
		$num_comments = get_comments_number();
		if($num_comments == 0) {
			$comment_text = __('No Comments', 'wp-print');
		} else {
			$comment_text = sprintf(__ngettext('%s Comment', '%s Comments', $num_comments, 'wp-print'), number_format_i18n($num_comments));
		}
	} else {
		$comment_text = __('Comments Disabled', 'wp-print');
	}
	if(!empty($post->post_password) && stripslashes($_COOKIE['wp-postpass_'.COOKIEHASH]) != $post->post_password) {
		_e('Comments Hidden', 'wp-print');
	} else {
		echo $comment_text;
	}
}


### Function: Print Links
function print_links($text_links = '') {
	global $links_text;
	if(empty($text_links)) {
		$text_links = __('URLs in this post:', 'wp-print');
	}
	if(!empty($links_text)) { 
		echo $text_links.$links_text; 
	}
}


### Function: Load WP-Print
add_action('template_redirect', 'wp_print', 5);
function wp_print() {
	if(intval(get_query_var('print')) == 1 || intval(get_query_var('printpage')) == 1) {
		include(WP_PLUGIN_DIR.'/wp-print/print.php');
		exit;
	}
}


### Function: Add Print Comments Template
function print_template_comments($file = '') {
	if(file_exists(TEMPLATEPATH.'/print-comments.php')) {
		$file = TEMPLATEPATH.'/print-comments.php';
	} else {
		$file = WP_PLUGIN_DIR.'/wp-print/print-comments.php';
	}
	return $file;
}


### Function: Print Page Title
function print_pagetitle($page_title) {
	$page_title .= ' &raquo; '.__('Print', 'wp-print');
	return $page_title;
}


### Function: Can Print?
function print_can($type) {
	$print_options = get_option('print_options');
	return intval($print_options[$type]);
}


### Function: Remove Image From Text
function remove_image($content) {
	$content= preg_replace('/<img(.+?)src=[\"\'](.+?)[\"\'](.*?)>/', '',$content);
	return $content;
}


### Function: Remove Video From Text
function remove_video($content) {
	$content= preg_replace('/<object[^>]*?>.*?<\/object>/', '',$content);
	$content= preg_replace('/<embed[^>]*?>.*?<\/embed>/', '',$content);
	return $content;
}


### Function: Replace One Time Only
function str_replace_one($search, $replace, $content){
	if ($pos = strpos($content, $search)) {
		return substr($content, 0, $pos).$replace.substr($content, $pos+strlen($search));
	} else {
		return $content;
	}
}


### Function: Print Options
add_action('activate_wp-print/wp-print.php', 'print_init');
function print_init() {
	print_textdomain();
	// Add Options
	$print_options = array();
	$print_options['post_text'] = __('Print This Post', 'wp-print');
	$print_options['page_text'] = __('Print This Page', 'wp-print');
	$print_options['print_icon'] = 'print.gif';
	$print_options['print_style'] = 1;
	$print_options['print_html'] = '<a href="%PRINT_URL%" rel="nofollow" title="%PRINT_TEXT%">%PRINT_TEXT%</a>';
	$print_options['comments'] = 0;
	$print_options['links'] = 1;
	$print_options['images'] = 1;
	$print_options['videos'] = 0;
	$print_options['disclaimer'] = sprintf(__('Copyright &copy; %s %s. All rights reserved.', 'wp-print'), date('Y'), get_option('blogname'));
	add_option('print_options', $print_options, 'Print Options');
}
?>
