<?php
/*
Plugin Name: Popularity Contest
Plugin URI: http://alexking.org/projects/wordpress
Description: This will enable ranking of your posts by popularity; using the behavior of your visitors to determine each post's popularity. You set a value (or use the default value) for every post view, comment, etc. and the popularity of your posts is calculated based on those values. Once you have activated the plugin, you can configure the <a href="options-general.php?page=popularity-contest.php">Popularity Values</a> and <a href="index.php?page=popularity-contest.php">View Reports</a>. You can also use the included <a href="options-general.php?page=popularity-contest.php#akpc_template_tags">Template Tags</a> to display post popularity and lists of popular posts on your blog.
Version: 1.3b3
Author: Alex King
Author URI: http://alexking.org/
*/ 

// Copyright (c) 2005-2007 Alex King. All rights reserved.
//
// Released under the GPL license
// http://www.opensource.org/licenses/gpl-license.php
//
// This is an add-on for WordPress
// http://wordpress.org/
//
// **********************************************************************
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
// **********************************************************************
//
// Known Issues
// - When spam comments/pingbacks/trackbacks are deleted or marked as
//   spam, their value is not always removed from the posts they were
//   applied to. This is because the hooks in WP do not seem to fire
//   consistently with sufficient data. Hopefully this will be fixed in 
//   a future release of WP.

// Special thanks to Martijn Stegink for help with WordPress 2.3 compatibility.


/* -- INSTALLATION --------------------- */

// Change this to "0" below if you don't want to show each post's popularity with the post content

@define('AKPC_SHOWPOP', 0);


// To hide the popularity score on a per post/page basis, add a custom field to the post/page as follows:
//   name: hide_popularity
//   value: 1


// Change this to "0" if you don't want to show the little [?] that links to the explanation of what the popularity means

@define('AKPC_SHOWHELP', 0);


// If you would like to show lists of popular posts in the sidebar, 
// take a look at how it is implemented in the included sidebar.php.

/* ------------------------------------- */


if (!isset($wpdb)) {
	require('../../wp-blog-header.php');
	akpc_init();
}

load_plugin_textdomain('alexking.org');

if (!function_exists('is_admin_page')) {
	function is_admin_page() {
		if (function_exists('is_admin')) {
			return is_admin();
		}
		if (function_exists('check_admin_referer')) {
			return true;
		}
		else {
			return false;
		}
	}
}

// -- MAIN FUNCTIONALITY

class ak_popularity_contest {
	var $feed_value;
	var $home_value;
	var $archive_value;
	var $category_value;
	var $single_value;
	var $comment_value;
	var $pingback_value;
	var $trackback_value;
	var $logged;
	var $options;
	var $top_ranked;
	var $current_posts;
	
	function ak_popularity_contest() {
		$this->options = array(
			'feed_value'
			,'home_value'
			,'archive_value'
			,'category_value'
			,'single_value'
			,'comment_value'
			,'pingback_value'
			,'trackback_value'
		);
		$this->feed_value = 1;
		$this->home_value = 2;
		$this->archive_value = 4;
		$this->category_value = 6;
		$this->single_value = 10;
		$this->comment_value = 20;
		$this->pingback_value = 50;
		$this->trackback_value = 80;
		$this->logged = 0;
		$this->top_ranked = array();
		$this->current_posts = array();
	}
	
