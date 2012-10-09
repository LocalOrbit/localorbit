<?php
/*
Plugin Name: WP-EMail
Plugin URI: http://lesterchan.net/portfolio/programming/php/
Description: Allows people to recommand/send your WordPress blog's post/page to a friend.
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


### Define: Show Email Remarks In Logs?
define('EMAIL_SHOW_REMARKS', true);


### Load WP-Config File If This File Is Called Directly
if (!function_exists('add_action')) {
	$wp_root = '../../..';
	if (file_exists($wp_root.'/wp-load.php')) {
		require_once($wp_root.'/wp-load.php');
	} else {
		require_once($wp_root.'/wp-config.php');
	}
}


### Create Text Domain For Translations
add_action('init', 'email_textdomain');
function email_textdomain() {
	load_plugin_textdomain('wp-email', false, 'wp-email');
}


### E-Mail Table Name
global $wpdb;
$wpdb->email = $wpdb->prefix.'email';


### Function: E-Mail Administration Menu
add_action('admin_menu', 'email_menu');
function email_menu() {
	if (function_exists('add_menu_page')) {
		add_menu_page(__('E-Mail', 'wp-email'), __('E-Mail', 'wp-email'), 'manage_email', 'wp-email/email-manager.php', '', plugins_url('wp-email/images/email_famfamfam.png'));
	}
	if (function_exists('add_submenu_page')) {
		add_submenu_page('wp-email/email-manager.php', __('Manage E-Mail', 'wp-email'), __('Manage E-Mail', 'wp-email'), 'manage_email', 'wp-email/email-manager.php');
		add_submenu_page('wp-email/email-manager.php', __('E-Mail Options', 'wp-email'), __('E-Mail Options', 'wp-email'),  'manage_email', 'wp-email/email-options.php');
		add_submenu_page('wp-email/email-manager.php', __('Uninstall WP-EMail', 'wp-email'), __('Uninstall WP-EMail', 'wp-email'),  'manage_email', 'wp-email/email-uninstall.php');
	}
}


### Function: E-Mail htaccess ReWrite Rules
add_filter('generate_rewrite_rules', 'email_rewrite');
function email_rewrite($wp_rewrite) {
	$email_link = get_permalink();
	$page_uris = $wp_rewrite->page_uri_index();
	$uris = $page_uris[0];
	if(substr($email_link, -1, 1) != '/' && substr($wp_rewrite->permalink_structure, -1, 1) != '/') {
		$email_link_text = '/email';
		$email_popup_text = '/emailpopup';
	} else {
		$email_link_text = 'email';
		$email_popup_text = 'emailpopup';
	}
	// WP-EMail Standalone Post Rules
	$rewrite_rules = $wp_rewrite->generate_rewrite_rule($wp_rewrite->permalink_structure.$email_link_text, EP_PERMALINK);
	$rewrite_rules = array_slice($rewrite_rules, 5, 1);
	$r_rule = array_keys($rewrite_rules);
	$r_rule = array_shift($r_rule);
	$r_rule = str_replace('/trackback', '', $r_rule);
	$r_link = array_values($rewrite_rules);
	$r_link = array_shift($r_link);
	$r_link = str_replace('tb=1', 'email=1', $r_link);
	$wp_rewrite->rules = array_merge(array($r_rule => $r_link), $wp_rewrite->rules);
	// WP-Email Standalone Page Rules	
	if(is_array($uris)) {
		$email_page_rules = array();
		foreach ($uris as $uri => $pagename) {			
			$wp_rewrite->add_rewrite_tag('%pagename%', "($uri)", 'pagename=');
			$rewrite_rules = $wp_rewrite->generate_rewrite_rules($wp_rewrite->get_page_permastruct().'/emailpage', EP_PAGES);
			$rewrite_rules = array_slice($rewrite_rules, 5, 1);
			$r_rule = array_keys($rewrite_rules);
			$r_rule = array_shift($r_rule);
			$r_rule = str_replace('/trackback', '', $r_rule);
			$r_link = array_values($rewrite_rules);
			$r_link = array_shift($r_link);
			$r_link = str_replace('tb=1', 'email=1', $r_link);
			$email_page_rules = array_merge($email_page_rules, array($r_rule => $r_link));
		}
		$wp_rewrite->rules = array_merge($email_page_rules, $wp_rewrite->rules);
	}

	// WP-EMail Popup Post Rules
	$rewrite_rules = $wp_rewrite->generate_rewrite_rule($wp_rewrite->permalink_structure.$email_popup_text, EP_PERMALINK);
	$rewrite_rules = array_slice($rewrite_rules, 5, 1);
	$r_rule = array_keys($rewrite_rules);
	$r_rule = array_shift($r_rule);
	$r_rule = str_replace('/trackback', '', $r_rule);
	$r_link = array_values($rewrite_rules);
	$r_link = array_shift($r_link);
	$r_link = str_replace('tb=1', 'emailpopup=1', $r_link);
	$wp_rewrite->rules = array_merge(array($r_rule => $r_link), $wp_rewrite->rules);
	if(is_array($uris)) {
		$email_page_rules = array();
		foreach ($uris as $uri => $pagename) {			
			$wp_rewrite->add_rewrite_tag('%pagename%', "($uri)", 'pagename=');
			$rewrite_rules = $wp_rewrite->generate_rewrite_rules($wp_rewrite->get_page_permastruct().'/emailpopuppage', EP_PAGES);
			$rewrite_rules = array_slice($rewrite_rules, 5, 1);
			$r_rule = array_keys($rewrite_rules);
			$r_rule = array_shift($r_rule);
			$r_rule = str_replace('/trackback', '', $r_rule);
			$r_link = array_values($rewrite_rules);
			$r_link = array_shift($r_link);
			$r_link = str_replace('tb=1', 'emailpopup=1', $r_link);
			$email_page_rules = array_merge($email_page_rules, array($r_rule => $r_link));
		}
		$wp_rewrite->rules = array_merge($email_page_rules, $wp_rewrite->rules);
	}
}


### Function: E-Mail Public Variables
add_filter('query_vars', 'email_variables');
function email_variables($public_query_vars) {
	$public_query_vars[] = 'email';
	$public_query_vars[] = 'emailpopup';
	return $public_query_vars;
}


### Function: E-Mail Javascript
add_action('wp_head', 'email_js');
function email_js() {
	global $text_direction;
	$email_max = intval(get_option('email_multiple'));
	echo "\n".'<!-- Start Of Script Generated By WP-EMail 2.40 -->'."\n";
	echo '<script type="text/javascript">'."\n";
	echo '/* <![CDATA[ */'."\n";
	echo "\t".'var email_ajax_url = \''.plugins_url('wp-email/wp-email.php')."';\n";
	echo "\t".'var email_max_allowed = \''.$email_max.'\';'."\n";
	echo "\t".'var email_verify = \''.$_SESSION['email_verify'].'\';'."\n";
	echo "\t".'var email_text_error = \''.js_escape(__('The Following Error Occurs:', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_name_invalid = \''.js_escape(__('- Your Name is empty/invalid', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_email_invalid = \''.js_escape(__('- Your Email is empty/invalid', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_remarks_invalid = \''.js_escape(__('- Your Remarks is invalid', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_friend_names_empty = \''.js_escape(__('- Friend Name(s) is empty', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_friend_name_invalid = \''.js_escape(__('- Friend Name is empty/invalid:', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_max_friend_names_allowed = \''.js_escape(sprintf(__ngettext('- Maximum %s Friend Name allowed', '- Maximum %s Friend Names allowed', $email_max, 'wp-email'), number_format_i18n($email_max))).'\';'."\n";
	echo "\t".'var email_text_friend_emails_empty = \''.js_escape(__('- Friend Email(s) is empty', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_friend_email_invalid = \''.js_escape(__('- Friend Email is invalid:', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_max_friend_emails_allowed = \''.js_escape(sprintf(__ngettext('- Maximum %s Friend Email allowed', '- Maximum %s Friend Emails allowed', $email_max, 'wp-email'), number_format_i18n($email_max))).'\';'."\n";
	echo "\t".'var email_text_friends_tally = \''.js_escape(__('- Friend Name(s) count does not tally with Friend Email(s) count', 'wp-email')).'\';'."\n";
	echo "\t".'var email_text_image_verify_empty = \''.js_escape(__('- Image Verification is empty', 'wp-email')).'\';'."\n";
	echo '/* ]]> */'."\n";
	echo '</script>'."\n";
	wp_register_script('wp-email', plugins_url('wp-email/email-js-packed.js'), false, '2.40');
	wp_print_scripts(array('sack', 'wp-email'));
	if(@file_exists(TEMPLATEPATH.'/email-css.css')) {
		wp_register_style('wp-email', get_stylesheet_directory_uri().'/email-css.css', false, '2.40', 'all');
	} else {
		wp_register_style('wp-email', plugins_url('wp-email/email-css.css'), false, '2.40', 'all');
	}	
	if('rtl' == $text_direction) {
		if(@file_exists(TEMPLATEPATH.'/email-css-rtl.css')) {
			wp_register_style('wp-email-rtl', get_stylesheet_directory_uri().'/email-css-rtl.css', false, '2.40', 'all');
		} else {
			wp_register_style('wp-email-rtl', plugins_url('wp-email/email-css-rtl.css'), false, '2.40', 'all');
		}
	}
	wp_print_styles(array('wp-email', 'wp-email-rtl'));
	echo '<!-- End Of Script Generated By WP-EMail 2.40 -->'."\n";
}


### Function: Displays E-Mail Header In WP-Admin
add_action('admin_head-wp-email/email-manager.php', 'email_header_admin');
add_action('admin_head-wp-email/email-options.php', 'email_header_admin');
add_action('admin_head-wp-email/email-uninstall.php', 'email_header_admin');
function email_header_admin() {
	wp_register_style('wp-email-admin', plugins_url('wp-email/email-admin-css.css'), false, '2.40', 'all');
	echo "\n".'<!-- Start Of Script Generated By WP-EMail 1.40 -->'."\n";
	wp_print_styles('wp-email-admin');
	echo '<!-- End Of Script Generated By WP-EMail 1.40 -->'."\n";
}


### Function: Display E-Mail Link
function email_link($email_post_text = '', $email_page_text = '', $echo = true) {
	global $id;
	$output = '';
	$using_permalink = get_option('permalink_structure');
	$email_options = get_option('email_options');
	$email_style = intval($email_options['email_style']);
	$email_type = intval($email_options['email_type']);
	if(empty($email_post_text)) {
		$email_text = stripslashes($email_options['post_text']);
	} else {
		$email_text = $email_post_text;
	}
	$email_icon = plugins_url('wp-email/images/'.$email_options['email_icon']);
	$email_link = get_permalink();
	$email_html = stripslashes($email_options['email_html']);
	$onclick = '';
	// Fix For Static Page
	if(get_option('show_on_front') == 'page' && is_page()) {
		if(intval(get_option('page_on_front')) > 0) {
			$email_link = _get_page_link();
		}
	}
	switch($email_type) {
		// E-Mail Standalone Page
		case 1:
			if(!empty($using_permalink)) {
				if(substr($email_link, -1, 1) != '/') {
					$email_link= $email_link.'/';
				}
				if(is_page()) {
					if(empty($email_page_text)) {
						$email_text = stripslashes($email_options['page_text']);
					} else {
						$email_text = $email_page_text;
					}
					$email_link = $email_link.'emailpage/';
				} else {
					$email_link = $email_link.'email/';
				}
			} else {
				if(is_page()) {
					if(empty($email_page_text)) {
						$email_text = stripslashes($email_options['page_text']);
					} else {
						$email_text = $email_page_text;
					}
				}
				$email_link = $email_link.'&amp;email=1';
			}
			break;
		// E-Mail Popup
		case 2:
			if(!empty($using_permalink)) {
				if(substr($email_link, -1, 1) != '/') {
					$email_link= $email_link.'/';
				}
				if(is_page()) {
					if(empty($email_page_text)) {
						$email_text = stripslashes($email_options['page_text']);
					} else {
						$email_text = $email_page_text;
					}
					$email_link = $email_link.'emailpopuppage/';
				} else {
					$email_link = $email_link.'emailpopup/';
				}
			} else {
				if(is_page()) {
					if(empty($email_page_text)) {
						$email_text = stripslashes($email_options['page_text']);
					} else {
						$email_text = $email_page_text;
					}
				}
				$email_link = $email_link.'&amp;emailpopup=1';
			}
			$onclick = ' onclick="email_popup(this.href); return false;" ';
			break;
	}
	unset($email_options);
	switch($email_style) {
		// Icon + Text Link
		case 1:
			$output = '<a href="'.$email_link.'"'.$onclick.' title="'.$email_text.'" rel="nofollow"><img class="WP-EmailIcon" src="'.$email_icon.'" alt="'.$email_text.'" title="'.$email_text.'" style="border: 0px;" /></a>&nbsp;<a href="'.$email_link.'"'.$onclick.' title="'.$email_text.'" rel="nofollow">'.$email_text.'</a>';
			break;
		// Icon Only
		case 2:
			$output = '<a href="'.$email_link.'"'.$onclick.' title="'.$email_text.'" rel="nofollow"><img class="WP-EmailIcon" src="'.$email_icon.'" alt="'.$email_text.'" title="'.$email_text.'" style="border: 0px;" /></a>';
			break;
		// Text Link Only
		case 3:
			$output = '<a href="'.$email_link.'"'.$onclick.' title="'.$email_text.'" rel="nofollow">'.$email_text.'</a>';
			break;
		case 4:
			$email_html = str_replace("%EMAIL_URL%", $email_link, $email_html);
			$email_html = str_replace("%EMAIL_POPUP%", $onclick, $email_html);
			$email_html = str_replace("%EMAIL_TEXT%", $email_text, $email_html);
			$email_html = str_replace("%EMAIL_ICON_URL%", $email_icon, $email_html);
			$output = $email_html;
			break;
	}
	if($echo) {
		echo $output."\n";
	} else {
		return $output;
	}
}


### Function: Short Code For Inserting Email Links Into Posts/Pages
add_shortcode('email_link', 'email_link_shortcode');
function email_link_shortcode($atts) {
	if(!is_feed()) {
		return email_link('', '', false);
	} else {
		return __('Note: There is an email link embedded within this post, please visit this post to email it.', 'wp-email');
	}
}


### Function: Snippet Words
if(!function_exists('snippet_words')) {
	function snippet_words($text, $length = 0) {
		$words = split(' ', $text); 
		return join(" ",array_slice($words, 0, $length)).'...';
	}
}


### Function: Snippet Text
if(!function_exists('snippet_text')) {
	function snippet_text($text, $length = 0) {
		if (defined('MB_OVERLOAD_STRING')) {
		  $text = @html_entity_decode($text, ENT_QUOTES, get_option('blog_charset'));
		 	if (mb_strlen($text) > $length) {
				return htmlentities(mb_substr($text,0,$length), ENT_COMPAT, get_option('blog_charset')).'...';
		 	} else {
				return htmlentities($text, ENT_COMPAT, get_option('blog_charset'));
		 	}
		} else {
			$text = @html_entity_decode($text, ENT_QUOTES, get_option('blog_charset'));
		 	if (strlen($text) > $length) {
				return htmlentities(substr($text,0,$length), ENT_COMPAT, get_option('blog_charset')).'...';
		 	} else {
				return htmlentities($text, ENT_COMPAT, get_option('blog_charset'));
		 	}
		}
	}
}


### Function: Add E-Mail Filters
function email_addfilters() {
	global $emailfilters_count;
	if(get_option('k2version') === false) {
		$loop_count = 0;
	} else {
		$loop_count = 1;
	}
	if(intval($emailfilters_count) == $loop_count) {
		add_filter('the_title', 'email_title');
		add_filter('the_content', 'email_form');
	}
	$emailfilters_count++;
}


### Function: Remove E-Mail Filters
function email_removefilters() {
	remove_filter('the_title', 'email_title');
	remove_filter('the_content', 'email_form');
}


### Function: E-Mail Page Title
function email_pagetitle($page_title) {
	$page_title .= ' &raquo; '.__('E-Mail', 'wp-email');
	return $page_title;
}


### Function: E-Mail Post ID
if(!function_exists('get_the_id')) {
	function get_the_id() {
		global $id;
		return $id;
	}
}


### Function: Get E-Mail Title
function email_get_title() {
	global $post;
	$post_title = $post->post_title;
	if(!empty($post->post_password)) {
		$post_title = sprintf(__('Protected: %s', 'wp-email'), $post_title);
	} elseif($post->post_status == 'private') {
		$post_title = sprintf(__('Private: %s', 'wp-email'), $post_title);
	}
	return $post_title;
}


### Function: E-Mail Title
function email_title($page_title) {
	if(in_the_loop()) {
		$post_title = email_get_title();
		$post_author = the_author('', false);			
		$post_date = get_the_time(get_option('date_format').' ('.get_option('time_format').')', '', '', false);
		$post_category = email_category(__(',', 'wp-email').' ');
		$post_category_alt = strip_tags($post_category);
		$template_title = stripslashes(get_option('email_template_title'));
		$template_title = str_replace("%EMAIL_POST_TITLE%", $post_title, $template_title);
		$template_title = str_replace("%EMAIL_POST_AUTHOR%", $post_author, $template_title);
		$template_title = str_replace("%EMAIL_POST_DATE%", $post_date, $template_title);
		$template_title = str_replace("%EMAIL_POST_CATEGORY%", $post_category, $template_title);
		$template_title = str_replace("%EMAIL_BLOG_NAME%", get_bloginfo('name'), $template_title);
		$template_title = str_replace("%EMAIL_BLOG_URL%", get_bloginfo('url'), $template_title);
		$template_title = str_replace("%EMAIL_PERMALINK%", get_permalink(), $template_title);
		return $template_title;
	} else {
		return $page_title;
	}
}


### Function: E-Mail Category
function email_category($separator = ', ', $parents='') {
	return get_the_category_list($separator, $parents);
}


### Function: E-Mail Content
function email_content() {
	$content = get_email_content();
	$email_snippet = intval(get_option('email_snippet'));
	if($email_snippet > 0) {
		return snippet_words($content , $email_snippet);
	} else {
		return $content;
	}
}


### Function: E-Mail Alternate Content
function email_content_alt() {
	remove_filter('the_content', 'wptexturize');
	$content = get_email_content();
	$content = clean_pre($content);
	$content = strip_tags($content);
	$email_snippet = intval(get_option('email_snippet'));
	if($email_snippet > 0) {
		return snippet_words($content , $email_snippet);
	} else {
		return $content;
	}
}


### Function: E-Mail Get The Content
function get_email_content() {
	global $pages, $multipage, $numpages, $post;
	if (!empty($post->post_password)) {
		if (stripslashes($_COOKIE['wp-postpass_'.COOKIEHASH]) != $post->post_password) {
			return __('Password Protected Post', 'wp-email');
		}
	}
	if($multipage) {
		for($page = 0; $page < $numpages; $page++) {
			$content .= $pages[$page];
		}
	} else {
		$content = $pages[0];
	}
	$content = html_entity_decode($content);
	$content = htmlspecialchars_decode($content);
	$content = apply_filters('the_content', $content);
	return $content;
}


### Function: Get IP Address
function get_email_ipaddress() {
	if (empty($_SERVER["HTTP_X_FORWARDED_FOR"])) {
		$ip_address = $_SERVER["REMOTE_ADDR"];
	} else {
		$ip_address = $_SERVER["HTTP_X_FORWARDED_FOR"];
	}
	if(strpos($ip_address, ',') !== false) {
		$ip_address = explode(',', $ip_address);
		$ip_address = $ip_address[0];
	}
	return $ip_address;
}


### Function: Check For Password Protected Post
function not_password_protected() {
	global $post;
	if (!empty($post->post_password)) {
		if ($_COOKIE['wp-postpass_'.COOKIEHASH] != $post->post_password) {
			return false;
		}
	}
	return true;
}


### Function: There Are Still Many PHP 4.x Users
if(!function_exists('htmlspecialchars_decode')) {
	function htmlspecialchars_decode($string, $style = ENT_COMPAT) {
		$translation = array_flip(get_html_translation_table(HTML_SPECIALCHARS,$style));
		if($style === ENT_QUOTES) {
			$translation['&#039;'] = '\'';
		}
		return strtr($string, $translation);
	}
}


### Function: Check Vaild Name (AlphaNumeric With Spaces Allowed Only)
if(!function_exists('is_valid_name')) {
	function is_valid_name($name) {
	   $regex = '/[(\*\(\)\[\]\+\,\/\?\:\;\'\"\`\~\\#\$\%\^\&\<\>)+]/';
	   return !(preg_match($regex, $name));
	}
}


### Function: Check Valid E-Mail Address
if(!function_exists('is_valid_email')) {
	function is_valid_email($email) {
	   $regex = '/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/';
	   return (preg_match($regex, $email));
	}
}


### Function: Check Valid Remarks (Ensure No E-Mail Injections)
if(!function_exists('is_valid_remarks')) {
	function is_valid_remarks($content) { 
		$injection_strings = array('apparently-to', 'cc', 'bcc', 'boundary', 'charset', 'content-disposition', 'content-type', 'content-transfer-encoding', 'errors-to', 'in-reply-to', 'message-id', 'mime-version', 'multipart/mixed', 'multipart/alternative', 'multipart/related', 'reply-to', 'x-mailer', 'x-sender', 'x-uidl'); 
		foreach ($injection_strings as $spam) { 
			$check = strpos(strtolower($content), $spam); 
			if ($check !== false) {
				return false;
			}
		}
		return true;
	}
}


### Function: Check For E-Mail Spamming
function not_spamming() {
	global $wpdb;
	$current_time = current_time('timestamp');
	$email_ip = get_email_ipaddress();
	$email_host = @gethostbyaddr($email_ip);
	$email_status = __('Success', 'wp-email');
	$last_emailed = $wpdb->get_var("SELECT email_timestamp FROM $wpdb->email WHERE email_ip = '$email_ip' AND email_host = '$email_host' AND email_status = '$email_status' ORDER BY email_timestamp DESC LIMIT 1");
	$email_allow_interval = intval(get_option('email_interval'))*60;
	if(($current_time-$last_emailed) < $email_allow_interval) {
		return false;
	} else {
		return true;
	}
}


### Function: E-Mail Flood Interval
function email_flood_interval($echo = true) {
	$email_allow_interval_min = intval(get_option('email_interval'));
	if($echo) {
		echo $email_allow_interval_min;
	} else {
		return $email_allow_interval_min;
	}
}


### Function: E-Mail Form Header
function email_form_header($echo = true, $temp_id) {
	global $id;
	if(intval($temp_id) > 0) {
		$id = $temp_id;
	}
	$using_permalink = get_option('permalink_structure');
	$permalink = get_permalink();
	// Fix For Static Page
	if(get_option('show_on_front') == 'page' && is_page()) {
		if(intval(get_option('page_on_front')) > 0) {
			$permalink = _get_page_link();
		}
	}
	$output = '';
	if(!empty($using_permalink)) {
		if(is_page()) {
			$output .= '<form action="'.$permalink.'emailpage/" method="post">'."\n";
			$output .= '<p style="display: none;"><input type="hidden" id="page_id" name="page_id" value="'.$id.'" /></p>'."\n";
		} else {
			$output = '<form action="'.$permalink.'email/" method="post">'."\n";
			$output .= '<p style="display: none;"><input type="hidden" id="p" name="p" value="'.$id.'" /></p>'."\n";
		}
	} else {
		if(is_page()) {
			$output .= '<form action="'.$permalink.'&amp;email=1" method="post">'."\n";
			$output .= '<p style="display: none;"><input type="hidden" id="page_id" name="page_id" value="'.$id.'" /></p>'."\n";
		} else {
			$output .= '<form action="'.$permalink.'&amp;email=1" method="post">'."\n";
			$output .= '<p style="display: none;"><input type="hidden" id="p" name="p" value="'.$id.'" /></p>'."\n";
		}
	}
	$output .= '<p style="display: none;"><input type="hidden" id="popup" name="popup" value="0" /></p>'."\n";
	if($echo) {
		echo $output;
	} else {
		return $output;
	}
}


### Function: E-Mail Form Header For Popup
function email_popup_form_header($echo = true, $temp_id) {
	global $post;
	$id = intval($post->ID);
	if(intval($temp_id) > 0) {
		$id = $temp_id;
	}
	$using_permalink = get_option('permalink_structure');
	$permalink = get_permalink();
	// Fix For Static Page
	if(get_option('show_on_front') == 'page' && is_page()) {
		if(intval(get_option('page_on_front')) > 0) {
			$permalink = _get_page_link();
		}
	}
	$output = '';
	if(!empty($using_permalink)) {
		if(is_page()) {
			$output .= '<form action="'.$permalink.'emailpopuppage/" method="post">'."\n";
			$output .= '<p style="display: none;"><input type="hidden" id="page_id" name="page_id" value="'.$id.'" /></p>'."\n";
		} else {
			$output = '<form action="'.$permalink.'emailpopup/" method="post">'."\n";
			$output .= '<p style="display: none;"><input type="hidden" id="p" name="p" value="'.$id.'" /></p>'."\n";
		}
	} else {
		if(is_page()) {
			$output .= '<form action="'.$permalink.'&amp;emailpopup=1" method="post">'."\n";
			$output .= '<p style="display: none;"><input type="hidden" id="page_id" name="page_id" value="'.$id.'" /></p>'."\n";
		} else {
			$output .= '<form action="'.$permalink.'&amp;emailpopup=1" method="post">'."\n";
			$output .= '<p style="display: none;"><input type="hidden" id="p" name="p" value="'.$id.'" /></p>'."\n";
		}
	}
	$output .= '<p style="display: none;"><input type="hidden" id="popup" name="popup" value="1" /></p>'."\n";
	if($echo) {
		echo $output;
	} else {
		return $output;
	}
}


### Function: Multiple E-Mails
function email_multiple($echo = true) {
	$email_multiple = intval(get_option('email_multiple'));
	if($email_multiple > 1) {
		$output = '<br /><em>'.sprintf(__ngettext('Separate multiple entries with a comma. Maximum %s entry.', 'Separate multiple entries with a comma. Maximum %s entries.', $email_multiple, 'wp-email'), number_format_i18n($email_multiple)).'</em>';
		if($echo) {
			echo $outut;
		} else {
			return $output;
		}
	}
}


### Function: Get EMail Total Sent
if(!function_exists('get_emails')) {
	function get_emails($echo = true) {
		global $wpdb;
		$totalemails = $wpdb->get_var("SELECT COUNT(email_id) FROM $wpdb->email");
		if($echo) {
			echo number_format_i18n($totalemails);
		} else {
			return number_format_i18n($totalemails);
		}
	}
}


### Function: Get EMail Total Sent Success
if(!function_exists('get_emails_success')) {
	function get_emails_success($echo = true) {
		global $wpdb; 
		$totalemails_success = $wpdb->get_var("SELECT COUNT(email_id) FROM $wpdb->email WHERE email_status = '".__('Success', 'wp-email')."'");
		if($echo) {
			echo number_format_i18n($totalemails_success);
		} else {
			return number_format_i18n($totalemails_success);
		}
	}
}


### Function: Get EMail Total Sent Failed
if(!function_exists('get_emails_failed')) {
	function get_emails_failed($echo = true) {
		global $wpdb; 
		$totalemails_failed = $wpdb->get_var("SELECT COUNT(email_id) FROM $wpdb->email WHERE email_status = '".__('Failed', 'wp-email')."'");
		if($echo) {
			echo number_format_i18n($totalemails_failed);
		} else {
			return number_format_i18n($totalemails_failed);
		}
	}
}


### Function: Get Most E-Mailed
if(!function_exists('get_mostemailed')) {
	function get_mostemailed($mode = '', $limit = 10, $chars = 0, $echo = true) {
		global $wpdb, $post;
		$temp_post = $post;
		$where = '';
		$temp = '';
		if(!empty($mode) && $mode != 'both') {
			$where = "post_type = '$mode'";
		} else {
			$where = '1=1';
		}
		$mostemailed= $wpdb->get_results("SELECT $wpdb->posts.*, COUNT($wpdb->email.email_postid) AS email_total FROM $wpdb->email LEFT JOIN $wpdb->posts ON $wpdb->email.email_postid = $wpdb->posts.ID WHERE post_date < '".current_time('mysql')."' AND $where AND post_password = '' AND post_status = 'publish' GROUP BY $wpdb->email.email_postid ORDER  BY email_total DESC LIMIT $limit");
		if($mostemailed) {
			if($chars > 0) {
				foreach ($mostemailed as $post) {
						$post_title = get_the_title();
						$email_total = intval($post->email_total);
						$temp .= "<li><a href=\"".get_permalink()."\">".snippet_text($post_title, $chars)."</a> - ".sprintf(__ngettext('%s email', '%s emails', $email_total, 'wp-email'), number_format_i18n($email_total))."</li>\n";
				}
			} else {
				foreach ($mostemailed as $post) {
						$post_title = get_the_title();
						$email_total = intval($post->email_total);
						$temp .= "<li><a href=\"".get_permalink()."\">$post_title</a> - ".sprintf(__ngettext('%s email', '%s emails', $email_total, 'wp-email'), number_format_i18n($email_total))."</li>\n";
				}
			}
		} else {
			$temp = '<li>'.__('N/A', 'wp-email').'</li>'."\n";
		}
		$post = $temp_post;
		if($echo) {
			echo $temp;
		} else {
			return $temp;
		}
	}
}


### Function: Load WP-EMail
add_action('template_redirect', 'wp_email', 5);
function wp_email() {
	if(intval(get_query_var('email')) == 1) {
		include(WP_PLUGIN_DIR.'/wp-email/email-standalone.php');
		exit;
	} elseif(intval(get_query_var('emailpopup')) == 1) {
		include(WP_PLUGIN_DIR.'/wp-email/email-popup.php');
		exit;
	}
}


### Function: Process E-Mail Form
process_email_form();
function process_email_form() {
	global $wpdb, $post, $text_direction;
	// If User Click On Mail
	if(!empty($_POST['wp-email'])) {
		#@session_start();
		email_textdomain();
		header('Content-Type: text/html; charset='.get_option('blog_charset').'');
		// POST Variables
		$yourname = strip_tags(stripslashes(trim($_POST['yourname'])));
		$youremail = strip_tags(stripslashes(trim($_POST['youremail'])));
		$yourremarks = strip_tags(stripslashes(trim($_POST['yourremarks'])));
		$friendname = strip_tags(stripslashes(trim($_POST['friendname'])));
		$friendemail = strip_tags(stripslashes(trim($_POST['friendemail'])));
		$email_popup = intval($_POST['popup']);
		$imageverify = $_POST['imageverify'];
		$p = intval($_POST['p']);
		$page_id = intval($_POST['page_id']);
		// Get Post Information
		if($p > 0) {
			$query_post = 'p='.$p;
			$id = $p;
		} else {
			$query_post = 'page_id='.$page_id;
			$id = $page_id;
		}
		query_posts($query_post);
		if(have_posts()) {
			while(have_posts()) {
				the_post();
				$post_title = email_get_title();
				$post_author = get_the_author();
				$post_date = get_the_time(get_option('date_format').' ('.get_option('time_format').')', '', '', false);
				$post_category = email_category(__(',', 'wp-email').' ');			
				$post_category_alt = strip_tags($post_category);
				$post_excerpt = get_the_excerpt();
				$post_content = email_content();
				$post_content_alt = email_content_alt();
			}
		}
		// Error
		$error = '';
		$error_field = array('yourname' => $yourname, 'youremail' => $youremail, 'yourremarks' => $yourremarks, 'friendname' => $friendname, 'friendemail' => $friendemail, 'id' => $id);
		// Get Options
		$email_fields = get_option('email_fields');
		$email_image_verify = intval(get_option('email_imageverify'));		
		$email_smtp = get_option('email_smtp');		
		// Multiple Names/Emails
		$friends = array();
		$friendname_count = 0;
		$friendemail_count = 0;
		$multiple_names = explode(',', $friendname);
		$multiple_emails = explode(',', $friendemail);
		$multiple_max = intval(get_option('email_multiple'));
		if($multiple_max == 0) { $multiple_max = 1; }
		// Checking Your Name Field For Errors
		if(intval($email_fields['yourname']) == 1) {
			if(empty($yourname)) {
				$error .= '<br /><strong>&raquo;</strong> '.__('Your Name is empty', 'wp-email');
			}
			if(!is_valid_name($yourname)) {
				$error .= '<br /><strong>&raquo;</strong> '.__('Your Name is invalid', 'wp-email');
			}
		}
		// Checking Your E-Mail Field For Errors
		if(intval($email_fields['youremail']) == 1) {
			if(empty($youremail)) {
				$error .= '<br /><strong>&raquo;</strong> '.__('Your Email is empty', 'wp-email');
			}
			if(!is_valid_email($youremail)) {
				$error .= '<br /><strong>&raquo;</strong> '.__('Your Email is invalid', 'wp-email');
			}
		}
		// Checking Your Remarks Field For Errors
		if(intval($email_fields['yourremarks']) == 1) {
			if(!is_valid_remarks($yourremarks)) {
				$error .= '<br /><strong>&raquo;</strong> '.__('Your Remarks is invalid', 'wp-email');
			}
		}
		// Checking Friend's Name Field For Errors
		if(intval($email_fields['friendname']) == 1) {
			if(empty($friendname)) {
				$error .= '<br /><strong>&raquo;</strong> '.__('Friend Name(s) is empty', 'wp-email');
			} else {
				if($multiple_names) {
					foreach($multiple_names as $multiple_name) {
						$multiple_name = trim($multiple_name);
						if(empty($multiple_name)) {
							$error .= '<br /><strong>&raquo;</strong> '.sprintf(__('Friend Name is empty: %s', 'wp-email'), $multiple_name);
						} elseif(!is_valid_name($multiple_name)) {
							$error .= '<br /><strong>&raquo;</strong> '.sprintf(__('Friend Name is invalid: %s', 'wp-email'), $multiple_name);
						} else {
							$friends[$friendname_count]['name'] = $multiple_name;
							$friendname_count++;
						}
						if($friendname_count > $multiple_max) {
							break;
						}
					}
				}
			}
		}
		// Checking Friend's E-Mail Field For Errors
		if(empty($friendemail)) {
			$error .= '<br /><strong>&raquo;</strong> '.__('Friend Email(s) is empty', 'wp-email');
		} else {
			if($multiple_emails) {
				foreach($multiple_emails as $multiple_email) {
					$multiple_email = trim($multiple_email);
					if(empty($multiple_email)) {
						$error .= '<br /><strong>&raquo;</strong> '.sprintf(__('Friend Email is empty: %s', 'wp-email'), $multiple_email);
					} elseif(!is_valid_email($multiple_email)) {
						$error .= '<br /><strong>&raquo;</strong> '.sprintf(__('Friend Email is invalid: %s', 'wp-email'), $multiple_email);
					} else {
						$friends[$friendemail_count]['email'] = $multiple_email;
						$friendemail_count++;
					}
					if($friendemail_count > $multiple_max) {
						break;
					}
				}
			}
		}
		// Checking If The Fields Exceed The Size Of Maximum Entries Allowed
		if(sizeof($friends) > $multiple_max) {
			$error .= '<br /><strong>&raquo;</strong> '.sprintf(__ngettext('Maximum %s Friend allowed', 'Maximum %s Friend(s) allowed', $multiple_max, 'wp-email'), number_format_i18n($multiple_max));
		}
		if(intval($email_fields['friendname']) == 1) {
			if($friendname_count != $friendemail_count) {
				$error .= '<br /><strong>&raquo;</strong> '.__('Friend Name(s) count does not tally with Friend Email(s) count', 'wp-email');
			}
		}
		// Check Whether We Enable Image Verification
		if($email_image_verify) {
			$imageverify = strtoupper($imageverify);
			if(empty($imageverify)) {
				$error .= '<br /><strong>&raquo;</strong> '.__('Image Verification is empty', 'wp-email');
			} else {
				if($_SESSION['email_verify'] != md5($imageverify)) {
					$error .= '<br /><strong>&raquo;</strong> '.__('Image Verification failed', 'wp-email');
				}
			}
		}
		// If There Is No Error, We Process The E-Mail
		if(empty($error) && not_spamming()) {
			// If Remarks Is Empty, Assign N/A
			if(empty($yourremarks)) { $yourremarks = __('N/A', 'wp-email'); }
			// Template For E-Mail Subject
			$template_email_subject = stripslashes(get_option('email_template_subject'));
			$template_email_subject = str_replace("%EMAIL_YOUR_NAME%", $yourname, $template_email_subject);
			$template_email_subject = str_replace("%EMAIL_YOUR_EMAIL%", $youremail, $template_email_subject);
			$template_email_subject = str_replace("%EMAIL_POST_TITLE%", $post_title, $template_email_subject);
			$template_email_subject = str_replace("%EMAIL_POST_AUTHOR%", $post_author, $template_email_subject);
			$template_email_subject = str_replace("%EMAIL_POST_DATE%", $post_date, $template_email_subject);
			$template_email_subject = str_replace("%EMAIL_POST_CATEGORY%", $post_category_alt, $template_email_subject);
			$template_email_subject = str_replace("%EMAIL_BLOG_NAME%", get_bloginfo('name'), $template_email_subject);
			$template_email_subject = str_replace("%EMAIL_BLOG_URL%", get_bloginfo('url'), $template_email_subject);
			$template_email_subject = str_replace("%EMAIL_PERMALINK%", get_permalink(), $template_email_subject);
			// Template For E-Mail Body
			$template_email_body = stripslashes(get_option('email_template_body'));
			$template_email_body = str_replace("%EMAIL_YOUR_NAME%", $yourname, $template_email_body);
			$template_email_body = str_replace("%EMAIL_YOUR_EMAIL%", $youremail, $template_email_body);
			$template_email_body = str_replace("%EMAIL_YOUR_REMARKS%", $yourremarks, $template_email_body);
			$template_email_body = str_replace("%EMAIL_FRIEND_NAME%", $friendname, $template_email_body);
			$template_email_body = str_replace("%EMAIL_FRIEND_EMAIL%", $friendemail, $template_email_body);
			$template_email_body = str_replace("%EMAIL_POST_TITLE%", $post_title, $template_email_body);
			$template_email_body = str_replace("%EMAIL_POST_AUTHOR%", $post_author, $template_email_body);
			$template_email_body = str_replace("%EMAIL_POST_DATE%", $post_date, $template_email_body);
			$template_email_body = str_replace("%EMAIL_POST_CATEGORY%", $post_category, $template_email_body);
			$template_email_body = str_replace("%EMAIL_POST_EXCERPT%", $post_excerpt, $template_email_body);
			$template_email_body = str_replace("%EMAIL_POST_CONTENT%", $post_content, $template_email_body);
			$template_email_body = str_replace("%EMAIL_BLOG_NAME%", get_bloginfo('name'), $template_email_body);
			$template_email_body = str_replace("%EMAIL_BLOG_URL%", get_bloginfo('url'), $template_email_body);
			$template_email_body = str_replace("%EMAIL_PERMALINK%", get_permalink(), $template_email_body);
			if('rtl' == $text_direction) {
				$template_email_body = "<div style=\"direction: rtl;\">$template_email_body</div>";
			}
			// Template For E-Mail Alternate Body
			$template_email_bodyalt = stripslashes(get_option('email_template_bodyalt'));
			$template_email_bodyalt = str_replace("%EMAIL_YOUR_NAME%", $yourname, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_YOUR_EMAIL%", $youremail, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_YOUR_REMARKS%", $yourremarks, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_FRIEND_NAME%", $friendname, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_FRIEND_EMAIL%", $friendemail, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_POST_TITLE%", $post_title, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_POST_AUTHOR%", $post_author, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_POST_DATE%", $post_date, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_POST_CATEGORY%", $post_category_alt, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_POST_EXCERPT%", $post_excerpt, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_POST_CONTENT%", $post_content_alt, $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_BLOG_NAME%", get_bloginfo('name'), $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_BLOG_URL%", get_bloginfo('url'), $template_email_bodyalt);
			$template_email_bodyalt = str_replace("%EMAIL_PERMALINK%", get_permalink(), $template_email_bodyalt);
			// PHP Mailer Variables
			if (!class_exists("phpmailer")) {
				require_once(ABSPATH.'wp-includes/class-phpmailer.php');
			}		
			$mail = new PHPMailer();
			$mail->From     = $youremail;
			$mail->FromName = $yourname;
			foreach($friends as $friend) {
				$mail->AddAddress($friend['email'], $friend['name']);
			}
			$mail->CharSet = get_bloginfo('charset');
			$mail->Username = $email_smtp['username']; 
			$mail->Password = $email_smtp['password'];
			$mail->Host     = $email_smtp['server'];
			$mail->Mailer   = get_option('email_mailer');
			if($mail->Mailer == 'smtp') {
				$mail->SMTPAuth = true;
			}
			$mail->ContentType =  get_option('email_contenttype');
			$mail->Subject = $template_email_subject;
			if(get_option('email_contenttype') == 'text/plain') {
				$mail->Body    = $template_email_bodyalt;
			} else {
				$mail->Body    = $template_email_body;
				$mail->AltBody = $template_email_bodyalt;
			}
			// Send The Mail if($mail->Send()) {
			if($mail->Send()) {
				$email_status = __('Success', 'wp-email');
				// Template For Sent Successfully
				$template_email_sentsuccess = stripslashes(get_option('email_template_sentsuccess'));
				$template_email_sentsuccess = str_replace("%EMAIL_FRIEND_NAME%", $friendname, $template_email_sentsuccess);
				$template_email_sentsuccess = str_replace("%EMAIL_FRIEND_EMAIL%", $friendemail, $template_email_sentsuccess);
				$template_email_sentsuccess = str_replace("%EMAIL_POST_TITLE%", $post_title, $template_email_sentsuccess);
				$template_email_sentsuccess = str_replace("%EMAIL_BLOG_NAME%", get_bloginfo('name'), $template_email_sentsuccess);
				$template_email_sentsuccess = str_replace("%EMAIL_BLOG_URL%", get_bloginfo('url'), $template_email_sentsuccess);
				$template_email_sentsuccess = str_replace("%EMAIL_PERMALINK%", get_permalink(), $template_email_sentsuccess);
			// If There Is Error Sending
			} else {
				if($yourremarks == __('N/A', 'wp-email')) { $yourremarks = ''; }
				$email_status = __('Failed', 'wp-email');
				// Template For Sent Failed
				$template_email_sentfailed = stripslashes(get_option('email_template_sentfailed'));
				$template_email_sentfailed = str_replace("%EMAIL_FRIEND_NAME%", $friendname, $template_email_sentfailed);
				$template_email_sentfailed = str_replace("%EMAIL_FRIEND_EMAIL%", $friendemail, $template_email_sentfailed);
				$template_email_sentfailed = str_replace("%EMAIL_ERROR_MSG%", $mail->ErrorInfo, $template_email_sentfailed);
				$template_email_sentfailed = str_replace("%EMAIL_POST_TITLE%", $post_title, $template_email_sentfailed);
				$template_email_sentfailed = str_replace("%EMAIL_BLOG_NAME%", get_bloginfo('name'), $template_email_sentfailed);
				$template_email_sentfailed = str_replace("%EMAIL_BLOG_URL%", get_bloginfo('url'), $template_email_sentfailed);
				$template_email_sentfailed = str_replace("%EMAIL_PERMALINK%", get_permalink(), $template_email_sentfailed);
			}
			// Logging
			$email_yourname = addslashes($yourname);
			$email_youremail = addslashes($youremail);
			$email_yourremarks = addslashes($yourremarks);
			$email_postid = intval(get_the_id());
			$email_posttitle = addslashes($post_title);
			$email_timestamp = current_time('timestamp');
			$email_ip = get_email_ipaddress();
			$email_host = @gethostbyaddr($email_ip);
			foreach($friends as $friend) {
				$email_friendname = addslashes($friend['name']);
				$email_friendemail = addslashes($friend['email']);
				$wpdb->query("INSERT INTO $wpdb->email VALUES (0, '$email_yourname', '$email_youremail', '$email_yourremarks', '$email_friendname', '$email_friendemail', $email_postid, '$email_posttitle', '$email_timestamp', '$email_ip', '$email_host', '$email_status')");
			}
			if($email_status == __('Success', 'wp-email')) {
				$output = $template_email_sentsuccess;
			} else {
				$output = $template_email_sentfailed;
			}
			echo $output;
			exit();
		// If There Are Errors
		} else {
			$error = substr($error, 21);
			$template_email_error = stripslashes(get_option('email_template_error'));
			$template_email_error = str_replace("%EMAIL_ERROR_MSG%", $error, $template_email_error);
			$template_email_error = str_replace("%EMAIL_BLOG_NAME%", get_bloginfo('name'), $template_email_error);
			$template_email_error = str_replace("%EMAIL_BLOG_URL%", get_bloginfo('url'), $template_email_error);
			$template_email_error = str_replace("%EMAIL_PERMALINK%", get_permalink(), $template_email_error);
			$output = $template_email_error;
			if(!$email_popup) {
				$output .= email_form(false, false, false, false, $error_field);
			} else {
				$output .= email_form(true, false, false, false, $error_field);
			}
			echo $output;
			exit();
		} // End if(empty($error))
	} // End if(!empty($_POST['wp-email']))
}


### Function: E-Mail Form
function email_form($popup = false, $echo = true, $subtitle = true, $div = true, $error_field = '') {
	global $wpdb, $multipage;	
	// Variables
	$multipage = false;
	$post_title = email_get_title();
	$post_author = the_author('', false);			
	$post_date = get_the_time(get_option('date_format').' ('.get_option('time_format').')', '', '', false);
	$post_category = email_category(__(',', 'wp-email').' ');			
	$post_category_alt = strip_tags($post_category);
	$email_fields = get_option('email_fields');
	$email_image_verify = intval(get_option('email_imageverify'));
	// Template - Subtitle
	if($subtitle) {
		$template_subtitle = stripslashes(get_option('email_template_subtitle'));
		$template_subtitle = str_replace("%EMAIL_POST_TITLE%", $post_title, $template_subtitle);
		$template_subtitle = str_replace("%EMAIL_POST_AUTHOR%", $post_author, $template_subtitle);
		$template_subtitle = str_replace("%EMAIL_POST_DATE%", $post_date, $template_subtitle);
		$template_subtitle = str_replace("%EMAIL_POST_CATEGORY%", $post_category, $template_subtitle);
		$template_subtitle = str_replace("%EMAIL_BLOG_NAME%", get_bloginfo('name'), $template_subtitle);
		$template_subtitle = str_replace("%EMAIL_BLOG_URL%", get_bloginfo('url'), $template_subtitle);
		$template_subtitle = str_replace("%EMAIL_PERMALINK%", get_permalink(), $template_subtitle);
		$output .= $template_subtitle;
	}
	// Display WP-EMail Form
	if($div) {
		$output .= '<div id="wp-email" class="wp-email">'."\n";
	}
	if (not_spamming()) {
		if(not_password_protected()) {
			if($popup){
				$output .= email_popup_form_header(false, $error_field['id']);
			} else {
				$output .= email_form_header(false, $error_field['id']);
			}
			$output .= '<!-- Display Error, If There Is Any -->'."\n";
			$output .= $template_email_sentfailed;
			$output .= $template_email_error;
			$output .= '<!-- End Display Error, If There Is Any -->'."\n";
			$output .= '<p id="wp-email-required">'.__('* Required Field', 'wp-email').'</p>'."\n";
			if(intval($email_fields['yourname']) == 1) {
				$output .= '<p>'."\n";
				$output .= '<label for="yourname">'.__('Your Name: *', 'wp-email').'</label><br />'."\n";
				$output .= '<input type="text" size="50" id="yourname" name="yourname" class="TextField" value="'.$error_field['yourname'].'" />'."\n";
				$output .= '</p>'."\n";
			}
			if(intval($email_fields['youremail']) == 1) {
				$output .= '<p>'."\n";
				$output .= '<label for="youremail">'.__('Your E-Mail: *', 'wp-email').'</label><br />'."\n";
				$output .= '<input type="text" size="50" id="youremail" name="youremail" class="TextField" value="'.$error_field['youremail'].'" dir="ltr" />'."\n";
				$output .= '</p>'."\n";
			}
			if(intval($email_fields['yourremarks']) == 1) {
				$output .= '<p>'."\n";
				$output .= '	<label for="yourremarks">'.__('Your Remark:', 'wp-email').'</label><br />'."\n";
				$output .= '	<textarea cols="49" rows="8" id="yourremarks" name="yourremarks" class="Forms">'.$error_field['yourremarks'].'</textarea>'."\n";
				$output .= '</p>'."\n";
			}
			if(intval($email_fields['friendname']) == 1) {
				$output .= '<p>'."\n";
				$output .= '<label for="friendname">'.__('Friend\'s Name: *', 'wp-email').'</label><br />'."\n";
				$output .= '<input type="text" size="50" id="friendname" name="friendname" class="TextField" value="'.$error_field['friendname'].'" />'.email_multiple(false)."\n";
				$output .= '</p>'."\n";
			}
			$output .= '<p>'."\n";
			$output .= '<label for="friendemail">'.__('Friend\'s E-Mail: *', 'wp-email').'</label><br />'."\n";
			$output .= '<input type="text" size="50" id="friendemail" name="friendemail" class="TextField" value="'.$error_field['friendemail'].'" dir="ltr" />'.email_multiple(false)."\n";
			$output .= '</p>'."\n";
			if($email_image_verify) {
				$output .= '<p>'."\n";
				$output .= '<label for="imageverify">'.__('Image Verification: *', 'wp-email').'</label><br />'."\n";
				$output .= '<img src="'.plugins_url('wp-email/email-image-verify.php').'" width="55" height="15" alt="'.__('E-Mail Image Verification', 'wp-email').'" /><input type="text" size="5" maxlength="5" id="imageverify" name="imageverify" class="TextField" />'."\n";
				$output .= '</p>'."\n";
			}
			$output .= '<p id="wp-email-button"><input type="button" value="'.__('     Mail It!     ', 'wp-email').'" id="wp-email-submit" class="Button" onclick="email_form();" onkeypress="email_form();" /></p>'."\n";
			$output .= '</form>'."\n";
		} else { 
			$output .= get_the_password_form();
		} // End if(not_password_protected())
	} else {
		$output .= '<p>'.sprintf(__ngettext('Please wait for <strong>%s Minute</strong> before sending the next article.', 'Please wait for <strong>%s Minutes</strong> before sending the next article.', email_flood_interval(false), 'wp-email'), email_flood_interval(false)).'</p>'."\n";
	} // End if (not_spamming())
	$output .= '<div id="wp-email-loading" class="wp-email-loading"><img src="'.plugins_url('wp-email/images/loading.gif').'" width="16" height="16" alt="'.__('Loading', 'wp-email').' ..." title="'.__('Loading', 'wp-email').' ..." class="wp-email-image" />&nbsp;'.__('Loading', 'wp-email').' ...</div>'."\n";
	if($div) {
		$output .= '</div>'."\n";
	}
	email_removefilters();
	if($echo) {
		echo $output;
	} else {
		return $output;
	}
}


### Function: Modify Default WordPress Listing To Make It Sorted By Most E-Mailed
function email_fields($content) {
	global $wpdb;
	$content .= ", COUNT($wpdb->email.email_postid) AS email_total";
	return $content;
}
function email_join($content) {
	global $wpdb;
	$content .= " LEFT JOIN $wpdb->email ON $wpdb->email.email_postid = $wpdb->posts.ID";
	return $content;
}
function email_groupby($content) {
	global $wpdb;
	$content .= " $wpdb->email.email_postid";
	return $content;
}
function email_orderby($content) {
	$orderby = trim(addslashes($_GET['orderby']));
	if(empty($orderby) || ($orderby != 'asc' && $orderby != 'desc')) {
		$orderby = 'desc';
	}
	$content = " email_total $orderby";
	return $content;
}


### Process The Sorting
/*
if($_GET['sortby'] == 'email') {
	add_filter('posts_fields', 'email_fields');
	add_filter('posts_join', 'email_join');
	add_filter('posts_groupby', 'email_groupby');
	add_filter('posts_orderby', 'email_orderby');
}
*/


### Function: Plug Into WP-Stats
if(strpos(get_option('stats_url'), $_SERVER['REQUEST_URI']) || strpos($_SERVER['REQUEST_URI'], 'stats-options.php') || strpos($_SERVER['REQUEST_URI'], 'wp-stats/wp-stats.php')) {
	add_filter('wp_stats_page_admin_plugins', 'email_page_admin_general_stats');
	add_filter('wp_stats_page_admin_most', 'email_page_admin_most_stats');
	add_filter('wp_stats_page_plugins', 'email_page_general_stats');
	add_filter('wp_stats_page_most', 'email_page_most_stats');
}


### Function: Add WP-EMail General Stats To WP-Stats Page Options
function email_page_admin_general_stats($content) {
	$stats_display = get_option('stats_display');
	if($stats_display['email'] == 1) {
		$content .= '<input type="checkbox" name="stats_display[]" id="wpstats_email" value="email" checked="checked" />&nbsp;&nbsp;<label for="wpstats_email">'.__('WP-EMail', 'wp-email').'</label><br />'."\n";
	} else {
		$content .= '<input type="checkbox" name="stats_display[]" id="wpstats_email" value="email" />&nbsp;&nbsp;<label for="wpstats_email">'.__('WP-EMail', 'wp-email').'</label><br />'."\n";
	}
	return $content;
}


### Function: Add WP-EMail Top Most/Highest Stats To WP-Stats Page Options
function email_page_admin_most_stats($content) {
	$stats_display = get_option('stats_display');
	$stats_mostlimit = intval(get_option('stats_mostlimit'));
	if($stats_display['emailed_most'] == 1) {
		$content .= '<input type="checkbox" name="stats_display[]" id="wpstats_emailed_most" value="emailed_most" checked="checked" />&nbsp;&nbsp;<label for="wpstats_emailed_most">'.sprintf(__ngettext('%s Most Emailed Post', '%s Most Emailed Posts', $stats_mostlimit, 'wp-email'), number_format_i18n($stats_mostlimit)).'</label><br />'."\n";
	} else {
		$content .= '<input type="checkbox" name="stats_display[]" id="wpstats_emailed_most" value="emailed_most" />&nbsp;&nbsp;<label for="wpstats_emailed_most">'.sprintf(__ngettext('%s Most Emailed Post', '%s Most Emailed Posts', $stats_mostlimit, 'wp-email'), number_format_i18n($stats_mostlimit)).'</label><br />'."\n";
	}
	return $content;
}


### Function: Add WP-EMail General Stats To WP-Stats Page
function email_page_general_stats($content) {
	global $wpdb;
	$stats_display = get_option('stats_display');
	if($stats_display['email'] == 1) {
		$email_stats = $wpdb->get_results("SELECT email_status, COUNT(email_id) AS email_total FROM $wpdb->email GROUP BY email_status");
		if($email_stats) {
			$email_stats_array = array();
			$email_stats_array['total'] = 0;
			foreach($email_stats as $email_stat) {
				$email_stats_array[$email_stat->email_status] = intval($email_stat->email_total);
				$email_stats_array['total'] += intval($email_stat->email_total);
			}
		}
		$content .= '<p><strong>'.__('WP-EMail', 'wp-email').'</strong></p>'."\n";
		$content .= '<ul>'."\n";
		$content .= '<li>'.sprintf(__ngettext('<strong>%s</strong> email was sent.', '<strong>%s</strong> emails were sent.', $email_stats_array['total'], 'wp-email'), number_format_i18n($email_stats_array['total'])).'</li>'."\n";
		$content .= '<li>'.sprintf(__ngettext('<strong>%s</strong> email was sent successfully.', '<strong>%s</strong> emails were sent successfully.', $email_stats_array[__('Success', 'wp-email')], 'wp-email'), number_format_i18n($email_stats_array[__('Success', 'wp-email')])).'</li>'."\n";
		$content .= '<li>'.sprintf(__ngettext('<strong>%s</strong> email failed to send.', '<strong>%s</strong> emails failed to send.', $email_stats_array[__('Failed', 'wp-email')], 'wp-email'), number_format_i18n($email_stats_array[__('Failed', 'wp-email')])).'</li>'."\n";
		$content .= '</ul>'."\n";
	}
	return $content;
}


### Function: Add WP-EMail Top Most/Highest Stats To WP-Stats Page
function email_page_most_stats($content) {
	$stats_display = get_option('stats_display');
	$stats_mostlimit = intval(get_option('stats_mostlimit'));
	if($stats_display['emailed_most'] == 1) {
		$content .= '<p><strong>'.sprintf(__ngettext('%s Most Emailed Post', '%s Most Emailed Posts', $stats_mostlimit, 'wp-email'), number_format_i18n($stats_mostlimit)).'</strong></p>'."\n";
		$content .= '<ul>'."\n";
		$content .= get_mostemailed('post', $stats_mostlimit, 0, false);
		$content .= '</ul>'."\n";
	}
	return $content;
}


### Function: Create E-Mail Table
add_action('activate_wp-email/wp-email.php', 'create_email_table');
function create_email_table() {
	global $wpdb;
	email_textdomain();
	if(@is_file(ABSPATH.'/wp-admin/upgrade-functions.php')) {
		include_once(ABSPATH.'/wp-admin/upgrade-functions.php');
	} elseif(@is_file(ABSPATH.'/wp-admin/includes/upgrade.php')) {
		include_once(ABSPATH.'/wp-admin/includes/upgrade.php');
	} else {
		die('We have problem finding your \'/wp-admin/upgrade-functions.php\' and \'/wp-admin/includes/upgrade.php\'');
	}
	$charset_collate = '';
	if($wpdb->supports_collation()) {
		if(!empty($wpdb->charset)) {
			$charset_collate = "DEFAULT CHARACTER SET $wpdb->charset";
		}
		if(!empty($wpdb->collate)) {
			$charset_collate .= " COLLATE $wpdb->collate";
		}
	}
	// Create E-Mail Table
	$create_table = "CREATE TABLE $wpdb->email (".
							"email_id int(10) NOT NULL auto_increment,".
							"email_yourname varchar(200) NOT NULL default '',".
							"email_youremail varchar(200) NOT NULL default '',".
							"email_yourremarks text NOT NULL,".
							"email_friendname varchar(200) NOT NULL default '',".
							"email_friendemail varchar(200) NOT NULL default '',".
							"email_postid int(10) NOT NULL default '0',".
							"email_posttitle text NOT NULL,".
							"email_timestamp varchar(20) NOT NULL default '',".
							"email_ip varchar(100) NOT NULL default '',".
							"email_host varchar(200) NOT NULL default '',".
							"email_status varchar(20) NOT NULL default '',".
							"PRIMARY KEY (email_id)) $charset_collate;";
	maybe_create_table($wpdb->email, $create_table);
	// Add In Options (12 Records)
	add_option('email_smtp', array('username' => '', 'password' => '', 'server' => ''), 'Your SMTP Name, Password, Server');
	add_option('email_contenttype', 'text/html', 'Your E-Mail Type');
	add_option('email_mailer', 'php', 'Your Mailer Type');
	add_option('email_template_subject', __('Recommended Article By %EMAIL_YOUR_NAME%: %EMAIL_POST_TITLE%', 'wp-email'), 'Template For E-Mail Subject');
	add_option('email_template_body', __('<p>Hi <strong>%EMAIL_FRIEND_NAME%</strong>,<br />Your friend, <strong>%EMAIL_YOUR_NAME%</strong>, has recommended this article entitled \'<strong>%EMAIL_POST_TITLE%</strong>\' to you.</p><p><strong>Here is his/her remark:</strong><br />%EMAIL_YOUR_REMARKS%</p><p><strong>%EMAIL_POST_TITLE%</strong><br />Posted By %EMAIL_POST_AUTHOR% On %EMAIL_POST_DATE% In %EMAIL_POST_CATEGORY%</p>%EMAIL_POST_CONTENT%<p>Article taken from %EMAIL_BLOG_NAME% - <a href="%EMAIL_BLOG_URL%">%EMAIL_BLOG_URL%</a><br />URL to article: <a href="%EMAIL_PERMALINK%">%EMAIL_PERMALINK%</a></p>', 'wp-email'), 'Template For E-Mail Body');
	add_option('email_template_bodyalt', __('Hi %EMAIL_FRIEND_NAME%,'."\n".
	'Your friend, %EMAIL_YOUR_NAME%, has recommended this article entitled \'%EMAIL_POST_TITLE%\' to you.'."\n\n".
	'Here is his/her remarks:'."\n".
	'%EMAIL_YOUR_REMARKS%'."\n\n".
	'%EMAIL_POST_TITLE%'."\n".
	'Posted By %EMAIL_POST_AUTHOR% On %EMAIL_POST_DATE% In %EMAIL_POST_CATEGORY%'."\n".
	'%EMAIL_POST_CONTENT%'."\n".
	'Article taken from %EMAIL_BLOG_NAME% - %EMAIL_BLOG_URL%'."\n".
	'URL to article: %EMAIL_PERMALINK%', 'wp-email'), 'Template For E-Mail Alternate Body');
	add_option('email_template_sentsuccess', '<p>'.__('Article: <strong>%EMAIL_POST_TITLE%</strong> has been sent to <strong>%EMAIL_FRIEND_NAME% (%EMAIL_FRIEND_EMAIL%)</strong></p><p>&laquo; <a href="%EMAIL_PERMALINK%">'.__('Back to %EMAIL_POST_TITLE%', 'wp-email').'</a></p>', 'wp-email'), 'Template For E-Mail That Is Sent Successfully');
	add_option('email_template_sentfailed', '<p>'.__('An error has occurred when trying to send this email: ', 'wp-email').'<br /><strong>&raquo;</strong> %EMAIL_ERROR_MSG%</p>', 'Template For E-Mail That Failed To Sent');
	add_option('email_template_error', '<p>'.__('An error has occurred: ', 'wp-email').'<br /><strong>&raquo;</strong> %EMAIL_ERROR_MSG%</p>', 'Template For E-Mail That Has An Error');
	add_option('email_interval', 10, 'The Number Of Minutes Before The User Can E-Mail The Next Article');
	add_option('email_snippet', 0, 'Enable Snippet Feature For Your E-Mail?');
	add_option('email_multiple', 5, 'Maximum Number Of Multiple E-Mails');
	// Version 2.05 Options
	add_option('email_imageverify', 1, 'Enable Image Verification?');
	// Version 2.10 Options
	$email_options = array('post_text' => __('Email This Post', 'wp-email'), 'page_text' => __('Email This Page', 'wp-email'), 'email_icon' => 'email_famfamfam.png', 'email_type' => 1, 'email_style' => 1, 'email_html' => '<a href="%EMAIL_URL%" rel="nofollow" title="%EMAIL_TEXT%">%EMAIL_TEXT%</a>');
	$email_fields = array('yourname' => 1, 'youremail' => 1, 'yourremarks' => 1, 'friendname' => 1, 'friendemail' => 1);
	add_option('email_options', $email_options, 'Email Options');
	add_option('email_fields', $email_fields, 'Email Fields');
	// Version 2.11 Options
	add_option('email_template_title', __('E-Mail \'%EMAIL_POST_TITLE%\' To A Friend', 'wp-email'), 'Template For E-Mail Page Title');
	add_option('email_template_subtitle', '<p style="text-align: center;">'.__('Email a copy of <strong>\'%EMAIL_POST_TITLE%\'</strong> to a friend', 'wp-email').'</p>', 'Template For E-Mail Page SubTitle');
	// Version 2.20 Upgrade
	$email_mailer = get_option('email_mailer');
	if($email_mailer == 'php') {
		update_option('email_mailer', 'mail');
	}
	// Set 'manage_email' Capabilities To Administrator	
	$role = get_role('administrator');
	if(!$role->has_cap('manage_email')) {
		$role->add_cap('manage_email');
	}
}
?>
