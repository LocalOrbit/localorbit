<?php
/*
Plugin Name: Search Meter
Plugin URI: http://thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/
Description: Keeps track of what your visitors are searching for. After you have activated this plugin, you can check the Search Meter section in the Dashboard to see what your visitors are searching for on your blog.
Version: 2.9
Author: Bennett McElwee
Author URI: http://thunderguy.com/semicolon/
Donate link: http://thunderguy.com/semicolon/donate/

$Revision: 594693 $


INSTRUCTIONS

1. Copy this file into the plugins directory in your WordPress installation
   (wp-content/plugins/search-meter/search-meter.php).
2. Log in to WordPress administration. Go to the Plugins section and activate
   this plugin.

* To see search statistics, log in to WordPress Admin, go to the Dashboard
  section and click Search Meter.
* To control search statistics, log in to WordPress Admin, go to the Settings
  section and click Search Meter.
* To display recent and popular searches, use the Recent Searches and
  Popular Searches widgets, or the sm_list_popular_searches() and
  sm_list_recent_searches() template tags.
* For full details, see http://thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/

Thanks to Kaufman (http://www.terrik.com/wordpress/) and the many others who have offered suggestions.


Copyright (C) 2005-12 Bennett McElwee (bennett at thunderguy dotcom)

This program is free software; you can redistribute it and/or
modify it under the terms of version 2 of the GNU General Public
License as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details, available at
http://www.gnu.org/copyleft/gpl.html
or by writing to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

// This is here to avoid E_NOTICE when indexing nonexistent array keys. There's probably a better solution. Suggestions are welcome.
function tguy_sm_array_value(&$array, $key) {
	return (is_array($array) && array_key_exists($key, $array)) ? $array[$key] : null;
}


// Parameters (you can change these if you know what you're doing)

define('TGUY_SM_HISTORY_SIZE', 500);
// The number of recent searches that will be saved. The table can
// contain up to 100 more rows than this number 

define('TGUY_SM_ALLOW_EMPTY_REFERER', false);
// Searches with an empty referer header are often bogus requests
// from Google's AdSense crawler or something similar, so they are
// excluded. Set this to true to record all such searches.

define('TGUY_SM_ALLOW_DUPLICATE_SAVES', false);
// It may be that the filter gets called more than once for a given
// request. Search Meter ignores these duplicates. Set this to true
// to record duplicates (the fact that it's a dupe will be recorded
// in the details). This will mess up the stats, but could be useful
// for troubleshooting.


if (is_admin()) {
	require_once dirname(__FILE__) . '/admin.php';
	register_activation_hook(__FILE__, 'tguy_sm_init');
}

// Template Tags


function sm_list_popular_searches($before = '', $after = '', $count = 5) {
// List the most popular searches in the last month in decreasing order of popularity.
	global $wpdb, $wp_rewrite;
	$count = intval($count);
	$escaped_filter_regex = sm_get_escaped_filter_regex();
	$filter_term = ($escaped_filter_regex == "" ? "" : "AND NOT `terms` REGEXP '{$escaped_filter_regex}'");
	// This is a simpler query than the report query, and may produce
	// slightly different results. This query returns searches if they
	// have ever had any hits, even if the last search yielded no hits.
	// This makes for a more efficient search -- important if this
	// function will be used in a sidebar.
	$results = $wpdb->get_results(
		"SELECT `terms`, SUM(`count`) AS countsum
		FROM `{$wpdb->prefix}searchmeter`
		WHERE DATE_SUB( CURDATE( ) , INTERVAL 30 DAY ) <= `date`
		AND 0 < `last_hits`
		{$filter_term}
		GROUP BY `terms`
		ORDER BY countsum DESC, `terms` ASC
		LIMIT $count");
	if (count($results)) {
		echo "$before\n<ul>\n";
		$home_url_slash = get_settings('home') . '/';
		foreach ($results as $result) {
			echo '<li><a href="'. $home_url_slash . sm_get_relative_search_url($result->terms) . '">'. htmlspecialchars($result->terms) .'</a></li>'."\n";
		}
		echo "</ul>\n$after\n";
	}
}

function sm_list_recent_searches($before = '', $after = '', $count = 5) {
// List the most recent successful searches, ignoring duplicates
	global $wpdb;
	$count = intval($count);
	$escaped_filter_regex = sm_get_escaped_filter_regex();
	$filter_term = ($escaped_filter_regex == "" ? "" : "AND NOT `terms` REGEXP '{$escaped_filter_regex}'");
	$results = $wpdb->get_results(
		"SELECT `terms`, MAX(`datetime`) `maxdatetime`
		FROM `{$wpdb->prefix}searchmeter_recent`
		WHERE 0 < `hits`
		{$filter_term}
		GROUP BY `terms`
		ORDER BY `maxdatetime` DESC
		LIMIT $count");
	if (count($results)) {
		echo "$before\n<ul>\n";
		$home_url_slash = get_settings('home') . '/';
		foreach ($results as $result) {
			echo '<li><a href="'. $home_url_slash . sm_get_relative_search_url($result->terms) . '">'. htmlspecialchars($result->terms) .'</a></li>'."\n";
		}
		echo "</ul>\n$after\n";
	}
}

function sm_get_relative_search_url($term) {
// Return the URL for a search term, relative to the home directory.
	global $wp_rewrite;
	$relative_url = null;
	if ($wp_rewrite->using_permalinks()) {
		$structure = $wp_rewrite->get_search_permastruct();
		if (strpos($structure, '%search%') !== false) {
			$relative_url = str_replace('%search%', rawurlencode($term), $structure);
		}
	}
	if ( ! $relative_url) {
		$relative_url =  '?s=' . urlencode($term);
	}
	return $relative_url;
}


function sm_get_escaped_filter_regex() {
// Return a regular expression, escaped to go into a DB query, that will match any terms to be filtered out
	global $sm_escaped_filter_regex, $wpdb;
	if ( ! isset($sm_escaped_filter_regex)) {
		$options = get_option('tguy_search_meter');
		$filter_words = tguy_sm_array_value($options, 'sm_filter_words');
		if ($filter_words == '') {
			$sm_escaped_filter_regex = '';
		} else {
			$filter_regex = str_replace(' ', '|', preg_quote($filter_words));
			$wpdb->escape_by_ref($filter_regex);
			$sm_escaped_filter_regex = $filter_regex;
		}
	}
	return $sm_escaped_filter_regex;
}
$sm_escaped_filter_regex = null;

// Hooks


add_filter('the_posts', 'tguy_sm_save_search', 20); // run after other plugins


// Functionality


// Widgets

add_action('widgets_init', 'tguy_sm_register_widgets');
function tguy_sm_register_widgets() {
	register_widget('SM_Popular_Searches_Widget');
	register_widget('SM_Recent_Searches_Widget');
}

class SM_Popular_Searches_Widget extends WP_Widget {
	function SM_Popular_Searches_Widget() {
		$widget_ops = array('classname' => 'widget_search_meter', 'description' => __( "A list of the most popular successful searches in the last month"));
		$this->WP_Widget('popular_searches', __('Popular Searches'), $widget_ops);
	}

	function widget($args, $instance) {
		extract($args);
		$title = apply_filters('widget_title', empty($instance['popular-searches-title']) ? __('Popular Searches') : $instance['popular-searches-title']);
		$count = (int) (empty($instance['popular-searches-number']) ? 5 : $instance['popular-searches-number']);
		
		echo $before_widget;
		if ($title) {
			echo $before_title . $title . $after_title;
		}
		sm_list_popular_searches('', '', sm_constrain_widget_search_count($count));
		echo $after_widget;
	}
		
	function update($new_instance, $old_instance){
		$instance = $old_instance;
		$instance['popular-searches-title'] = strip_tags(stripslashes($new_instance['popular-searches-title']));
		$instance['popular-searches-number'] = (int) ($new_instance['popular-searches-number']);
		return $instance;
	}
	
	function form($instance){
		//Defaults
		$instance = wp_parse_args((array) $instance, array('popular-searches-title' => 'Popular Searches', 'popular-searches-number' => 5));
		
		$title = htmlspecialchars($instance['popular-searches-title']);
		$count = htmlspecialchars($instance['popular-searches-number']);
		
		# Output the options
		echo '<p><label for="' . $this->get_field_name('popular-searches-title') . '">' . __('Title:') . ' <input class="widefat" id="' . $this->get_field_id('title') . '" name="' . $this->get_field_name('popular-searches-title') . '" type="text" value="' . $title . '" /></label></p>';
		echo '<p><label for="' . $this->get_field_name('popular-searches-number') . '">' . __('Number of searches to show:') . ' <input id="' . $this->get_field_id('popular-searches-number') . '" name="' . $this->get_field_name('popular-searches-number') . '" type="text" value="' . $count . '" size="3" /></label></p>';
		echo '<p><small>Powered by Search Meter</small></p>';
	}
}

class SM_Recent_Searches_Widget extends WP_Widget {
	function SM_Recent_Searches_Widget() {
		$widget_ops = array('classname' => 'widget_search_meter', 'description' => __( "A list of the most recent successful searches on your blog"));
		$this->WP_Widget('recent_searches', __('Recent Searches'), $widget_ops);
	}

	function widget($args, $instance) {
		extract($args);
		$title = apply_filters('widget_title', empty($instance['recent-searches-title']) ? __('Recent Searches') : $instance['recent-searches-title']);
		$count = (int) (empty($instance['recent-searches-number']) ? 5 : $instance['recent-searches-number']);
		
		echo $before_widget;
		if ($title) {
			echo $before_title . $title . $after_title;
		}
		sm_list_recent_searches('', '', sm_constrain_widget_search_count($count));
		echo $after_widget;
	}
		
	function update($new_instance, $old_instance){
		$instance = $old_instance;
		$instance['recent-searches-title'] = strip_tags(stripslashes($new_instance['recent-searches-title']));
		$instance['recent-searches-number'] = (int) ($new_instance['recent-searches-number']);
		return $instance;
	}
	
	function form($instance){
		//Defaults
		$instance = wp_parse_args((array) $instance, array('recent-searches-title' => 'Recent Searches', 'recent-searches-number' => 5));
		
		$title = htmlspecialchars($instance['recent-searches-title']);
		$count = htmlspecialchars($instance['recent-searches-number']);
		
		# Output the options
		echo '<p><label for="' . $this->get_field_name('recent-searches-title') . '">' . __('Title:') . ' <input class="widefat" id="' . $this->get_field_id('title') . '" name="' . $this->get_field_name('recent-searches-title') . '" type="text" value="' . $title . '" /></label></p>';
		echo '<p><label for="' . $this->get_field_name('recent-searches-number') . '">' . __('Number of searches to show:') . ' <input id="' . $this->get_field_id('recent-searches-number') . '" name="' . $this->get_field_name('recent-searches-number') . '" type="text" value="' . $count . '" size="3" /></label></p>';
		echo '<p><small>Powered by Search Meter</small></p>';
	}
}

function sm_constrain_widget_search_count($number) {
	return max(1, min((int)$number, 100));
}

// Keep track of how many times SM has been called for this request.
// Normally we only record the first time.
$tguy_sm_action_count = 0;

function tguy_sm_save_search($posts) {
// Check if the request is a search, and if so then save details.
// This is a filter but does not change the posts.
	global $wpdb, $wp_query, $tguy_sm_action_count;

	++$tguy_sm_action_count;
	if (is_search()
	&& !is_paged() // not the second or subsequent page of a previously-counted search
	&& !is_admin() // not using the administration console
	&& (1 == $tguy_sm_action_count || TGUY_SM_ALLOW_DUPLICATE_SAVES)
	&& (tguy_sm_array_value($_SERVER, 'HTTP_REFERER') || TGUY_SM_ALLOW_EMPTY_REFERER) // proper referrer (otherwise could be search engine, cache...)
	) {
		// Get all details of this search
		// search string is the raw query
		$search_string = $wp_query->query_vars['s'];
		if (get_magic_quotes_gpc()) {
			$search_string = stripslashes($search_string);
		}
		// search terms is the words in the query
		$search_terms = $search_string;
		$search_terms = preg_replace('/[," ]+/', ' ', $search_terms);
		$search_terms = trim($search_terms);
		$hit_count = $wp_query->found_posts; // Thanks to Will for this line
		// Other useful details of the search
		$details = '';
		$options = get_option('tguy_search_meter');
		if ($options['sm_details_verbose']) {
			if (TGUY_SM_ALLOW_DUPLICATE_SAVES) {
				$details .= "Search Meter action count: $tguy_sm_action_count\n";
			}
			foreach (array('REQUEST_URI','REQUEST_METHOD','QUERY_STRING','REMOTE_ADDR','HTTP_USER_AGENT','HTTP_REFERER')
			         as $header) {
				$details .= $header . ': ' . tguy_sm_array_value($_SERVER, $header) . "\n";
			}
		}

		// Sanitise as necessary
		$search_string = $wpdb->escape($search_string);
		$search_terms = $wpdb->escape($search_terms);
		$details = $wpdb->escape($details);

		// Save the individual search to the DB
		$query = "INSERT INTO `{$wpdb->prefix}searchmeter_recent` (`terms`,`datetime`,`hits`,`details`)
		VALUES ('$search_string',NOW(),$hit_count,'$details')";
		$success = $wpdb->query($query);
		if ($success) {
			// Ensure table never grows larger than TGUY_SM_HISTORY_SIZE + 100
			$rowcount = $wpdb->get_var(
				"SELECT count(`datetime`) as rowcount
				FROM `{$wpdb->prefix}searchmeter_recent`");
			if ((TGUY_SM_HISTORY_SIZE + 100) < $rowcount) {
				// find time of (TGUY_SM_HISTORY_SIZE)th entry
				$dateZero = $wpdb->get_var(
					"SELECT `datetime`
					FROM `{$wpdb->prefix}searchmeter_recent`
					ORDER BY `datetime` DESC LIMIT ".TGUY_SM_HISTORY_SIZE.", 1");
				$query = "DELETE FROM `{$wpdb->prefix}searchmeter_recent` WHERE `datetime` < '$dateZero'";
				$success = $wpdb->query($query);
			}
		}
		// Save search summary into the DB. Usually this will be a new row, so try to insert first
		$query = "INSERT INTO `{$wpdb->prefix}searchmeter` (`terms`,`date`,`count`,`last_hits`)
		VALUES ('$search_terms',CURDATE(),1,$hit_count)";
		// Temporarily suppress errors, as this query is expected to fail on duplicate searches in a single day. Thanks to James Collins.
		$suppress = $wpdb->suppress_errors();
		$success = $wpdb->query($query);
		$wpdb->suppress_errors($suppress);
		if (!$success) {
			$query = "UPDATE `{$wpdb->prefix}searchmeter` SET
				`count` = `count` + 1,
				`last_hits` = $hit_count
			WHERE `terms` = '$search_terms' AND `date` = CURDATE()";
			$success = $wpdb->query($query);
		}
	}
	return $posts;
}