	function get_settings() {
		global $wpdb;		
		$result = mysql_query("
			SELECT *
			FROM $wpdb->ak_popularity_options
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		if (!$result) {
			return false;
		}
		
		while ($data = mysql_fetch_object($result)) {
			if (in_array($data->option_name, $this->options)) {
				$temp = $data->option_name;
				$this->$temp = $data->option_value;
			}
		}
		
		return true;
	}
	
	function install() {
		global $wpdb;
		$result = mysql_query("
			CREATE TABLE `$wpdb->ak_popularity_options`
			(
				`option_name` VARCHAR( 50 ) NOT NULL
				, `option_value` VARCHAR( 50 ) NOT NULL
			) 
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		if (!$result) {
			return false;
		}
	
		$this->default_values();

		$result = mysql_query("
			CREATE TABLE `$wpdb->ak_popularity`
			(
				`post_id` INT( 11 ) NOT NULL 
				, `total` INT( 11 ) NOT NULL 
				, `feed_views` INT( 11 ) NOT NULL 
				, `home_views` INT( 11 ) NOT NULL 
				, `archive_views` INT( 11 ) NOT NULL 
				, `category_views` INT( 11 ) NOT NULL 
				, `single_views` INT( 11 ) NOT NULL 
				, `comments` INT( 11 ) NOT NULL 
				, `pingbacks` INT( 11 ) NOT NULL 
				, `trackbacks` INT( 11 ) NOT NULL 
				, `last_modified` DATETIME NOT NULL
				, KEY `post_id` ( `post_id` )
			) 
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		if (!$result) {
			return false;
		}
		
		$this->mine_data();
		
		return true;		
	}
	
	function default_values() {
		global $wpdb;
		foreach ($this->options as $option) {
			$temp = $this->$option;
			$result = mysql_query("
				INSERT 
				INTO $wpdb->ak_popularity_options
				VALUES
				(
					'$option'
					, '$temp'
				)
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
	
			if (!$result) {
				return false;
			}
		}
		
		return true;
	}
	
	function update_settings() {
		global $wpdb;
		foreach ($this->options as $option) {
			if (isset($_POST[$option])) {
				$this->$option = intval($_POST[$option]);
				$temp = $this->$option;

				$result = mysql_query("
					UPDATE $wpdb->ak_popularity_options
					SET option_value = '$temp'
					WHERE option_name = '$option'
				", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
				
				if (!$result) {
					return false;
				}
			}
		}

		$this->recalculate_popularity();

		header('Location: '.get_bloginfo('wpurl').'/wp-admin/options-general.php?page=popularity-contest.php&updated=true');
		die();
	}
	
	function recalculate_popularity() {
		global $wpdb;
		$result = mysql_query("
			UPDATE $wpdb->ak_popularity
			SET total = (home_views * $this->home_value)
				+ (feed_views * $this->feed_value)
				+ (archive_views * $this->archive_value)
				+ (category_views * $this->category_value)
				+ (single_views * $this->single_value)
				+ (comments * $this->comment_value)
				+ (pingbacks * $this->pingback_value)
				+ (trackbacks * $this->trackback_value)
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
	}
	
	function reset_data() {
		global $wpdb;
		$result = mysql_query("
			TRUNCATE $wpdb->ak_popularity
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		if (!$result) {
			return false;
		}

		$result = mysql_query("
			TRUNCATE $wpdb->ak_popularity_options
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

		if (!$result) {
			return false;
		}
		
		$this->default_values();
		
		return true;
	}

	function create_post_record($post_ID = -1) {
		global $wpdb;
		if ($post_ID == -1) {
			global $post_ID;
		}
		$result = mysql_query("
			SELECT post_id
			FROM $wpdb->ak_popularity
			WHERE post_id = '$post_ID'
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		if (mysql_num_rows($result) == 0) {
			$result = mysql_query("
				INSERT 
				INTO $wpdb->ak_popularity
				VALUES
				(
					'$post_ID'
					, '0'
					, '0'
					, '0'
					, '0'
					, '0'
					, '0'
					, '0'
					, '0'
					, '0'
					, '".date('Y-m-d H:i:s')."'
				)
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		}
	}
	
	function delete_post_record($post_ID = -1) {
		global $wpdb;
		if ($post_ID == -1) {
			global $post_ID;
		}
		$result = mysql_query("
			DELETE 
			FROM $wpdb->ak_popularity
			WHERE post_id = '$post_ID'
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

	}
	
	function mine_data() {
		global $wpdb;
		
		$posts = mysql_query("
			SELECT ID
			FROM $wpdb->posts
			WHERE post_status = 'publish'
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		if ($posts && mysql_num_rows($posts) > 0) {
			while ($post = mysql_fetch_object($posts)) {
				$this->create_post_record($post->ID);
				$this->populate_post_data($post->ID);
			}
		}
		
		return true;
	}
	
	function mine_gap_data() {
		global $wpdb;
		$posts = mysql_query("
			SELECT p.ID
			FROM $wpdb->posts p
			LEFT JOIN $wpdb->ak_popularity pop
			ON p.ID = pop.post_id
			WHERE pop.post_id IS NULL
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		if ($posts && mysql_num_rows($posts) > 0) {
			while ($post = mysql_fetch_object($posts)) {
				$this->create_post_record($post->ID);
				$this->populate_post_data($post->ID);
			}
		}
	}
	
	function populate_post_data($post_id) {
		global $wpdb;
// grab existing comments
		$result = mysql_query("
			SELECT comment_ID
			FROM $wpdb->comments
			WHERE comment_post_ID = '$post_id'
			AND comment_type = ''
			AND comment_approved = '1'
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		$count = mysql_num_rows($result);

		if ($result && $count > 0) {

// increase post popularity
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET comments = comments + $count
				, total = total + ".($this->comment_value * $count)."
				WHERE post_id = '$post_id'
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}
		}

// grab existing trackbacks
		$result = mysql_query("
			SELECT comment_ID
			FROM $wpdb->comments
			WHERE comment_post_ID = '$post_id'
			AND comment_type = 'trackback'
			AND comment_approved = '1'
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		$count = mysql_num_rows($result);

		if ($result && $count > 0) {

// increase post popularity
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET trackbacks = trackbacks + $count
				, total = total + ".($this->trackback_value * $count)."
				WHERE post_id = '$post_id'
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}
		}

// grab existing pingbacks
		$result = mysql_query("
			SELECT comment_ID
			FROM $wpdb->comments
			WHERE comment_post_ID = '$post_id'
			AND comment_type = 'pingback'
			AND comment_approved = '1'
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		$count = mysql_num_rows($result);

		if ($result && $count > 0) {

// increase post popularity
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET pingbacks = pingbacks + $count
				, total = total + ".($this->pingback_value * $count)."
				WHERE post_id = '$post_id'
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}
		}
	}
	
	function record_view() {
		if ($this->logged > 0) {
			return true;
		}
		global $wpdb, $posts;
		
		if (!isset($posts) || !is_array($posts) || count($posts) == 0 || is_admin_page()) {
			return;
		}
		
		$ids = array();
		$ak_posts = $posts;
		foreach ($ak_posts as $post) {
			$ids[] = $post->ID;
		}
		
		if (is_feed()) {
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET feed_views = feed_views + 1
				, total = total + $this->feed_value
				WHERE post_id IN (".implode(',', $ids).")
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}
		}
		else if (is_archive() && !is_category()) {
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET archive_views = archive_views + 1
				, total = total + $this->archive_value
				WHERE post_id IN (".implode(',', $ids).")
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}
		}
		else if (is_category()) {
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET category_views = category_views + 1
				, total = total + $this->category_value
				WHERE post_id IN (".implode(',', $ids).")
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}
		}
		else if (is_single()) {
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET single_views = single_views + 1
				, total = total + $this->single_value
				WHERE post_id = '".$ids[0]."'
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}
		}
		else {
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET home_views = home_views + 1
				, total = total + $this->home_value
				WHERE post_id IN (".implode(',', $ids).")
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}
		}
		
		$this->logged++;

		return true;
	}
	
	function record_feedback($type, $action = '+') {
		global $wpdb, $comment_post_ID;
		switch ($type) {
			case 'trackback':
				$result = mysql_query("
					UPDATE $wpdb->ak_popularity
					SET trackbacks = trackbacks $action 1
					, total = total $action $this->trackback_value
					WHERE post_id = '$comment_post_ID'
				", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
	
				if (!$result) {
					return false;
				}
				break;
			case 'pingback':
				$result = mysql_query("
					UPDATE $wpdb->ak_popularity
					SET pingback_views = pingback_views $action 1
					, total = total $action $this->pingback_value
					WHERE post_id = '$comment_post_ID'
				", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
	
				if (!$result) {
					return false;
				}
				break;
			default:
				$result = mysql_query("
					UPDATE $wpdb->ak_popularity
					SET comments = comments $action 1
					, total = total $action $this->comment_value
					WHERE post_id = '$comment_post_ID'
				", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
	
				if (!$result) {
					return false;
				}
				break;
		}

		return true;
	}
	
	function edit_feedback($comment_id, $action) {
		global $wpdb, $comment_post_ID;
		switch ($action) {
			case 'delete':
				if (!isset($comment_post_ID) || empty($comment_post_ID)) {
					// Often, this data isn't set for us - without it there is no joy
					return;
				}
				else {
					// Unfortunately, this hook happens after the comment
					// is already out of the DB, so we don't know what type it was.
					// Assuming it was a comment (not a trackback or pingback) is
					// the safest solution.
					$this->record_feedback('', '-');
				}
				break;
			case 'status':
				$result = mysql_query("
					SELECT comment_post_ID, comment_type, comment_approved
					FROM $wpdb->comments
					WHERE comment_ID = '$comment_id'
				", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
				
				if ($result) {
					while ($data = mysql_fetch_object($result)) {
						if ($data->comment_approved == 'spam') {
							$comment_post_ID = $data->comment_post_ID;
							$this->record_feedback($data->comment_type, '-');
							return;
						}
					}
				}
		}
	}
	
	function recount_feedback() {
		global $wpdb;
		$posts = mysql_query("
			SELECT ID
			FROM $wpdb->posts
			WHERE post_status = 'publish'
			OR post_status = 'static'
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

		if ($posts && mysql_num_rows($posts) > 0) {
			$result = mysql_query("
				UPDATE $wpdb->ak_popularity
				SET comments = 0
				, trackbacks = 0
				, pingbacks = 0
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);

			while ($post = mysql_fetch_object($posts)) {
				$this->populate_post_data($post->ID);
			}
		}

		$this->recalculate_popularity();

		header('Location: '.get_bloginfo('wpurl').'/wp-admin/options-general.php?page=popularity-contest.php&updated=true');
		die();
	}
	
	function options_form() {
		$temp = new ak_popularity_contest;
		print('
			<div class="wrap">
				<h2>'.__('Popularity Contest Options', 'alexking.org').'</h2>
				<form name="ak_popularity" action="'.get_bloginfo('wpurl').'/wp-admin/options-general.php" method="post">
					<fieldset class="options">
						<legend>'.__('Popularity Values', 'alexking.org').'</legend>
						<p>'.__('Adjust the values below as you see fit. When you save the new options the <a href="index.php?page=popularity-contest.php"><strong>popularity rankings</strong></a> for your posts will be automatically updated to reflect the new values you have chosen.', 'alexking.org').'</p>
						<table width="100%" cellspacing="2" cellpadding="5" class="editform"> 
							<tr valign="top"> 
								<th width="33%" scope="row"><label for="single_value">'.__('Permalink Views:', 'alexking.org').'</label></th> 
								<td><input type="text" name="single_value" id="single_value" value="'.$this->single_value.'" /> '.__("(default: $temp->single_value)", 'alexking.org').'</td> 
							</tr>
							<tr valign="top"> 
								<th width="33%" scope="row"><label for="home_value">'.__('Home Views:', 'alexking.org').'</label></th> 
								<td><input type="text" name="home_value" id="home_value" value="'.$this->home_value.'" /> '.__("(default: $temp->home_value)", 'alexking.org').'</td> 
							</tr>
							<tr valign="top"> 
								<th width="33%" scope="row"><label for="archive_value">'.__('Archive Views:', 'alexking.org').'</label></th> 
								<td><input type="text" name="archive_value" id="archive_value" value="'.$this->archive_value.'" /> '.__("(default: $temp->archive_value)", 'alexking.org').'</td> 
							</tr>
							<tr valign="top"> 
								<th width="33%" scope="row"><label for="category_value">'.__('Category Views:', 'alexking.org').'</label></th> 
								<td><input type="text" name="category_value" id="category_value" value="'.$this->category_value.'" /> '.__("(default: $temp->category_value)", 'alexking.org').'</td> 
							</tr>
							<tr valign="top"> 
								<th width="33%" scope="row"><label for="feed_value">'.__('Feed Views (full content only):', 'alexking.org').'</label></th> 
								<td><input type="text" name="feed_value" id="feed_value" value="'.$this->feed_value.'" /> '.__("(default: $temp->feed_value)", 'alexking.org').'</td> 
							</tr>
							<tr valign="top"> 
								<th width="33%" scope="row"><label for="comment_value">'.__('Comments:', 'alexking.org').'</label></th> 
								<td><input type="text" name="comment_value" id="comment_value" value="'.$this->comment_value.'" /> '.__("(default: $temp->comment_value)", 'alexking.org').'</td> 
							</tr>
							<tr valign="top"> 
								<th width="33%" scope="row"><label for="pingback_value">'.__('Pingbacks:', 'alexking.org').'</label></th> 
								<td><input type="text" name="pingback_value" id="pingback_value" value="'.$this->pingback_value.'" /> '.__("(default: $temp->pingback_value)", 'alexking.org').'</td> 
							</tr>
							<tr valign="top"> 
								<th width="33%" scope="row"><label for="trackback_value">'.__('Trackbacks:', 'alexking.org').'</label></th> 
								<td><input type="text" name="trackback_value" id="trackback_value" value="'.$this->trackback_value.'" /> '.__("(default: $temp->trackback_value)", 'alexking.org').'</td> 
							</tr>
						</table>
						<h3>'.__('Example', 'alexking.org').'</h3>
						<ul>
							<li>'.__('Post #1 receives 11 Home Page Views (11 * 2 = 22), 6 Permalink Views (6 * 10 = 60) and 3 Comments (3 * 20 = 60) for a total value of: <strong>142</strong>', 'alexking.org').'</li>
							<li>'.__('Post #2 receives 7 Home Page Views (7 * 2 = 14), 10 Permalink Views (10 * 10 = 100), 7 Comments (7 * 20 = 140) and 3 Trackbacks (3 * 80 = 240) for a total value of: <strong>494</strong>', 'alexking.org').'</li>
						</ul>
						<input type="hidden" name="ak_action" value="update_popularity_values" />
					</fieldset>
					<p class="submit">
						<input type="submit" name="submit" value="'.__('Update Popularity Values', 'alexking.org').'" />
						<input type="button" name="recount" value="'.__('Reset Comments/Trackback/Pingback Counts', 'alexking.org').'" onclick="location.href=\''.get_bloginfo('wpurl').'/wp-admin/options-general.php?ak_action=recount_feedback\';" />
					</p>
				</form>
				<div id="akpc_template_tags">
					<h2>'.__('Popularity Contest Template Tags', 'alexking.org').'</h2>
					<dl>
						<dt><code>akpc_the_popularity()</code></dt>
						<dd>
							<p>'.__('Put this tag within <a href="http://codex.wordpress.org/The_Loop">The Loop</a> to show the popularity of the post being shown. The popularity is shown as a percentage of your most popular post. For example, if the popularity total for Post #1 is 500 and your popular post has a total of 1000, this tag will show a value of <strong>50%</strong>.', 'alexking.org').'</p>
							<p>Example:</p> 
							<ul>
								<li><code>&lt;?php akpc_the_popularity(); ?></code></li>
							</ul>
						</dd>
						<dt><code>akpc_most_popular($limit = 10, $before = &lt;li>, $after = &lt;/li>)</code></dt>
						<dd>
							<p>'.__('Put this tag outside of <a href="http://codex.wordpress.org/The_Loop">The Loop</a> (perhaps in your sidebar?) to show a list (like the archives/categories/links list) of your most popular posts. All arguments are optional, the defaults are included in the example above.', 'alexking.org').'</p>
							<p>Examples:</p> 
							<ul>
								<li><code>&lt;?php akpc_most_popular(); ?></code></li>
								<li><code>
									&lt;li>&lt;h2>Most Popular Posts&lt;/h2><br />
									&nbsp;&nbsp;	&lt;ul><br />
									&nbsp;&nbsp;	&lt;?php akpc_most_popular(); ?><br />
									&nbsp;&nbsp;	&lt;/ul><br />
									&lt;/li>
								</code></li>
							</ul>
						</dd>
						<dt><code>akpc_most_popular_in_cat($limit = 10, $before = &lt;li>, $after = &lt;/li>, $cat_ID = current category)</code></dt>
						<dd>
							<p>'.__('Put this tag outside of <a href="http://codex.wordpress.org/The_Loop">The Loop</a> (perhaps in your sidebar?) to show a list of the most popular posts in a specific category. You may want to use this on category archive pages. All arguments are', 'alexking.org').'</p>
							<p>Examples:</p> 
							<ul>
								<li><code>&lt;?php akpc_most_popular_in_cat(1); ?></code></li>
								<li><code>&lt;php if (is_category()) { akpc_most_popular_in_cat(); } ?></code></li>
								<li><code>
									&lt;?php if (is_category()) { ?><br />
									&lt;li>&lt;h2>Most Popular in \'&lt;?php single_cat_title(); ?>\'&lt;/h2><br />
									&nbsp;&nbsp;	&lt;ul><br />
									&nbsp;&nbsp;	&lt;?php akpc_most_popular_in_cat(); ?><br />
									&nbsp;&nbsp;	&lt;/ul><br />
									&lt;/li><br />
									&lt;?php } ?>
								</code></li>
							</ul>
						</dd>
						<dt><code>akpc_most_popular_in_month($limit, $before, $after, $m = YYYYMM)</code></dt>
						<dd>
							<p>'.__('Put this tag outside of <a href="http://codex.wordpress.org/The_Loop">The Loop</a> (perhaps in your sidebar?) to show a list of the most popular posts in a specific month. You may want to use this on monthly archive pages.', 'alexking.org').'</p>
							<p>Examples:</p> 
							<ul>
								<li><code>&lt;?php akpc_most_popular_in_month(\'200504\'); ?></code></li>
								<li><code>&lt;php if (is_archive() && is_month()) { akpc_most_popular_in_month(); } ?></code></li>
								<li><code>
									&lt;?php if (is_archive() && is_month()) { ?><br />
									&lt;li>&lt;h2>Most Popular in &lt;?php the_time(\'F, Y\'); ?>&lt;/h2><br />
									&nbsp;&nbsp;	&lt;ul><br />
									&nbsp;&nbsp;	&lt;?php akpc_most_popular_in_month(); ?><br />
									&nbsp;&nbsp;	&lt;/ul><br />
									&lt;/li><br />
									&lt;?php } ?>
								</code></li>
							</ul>
						</dd>
					</dl>
				</div>
			</div>
		');
	}
	
	function show_report($type = 'popular', $limit = 10, $custom = array()) {
		global $wpdb;
		if (count($custom) > 0 && 1 == 0) {
		}
		else {
			$query = '';
			$column = '';
			$items = array();
			switch ($type) {
				case 'category':
					$title = $custom['cat_name'];
					$items = $wpdb->get_results("
						SELECT p.ID AS ID, p.post_title AS post_title, pop.total AS total
						FROM $wpdb->posts p
						LEFT JOIN $wpdb->ak_popularity pop
						ON p.ID = pop.post_id
						LEFT JOIN $wpdb->term_relationships tr
						ON p.ID = tr.object_id
						LEFT JOIN $wpdb->term_taxonomy tt
						ON tt.term_taxonomy_id = tr.term_taxonomy_id
						WHERE tt.term_id = ".$custom['cat_ID']."
						AND p.post_status = 'publish'
						ORDER BY pop.total DESC
						LIMIT $limit
					");
					$list = '';
					if (count($items) > 0) {
						foreach ($items as $item) {
							$list .= '	<li>
									<span>'.$this->get_post_rank(-1, $item->total).'</span>
									<a href="'.get_permalink($item->ID).'">'.$item->post_title.'</a>
								</li>'."\n";
						}
					}
					break;
				case 'pop_by_category':
					$cats = array();
					$cats = $wpdb->get_results("
						SELECT name, t.term_id
						FROM $wpdb->terms t
						LEFT JOIN $wpdb->term_taxonomy tt
						ON t.term_id = tt.term_id
						WHERE tt.taxonomy = 'category'
						ORDER BY name
					");
					$i = 1;
					if (count($cats) > 0) {
						foreach ($cats as $cat) {
							$temp = array(
								'cat_ID' => $cat->term_id
								,'cat_name' => $cat->name
							);
							$this->show_report('category', 10, $temp);
							if ($i == 3) {
								print('
										<div class="clear"></div>
								');
								$i = 0;
							}
							$i++;
						}
					}
					break;
				case 'category_popularity':
					$title = __('Average by Category', 'alexking.org');
					$items = $wpdb->get_results("
						SELECT DISTINCT name, AVG(pop.total) AS avg
						FROM $wpdb->posts p
						LEFT JOIN $wpdb->ak_popularity pop
						ON p.ID = pop.post_id
						LEFT JOIN $wpdb->term_relationships tr
						ON p.ID = tr.object_id
						LEFT JOIN $wpdb->term_taxonomy tt
						ON tr.term_taxonomy_id = tt.term_taxonomy_id
						LEFT JOIN $wpdb->terms t
						ON tt.term_id = t.term_id
						GROUP BY name
						ORDER BY avg DESC
					");
					$list = '';
					if (count($items) > 0) {
						foreach ($items as $item) {
							$list .= '	<li>
									<span>'.ceil($item->avg).'</span>
									'.$item->name.'
								</li>'."\n";
						}
					}
					break;
				case 'year':
					global $month;
					$title = $custom['y'].__(' Average by Month', 'alexking.org');
					$items = $wpdb->get_results("
						SELECT MONTH(p.post_date) AS month, AVG(pop.total) AS avg
						FROM $wpdb->posts p
						LEFT JOIN $wpdb->ak_popularity pop
						ON p.ID = pop.post_id
						WHERE YEAR(p.post_date) = '".$custom['y']."'
						GROUP BY month
						ORDER BY avg DESC
					");
					$list = '';
					if (count($items) > 0) {
						foreach ($items as $item) {
							$list .= '	<li>
									<span>'.ceil($item->avg).'</span>
									'.$month[str_pad($item->month, 2, '0', STR_PAD_LEFT)].'
								</li>'."\n";
						}
					}
					break;
				case 'month_popularity':
					$years = array();
					$years = $wpdb->get_results("
						SELECT DISTINCT YEAR(post_date) AS year
						FROM $wpdb->posts
						ORDER BY year DESC
					");
					$i = 2;
					if (count($years) > 0) {
						foreach ($years as $year) {
							$temp = array(
								'y' => $year->year
							);
							$this->show_report('year', 10, $temp);
							if ($i == 3) {
								print('
										<div class="clear"></div>
								');
								$i = 0;
							}
							$i++;
						}
					}
					break;
				case 'views_wo_feedback':
					$title = __('Views w/o Feedback', 'alexking.org');
					$items = $wpdb->get_results("
						SELECT p.ID AS ID, p.post_title AS post_title, pop.total AS total
						FROM $wpdb->posts p
						LEFT JOIN $wpdb->ak_popularity pop
						ON p.ID = pop.post_id
						WHERE pop.comments = 0
						AND pop.pingbacks = 0
						AND pop.trackbacks = 0
						AND p.post_status = 'publish'
						ORDER BY pop.total DESC
						LIMIT $limit
					");
					$list = '';
					if (count($items) > 0) {
						foreach ($items as $item) {
							$list .= '	<li>
									<span>'.$this->get_post_rank(-1, $item->total).'</span>
									<a href="'.get_permalink($item->ID).'">'.$item->post_title.'</a>
								</li>'."\n";
						}
					}
					break;
				case 'most_feedback':
					$query = 'sum';
					$column = 'pop.comments + pop.pingbacks + pop.trackbacks AS feedback';
					$title = __('Feedback', 'alexking.org');
					break;
				case 'last_30':
					$query = 'date';
					$days = 30;
					$offset = 0;
					$compare = '>';
					$title = __('Last 30 Days', 'alexking.org');
					break;
				case 'last_60':
					$query = 'date';
					$days = 60;
					$offset = 0;
					$compare = '>';
					$title = __('Last 60 Days', 'alexking.org');
					break;
				case 'last_90':
					$query = 'date';
					$days = 90;
					$offset = 0;
					$compare = '>';
					$title = __('Last 90 Days', 'alexking.org');
					break;
				case 'last_365':
					$query = 'date';
					$days = 365;
					$offset = 0;
					$compare = '>';
					$title = __('Last Year', 'alexking.org');
					break;
				case '365_plus':
					$query = 'date';
					$days = 0;
					$offset = -365;
					$compare = '<';
					$title = __('Older Than 1 Year', 'alexking.org');
					break;
				case 'most_feed_views':
					$query = 'most';
					$column = 'feed_views';
					$title = __('Feed Views', 'alexking.org');
					break;
				case 'most_home_views':
					$query = 'most';
					$column = 'home_views';
					$title = __('Home Page Views', 'alexking.org');
					break;
				case 'most_archive_views':
					$query = 'most';
					$column = 'archive_views';
					$title = __('Archive Views', 'alexking.org');
					break;
				case 'most_category_views':
					$query = 'most';
					$column = 'category_views';
					$title = __('Category Views', 'alexking.org');
					break;
				case 'most_single_views':
					$query = 'most';
					$column = 'single_views';
					$title = __('Permalink Views', 'alexking.org');
					break;
				case 'most_comments':
					$query = 'most';
					$column = 'comments';
					$title = __('Comments', 'alexking.org');
					break;
				case 'most_pingbacks':
					$query = 'most';
					$column = 'pingbacks';
					$title = __('Pingbacks', 'alexking.org');
					break;
				case 'most_trackbacks':
					$query = 'most';
					$column = 'trackbacks';
					$title = __('Trackbacks', 'alexking.org');
					break;
				case 'popular':
					$query = 'popular';
					$column = 'total';
					$title = __('Most Popular', 'alexking.org');
					$list = '';
					break;
			}
			if (!empty($query)) {
				switch ($query) {
					case 'most':
						$items = $wpdb->get_results("
							SELECT p.ID AS ID, p.post_title AS post_title, pop.$column AS $column
							FROM $wpdb->posts p
							LEFT JOIN $wpdb->ak_popularity pop
							ON p.ID = pop.post_id
							WHERE p.post_status = 'publish'
							ORDER BY pop.$column DESC
							LIMIT $limit
						");
						$list = '';
						if (count($items) > 0) {
							foreach ($items as $item) {
								$list .= '	<li>
										<span>'.$item->$column.'</span>
										<a href="'.get_permalink($item->ID).'">'.$item->post_title.'</a>
									</li>'."\n";
							}
						}
						break;
					case 'date':
						$items = $wpdb->get_results("
							SELECT p.ID AS ID, p.post_title AS post_title, pop.total AS total
							FROM $wpdb->posts p
							LEFT JOIN $wpdb->ak_popularity pop
							ON p.ID = pop.post_id
							WHERE DATE_ADD(p.post_date, INTERVAL $days DAY) $compare DATE_ADD(NOW(), INTERVAL $offset DAY)
							AND p.post_status = 'publish'
							ORDER BY pop.total DESC
							LIMIT $limit
						");
						$list = '';
						if (count($items) > 0) {
							foreach ($items as $item) {
								$list .= '	<li>
										<span>'.$this->get_post_rank(-1, $item->total).'</span>
										<a href="'.get_permalink($item->ID).'">'.$item->post_title.'</a>
									</li>'."\n";
							}
						}
						break;
					case 'popular':
						$items = $wpdb->get_results("
							SELECT p.ID AS ID, p.post_title AS post_title, pop.$column AS $column
							FROM $wpdb->posts p
							LEFT JOIN $wpdb->ak_popularity pop
							ON p.ID = pop.post_id
							WHERE p.post_status = 'publish'
							ORDER BY pop.$column DESC
							LIMIT $limit
						");
						$list = '';
						if (count($items) > 0) {
							foreach ($items as $item) {
								$list .= '	<li>
										<span>'.$this->get_post_rank(-1, $item->total).'</span>
										<a href="'.get_permalink($post->ID).'">'.$item->post_title.'</a>
									</li>'."\n";
							}
						}
						break;
				}
			}
		}
		if (!empty($list)) {
			print('
				<div class="akpc_report">
					<h3>'.$title.'</h3>
					<ol>
						'.$list.'
					</ol>
				</div>
			');
		}
	}
	
	function show_report_extended($type = 'popular', $limit = 50) {
		global $wpdb, $post;
		$columns = array(
			'popularity' => __('', 'alexking.org')
			,'title'      => __('Title')
			,'categories' => __('Categories')
			,'single_views'     => __('Post', 'alexking.org')
			,'category_views'     => __('Cat', 'alexking.org')
			,'archive_views'     => __('Arch', 'alexking.org')
			,'home_views'     => __('Home', 'alexking.org')
			,'feed_views'     => __('Feed', 'alexking.org')
			,'comments'     => __('Com')
			,'pingbacks'     => __('Ping')
			,'trackbacks'     => __('Track')
		);
?>
<div id="akpc_most_popular">
	<table width="100%" cellpadding="3" cellspacing="2"> 
		<tr>
<?php 
		foreach($columns as $column_display_name) { 
?>
			<th scope="col"><?php echo $column_display_name; ?></th>
<?php 
		} 
?>
			</tr>
<?php
		$posts = $wpdb->get_results("
			SELECT p.*, pop.*
			FROM $wpdb->posts p
			LEFT JOIN $wpdb->ak_popularity pop
			ON p.ID = pop.post_id
			WHERE p.post_status = 'publish'
			ORDER BY pop.total DESC
			LIMIT ".intval($limit)
		);
		if ($posts) {
			$bgcolor = '';
			foreach ($posts as $post) { 
				start_wp();
				$class = ('alternate' == $class) ? '' : 'alternate';
?> 
		<tr class='<?php echo $class; ?>'>
<?php
				foreach($columns as $column_name => $column_display_name) {
					switch($column_name) {
						case 'popularity':
?>
				<td><?php $this->show_post_rank(-1, $post->total); ?></td>
<?php
						break;
						case 'title':
?>
				<td><a href="<?php the_permalink(); ?>"><?php the_title() ?></a></td>
<?php
							break;
						case 'categories':
?>
				<td><?php the_category(','); ?></td>
<?php
							break;
						case 'single_views':
?>
				<td class="right"><?php print($post->single_views); ?></td>
<?php
							break;
						case 'category_views':
?>
				<td class="right"><?php print($post->category_views); ?></td>
<?php
							break;
						case 'archive_views':
?>
				<td class="right"><?php print($post->archive_views); ?></td>
<?php
							break;
						case 'home_views':
?>
				<td class="right"><?php print($post->home_views); ?></td>
<?php
							break;
						case 'feed_views':
?>
				<td class="right"><?php print($post->feed_views); ?></td>
<?php
							break;
						case 'comments':
?>
				<td class="right"><?php print($post->comments); ?></td>
<?php
							break;
						case 'pingbacks':
?>
				<td class="right"><?php print($post->pingbacks); ?></td>
<?php
							break;
						case 'trackbacks':
?>
				<td class="right"><?php print($post->trackbacks); ?></td>
<?php
							break;
					}
				}
?>
		</tr> 
<?php
			}
		} 
		else {
?>
	  <tr style='background-color: <?php echo $bgcolor; ?>'> 
		<td colspan="8"><?php _e('No posts found.') ?></td> 
	  </tr> 
<?php
		} // end if ($posts)
?> 
	</table> 
</div>
<?php
	}
	
	function view_stats($limit = 100) {
		global $wpdb, $post;
		print('
			<div class="wrap">
				<h2>'.__('Most Popular', 'alexking.org').'</h2>
		');
		
		$this->show_report_extended('popular', 50);

		print('
				<p id="akpc_options_link"><a href="options-general.php?page=popularity-contest.php">Change Popularity Values</a></p>
				<h2>'.__('Views', 'alexking.org').'</h2>
		');

		$this->show_report('most_single_views');
		$this->show_report('most_category_views');
		$this->show_report('most_archive_views');

		print('
				<div class="clear"></div>
		');

		$this->show_report('most_home_views');
		$this->show_report('most_feed_views');

		print('
				<div class="clear"></div>
				<h2>'.__('Feedback', 'alexking.org').'</h2>
		');

		$this->show_report('most_comments');
		$this->show_report('most_pingbacks');
		$this->show_report('most_trackbacks');

		print('
				<div class="clear"></div>
		');

		$this->show_report('views_wo_feedback');

		print('
				<div class="clear"></div>
				<h2>'.__('Averages', 'alexking.org').'</h2>
		');

		$this->show_report('category_popularity');
		$this->show_report('month_popularity');

		print('
				<div class="clear"></div>
				<h2>'.__('Categories', 'alexking.org').'</h2>
		');

		$this->show_report('pop_by_category');

		print('
				<div class="clear"></div>
				<h2>'.__('Date Range', 'alexking.org').'</h2>
		');

		$this->show_report('last_30');
		$this->show_report('last_60');
		$this->show_report('last_90');

		print('
				<div class="clear"></div>
		');

		$this->show_report('last_365');
		$this->show_report('365_plus');

		print('
				<div class="clear"></div>
			</div>
		');
	}
	
	function get_post_total($post_id) {
		if (!isset($this->current_posts['id_'.$post_id])) {
			$this->get_current_posts();
		}
		return $this->current_posts['id_'.$post_id];
	}

	function get_post_rank($post_id = -1, $total = -1) {
		if (count($this->top_ranked) == 0) {
			$this->get_top_ranked();
		}
		if ($total > -1 && $post_id == -1) {
			return ceil(($total/$this->top_rank()) * 100).'%';
		}
		if (isset($this->top_ranked['id_'.$post_id])) {
			$rank = $this->top_ranked['id_'.$post_id];
		}
		else {
			$rank = $this->get_post_total($post_id);
		}
		if (AKPC_SHOWHELP == 1) {
			$suffix = ' <span class="akpc_help">[<a href="http://alexking.org/projects/wordpress/popularity-contest" title="'.__('What does this mean?', 'alexking.org').'">?</a>]</span>';
		}
		else {
			$suffix = '';
		}
		if (isset($rank) && $rank != false) {
			return __('Popularity:', 'alexking.org').' '.ceil(($rank/$this->top_rank()) * 100).'%'.$suffix;
		}
		else {
			return __('Popularity:', 'alexking.org').' '.__('unranked', 'alexking.org').$suffix;
		}
	}
	
	function show_post_rank($post_id = -1, $total = -1) {
		print($this->get_post_rank($post_id, $total));
	}
	
	function top_rank() {
		if (count($this->top_ranked) == 0) {
			$this->get_top_ranked();
		}
		foreach ($this->top_ranked as $id => $rank) {
			return $rank;
		}
	}

	function get_current_posts() {
		global $wpdb, $posts;
		
		if (!isset($posts) || count($posts) == 0) {
			return true;
		}
		
		$ids = array();
		$ak_posts = $posts;
		foreach ($ak_posts as $post) {
			$ids[] = $post->ID;
		}
		if (count($ids) > 0) {
			$result = mysql_query("
				SELECT post_id, total
				FROM $wpdb->ak_popularity
				WHERE post_id IN (".implode(',', $ids).")
			", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
			
			if ($result) {
				while ($data = mysql_fetch_object($result)) {
					$this->current_posts['id_'.$data->post_id] = $data->total;
				}
			}
		}
		
		return true;
	}
	
	
	function get_top_ranked() {
		global $wpdb;
		$result = mysql_query("
			SELECT post_id, total
			FROM $wpdb->ak_popularity
			ORDER BY total DESC
			LIMIT 10
		", $wpdb->dbh) or die(mysql_error().' on line: '.__LINE__);
		
		if (!$result) {
			return false;
		}
		
		while ($data = mysql_fetch_object($result)) {
			$this->top_ranked['id_'.$data->post_id] = $data->total;
		}
		
		return true;
	}
	
	function show_top_ranked($limit, $before, $after) {
		global $wpdb;
		$temp = $wpdb;
		
		$join = apply_filters('posts_join', '');
		$where = apply_filters('posts_where', '');
		$groupby = apply_filters('posts_groupby', '');
		if (!empty($groupby)) {
			$groupby = ' GROUP BY '.$groupby;
		}
		else {
			$groupby = ' GROUP BY '.$wpdb->posts.'.ID ';
		}
		
		$posts = $wpdb->get_results("
			SELECT ID, post_title
			FROM $wpdb->posts
			LEFT JOIN $wpdb->ak_popularity pop
			ON $wpdb->posts.ID = pop.post_id
			$join
			WHERE post_status = 'publish'
			AND post_date < NOW()
			$where
			$groupby
			ORDER BY pop.total DESC
			LIMIT ".intval($limit)
		);
		if ($posts) {
			foreach ($posts as $post) {
    			print(
    				$before.'<a href="'.get_permalink($post->ID).'">'
    				.$post->post_title.'</a>'.$after
    			);
			}
		}
		else {
			print($before.'(none)'.$after);
		}
		$wpdb = $temp;
	}
	
	function show_top_ranked_in_cat($limit, $before, $after, $cat_ID = '') {
		if (empty($cat_ID) && is_category()) {
			global $cat;
			$cat_ID = $cat;
		}
		if (empty($cat_ID)) {
			return;
		}
		global $wpdb;
		$temp = $wpdb;

		$join = apply_filters('posts_join', '');
		$where = apply_filters('posts_where', '');
		$groupby = apply_filters('posts_groupby', '');
		if (!empty($groupby)) {
			$groupby = ' GROUP BY '.$groupby;
		}
		else {
			$groupby = ' GROUP BY p.ID ';
		}

		$posts = $wpdb->get_results("
			SELECT ID, post_title
			FROM $wpdb->posts p
			LEFT JOIN $wpdb->term_relationships tr
			ON p.ID = tr.object_id
			LEFT JOIN $wpdb->term_taxonomy tt
			ON tr.term_taxonomy_id = tt.term_taxonomy_id
			LEFT JOIN $wpdb->ak_popularity pop
			ON p.ID = pop.post_id
			$join
			WHERE tt.term_id = '".intval($cat_ID)."'
			AND tt.taxonomy = 'category'
			AND post_status = 'publish'
			AND post_type = 'post' 
			AND post_date < NOW()
			$where
			$groupby
			ORDER BY pop.total DESC
			LIMIT ".intval($limit)
		);
		if ($posts) {
			foreach ($posts as $post) {
    			print(
    				$before.'<a href="'.get_permalink($post->ID).'">'
    				.$post->post_title.'</a>'.$after
    			);
			}
		}
		else {
			print($before.'(none)'.$after);
		}
		$wpdb = $temp;
	}
	
	function show_top_ranked_in_month($limit, $before, $after, $m = '') {
		if (empty($m) && is_archive()) {
			global $m;
		}
		if (empty($m)) {
			global $post;
			$m = get_the_time('Ym');
		}
		if (empty($m)) {
			return;
		}
		$year = substr($m, 0, 4);
		$month = substr($m, 4, 2);
		global $wpdb;
		$temp = $wpdb;

		$join = apply_filters('posts_join', '');
		$where = apply_filters('posts_where', '');
		$groupby = apply_filters('posts_groupby', '');
		if (!empty($groupby)) {
			$groupby = ' GROUP BY '.$groupby;
		}
		else {
			$groupby = ' GROUP BY '.$wpdb->posts.'.ID ';
		}

		$posts = $wpdb->get_results("
			SELECT ID, post_title
			FROM $wpdb->posts
			LEFT JOIN $wpdb->ak_popularity pop
			ON $wpdb->posts.ID = pop.post_id
			$join
			WHERE YEAR(post_date) = '$year'
			AND MONTH(post_date) = '$month'
			AND post_status = 'publish'
			AND post_date < NOW()
			$where
			$groupby
			ORDER BY pop.total DESC
			LIMIT ".intval($limit)
		);
		if ($posts) {
			foreach ($posts as $post) {
    			print(
    				$before.'<a href="'.get_permalink($post->ID).'">'
    				.$post->post_title.'</a>'.$after
    			);
			}
		}
		else {
			print($before.'(none)'.$after);
		}
		$wpdb = $temp;
	}
}


// -- "HOOKABLE" FUNCTIONS

function akpc_init() {
	global $wpdb, $akpc;

	$wpdb->ak_popularity = $wpdb->prefix.'ak_popularity';
	$wpdb->ak_popularity_options = $wpdb->prefix.'ak_popularity_options';

	$akpc = new ak_popularity_contest;
	
// CHECK FOR POPULARITY TABLES

	if (isset($_GET['activate']) && $_GET['activate'] == 'true') {
		$result = mysql_list_tables(DB_NAME);
		$tables = array();
		while ($row = mysql_fetch_row($result)) {
			$tables[] = $row[0];
		}
		if (!in_array($wpdb->ak_popularity, $tables) && !in_array($wpdb->ak_popularity_options, $tables)) {
			$akpc->install();
		}
		else {
			$akpc->get_settings();
			$akpc->mine_gap_data();
		}
	}

	$akpc->get_settings();
}

function akpc_view($content) {
	global $akpc;
	$akpc->record_view();
	return $content;
}

function akpc_feedback_comment() {
	global $akpc;
	$akpc->record_feedback('comment');
}

function akpc_comment_status($comment_id) {
	global $akpc;
	$akpc->edit_feedback($comment_id, 'status');
}

function akpc_comment_delete($comment_id) {
	global $akpc;
	$akpc->edit_feedback($comment_id, 'delete');
}

function akpc_feedback_pingback() {
	global $akpc;
	$akpc->record_feedback('pingback');
}

function akpc_feedback_trackback() {
	global $akpc;
	$akpc->record_feedback('trackback');
}

function akpc_publish($post_ID) {
	global $akpc;
	$akpc->create_post_record($post_ID);
}

function akpc_post_delete($post_ID) {
	global $akpc;
	$akpc->delete_post_record($post_ID);
}

function akpc_options_form() {
	global $akpc;
	$akpc->options_form();
}

function akpc_view_stats() {
	global $akpc;
	$akpc->view_stats();
}

function akpc_options() {
	if (function_exists('add_options_page')) {
		add_options_page(
			__('Popularity Contest Options', 'alexking.org')
			, __('Popularity', 'alexking.org')
			, 10
			, basename(__FILE__)
			, 'akpc_options_form'
		);
	}
	if (function_exists('add_submenu_page')) {
		add_submenu_page(
			'index.php'
			, __('Most Popular Posts', 'alexking.org')
			, __('Most Popular Posts', 'alexking.org')
			, 0
			, basename(__FILE__)
			, 'akpc_view_stats'
		);
	}
}
function akpc_options_css() {
	print('<link rel="stylesheet" type="text/css" href="');
	bloginfo('wpurl');
	print('/wp-content/plugins/popularity-contest.php?ak_action=css" />');
}

// -- TEMPLATE FUNCTIONS

function akpc_the_popularity() {
	global $akpc, $post;
	$akpc->show_post_rank($post->ID);
}

function akpc_most_popular($limit = 10, $before = '<li>', $after = '</li>') {
	global $akpc;
	$akpc->show_top_ranked($limit, $before, $after);
}

function akpc_most_popular_in_cat($limit = 10, $before = '<li>', $after = '</li>', $cat_ID = '') {
	global $akpc;
	$akpc->show_top_ranked_in_cat($limit, $before, $after, $cat_ID);
}

function akpc_most_popular_in_month($limit = 10, $before = '<li>', $after = '</li>', $m = '') {
	global $akpc;
	$akpc->show_top_ranked_in_month($limit, $before, $after, $m);
}

function akpc_content_pop($str) {
	global $akpc, $post;
	$show = true;
	$show = apply_filters('akpc_display_popularity', $show, $post);
	if (is_feed() || is_admin_page() || get_post_meta($post->ID, 'hide_popularity', true) || !$show) {
		return $str;
	}
	return $str.'<p class="akpc_pop">'.$akpc->get_post_rank($post->ID).'</p>';
}

// -- HANDLE ACTIONS

if (!empty($_POST['ak_action'])) {
	switch($_POST['ak_action']) {
		case 'update_popularity_values': 
			akpc_init();
			$akpc = new ak_popularity_contest;
			$akpc->get_settings();
			$akpc->update_settings();
			break;
	}
}
if (!empty($_GET['ak_action'])) {
	switch($_GET['ak_action']) {
		case 'recount_feedback':
			akpc_init();
			$akpc = new ak_popularity_contest;
			$akpc->get_settings();
			$akpc->recount_feedback();
			break;
		case 'css':
			header("Content-type: text/css");
?>
#akpc_most_popular {
	height: 250px;
	overflow: auto;
	margin-bottom: 10px;
}
#akpc_most_popular td.right, #akpc_options_link {
	text-align: right;
}
#akpc_most_popular td a {
	border: 0;
}
.akpc_report {
	float: left;
	margin: 5px 30px 20px 0;
	width: 200px;
}
.akpc_report h3 {
	border-bottom: 1px solid #999;
	color #333;
	margin: 0 0 4px 0;
	padding: 0 0 2px 0;
}
.akpc_report ol {
	margin: 0 0 0 20px;
	padding: 0;
}
.akpc_report ol li span {
	float: right;
}
.akpc_report ol li a {
	border: 0;
	display: block;
	margin: 0 30px 0 0;
}
.clear {
	clear: both;
	float: none;
}
#akpc_template_tags dl {
	margin-left: 10px;
}
#akpc_template_tags dl dt {
	font-weight: bold;
	margin: 0 0 5px 0;
}
#akpc_template_tags dl dd {
	margin: 0 0 15px 0;
	padding: 0 0 0 15px;
}
<?php
			die();
			break;
	}
}

// -- GET HOOKED

if (AKPC_SHOWPOP == 1) {
	add_action('the_content', 'akpc_content_pop');
	add_action('the_excerpt', 'akpc_content_pop');
}

add_action('init', 'akpc_init');
add_action('admin_menu', 'akpc_options');
add_action('admin_head', 'akpc_options_css');

add_action('the_content', 'akpc_view');
add_action('comment_post', 'akpc_feedback_comment');
add_action('pingback_post', 'akpc_feedback_pingback');
add_action('trackback_post', 'akpc_feedback_trackback');

add_action('publish_post', 'akpc_publish');
add_action('delete_post', 'akpc_post_delete');

add_action('publish_page', 'akpc_publish');
add_action('delete_page', 'akpc_post_delete');

// Unfortunately, these don't seem to get called reliably
// w/ usable data available. If they do become available, 
// the code here is ready!
add_action('wp_set_comment_status', 'akpc_comment_status');
add_action('delete_comment', 'akpc_comment_delete');

?>