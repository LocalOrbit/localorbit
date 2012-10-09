<?php
/*
Plugin Name: Tweet Stats
Plugin URI: http://www.improvingtheweb.com/wordpress-plugins/tweet-stats/
Description: Two widgets showing the most tweeted posts and the recently tweeted posts
Author: Improving The Web
Version: 1.0
Author URI: http://www.improvingtheweb.com/
*/

if (!defined('WP_CONTENT_URL')) {
	define('WP_CONTENT_URL', get_option('siteurl') . '/wp-content');
}
if (!defined('WP_CONTENT_DIR')) {
	define('WP_CONTENT_DIR', ABSPATH . 'wp-content');
}
if (!defined('WP_PLUGIN_URL')) {
	define('WP_PLUGIN_URL', WP_CONTENT_URL. '/plugins');
}
if (!defined('WP_PLUGIN_DIR')) {
	define('WP_PLUGIN_DIR', WP_CONTENT_DIR . '/plugins');
}

register_activation_hook(__FILE__, 'ts_install');
register_deactivation_hook(__FILE__ , 'ts_uninstall');

if (is_admin()) {
	require dirname(__FILE__) . '/admin.php';	
} 

add_action('plugins_loaded', 'ts_widget_init');
	
function ts_install() {	
	if (!function_exists('yoast_get_tweetbacks')) {		
		$file = 'tweetbacks/tweetbacks.php';
		if (file_exists(WP_PLUGIN_DIR . '/' . $file)) {			
			$active_plugins = get_option('active_plugins');
			if (!in_array($file, $active_plugins)) {
				$active_plugins[] = $file;
				update_option('active_plugins', $active_plugins);
				do_action('activate_' . $file);
			}
		} else {
			deactivate_plugins('tweet-stats/tweet-stats.php');
			wp_die('Sorry, you\'ll need to install the <a href="http://yoast.com/wordpress/tweetbacks/" target="_blank">Tweetbacks</a> plugin first, this plugin\'s life depends on it.');
		}	
	}
	
	if (!get_option('ts_options')) {
		add_option('ts_options', array('mt_title' => 'Most Tweeted',
									   'mt_result_count' => 10, 
									   'mt_show_tweet_count' => 1, 
									   'mt_age' => 30, 
									   'mt_cache_expiry' => 3600, 
									   'mt_cache' => false, 
									   'mt_cache_date' => 0, 
									   'mt_trim_title' => 120, 
									   'rt_title' => 'Recently Tweeted', 
									   'rt_result_count' => 10, 
									   'rt_show_tweet_count' => 1, 
									   'rt_cache_expiry' => 3600,
									   'rt_cache' => false, 
									   'rt_cache_date' => 0, 
									   'rt_trim_title' => 120));
	}
}

function ts_uninstall() {
	if (function_exists('unregister_sidebar_widget')) {
		unregister_sidebar_widget(__('Most Tweeted', 'tweet_stats'));
		unregister_sidebar_widget(__('Recently Tweeted', 'tweet_stats'));
	}
	delete_option('ts_options');
}
	
function ts_widget_init() {
	if (!function_exists('register_sidebar_widget')) {
		return;
	}

	function ts_widget_most_tweeted($args) {
		extract($args);
		
		global $ts_options;
		
		if (empty($ts_options)) {
			$ts_options = get_option('ts_options');
		}

		if (empty($ts_options['mt_title'])) {
			$ts_options['mt_title'] = __('Most Tweeted', 'tweet_stats');
		}
		
		$posts = ts_get_most_tweeted();
		
		echo $before_widget;
		echo $before_title . $ts_options['mt_title'] . $after_title;
		echo '<ul id="ts_mt_tweet_stats">';
		
		if (is_array($posts) && !empty($posts)) {
			foreach ($posts as $post) {
				if ($ts_options['mt_trim_title']) {
					$post->post_title_trimmed = ts_trim_title($post->post_title, $ts_options['mt_trim_title']);
				} else {
					$post->post_title_trimmed = $post->post_title;
				}
				echo '<li><a href="' . get_permalink($post->ID) . '" title="' . htmlspecialchars($post->post_title) . ' has ' . (int) $post->tweets . ' tweets">' . htmlspecialchars($post->post_title_trimmed) . '</a>' . ($ts_options['mt_show_tweet_count'] ? ' (' . (int) $post->tweets . ')' : '') . '</li>';
			}
		} else {
			echo '<li>None found</li>';
		}
		
		echo '</ul>';
		
		echo $after_widget;
	}
	
	function ts_widget_most_tweeted_control() {
		require dirname(__FILE__) . '/widget_control_mt.php'; 
	}

	function ts_widget_recently_tweeted($args) {
		extract($args);
		
		global $ts_options;
		
		if (empty($ts_options)) {
			$ts_options = get_option('ts_options');
		}
		
		if (empty($ts_options['rt_title'])) {
			$ts_options['rt_title'] = __('Recently Tweeted', 'tweet_stats');
		}
		
		$posts = ts_get_recently_tweeted();
		
		echo $before_widget;
		echo $before_title . $ts_options['rt_title'] . $after_title;
		echo '<ul id="ts_mt_tweet_stats">';
		
		if (is_array($posts) && !empty($posts)) {
			foreach ($posts as $post) {
				if ($ts_options['rt_trim_title']) {
					$post->post_title_trimmed = ts_trim_title($post->post_title, $ts_options['rt_trim_title']);
				} else {
					$post->post_title_trimmed = $post->post_title;
				}
				echo '<li><a href="' . get_permalink($post->ID) . '" title="' . htmlspecialchars($post->post_title) . ' has ' . (int) $post->tweets . ' tweets">' . htmlspecialchars($post->post_title_trimmed) . '</a>' . ($ts_options['rt_show_tweet_count'] ? ' (' . (int) $post->tweets . ')' : '') . '</li>';
			}
		} else {
			echo '<li>None found</li>';
		}
		
		echo '</ul>';
		
		echo $after_widget;
	}
	
	function ts_widget_recently_tweeted_control() {
		require dirname(__FILE__) . '/widget_control_rt.php'; 
	}	
	
	register_sidebar_widget(__('Most Tweeted', 'tweet_stats'), 'ts_widget_most_tweeted');
	register_widget_control(__('Most Tweeted', 'tweet_stats'), 'ts_widget_most_tweeted_control');
	
	register_sidebar_widget(__('Recently Tweeted', 'tweet_stats'), 'ts_widget_recently_tweeted');
	register_widget_control(__('Recently Tweeted', 'tweet_stats'), 'ts_widget_recently_tweeted_control');
}

