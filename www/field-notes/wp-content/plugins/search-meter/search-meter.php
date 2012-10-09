<?php
/*
Plugin Name: Search Meter
Plugin URI: http://www.thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/
Description: Keeps track of what your visitors are searching for. After you have activated this plugin, you can check the Search Meter section in the Dashboard to see what your visitors are searching for on your blog.
Version: 2.5
Author: Bennett McElwee
Author URI: http://www.thunderguy.com/semicolon/

$Revision: 93952 $


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
* For full details, see http://www.thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/

Thanks to Kaufman (http://www.terrik.com/wordpress/) and the many others who have offered suggestions.


Copyright (C) 2005-09 Bennett McElwee (bennett at thunderguy dotcom)

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


if (!is_plugin_page()) :


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

define('TGUY_SM_STATS_CAPABILITY_LEVEL', 1);
// Minimum user capability level for users to be able to see stats.

define('TGUY_SM_OPTIONS_CAPABILITY_LEVEL', 10);
// Minimum user capability level for users to be able to set options.


// Template Tags


function sm_list_popular_searches($before = '', $after = '', $count = 5) {
// List the most popular searches in the last month in decreasing order of popularity.
	global $wpdb, $table_prefix;
	$count = intval($count);
	// This is a simpler query than the report query, and may produce
	// slightly different results. This query returns searches if they
	// have ever had any hits, even if the last search yielded no hits.
	// This makes for a more efficient search -- important if this
	// function will be used in a sidebar.
	$results = $wpdb->get_results(
		"SELECT `terms`,
			SUM( `count` ) AS countsum
		FROM `{$table_prefix}searchmeter`
		WHERE DATE_SUB( CURDATE( ) , INTERVAL 30 DAY ) <= `date`
		AND 0 < `last_hits`
		GROUP BY `terms`
		ORDER BY countsum DESC, `terms` ASC
		LIMIT $count");
	if (count($results)) {
		echo "$before\n<ul>\n";
		foreach ($results as $result) {
			echo '<li><a href="'. get_settings('home') . '/search/' . urlencode($result->terms) . '">'. htmlspecialchars($result->terms) .'</a></li>'."\n";
		}
		echo "</ul>\n$after\n";
	}
}

function sm_list_recent_searches($before = '', $after = '', $count = 5) {
// List the most recent successful searches.
	global $wpdb, $table_prefix;
	$count = intval($count);
	$results = $wpdb->get_results(
		"SELECT `terms`, `datetime`
		FROM `{$table_prefix}searchmeter_recent`
		WHERE 0 < `hits`
		ORDER BY `datetime` DESC
		LIMIT $count");
	if (count($results)) {
		echo "$before\n<ul>\n";
		foreach ($results as $result) {
			echo '<li><a href="'. get_settings('home') . '/search/' . urlencode($result->terms) . '">'. htmlspecialchars($result->terms) .'</a></li>'."\n";
		}
		echo "</ul>\n$after\n";
	}
}


// Hooks


if (function_exists('register_activation_hook')) {
	register_activation_hook(__FILE__, 'tguy_sm_init');
} else {
	add_action('init', 'tguy_sm_init');
}
add_action('init', 'tguy_sm_register_widgets');
add_filter('the_posts', 'tguy_sm_save_search', 20); // run after other plugins
add_action('admin_head', 'tguy_sm_stats_css');
add_action('admin_menu', 'tguy_sm_add_admin_pages');


// Functionality


function tguy_sm_init() {
	tguy_sm_create_summary_table();
	tguy_sm_create_recent_table();
}

// Widgets

function sm_list_popular_searches_widget($args) {
	$options = get_option('tguy_search_meter');
	$number = sm_constrain_widget_search_count((int)$options['popular-searches-number']);
	sm_list_popular_searches('<h2 class="widgettitle">Popular Searches</h2>', '', $number);
}

function sm_list_popular_searches_control() {
	$options = get_option('tguy_search_meter');
	if ($_POST["popular-searches-submit"]) {
		$options['popular-searches-number'] = (int) $_POST["popular-searches-number"];
		update_option('tguy_search_meter', $options);
	}
	$number = sm_constrain_widget_search_count((int)$options['popular-searches-number']);
?>
			<p>This widget shows the most popular successful search terms in the last month.</p>
			<p><label for="popular-searches-number"><?php _e('Number of searches to show:'); ?> <input style="width: 5ex; text-align: center;" id="popular-searches-number" name="popular-searches-number" type="text" value="<?php echo $number; ?>" /></label></p>
			<p><em>Powered by Search Meter</em></p>
			<input type="hidden" id="popular-searches-submit" name="popular-searches-submit" value="1" />
<?php
}

function sm_list_recent_searches_widget($args) {
	$options = get_option('tguy_search_meter');
	$number = sm_constrain_widget_search_count((int)$options['recent-searches-number']);
	sm_list_recent_searches('<h2 class="widgettitle">Recent Searches</h2>', '', $number);
}

function sm_list_recent_searches_control() {
	$options = get_option('tguy_search_meter');
	if ($_POST["recent-searches-submit"]) {
		$options['recent-searches-number'] = (int) $_POST["recent-searches-number"];
		update_option('tguy_search_meter', $options);
	}
	$number = sm_constrain_widget_search_count((int)$options['recent-searches-number']);
?>
			<p>This widget shows the most recent successful search terms.</p>
			<p><label for="recent-searches-number"><?php _e('Number of searches to show:'); ?> <input style="width: 5ex; text-align: center;" id="recent-searches-number" name="recent-searches-number" type="text" value="<?php echo $number; ?>" /></label></p>
			<p><em>Powered by Search Meter</em></p>
			<input type="hidden" id="recent-searches-submit" name="recent-searches-submit" value="1" />
<?php
}

function sm_constrain_widget_search_count($number) {
	return max(1, min((int)$number, 100));
}

function tguy_sm_register_widgets() {
	if (function_exists('register_sidebar_widget') ) {
		register_sidebar_widget('Recent Searches', 'sm_list_recent_searches_widget', 'recent_searches');
		register_sidebar_widget('Popular Searches', 'sm_list_popular_searches_widget', 'popular_searches');
		register_widget_control('Recent Searches', 'sm_list_recent_searches_control', '', '120px');
		register_widget_control('Popular Searches', 'sm_list_popular_searches_control', '', '120px');
	}
}

// Keep track of how many times SM has been called for this request.
// Normally we only record the first time.
$tguy_sm_action_count = 0;

function tguy_sm_save_search(&$posts) {
// Check if the request is a search, and if so then save details.
// This is a filter but does not change the posts.
	global $wpdb, $wp_query, $table_prefix, $tguy_sm_action_count;

	++$tguy_sm_action_count;
	if (is_search()
	&& !is_paged() // not the second or subsequent page of a previously-counted search
	&& !is_admin() // not using the administration console
	&& (1 == $tguy_sm_action_count || TGUY_SM_ALLOW_DUPLICATE_SAVES)
	&& ($_SERVER['HTTP_REFERER'] || TGUY_SM_ALLOW_EMPTY_REFERER) // proper referrer (otherwise could be search engine, cache...)
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
				$details .= $header . ': ' . $_SERVER[$header] . "\n";
			}
		}

		// Sanitise as necessary
		$search_string = $wpdb->escape($search_string);
		$search_terms = $wpdb->escape($search_terms);
		$details = $wpdb->escape($details);

		// Save the individual search to the DB
		$query = "INSERT INTO `{$table_prefix}searchmeter_recent` (`terms`,`datetime`,`hits`,`details`)
		VALUES ('$search_string',NOW(),$hit_count,'$details')";
		$success = $wpdb->query($query);
		if ($success) {
			// Ensure table never grows larger than TGUY_SM_HISTORY_SIZE + 100
			$rowcount = $wpdb->get_var(
				"SELECT count(`datetime`) as rowcount
				FROM `{$table_prefix}searchmeter_recent`");
			if ((TGUY_SM_HISTORY_SIZE + 100) < $rowcount) {
				// find time of (TGUY_SM_HISTORY_SIZE)th entry
				$dateZero = $wpdb->get_var(
					"SELECT `datetime`
					FROM `{$table_prefix}searchmeter_recent`
					ORDER BY `datetime` DESC LIMIT ".TGUY_SM_HISTORY_SIZE.", 1");
				$query = "DELETE FROM `{$table_prefix}searchmeter_recent` WHERE `datetime` < '$dateZero'";
				$success = $wpdb->query($query);
			}
		}
		// Save search summary into the DB. Usually this will be a new row, so try to insert first
		$query = "INSERT INTO `{$table_prefix}searchmeter` (`terms`,`date`,`count`,`last_hits`)
		VALUES ('$search_terms',CURDATE(),1,$hit_count)";
		// Temporarily suppress errors, as this query is expected to fail on duplicate searches in a single day. Thanks to James Collins.
		$suppress = $wpdb->suppress_errors();
		$success = $wpdb->query($query);
		$wpdb->suppress_errors($suppress);
		if (!$success) {
			$query = "UPDATE `{$table_prefix}searchmeter` SET
				`count` = `count` + 1,
				`last_hits` = $hit_count
			WHERE `terms` = '$search_terms' AND `date` = CURDATE()";
			$success = $wpdb->query($query);
		}
	}
	return $posts;
}

function tguy_sm_create_summary_table() {
// Create the table if not already there.
	global $wpdb, $table_prefix;
	$table_name = $table_prefix . "searchmeter";
	if ($wpdb->get_var("show tables like '$table_name'") != $table_name) {
		if (file_exists(ABSPATH . 'wp-admin/includes/upgrade.php')) {
			require_once(ABSPATH . '/wp-admin/includes/upgrade.php');
		} else { // Wordpress 2.2 or earlier
			require_once(ABSPATH . 'wp-admin/upgrade-functions.php');
		}
		dbDelta("CREATE TABLE `{$table_name}` (
				`terms` VARCHAR(50) NOT NULL,
				`date` DATE NOT NULL,
				`count` INT(11) NOT NULL,
				`last_hits` INT(11) NOT NULL,
				PRIMARY KEY (`terms`,`date`)
				);
			");
	}
}

function tguy_sm_create_recent_table() {
// Create the table if not already there.
	global $wpdb, $table_prefix;
	$table_name = $table_prefix . "searchmeter_recent";
	if ($wpdb->get_var("show tables like '$table_name'") != $table_name) {
		if (file_exists(ABSPATH . 'wp-admin/includes/upgrade.php')) {
			require_once(ABSPATH . '/wp-admin/includes/upgrade.php');
		} else { // Wordpress 2.2 or earlier
			require_once(ABSPATH . 'wp-admin/upgrade-functions.php');
		}
		dbDelta("CREATE TABLE `{$table_name}` (
				`terms` VARCHAR(50) NOT NULL,
				`datetime` DATETIME NOT NULL,
				`hits` INT(11) NOT NULL,
				`details` TEXT NOT NULL,
				KEY `datetimeindex` (`datetime`)
				);
			");
	}
}

function tguy_sm_reset_stats() {
	global $wpdb, $table_prefix;
	// Delete all records
	$wpdb->query("DELETE FROM `{$table_prefix}searchmeter`");
	$wpdb->query("DELETE FROM `{$table_prefix}searchmeter_recent`");
}

function tguy_sm_add_admin_pages() {
	add_submenu_page('index.php', 'Search Meter Statistics', 'Search Meter', TGUY_SM_STATS_CAPABILITY_LEVEL, __FILE__, 'tguy_sm_stats_page');
	add_options_page('Search Meter', 'Search Meter', TGUY_SM_OPTIONS_CAPABILITY_LEVEL, __FILE__, 'tguy_sm_options_page');
}


// Display information


function tguy_sm_stats_css() {
?>
<style type="text/css">
#search_meter_menu { 
	margin: 0;
	padding: 0; 
}
#search_meter_menu li { 
	display: inline; list-style-type: none; list-style-image: none; list-style-position: outside; text-align: center;
	margin: 0;
	line-height: 170%;
}
#search_meter_menu li.current { 
	font-weight: bold; 
	background-color: #fff;
	color: #000;
	padding: 5px;
}
#search_meter_menu a {
	background-color: #fff;
	color: #69c; 
	padding: 4px;
	font-size: 12px;
	border-bottom: none;
}
#search_meter_menu a:hover {
	background-color: #69c;
	color: #fff; 
}
#search_meter_menu + .wrap {
	margin-top: 0;
}
div.sm-stats-table {
	float: left;
	padding-right: 5em;
	padding-bottom: 3ex;
}
div.sm-stats-table h3 {
	margin-top: 0;
}
div.sm-stats-table .left {
	text-align: left;
}
div.sm-stats-table .right {
	text-align: right;
}
div.sm-stats-clear {
	clear: both;
}
</style>
<?php
}

function tguy_sm_stats_page() {
	$recent_count = intval($_GET['recent']);
	if (0 < $recent_count) {
		$do_show_details = intval($_GET['details']);
		tguy_sm_recent_page($recent_count, $do_show_details);
	} else {
		tguy_sm_summary_page();
	}
}

function tguy_sm_summary_page() {
	global $wpdb, $table_prefix;

	$options = get_option('tguy_search_meter');
	$is_disable_donation = $options['sm_disable_donation'];

	// Delete old records
	$result = $wpdb->query(
	"DELETE FROM `{$table_prefix}searchmeter`
	WHERE `date` < DATE_SUB( CURDATE() , INTERVAL 30 DAY)");
	echo "<!-- Search Meter: deleted $result old rows -->\n";
	?>
	<div class="wrap">

		<ul id="search_meter_menu">
		<li class="current">Summary</li>
		<li><a href="<?php echo $_SERVER['PHP_SELF'] . "?page=" . $_REQUEST['page'] . "&amp;recent=100" ?>">Last 100 Searches</a></li>
		<li><a href="<?php echo $_SERVER['PHP_SELF'] . "?page=" . $_REQUEST['page'] . "&amp;recent=500" ?>">Last 500 Searches</a></li>
		</ul>

		<h2>Search summary</h2>

		<p>These tables show the most popular searches on your blog for the given time periods. <strong>Term</strong> is the text that was searched for; you can click it to see which posts contain that term. (This won't be counted as another search.) <strong>Searches</strong> is the number of times the term was searched for. <strong>Results</strong> is the number of posts that were returned from the <em>last</em> search for that term.</p>

		<div class="sm-stats-table">
		<h3>Yesterday and today</h3>
		<?php tguy_sm_summary_table($results, 1, true); 	?>
		</div>
		<div class="sm-stats-table">
		<h3>Last 7 days</h3>
		<?php tguy_sm_summary_table($results, 7, true); ?>
		</div>
		<div class="sm-stats-table">
		<h3>Last 30 days</h3>
		<?php tguy_sm_summary_table($results, 30, true); ?>
		</div>
		<div class="sm-stats-clear"></div>

		<h2>Unsuccessful search summary</h2>

		<p>These tables show only the search terms for which the last search yielded no results. People are searching your blog for these terms; maybe you should give them what they want.</p>

		<div class="sm-stats-table">
		<h3>Yesterday and today</h3>
		<?php tguy_sm_summary_table($results, 1, false); ?>
		</div>
		<div class="sm-stats-table">
		<h3>Last 7 days</h3>
		<?php tguy_sm_summary_table($results, 7,false); 	?>
		</div>
		<div class="sm-stats-table">
		<h3>Last 30 days</h3>
		<?php tguy_sm_summary_table($results, 30, false); ?>
		</div>
		<div class="sm-stats-clear"></div>

		<h2>Notes</h2>

		<?php if (current_user_can(TGUY_SM_OPTIONS_CAPABILITY_LEVEL)) : ?>
		<p>To manage your search statistics, go to the <strong>Settings</strong> section and choose <strong>Search Meter</strong>.</p>
		<?php endif; ?>

		<p>For information and updates, see the <a href="http://www.thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/">Search Meter home page</a>. You can also offer suggestions, request new features or report problems.</p>

		<?php if (!$options['sm_disable_donation']) { tguy_sm_show_donation_message(); } ?>

	</div>
	<?php
}

function tguy_sm_summary_table($results, $days, $do_include_successes = false) {
	global $wpdb, $table_prefix;
	// Explanation of the query:
	// We group by terms, because we want all rows for a term to be combined.
	// For the search count, we simply SUM the count of all searches for the term.
	// For the result count, we only want the number of results for the latest search. Each row
	// contains the result for the latest search on that row's date. So for each date,
	// CONCAT the date with the number of results, and take the MAX. This gives us the
	// latest date combined with its hit count. Then strip off the date with SUBSTRING.
	// This Rube Goldberg-esque procedure should work in older MySQL versions that
	// don't allow subqueries. It's inefficient, but that doesn't matter since it's
	// only used in admin pages and the tables involved won't be too big.
	$hits_selector = $do_include_successes ? '' : 'HAVING hits = 0';
	$results = $wpdb->get_results(
		"SELECT `terms`,
			SUM( `count` ) AS countsum,
			SUBSTRING( MAX( CONCAT( `date` , ' ', `last_hits` ) ) , 12 ) AS hits
		FROM `{$table_prefix}searchmeter`
		WHERE DATE_SUB( CURDATE( ) , INTERVAL $days DAY ) <= `date`
		GROUP BY `terms`
		$hits_selector
		ORDER BY countsum DESC, `terms` ASC
		LIMIT 20");
	if (count($results)) {
		?>
		<table cellpadding="3" cellspacing="2">
		<tbody>
		<tr class="alternate"><th class="left">Term</th><th>Searches</th>
		<?php
		if ($do_include_successes) {
			?><th>Results</th><?php
		}
		?></tr><?php
		$class= '';
		foreach ($results as $result) {
			?>
			<tr class="<?php echo $class ?>">
			<td><a href="<?php echo get_bloginfo('wpurl').'/wp-admin/edit.php?s='.urlencode($result->terms).'&submit=Search' ?>"><?php echo htmlspecialchars($result->terms) ?></a></td>
			<td class="right"><?php echo $result->countsum ?></td>
			<?php
			if ($do_include_successes) {
				?>
				<td class="right"><?php echo $result->hits ?></td></tr>
				<?php
			}
			$class = ($class == '' ? 'alternate' : '');
		}
		?>
		</tbody>
		</table>
		<?php
	} else {
		?><p>No searches recorded for this period.</p><?php
	}
}

function tguy_sm_recent_page($max_lines, $do_show_details) {
	global $wpdb, $table_prefix;

	$options = get_option('tguy_search_meter');
	$is_details_available = $options['sm_details_verbose'];
	$is_disable_donation = $options['sm_disable_donation'];
	$this_url_base = $_SERVER['PHP_SELF'] . '?page=' . $_REQUEST['page'];
	$this_url_recent_arg = '&amp;recent=' . $max_lines;
	?>
	<div class="wrap">

		<ul id="search_meter_menu">
		<li><a href="<?php echo $this_url_base ?>">Summary</a></li>
		<?php if (100 == $max_lines) : ?>
			<li class="current">Last 100 Searches</li>
		<?php else : ?>
			<li><a href="<?php echo $this_url_base . '&amp;recent=100' ?>">Last 100 Searches</a></li>
		<?php endif ?>
		<?php if (500 == $max_lines) : ?>
			<li class="current">Last 500 Searches</li>
		<?php else : ?>
			<li><a href="<?php echo $this_url_base . '&amp;recent=500' ?>">Last 500 Searches</a></li>
		<?php endif ?>
		</ul>

		<h2>Recent searches</h2>

		<p>This table shows the last <?php echo $max_lines; ?> searches on this blog. <strong>Term</strong> is the text that was searched for; you can click it to see which posts contain that term. (This won't be counted as another search.) <strong>Results</strong> is the number of posts that were returned from the search.
		</p>

		<div class="sm-stats-table">
		<?php
		$query = 
			"SELECT `datetime`, `terms`, `hits`, `details`
			FROM `{$table_prefix}searchmeter_recent`
			ORDER BY `datetime` DESC, `terms` ASC
			LIMIT $max_lines";
		$results = $wpdb->get_results($query);
		if (count($results)) {
			?>
			<table cellpadding="3" cellspacing="2">
			<tbody>
			<tr class="alternate"><th class="left">Date &amp; time</th><th class="left">Term</th><th class="right">Results</th>
			<?php if ($do_show_details) { ?>
				<th class="left">Details</th>
			<?php } else if ($is_details_available) { ?>
				<th class="left"><a href="<?php echo $this_url_base . $this_url_recent_arg . '&amp;details=1' ?>">Show details</a></th>
			<?php } ?>
			</tr>
			<?php
			$class= '';
			foreach ($results as $result) {
				?>
				<tr valign="top" class="<?php echo $class ?>">
				<td><?php echo $result->datetime ?></td>
				<td><a href="<?php echo get_bloginfo('wpurl').'/wp-admin/edit.php?s='.urlencode($result->terms).'&submit=Search' ?>"><?php echo htmlspecialchars($result->terms) ?></a></td>
				<td class="right"><?php echo $result->hits ?></td>
				<?php if ($do_show_details) : ?>
					<td><?php echo str_replace("\n", "<br />", htmlspecialchars($result->details)) ?></td>
				<?php endif ?>
				</tr>
				<?php
				$class = ($class == '' ? 'alternate' : '');
			}
			?>
			</tbody>
			</table>
			<?php
		} else {
			?><p>No searches recorded.</p><?php
		}
		?>
		</div>
		<div class="sm-stats-clear"></div>

		<h2>Notes</h2>

		<?php if (current_user_can(TGUY_SM_OPTIONS_CAPABILITY_LEVEL)) : ?>
		<p>To manage your search statistics, go to the <strong>Settings</strong> section and choose <strong>Search Meter</strong>.</p>
		<?php endif; ?>

		<p>For information and updates, see the <a href="http://www.thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/">Search Meter home page</a>. You can also offer suggestions, request new features or report problems.</p>

		<?php if (!$options['sm_disable_donation']) { tguy_sm_show_donation_message(); } ?>

	</div>
	<?php
}


endif; // if (!is_plugin_page())


function tguy_sm_options_page() {
	if (isset($_POST['submitted'])) {
		check_admin_referer('search-meter-update-options_all');
		$options = get_option('tguy_search_meter');
		$options['sm_details_verbose']  = (bool)($_POST['sm_details_verbose']);
		$options['sm_disable_donation'] = (bool)($_POST['sm_disable_donation']);
		update_option('tguy_search_meter', $options);
		echo '<div id="message" class="updated fade"><p><strong>Plugin settings saved.</strong></p></div>';
	} else if (isset($_POST['tguy_sm_reset'])) {
		check_admin_referer('search-meter-reset-stats');
		tguy_sm_reset_stats();
		echo '<div id="message" class="updated fade"><p><strong>Statistics have been reset.</strong></p></div>';
	}
	$options = get_option('tguy_search_meter');
	?>
	<div class="wrap">

		<h2>Search Meter Options</h2>

		<form name="searchmeter" action="" method="post">
			<?php
			if (function_exists('wp_nonce_field')) {
				wp_nonce_field('search-meter-update-options_all');
			}
			?>

			<input type="hidden" name="submitted" value="1" />

			<table class="form-table">
				<tr>
					<th class="th-full" scope="row">
						<label for="sm_details_verbose">
							<input type="checkbox" id="sm_details_verbose" name="sm_details_verbose" <?php echo ($options['sm_details_verbose']==true?"checked=\"checked\"":"") ?> />
							Keep detailed information about recent searches (taken from HTTP headers)
						</label>
					</th>
				</tr>
				<tr>
					<th class="th-full" scope="row">
						<label for="sm_disable_donation">
							<input type="checkbox" id="sm_disable_donation" name="sm_disable_donation" <?php echo ($options['sm_disable_donation']==true?"checked=\"checked\"":"") ?> />
							Hide the &#8220;Do you find this plugin useful?&#8221; box
						</label>
					</th>
				</tr>
			</table>

			<p class="submit">
				<input name="Submit" class="button-primary" value="Save Changes" type="submit">
			</p>
		</form>

		<h3>Reset statistics</h3>

		<p>Click this button to reset all search statistics. This will delete all information about previous searches.</p>

		<form name="tguy_sm_admin" action="" method="post">
			<?php
			if (function_exists('wp_nonce_field')) {
				wp_nonce_field('search-meter-reset-stats');
			}
			?>
			<p class="submit">
				<input name="tguy_sm_reset" class="button-secondary delete" value="Reset Statistics" type="submit" onclick="return confirm('You are about to delete all saved search statistics.\n  \'Cancel\' to stop, \'OK\' to delete.');" />
			</p>
		</form>

		<h3>Notes</h3>

		<p>To see your search statistics, go to the <strong>Dashboard</strong> and choose <strong>Search Meter</strong>.</p>

		<p>For information and updates, see the <a href="http://www.thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/">Search Meter home page</a>. At that page, you can also offer suggestions, request new features or report problems.</p>

		<?php if (!$options['sm_disable_donation']) { tguy_sm_show_donation_message(); } ?>

	</div>
	<?php
}

function tguy_sm_show_donation_message() {
?>
<p><div style="margin: 0; padding: 0 2ex 0.25ex 0; float: left;">
<?php tguy_sm_show_donation_button() ?>
</div>
<strong>Do you find this plugin useful?</strong><br />
I write WordPress plugins because I enjoy doing it, but it does take up a lot
of my time. If you think this plugin is useful, please consider donating some appropriate
amount by clicking the Donate button. Thank you.</p>
<?php
}

function tguy_sm_show_donation_button() {
// I wish PayPal offered a simple little REST-style URL instead of this monstrosity
?><form action="https://www.paypal.com/cgi-bin/webscr" method="post" style="margin:0; padding:0;"
><input name="cmd" value="_s-xclick" type="hidden" style="margin:0; padding:0;"
/><input src="https://www.paypal.com/en_US/i/btn/x-click-but04.gif" name="submit" alt="Make payments with PayPal - it's fast, free and secure!" border="0" type="image" style="margin:0; padding:0;"
/><input name="encrypted" value="-----BEGIN PKCS7-----MIIHXwYJKoZIhvcNAQcEoIIHUDCCB0wCAQExggEwMIIBLAIBADCBlDCBjjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MRQwEgYDVQQKEwtQYXlQYWwgSW5jLjETMBEGA1UECxQKbGl2ZV9jZXJ0czERMA8GA1UEAxQIbGl2ZV9hcGkxHDAaBgkqhkiG9w0BCQEWDXJlQHBheXBhbC5jb20CAQAwDQYJKoZIhvcNAQEBBQAEgYA7BglQn0K1FJvdqm+zAop0IFZb02mJnn56wpZYpbqWE6go360iySXAwUS8eMEMSxp2/OUmWh6VQzm07kEP0buqLG0wwi4yOwawTYB2cahVUPadwYA+KyE78xQI4plMGO1LRchjNdVPkjFuD5s0K64SyYOwtCPYOo/Xs1vZPbpH/zELMAkGBSsOAwIaBQAwgdwGCSqGSIb3DQEHATAUBggqhkiG9w0DBwQIP5kNv+75+iKAgbhN2BQBAd0BiS1W5qaECVs/v8Jqdoe/SVb+bykh9HucP/8+tYncHVffnDf0TAMxdjlQT65QdNc8T8FGDDhQZN8BwWx2kUwFgxKPBlPvL+KFWcu50jrBsyFsK9zLM260ZR6+aA9ZBdgtMKwCBk/38bo6LmUtZ5PM+LSfJRh3HtFoUKgGndaDYl/9N4vhK2clyt0DaQO3Mum8DTXwb57Aq8pjQPwsUzWl3OqZdZEI+YXJX4xxQIHkKAsSoIIDhzCCA4MwggLsoAMCAQICAQAwDQYJKoZIhvcNAQEFBQAwgY4xCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEWMBQGA1UEBxMNTW91bnRhaW4gVmlldzEUMBIGA1UEChMLUGF5UGFsIEluYy4xEzARBgNVBAsUCmxpdmVfY2VydHMxETAPBgNVBAMUCGxpdmVfYXBpMRwwGgYJKoZIhvcNAQkBFg1yZUBwYXlwYWwuY29tMB4XDTA0MDIxMzEwMTMxNVoXDTM1MDIxMzEwMTMxNVowgY4xCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTEWMBQGA1UEBxMNTW91bnRhaW4gVmlldzEUMBIGA1UEChMLUGF5UGFsIEluYy4xEzARBgNVBAsUCmxpdmVfY2VydHMxETAPBgNVBAMUCGxpdmVfYXBpMRwwGgYJKoZIhvcNAQkBFg1yZUBwYXlwYWwuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDBR07d/ETMS1ycjtkpkvjXZe9k+6CieLuLsPumsJ7QC1odNz3sJiCbs2wC0nLE0uLGaEtXynIgRqIddYCHx88pb5HTXv4SZeuv0Rqq4+axW9PLAAATU8w04qqjaSXgbGLP3NmohqM6bV9kZZwZLR/klDaQGo1u9uDb9lr4Yn+rBQIDAQABo4HuMIHrMB0GA1UdDgQWBBSWn3y7xm8XvVk/UtcKG+wQ1mSUazCBuwYDVR0jBIGzMIGwgBSWn3y7xm8XvVk/UtcKG+wQ1mSUa6GBlKSBkTCBjjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MRQwEgYDVQQKEwtQYXlQYWwgSW5jLjETMBEGA1UECxQKbGl2ZV9jZXJ0czERMA8GA1UEAxQIbGl2ZV9hcGkxHDAaBgkqhkiG9w0BCQEWDXJlQHBheXBhbC5jb22CAQAwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOBgQCBXzpWmoBa5e9fo6ujionW1hUhPkOBakTr3YCDjbYfvJEiv/2P+IobhOGJr85+XHhN0v4gUkEDI8r2/rNk1m0GA8HKddvTjyGw/XqXa+LSTlDYkqI8OwR8GEYj4efEtcRpRYBxV8KxAW93YDWzFGvruKnnLbDAF6VR5w/cCMn5hzGCAZowggGWAgEBMIGUMIGOMQswCQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFjAUBgNVBAcTDU1vdW50YWluIFZpZXcxFDASBgNVBAoTC1BheVBhbCBJbmMuMRMwEQYDVQQLFApsaXZlX2NlcnRzMREwDwYDVQQDFAhsaXZlX2FwaTEcMBoGCSqGSIb3DQEJARYNcmVAcGF5cGFsLmNvbQIBADAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMDYwMjA3MTEyOTQ5WjAjBgkqhkiG9w0BCQQxFgQUO31wm3aCiCMdh2XIXxIAeS8LfBIwDQYJKoZIhvcNAQEBBQAEgYB3CtAsDm+ZRBkd/XLEhUx0IbaeyK9ymOT8R5EQfSZnoJ+QP05XWBc8zi21wSOiQ8nH9LtN2MtS4GRBAQFU1vbvGxw6bG2gJfggJ1pDPUOtkFgf1YA8At+m2I6G2E+YWx2/QHdfMo3BpTJWQOUka52wjuTmIX9X6+CFMPokF91f0w==-----END PKCS7-----
" type="hidden" style="margin:0; padding:0;"
/></form><?php
}