function ts_trim_title($text, $chars=120) {
	if (strlen($text) > $chars) {
		$text = substr($text, 0, $chars-3);
		$text = trim(substr($text, 0, strrpos($text, ' ')));
		$text .= '...';
	}
	
	return $text;
}

function ts_get_most_tweeted() {
	global $ts_options;
	if (empty($ts_options)) {
		$ts_options = get_option('ts_options');
	}
			
	if (empty($ts_options['mt_cache']) || $ts_options['mt_cache_date'] < (mktime() - $ts_options['mt_cache_expiry'])) {
		global $wpdb;
						
		$ts_options['mt_result_count'] = (int) $ts_options['mt_result_count'];
		
		if ($ts_options['mt_result_count'] < 1) {
			$ts_options['mt_result_count'] = 5;
		} else if ($ts_options['mt_result_count'] > 100) {
			$ts_options['mt_result_count'] = 100;
		}
		
		if ($ts_options['mt_age']) {
			$age_sql = " AND DATE_SUB(CURDATE(), INTERVAL {$ts_options['mt_age']} DAY) < $wpdb->posts.post_date ";
		} else {
			$age_sql = '';
		}
				
		$sql = "SELECT $wpdb->posts.ID, $wpdb->posts.post_title, ($wpdb->postmeta.meta_value+0) AS tweets FROM $wpdb->posts LEFT JOIN $wpdb->postmeta ON ($wpdb->posts.ID = $wpdb->postmeta.post_id) 
				WHERE $wpdb->posts.post_status = 'publish' AND $wpdb->postmeta.meta_key = 'tweetcount' $age_sql AND $wpdb->postmeta.meta_value != '0' AND $wpdb->postmeta.meta_value 
				IS NOT NULL ORDER BY tweets DESC, $wpdb->posts.post_date LIMIT 0, {$ts_options['mt_result_count']}";
					
		$results = $wpdb->get_results($sql);
				
		if (!$results) {
			$results = 'none';
		}
		
		$ts_options['mt_cache'] 	 = $results;
		$ts_options['mt_cache_date'] = mktime();
		
		update_option('ts_options', $ts_options);

		return $results;
	} else {
		return $ts_options['mt_cache'];
	}
}

function ts_get_recently_tweeted() {
	global $ts_options;
	if (empty($ts_options)) {
		$ts_options = get_option('ts_options');
	}
		
	if (empty($ts_options['rt_cache']) || $ts_options['rt_cache_date'] < (mktime() - $ts_options['rt_cache_expiry'])) {
		global $wpdb;
						
		$ts_options['rt_result_count'] = (int) $ts_options['rt_result_count'];
		
		if ($ts_options['rt_result_count'] < 1) {
			$ts_options['rt_result_count'] = 5;
		} else if ($ts_options['rt_result_count'] > 100) {
			$ts_options['rt_result_count'] = 100;
		}			
		
		$sql = "SELECT DISTINCT($wpdb->comments.comment_post_ID) AS post_id FROM $wpdb->comments WHERE $wpdb->comments.comment_type = 'tweetback' ORDER BY $wpdb->comments.comment_date_gmt DESC LIMIT {$ts_options['rt_result_count']}";
				
		$results = $wpdb->get_results($sql);
		
		if (!$results) {
			$results = 'none';
		} else {
			$posts = array();
			foreach ($results as $result) {
				$posts[(int) $result->post_id] = false;
			}
						
			$sql = "SELECT $wpdb->posts.ID, $wpdb->posts.post_title, ($wpdb->postmeta.meta_value+0) AS tweets FROM $wpdb->posts LEFT JOIN $wpdb->postmeta ON ($wpdb->posts.ID = $wpdb->postmeta.post_id) 
					WHERE $wpdb->posts.ID IN (" . implode(',', array_keys($posts)) . ") AND $wpdb->postmeta.meta_key = 'tweetcount' LIMIT 0, {$ts_options['rt_result_count']}";
		
			$unordered_results = $wpdb->get_results($sql);
			
			if (!$unordered_results) {
				$results = 'none';
			} else {
				foreach ($unordered_results as $result) {
					$posts[$result->ID] = $result;
				}
				$results = $posts;
			}
		}
		
		$ts_options['rt_cache']      = $results;
		$ts_options['rt_cache_date'] = mktime();
		
		update_option('ts_options', $ts_options);
		
		return $results;
	} else {
		return $ts_options['rt_cache'];
	}
}
?>