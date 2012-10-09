<?php
/*
Plugin Name: pixelstats
Plugin URI: http://www.arrogant.de/pixelstats/
Description: Generates statistics about article views for each post using counter pixel.
Author: Timo Fuchs <pixelstats@arrogant.de>
Version: 0.8.2
Author URI: http://www.arrogant.de
License: GPLv3
*/

// Pre-2.6 compatibility
if ( ! defined( 'WP_CONTENT_URL' ) )
      define( 'WP_CONTENT_URL', get_option( 'siteurl' ).DIRECTORY_SEPARATOR.'wp-content' );
if ( ! defined( 'WP_CONTENT_DIR' ) )
      define( 'WP_CONTENT_DIR', ABSPATH.'wp-content' );
if ( ! defined( 'WP_PLUGIN_URL' ) )
      define( 'WP_PLUGIN_URL', WP_CONTENT_URL.'/plugins' );
if ( ! defined( 'WP_PLUGIN_DIR' ) )
      define( 'WP_PLUGIN_DIR', WP_CONTENT_DIR.'/plugins' );


if (! class_exists('PixelstatsPlugin')) {
	class PixelstatsPlugin {
		function PixelstatsPlugin() {
			if (isset($_GET['activate']) and $_GET['activate'] == 'true') {
				add_action('init', array(&$this, '_assert_db_structure'));
			}
			add_action('admin_menu', array(&$this, 'add_pixelstats_admin_page'));
			add_action('admin_menu', array(&$this, 'add_pixelstats_options_page'));
			add_action('admin_head', array(&$this, 'pixelstats_css'));
			add_filter('init', array(&$this, 'pixelstats_set_visitor_id'));
			add_filter('the_content', array(&$this, 'pixelstats_display_hook'));
			add_filter('the_content_rss', array(&$this, 'pixelstats_display_hook'));
			add_action('wp_dashboard_setup', array(&$this, 'pixelstats_dashboard_setup')); 
			add_filter('manage_posts_columns', array(&$this, 'pixelstats_manage_post_add_column'));
			add_action('manage_posts_custom_column', array(&$this, 'pixelstats_manage_post_show_link'), 5, 2);
			add_filter('manage_pages_columns', array(&$this, 'pixelstats_manage_post_add_column'));
			add_action('manage_pages_custom_column', array(&$this, 'pixelstats_manage_post_show_link'), 5, 2);
			
			$this->_assert_options();
		}
		
		
		/*************************************************************
		 * Plugin hooks
		 *************************************************************/
		/*
		 * pixelstats dashboard widget
		 */
		function pixelstats_dashboard_setup() {
			wp_add_dashboard_widget( 'pixelstats_widget', __( 'pixelstats' ), 'pixelstats_widget' );
		}
		
		/*
		 * Add CSS
		 */
		function pixelstats_css() {
			?><style type="text/css">table.widefat th.column-pixelstats { width: 80px;}</style><?php
		}
		
		/*
		 * Add custom column in post list
		 */
		function pixelstats_manage_post_add_column( $defaults ) {
			$defaults['pixelstats'] = 'Pixelstats';
			return $defaults;
		}
		
		/*
		 * Show link in custom column
		 */
		function pixelstats_manage_post_show_link( $column_name, $id) {
			if( $column_name == 'pixelstats' ) {
				?>
				<a href="index.php?page=pixelstats&pixelstats_page=views_single&post_id=<?php echo $id; ?>">Show stats</a>
				<?php
		    }
		}
		/*
		 * Display the tracking pixel
		 */
		function pixelstats_display_hook($content='') {
			global $post;
			
			$conditionals = get_option('pixelstats_display_conditionals');
			if (((is_home()     and $conditionals['is_home']) or
			    (is_single()   and $conditionals['is_single']) or
			    (is_page()     and $conditionals['is_page']) or
			    (is_feed()     and $conditionals['is_feed'])) and 
				((is_user_logged_in() and get_option('pixelstats_count_logged_in')) or
				!is_user_logged_in()))
			$content .= "<img src=\"".WP_PLUGIN_URL."/".plugin_basename(dirname(__FILE__))."/trackingpixel.php?post_id=".$post->ID."&amp;ts=".time()."\" style=\"display:none;\" alt=\"pixelstats trackingpixel\"/>";

			return $content;
		}
		
		/*
		 * Add the admin page for this plugin.
		 */
		function add_pixelstats_admin_page() {
			if (function_exists('add_options_page')) {
				//add_menu_page('overview', 'pixelstats', 8, __FILE__, array(&$this, '_display_admin_page'));
				add_submenu_page('index.php', 'pixelstats analysis', 'pixelstats analysis', 8, 'pixelstats', array(&$this, '_display_admin_page'));
				//add_options_page('pixelstats', 'pixelstats', 9, __FILE__, array(&$this, '_display_options_page'));
			}
		}
		
		/*
		 * Add an options pane
		 */
		function add_pixelstats_options_page() {
			if (function_exists('add_options_page')) {
				add_options_page('pixelstats options', 'pixelstats options', 9, __FILE__, array(&$this, '_display_options_page'));
				//add_submenu_page(__FILE__, 'pixelstats settings', 'settings', 8, __FILE__, array(&$this, '_display_admin_page'));
			}
		}
		
		/*
		 * set visitor id
		 */
		function pixelstats_set_visitor_id() {
			if(empty($_COOKIE['pixelstats_visitor_id'])) {
				$visitor_id = substr(md5(sha1(crc32(md5(base64_decode(microtime())).microtime()))), 0, 32);
				setcookie('pixelstats_visitor_id', $visitor_id, time()+3600*24*30);
			}
		}
		
		/*************************************************************
		 * Functions
		 *************************************************************/
		
		/*
		 * Create the DB structure for this plugin (if not already existing)
		THIS PLUGIN DOES NOT DELETE ITS TABLE DATA WHEN DEACTIVATED
		
		http://codex.wordpress.org/Function_Reference/wpdb_Class
		 */
		function _assert_db_structure() {
			global $wpdb;
			
			$wpdb->query("CREATE TABLE IF NOT EXISTS ".$wpdb->prefix."pixelstats ( `stat_post_id` int NOT NULL default '0', `stat_date` datetime NOT NULL default '0000-00-00 00:00:00' , `stat_visitor_id` VARCHAR( 32 ) NULL , INDEX ".$wpdb->prefix."pixelstats_post_ids (stat_post_id,stat_date)) ENGINE = MYISAM");
			
			 $wpdb->query("CREATE TABLE IF NOT EXISTS ".$wpdb->prefix."pixelstats_daily (`stat_post_id` INT NOT NULL DEFAULT '0', `day` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00', `unique_visits` INT NOT NULL DEFAULT '0', `total_visits` INT NOT NULL DEFAULT '0', INDEX ".$wpdb->prefix."pixelstats_daily_post_ids (stat_post_id,day) ) ENGINE = MYISAM");
			
			$wpdb->query("CREATE TABLE IF NOT EXISTS ".$wpdb->prefix."pixelstats_total (`stat_post_id` INT NOT NULL DEFAULT '0', `until_day` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00', `unique_visits` INT NOT NULL DEFAULT '0', `total_visits` INT NOT NULL DEFAULT '0') ENGINE = MYISAM");
			
			// If indexes dont exist after update
			$result = $wpdb->get_results("show index from ".$wpdb->prefix."pixelstats where key_name='".$wpdb->prefix."pixelstats_post_ids'", ARRAY_N);
			if (count($result) == 0) {
				$wpdb->query("CREATE INDEX ".$wpdb->prefix."pixelstats_post_ids on ".$wpdb->prefix."pixelstats (stat_post_id,stat_date);");
			}

			$result = $wpdb->get_results("show index from ".$wpdb->prefix."pixelstats_daily where key_name='".$wpdb->prefix."pixelstats_daily_post_ids'", ARRAY_N);
			if (count($result) == 0) {
				$wpdb->query("CREATE INDEX ".$wpdb->prefix."pixelstats_daily_post_ids on ".$wpdb->prefix."pixelstats_daily (stat_post_id,day);");
			}
				
		}
		
		
		/*
		 * Make sure options are set, if not, set default values
		 */
		function _assert_options($restore="") {
			if(get_option('pixelstats_keep_detail_days') == "" || $restore) {
				update_option('pixelstats_keep_detail_days', 30);
			}
			if(get_option('pixelstats_keep_daily_days') == "" || $restore) {
				update_option('pixelstats_keep_daily_days', 365);
			}
			if(get_option('pixelstats_aggregate_passwd') == "" || $restore) {
				update_option('pixelstats_aggregate_passwd', "changeme");
			}
			if (!is_array(get_option('pixelstats_display_conditionals')) || $restore) {
				update_option('pixelstats_display_conditionals', array(
					'is_home' => true,
					'is_single' => true,
					'is_page' => true,
					'is_feed' => true,
				));
			}
			if($restore) {
				update_option('pixelstats_count_logged_in', true);
			}
		}
		/*
		 * Get pixelstats for post id
		 */
		function _get_pixelstats_for_id($post_id, $unique=true) {
			global $wpdb;
			
			if($unique) {
				return $wpdb->get_var("select count(distinct(stat_visitor_id)) from ".$wpdb->prefix."pixelstats where stat_post_id=".$post_id);
			} else {
				return $wpdb->get_var("select count(stat_visitor_id) from ".$wpdb->prefix."pixelstats where stat_post_id=".$post_id);
			}
			
		}
		
		/*
		 * Display the admin page for this plugin.
		 */
		function _display_admin_page() {
		?>
		<div class="wrap">
		  <h2>pixelstats admin page</h2>
			<?php 
			
			switch($_REQUEST['pixelstats_page']) {
				case "top_extended":
					$this->_display_top_extended_page();
					break;
				case "views_extended":
					$this->_display_views_extended_page();
					break;
				case "views_single";
					$this->_display_views_single_page($_REQUEST['post_id']);
					break;
				default:
					$this->_display_analysis_overview();
			}
			?>
		</div>
		<?php	
		}
		
		/*
		 * Extended views page
		 */
		function _display_views_extended_page() {
			?>
			<p><a href="?page=pixelstats" class="button">Back to overview</a><br /><br /></p>
			<?php
			// check if period is set
			$view_mode = "";
			$view_period = array();
			if(isset($_REQUEST['monthly_year']) &&
				isset($_REQUEST['monthly_month'])) {
			
				$view_mode = "monthly";
				$last_day = date('Y-m-d',(strtotime('next month',strtotime(date($_REQUEST['monthly_month'].'/01/'.$_REQUEST['monthly_year']))) - 1)); 
				$first_day = $_REQUEST['monthly_year']."-".$_REQUEST['monthly_month']."-01";
				$num_days = ceil((strtotime($last_day) - strtotime($first_day)) / 86400);
				$view_period = array($_REQUEST['monthly_year']."-".$_REQUEST['monthly_month']);		
			}
			if(isset($_REQUEST['period_start_year']) &&
				isset($_REQUEST['period_start_month']) &&
				isset($_REQUEST['period_start_day']) &&
				isset($_REQUEST['period_end_year']) &&
				isset($_REQUEST['period_end_month']) &&
				isset($_REQUEST['period_end_day'])) {
					$view_mode = "period";
					$view_period = array($_REQUEST['period_start_year']."-".$_REQUEST['period_start_month']."-".$_REQUEST['period_start_day'], $_REQUEST['period_end_year']."-".$_REQUEST['period_end_month']."-".$_REQUEST['period_end_day']);
					$first_day = $_REQUEST['period_start_year']."-".$_REQUEST['period_start_month']."-".$_REQUEST['period_start_day'];
					$last_day = $_REQUEST['period_end_year']."-".$_REQUEST['period_end_month']."-".$_REQUEST['period_end_day'];
					$num_days = ceil((strtotime($last_day) - strtotime($first_day)) / 86400);
			}
			if(empty($last_day) || empty($num_days)) {
				$last_day = date("Y-m-d");
				$num_days = 14;
			}
			?>
			<form method="post">
				<input type="hidden" name="pixelstats_page" value="<?php echo $_REQUEST['pixelstats_page']; ?>"/>
				<table class="widefat form-table" cellspacing="0" style="width: 800px;">
					<?php 
					if(isset($_REQUEST['monthly_chooser']) || ( isset($_REQUEST['monthly_year']) && isset($_REQUEST['submit']) )) $this->_display_monthly_chooser();
					if(isset($_REQUEST['period_chooser']) || ( isset($_REQUEST['period_start_year']) && isset($_REQUEST['submit']))) $this->_display_period_chooser();
					?>

				</table>
				<p class="submit">
					<input type="submit" name="submit" class="button-primary" value="Submit"/>&nbsp;
					<input type="submit" name="monthly_chooser" value="Stats per month"/>&nbsp;
					<input type="submit" name="period_chooser" value="Stats per time period"/>
				</p>
			</form>
			<p><?php if (!isset($_GET['page'])) echo "<a href=\"?page=pixelstats\">"; ?>
			<?php 
			$data = $this->_collect_visits_chart_data($num_days, strtotime($last_day));
			print($this->_get_chart_img_tag("lc", $data[0], $data[1], array("Total views", "Unique views", "Unique visitors"), "800x200"));

			if (!isset($_GET['page'])) echo "</a>"; ?></p>
			<?php
			
		}
		
		
		/*
		 * Display admin overview
		 */
		function _display_analysis_overview() {
			?>
			<h3>Article views per day</h3>
			<form method="post">
			<p class="submit">
				<input type="hidden" name="pixelstats_page" value="views_extended" /><input type="submit" name="submit" value="Details"/>
			</p>
			</form>
			<?php $this->_display_views_per_day(); ?>
			<br /><hr /><br />
			<h3>Top articles</h3>
			<form method="post">
			<p class="submit">
				<input type="hidden" name="pixelstats_page" value="top_extended" /><input type="submit" name="submit" value="Details"/>
			</p>
			</form>
			<p>
			<?php $this->_output_stats_table_html() ?>
			</p>
			<?php
		}
		

		
		/*
		 * Display extended top page
		 */
		function _display_top_extended_page() {
			if (isset($_REQUEST['pixelstats_top_limit'])) {
				$limit = $_REQUEST['pixelstats_top_limit'];
			} else {
				$limit = 10;
			}
			?>
			<p><a href="?page=pixelstats" class="button">Back to overview</a><br /><br /></p>
			<h3>Top articles</h3>
			<form method="post">
				<input type="hidden" name="pixelstats_page" value="<?php echo $_REQUEST['pixelstats_page']; ?>"/>
				<input type="hidden" name="sortby" value="<?php echo $_REQUEST['sortby']; ?>"/>
				<table class="widefat form-table" cellspacing="0" style="width: 800px;">
					<tr valign="top">
				        <td class='row-title' width="150px;">Limit output to top <i>n</i> articles</td>
				        <td>
							<select name="pixelstats_top_limit">
								<option value="10" <?php if($_REQUEST['pixelstats_top_limit'] == "10") echo 'selected'; ?>>10</option>
								<option value="20" <?php if($_REQUEST['pixelstats_top_limit'] == "20") echo 'selected'; ?>>20</option>
								<option value="50" <?php if($_REQUEST['pixelstats_top_limit'] == "50") echo 'selected'; ?>>50</option>
								<option value="100" <?php if($_REQUEST['pixelstats_top_limit'] == "100") echo 'selected'; ?>>100</option>
							</select>
						</td>
					</tr>
					<tr valign="top" class="alternate">
				        <td class='row-title' width="150px;">Sort by</td>
				        <td>
							<select name="sortby">
								<option value="unique" <?php if($_REQUEST['sortby'] == "unique") echo 'selected'; ?>>unique views</option>
								<option value="total" <?php if($_REQUEST['sortby'] == "total") echo 'selected'; ?>>total views</option>
							</select>
						</td>
					</tr>
					<tr valign="top">
				        <td class='row-title' width="150px;">Show both unique and total views in chart</td>
				        <td>
							<select name="show_both">
								<option value="both" <?php if($_REQUEST['show_both'] == "both") echo 'selected'; ?>>both</option>
								<option value="sortedby" <?php if($_REQUEST['show_both'] == "sortedby") echo 'selected'; ?>>only sorted by</option>
							</select>
						</td>
					</tr>
					<?php 
					if(isset($_REQUEST['daily_chooser']) || ( isset($_REQUEST['daily_year']) && isset($_REQUEST['submit']) )) $this->_display_daily_chooser();
					if(isset($_REQUEST['monthly_chooser']) || ( isset($_REQUEST['monthly_year']) && isset($_REQUEST['submit']) )) $this->_display_monthly_chooser();
					if(isset($_REQUEST['period_chooser']) || ( isset($_REQUEST['period_start_year']) && isset($_REQUEST['submit']))) $this->_display_period_chooser();
					?>

				</table>
				<p class="submit">
					<input type="submit" name="submit" class="button-primary" value="Submit"/>&nbsp;
					<input type="submit" name="total_stats" value="Total"/>&nbsp;
					<input type="submit" name="daily_chooser" value="Stats per day"/>&nbsp;
					<input type="submit" name="monthly_chooser" value="Stats per month"/>&nbsp;
					<input type="submit" name="period_chooser" value="Stats per time period"/>
				</p>
			</form>

			<!-- table class="widefat" cellspacing="0" style="width: 800px;">
				<tr class="alternate">

					<td class='row-title' width="150px;"><strong>Unique visitors</strong></td><td><?php print($this->_get_unique_visitors());?></td>
				</tr>
			</table //-->
			
			<?php
			if(!isset($_REQUEST['daily_chooser']) && !isset($_REQUEST['monthly_chooser']) && !isset($_REQUEST['period_chooser']))
				$this->_output_stats_table_html($limit);
			
		}
		
		/*
		 * Display extended top page monthly chooser
		 */
		function _display_monthly_chooser() {
			?>
			<tr class="alternate">
				<td class='row-title' style="width:150px;">Choose month</td>
				<td class='desc'>
					<select name="monthly_year">
						<?php
						if (isset($_REQUEST['monthly_year'])) {
							$monthly_year = $_REQUEST['monthly_year'];
						} else {
							$monthly_year = date("Y");
						}
						
						for ($y = 2009; $y <= date("Y"); $y++) {
							if ($monthly_year == $y) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$y."</option>\n";
						}
						?>
					</select>
					<select name="monthly_month">
						<?php
						if (isset($_REQUEST['monthly_month'])) {
							$monthly_month = $_REQUEST['monthly_month'];
						} else {
							$monthly_month = date("m");
						}
						
						for ($m = 1; $m <= 12; $m++) {
							$fm = sprintf('%02d', $m);
							if ($monthly_month == $fm) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$fm."</option>\n";
						}
						?>
					</select>
				</td>
			</tr>
			<?php
		}
		
		/*
		 * Display extended top page period chooser
		 */
		function _display_period_chooser() {
			?>
			<tr class="alternate">
				<td class='row-title' style="width:150px;">Choose begin</td>
				<td class='desc'>
					<select name="period_start_year">
						<?php
						if (isset($_REQUEST['period_start_year'])) {
							$period_start_year = $_REQUEST['period_start_year'];
						} else {
							$period_start_year = date("Y");
						}
						
						for ($y = 2009; $y <= date("Y"); $y++) {
							if ($daily_year == $y) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$y."</option>\n";
						}
						?>
					</select>
					<select name="period_start_month">
						<?php
						if (isset($_REQUEST['period_start_month'])) {
							$period_start_month = $_REQUEST['period_start_month'];
						} else {
							$period_start_month = date("m");
						}
						
						for ($m = 1; $m <= 12; $m++) {
							$fm = sprintf('%02d', $m);
							if ($period_start_month == $fm) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$fm."</option>\n";
						}
						?>
					</select>
					<select name="period_start_day">
						<?php
						if (isset($_REQUEST['period_start_day'])) {
							$period_start_day = $_REQUEST['period_start_day'];
						} else {
							$period_start_day = date("d");
						}
						for ($d = 1; $d <= 31; $d++) {
							$fd = sprintf('%02d', $d);
							if ($period_start_day == $fd) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$fd."</option>\n";
						}
						?>
					</select>
				</td>
			</tr>
			<tr>
				<td class='row-title' style="width:150px;">Choose end</td>
				<td class='desc'>
					<select name="period_end_year">
						<?php
						if (isset($_REQUEST['period_end_year'])) {
							$period_end_year = $_REQUEST['period_end_year'];
						} else {
							$period_end_year = date("Y");
						}

						for ($y = 2009; $y <= date("Y"); $y++) {
							if ($daily_year == $y) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$y."</option>\n";
						}
						?>
					</select>
					<select name="period_end_month">
						<?php
						if (isset($_REQUEST['period_end_month'])) {
							$period_end_month = $_REQUEST['period_end_month'];
						} else {
							$period_end_month = date("m");
						}

						for ($m = 1; $m <= 12; $m++) {
							$fm = sprintf('%02d', $m);
							if ($period_end_month == $fm) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$fm."</option>\n";
						}
						?>
					</select>
					<select name="period_end_day">
						<?php
						if (isset($_REQUEST['period_end_day'])) {
							$period_end_day = $_REQUEST['period_end_day'];
						} else {
							$period_end_day = date("d");
						}
						for ($d = 1; $d <= 31; $d++) {
							$fd = sprintf('%02d', $d);
							if ($period_end_day == $fd) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$fd."</option>\n";
						}
						?>
					</select>
				</td>
			</tr>
			<?php
		}
		
		/*
		 * Display extended top page daily chooser
		 */
		function _display_daily_chooser() {
			?>
			<tr class="alternate">
				<td class='row-title' style="width:150px;">Choose day</td>
				<td class='desc'>
					<select name="daily_year">
						<?php
						if (isset($_REQUEST['daily_year'])) {
							$daily_year = $_REQUEST['daily_year'];
						} else {
							$daily_year = date("Y");
						}
						
						for ($y = 2009; $y <= date("Y"); $y++) {
							if ($daily_year == $y) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$y."</option>\n";
						}
						?>
					</select>
					<select name="daily_month">
						<?php
						if (isset($_REQUEST['daily_month'])) {
							$daily_month = $_REQUEST['daily_month'];
						} else {
							$daily_month = date("m");
						}
						
						for ($m = 1; $m <= 12; $m++) {
							$fm = sprintf('%02d', $m);
							if ($daily_month == $fm) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$fm."</option>\n";
						}
						?>
					</select>
					<select name="daily_day">
						<?php
						if (isset($_REQUEST['daily_day'])) {
							$daily_day = $_REQUEST['daily_day'];
						} else {
							$daily_day = date("d");
						}
						for ($d = 1; $d <= 31; $d++) {
							$fd = sprintf('%02d', $d);
							if ($daily_day == $fd) $selected = " selected"; else $selected = "";
							echo "<option ".$selected.">".$fd."</option>\n";
						}
						?>
					</select>
				</td>
			</tr>
			<?php
			
		}
		
		/*
		 * Display article views per day
		 */
		function _display_views_per_day($width=800, $num_days=7, $last_day="") {
			if (isset($_REQUEST['last_day'])) {
				if(isset($_REQUEST['change_week_prev'])) $last_day = date("Y-m-d", strtotime("-1 week", strtotime($_REQUEST['last_day'])));
				if(isset($_REQUEST['change_week_curr'])) $last_day = date("Y-m-d");
				if(isset($_REQUEST['change_week_next'])) $last_day = date("Y-m-d", strtotime("+1 week", strtotime($_REQUEST['last_day'])));
				echo "<p>Showing $num_days days until ".$last_day.".</p>";
			} else {
				if (empty($last_day)) {
					$last_day = date("Y-m-d");
					echo "<p>Showing last $num_days days.</p>";
				} else {
					echo "<p>Showing $num_days days until ".$last_day.".</p>";
				}
			}
			?>
			<form method="post"><p class="submit"><input type="hidden" name="last_day" value="<?php echo $last_day; ?>"/>
		      <input type="submit" name="change_week_prev" value="Previous week" />&nbsp;<input type="submit" name="change_week_curr" value="Current week" />&nbsp;<input type="submit" name="change_week_next" value="Next week" />
			</p></form>
			<p><?php if (!isset($_GET['page'])) echo "<a href=\"?page=pixelstats\">"; ?>
			<?php 
			$data = $this->_collect_visits_chart_data($num_days, strtotime($last_day));
			print($this->_get_chart_img_tag("lc", $data[0], $data[1], array("Total views", "Unique views", "Unique visitors"), $width."x200"));

			?>
			<?php if (!isset($_GET['page'])) echo "</a>"; ?></p>
			<?php
		}
		
		/*
		 * Display article views per day and article
		 */
		function _display_views_single_page($post_id, $num_days=14, $last_day="") {
			?>
			<p><a href="?page=pixelstats" class="button">Back to overview</a><br /><br /></p>
			<?php
			// check if period is set
			$view_mode = "";
			$view_period = array();
			if(isset($_REQUEST['monthly_year']) &&
				isset($_REQUEST['monthly_month'])) {
			
				$view_mode = "monthly";
				$last_day = date('Y-m-d',(strtotime('next month',strtotime(date($_REQUEST['monthly_month'].'/01/'.$_REQUEST['monthly_year']))) - 1)); 
				$first_day = $_REQUEST['monthly_year']."-".$_REQUEST['monthly_month']."-01";
				$num_days = ceil((strtotime($last_day) - strtotime($first_day)) / 86400);
				$view_period = array($_REQUEST['monthly_year']."-".$_REQUEST['monthly_month']);		
			}
			if(isset($_REQUEST['period_start_year']) &&
				isset($_REQUEST['period_start_month']) &&
				isset($_REQUEST['period_start_day']) &&
				isset($_REQUEST['period_end_year']) &&
				isset($_REQUEST['period_end_month']) &&
				isset($_REQUEST['period_end_day'])) {
					$view_mode = "period";
					$view_period = array($_REQUEST['period_start_year']."-".$_REQUEST['period_start_month']."-".$_REQUEST['period_start_day'], $_REQUEST['period_end_year']."-".$_REQUEST['period_end_month']."-".$_REQUEST['period_end_day']);
					$first_day = $_REQUEST['period_start_year']."-".$_REQUEST['period_start_month']."-".$_REQUEST['period_start_day'];
					$last_day = $_REQUEST['period_end_year']."-".$_REQUEST['period_end_month']."-".$_REQUEST['period_end_day'];
					$num_days = ceil((strtotime($last_day) - strtotime($first_day)) / 86400);
			}
			
			$this_post = get_post($post_id);
			$title = $this_post->post_title;
			$link = get_permalink($post_id);
			echo "<p>Showing stats for <a href=\"".$link."\">".$title."</a></p>";
			?>
			<form action="?page=pixelstats" method="post">
				<input type="hidden" name="pixelstats_page" value="<?php echo $_REQUEST['pixelstats_page']; ?>"/>
				<input type="hidden" name="post_id" value="<?php echo $_REQUEST['post_id']; ?>"/>
				<table class="widefat form-table" cellspacing="0" style="width: 800px;">
					<?php 
					if(isset($_REQUEST['monthly_chooser']) || ( isset($_REQUEST['monthly_year']) && isset($_REQUEST['submit']) )) $this->_display_monthly_chooser();
					if(isset($_REQUEST['period_chooser']) || ( isset($_REQUEST['period_start_year']) && isset($_REQUEST['submit']))) $this->_display_period_chooser();
					?>

				</table>
				<p class="submit">
					<input type="submit" name="submit" class="button-primary" value="Submit"/>&nbsp;
					<input type="submit" name="monthly_chooser" value="Stats per month"/>&nbsp;
					<input type="submit" name="period_chooser" value="Stats per time period"/>
				</p>
			</form>
			<p><?php if (!isset($_GET['page'])) echo "<a href=\"?page=pixelstats\">"; ?>
			<?php 
			$data = $this->_collect_post_visits_chart_data($post_id, $num_days, strtotime($last_day));
			print($this->_get_chart_img_tag("lc", $data[0], $data[1], array("Total views", "Unique views"), "800x200"));

			?>
			<?php if (!isset($_GET['page'])) echo "</a>"; ?></p>
			<?php
		}
		
		/*
		 * Display options page
		 */
		function _display_options_page() {
			
			if(isset($_REQUEST['update'])) {
				$conditionals = Array();
				if (!$_REQUEST['conditionals']) $_REQUEST['conditionals'] = Array();
				if (get_option('pixelstats_display_conditionals') != "") {
					foreach(get_option('pixelstats_display_conditionals') as $condition=>$toggled) {
						$conditionals[$condition] = array_key_exists($condition, $_REQUEST['conditionals']);
					}
				}
				update_option('pixelstats_display_conditionals', $conditionals);
				
				update_option('pixelstats_keep_detail_days', $_REQUEST['pixelstats_keep_detail_days']);
				update_option('pixelstats_keep_daily_days', $_REQUEST['pixelstats_keep_daily_days']);
				update_option('pixelstats_aggregate_passwd', $_REQUEST['pixelstats_aggregate_passwd']);
				
				if(isset($_REQUEST['pixelstats_count_logged_in'])) {
					update_option('pixelstats_count_logged_in', true);
				} else {
					update_option('pixelstats_count_logged_in', false);
				}
				
			} elseif (isset($_REQUEST['restore'])) {
				$this->_assert_options(true);
			}
			
			$conditionals = get_option('pixelstats_display_conditionals');
		?>
		<div class="wrap">
		  <h2>pixelstats options</h2>
		  <form method="post">
		    <input type="hidden" name="action" value="update" />
			<fieldset id="pixelstats_display_conditionals">
			<p>Define where tracker pixel is shown.</p>

			<ul style="list-style-type: none">
				<li><input type="checkbox" name="conditionals[is_home]"<?php echo ($conditionals['is_home']) ? ' checked="checked"' : ''; ?> />&nbsp;Front page</li>
				<li><input type="checkbox" name="conditionals[is_single]"<?php echo ($conditionals['is_single']) ? ' checked="checked"' : ''; ?> />&nbsp;Single post</li>
				<li><input type="checkbox" name="conditionals[is_page]"<?php echo ($conditionals['is_page']) ? ' checked="checked"' : ''; ?> />&nbsp;Single page</li>
				<li><input type="checkbox" name="conditionals[is_feed]"<?php echo ($conditionals['is_feed']) ? ' checked="checked"' : ''; ?> />&nbsp;Feeds</li>
			</ul>
			</fieldset><br />
			<fieldset id="pixelstats_count_logged_in">
			<p>If you don't want to count hits from logged in users (editors, admins etc.), it might be useful to uncheck this box. If most of you users are logged in (as subscribers), you better leave it checked.</p>
			<input type="checkbox" name="pixelstats_count_logged_in" <?php echo get_option("pixelstats_count_logged_in") ? ' checked="checked"' : ''; ?> />&nbsp;Count logged in users
			</fieldset>
			<br/>
		    <p>These settings are needed for data aggregation. <strong>(Not implemented yet)</strong></p>
			<table class="form-table">
				<tr valign="top">
			        <th scope="row"><label for="pixelstats_keep_detail_days">Keep tracking details for <i>n</i> days</label></th>
			        <td>
						<input type="text" name="pixelstats_keep_detail_days" id="pixelstats_keep_detail_days" value="<?php echo htmlspecialchars(get_option('pixelstats_keep_detail_days')); ?>" class="regular-text code"/>
					</td>
				</tr>
				<tr valign="top">
			        <th scope="row"><label for="pixelstats_keep_daily_days">Keep daily statistics for <i>n</i> days</label></th>
			        <td>
						<input type="text" name="pixelstats_keep_daily_days" id="pixelstats_keep_daily_days" value="<?php echo htmlspecialchars(get_option('pixelstats_keep_daily_days')); ?>" class="regular-text code" />
					</td>
				</tr>
				<tr valign="top">
			        <th scope="row"><label for="pixelstats_aggregate_passwd">Password for automated aggregation</label></th>
			        <td>
						<input type="text" name="pixelstats_aggregate_passwd" id="pixelstats_aggregate_passwd" value="<?php print(htmlspecialchars(get_option('pixelstats_aggregate_passwd'))); ?>" class="regular-text code"/>
					</td>
				</tr>
				
			</table>
			<p class="submit">
		      <input type="submit" name="update" value="Save Changes" />&nbsp;<input type="submit" name="restore" value="Restore defaults" />
		    </p>
		  </form>
		</div>
		<?php
		}
		
		/*
		 * get all tracked ids
		 */
		function _get_all_tracked_ids() {
			global $wpdb;
			
			$all_tracked_ids;
			$result = $wpdb->get_results("select distinct(stat_post_id) from ".$wpdb->prefix."pixelstats", ARRAY_N);

			if(is_array($result)) {
				foreach ($result as $r) {
					$all_tracked_ids[] = $r[0];
				}
			} else {
				return array();
			}
			
			return $all_tracked_ids;
		}
		
		/*
		 * get number of unique visitors
		 */
		function _get_unique_visitors($date, $mode="", $period = array()) {
			global $wpdb;

			if ($date != "") {
				return $wpdb->get_var("select count(distinct(stat_visitor_id)) from ".$wpdb->prefix."pixelstats where date(stat_date) = \"".$date."\"");
			} else {
				return $wpdb->get_var("select count(distinct(stat_visitor_id)) from ".$wpdb->prefix."pixelstats");
			}
		}
		
		
		/*
		 * get sorted list of posts with number of visitors
		 */
		function _get_post_list_with_views($orderByDistinct = true, $limit=10, $mode="", $period = array()) {
			global $wpdb;
			
			// consider time period
			$add_filter = "";
			if(!empty($mode) && !empty($period)) {
				switch ($mode) {
					case "daily":
						$add_filter = "and date(stat_date)=\"".$period[0]."\"";
						break;
					case "monthly":
						$add_filter = "and stat_date like \"".$period[0]."\"";
						break;
					case "period":
						$add_filter = "and ( date(stat_date) >= \"".$period[0]."\" and date(stat_date) <= \"".$period[1]."\" )";
						break;
				}
				
			}
			
			if($orderByDistinct) {
				$query = "select stat_post_id,count(distinct(stat_visitor_id)),count(stat_visitor_id) from ".$wpdb->prefix."pixelstats where stat_post_id in (select distinct(stat_post_id) from ".$wpdb->prefix."pixelstats) ".$add_filter." group by stat_post_id order by count(distinct(stat_visitor_id)) desc limit ".$limit;
				//print("select stat_post_id,count(distinct(stat_visitor_id)),count(stat_visitor_id) from ".$wpdb->prefix."pixelstats where stat_post_id in (select distinct(stat_post_id) from ".$wpdb->prefix."pixelstats) ".$add_filter." group by stat_post_id order by count(distinct(stat_visitor_id)) desc limit ".$limit);
			} else {
				$query = "select stat_post_id,count(distinct(stat_visitor_id)),count(stat_visitor_id) from ".$wpdb->prefix."pixelstats where stat_post_id in (select distinct(stat_post_id) from ".$wpdb->prefix."pixelstats) ".$add_filter." group by stat_post_id order by count(stat_visitor_id) desc limit ".$limit;
				//print("select stat_post_id,count(distinct(stat_visitor_id)),count(stat_visitor_id) from ".$wpdb->prefix."pixelstats where stat_post_id in (select distinct(stat_post_id) from ".$wpdb->prefix."pixelstats) ".$add_filter." group by stat_post_id order by count(stat_visitor_id) desc limit ".$limit);
			}
			
			return $wpdb->get_results($query, ARRAY_N);
			
		}
		
		/*
		 * get number of article views per day and id
		 */
		function _get_num_views_per_day_and_id($day, $post_id, $unique=true) {
			global $wpdb;
			
			if($unique) {
				$query = "select count(post_id) from (select stat_post_id post_id,stat_visitor_id visitor_id, date(stat_date) date from ".$wpdb->prefix."pixelstats where stat_post_id=".$post_id." group by stat_visitor_id) result where date=\"".$day."\"";
			} else {
				$query = "select count(post_id) from (select stat_post_id post_id,stat_visitor_id visitor_id, date(stat_date) date from ".$wpdb->prefix."pixelstats where stat_post_id=".$post_id.") result where date=\"".$day."\"";
			}
			
			return $wpdb->get_var($query);
		}
		
		/*
		 * build table and chart for visitors
		 */
		function _output_stats_table_html($limit=10) {
			
			// check if period is set (only unless "total" button is pressed)
			$view_mode = "";
			$view_period = array();
			if (!isset($_REQUEST['total_stats'])) {
				if(isset($_REQUEST['daily_year']) &&
					isset($_REQUEST['daily_month']) &&
					isset($_REQUEST['daily_day'])) {
				
					$view_mode = "daily";
					$view_period = array($_REQUEST['daily_year']."-".$_REQUEST['daily_month']."-".$_REQUEST['daily_day']);		
				}
				if(isset($_REQUEST['monthly_year']) &&
					isset($_REQUEST['monthly_month'])) {
				
					$view_mode = "monthly";
					$view_period = array($_REQUEST['monthly_year']."-".$_REQUEST['monthly_month']);		
				}
				if(isset($_REQUEST['period_start_year']) &&
					isset($_REQUEST['period_start_month']) &&
					isset($_REQUEST['period_start_day']) &&
					isset($_REQUEST['period_end_year']) &&
					isset($_REQUEST['period_end_month']) &&
					isset($_REQUEST['period_end_day'])) {
						$view_mode = "period";
						$view_period = array($_REQUEST['period_start_year']."-".$_REQUEST['period_start_month']."-".$_REQUEST['period_start_day'], $_REQUEST['period_end_year']."-".$_REQUEST['period_end_month']."-".$_REQUEST['period_end_day']);
				}
			}
			
			
			if($_REQUEST['sortby'] == "total") {
				$results = $this->_get_post_list_with_views(false, $limit, $view_mode, $view_period);
				//echo "<p>Sorted by total article views.</p>";
			} elseif($_REQUEST['sortby'] == "unique") {
				$results = $this->_get_post_list_with_views(true, $limit, $view_mode, $view_period);
				//echo "<p>Sorted by unique article views.</p>";
			} else {
				$results = $this->_get_post_list_with_views(true, $limit, $view_mode, $view_period);
				//echo "<p>Sorted by total article views.</p>";
			}
			
			if (empty($results)) {
				echo "No data found.";
				return;
			}
			
			// build chart
			$data = array();
			$labels = array();
			$data[0] = array(); // unique visits
			$data[1] = array(); // total visits
			
			foreach ($results as $r) {
				$data[0][] = $r[1];
				$data[1][] = $r[2];
				$this_post = get_post($r[0]);
				$title = $this_post->post_title;
				if ( $_REQUEST['show_both'] == "sortedby" || $limit > 10) {
					$labels[] = substr($title, 0, 5)."..";
				} else {
					$labels[] = substr($title, 0, 10)."...";
				}
			}
			
			if($_REQUEST['show_both'] == "sortedby") {
				if ($_REQUEST['sortby'] == "total") {
					$labels = array_slice($labels, 0, 20);
					$show_data = array_slice($data[1], 0, 20);
				} elseif ($_REQUEST['sortby'] == "unique") {
					$labels = array_slice($labels, 0, 20);
					$show_data = array_slice($data[0], 0, 20);
				} else {
					$labels = array_slice($labels, 0, 10);
					$show_data = array(array_slice($data[0], 0, 10), array_slice($data[1], 0, 20));
				}
			} else {
				$labels = array_slice($labels, 0, 10);
				$show_data = array(array_slice($data[0], 0, 10), array_slice($data[1], 0, 10));
			}
			
			print($this->_get_chart_img_tag("bvg", $show_data, $labels));
			
			
			// build table
			if (count($results) > 0) {
				?><br /><br />
				<!-- form name="sortby_total" id="sortby_total" method="post"><input type="hidden" name="pixelstats_page" value="<?php echo $_REQUEST['pixelstats_page']; ?>" /><input type="hidden" name="sortby" value="total"/><input type="hidden" name="pixelstats_top_limit" value="<?php echo $limit; ?>" /></form>
				<form name="sortby_unique" id="sortby_unique" method="post"><input type="hidden" name="pixelstats_page" value="<?php echo $_REQUEST['pixelstats_page']; ?>" /><input type="hidden" name="sortby" value="unique"/><input type="hidden" name="pixelstats_top_limit" value="<?php echo $limit; ?>" /></form //-->
				<table class="widefat" cellspacing="0" id="visitor-stats-table" style="width:800px;">
					<thead>
					<tr>
						<th scope="col">Post</th>
						<th scope="col"><!-- a title="Sort result by unique article views" href="javascript:void(0);" onclick="document.forms['sortby_unique'].submit();"-->Unique views<!--/a--></th>
						<th scope="col"><!--a title="Sort result by total views" href="javascript:void(0);" onclick="document.forms['sortby_total'].submit();"-->Total views<!--/a--></th>
						<th scope="col">&nbsp;</th>
					</tr>
					</thead>

					<tfoot>
					<tr>
						<th scope="col">Post</th>
						<th scope="col"><!-- a title="Sort result by unique article views" href="javascript:void(0);" onclick="document.forms['sortby_unique'].submit();"-->Unique views<!--/a--></th>
						<th scope="col"><!--a title="Sort result by total views" href="javascript:void(0);" onclick="document.forms['sortby_total'].submit();"-->Total views<!--/a--></th>
						<th scope="col">&nbsp;</th>
					</tr>
					</tfoot>
					<tbody>
				<?php
				foreach ($results as $r) {
					$this_post = get_post($r[0]);
					$title = $this_post->post_title;
					$link = get_permalink($r[0]);
					echo "<tr><td><a href=\"".$link."\">".$title."</a></td><td style=\"width:100px;\">".$r[1]."</td><td style=\"width:100px;\">".$r[2]."</td>";
					?>
					<td><form method="post" name="views_single_<?php echo $r[0]; ?>">
						<input type="hidden" name="pixelstats_page" value="views_single"/><input type="hidden" name="post_id" value="<?php echo $r[0]; ?>"/>
					</form><a href="javascript:void(0);" onclick="document.forms['views_single_<?php echo $r[0]; ?>'].submit();">Show details</a></td>
					<?php
					echo "</tr>";
				}
				?>	
					</tbody>
				</table>
				<?php
			} else {
				return "No results yet.";
			}
		}
		
		/*
		 * Collect data for visits chart per post id
		 *
		 */
		function _collect_post_visits_chart_data($post_id, $days_back="14", $last_day = "") {
			global $wpdb;
			
			if($last_day == "") $last_day = time();
			$days = array();
			$short_days = array();
			$data = array();
			
			$even = true;
			if ($days_back > 14) $show_only_odd = true; else $show_only_odd = false;
			
			while ($days_back > 0) {
				$days_back = $days_back - 1;
				$date = date("Y-m-d", strtotime("-".$days_back." days", $last_day));
				$short_date = date("m-d", strtotime("-".$days_back." days", $last_day));
				$days[] = $date;
				if($even && $show_only_odd) {
					$short_days[] = "";
				} else {
					$short_days[] = $short_date;
				}
				if ($even) $even = false; else $even = true;
			}
			
			$data[0] = array();
			$data[1] = array();
			
			foreach ($days as $d) {
				$total_visits = $this->_get_num_views_per_day_and_id($d, $post_id, false);
				
				$unique_visits = $this->_get_num_views_per_day_and_id($d, $post_id);
				$data[0][] = $total_visits;
				$data[1][] = $unique_visits;
			}
			return(array($data, $short_days));
			
		}
		
		/*
		 * Collect data for visits chart
		 *
		 */
		function _collect_visits_chart_data($days_back="7", $last_day = "") {
			global $wpdb;
			
			if($last_day == "") $last_day = time();
			$days = array();
			$short_days = array();
			$data = array();
			
			$even = true;
			if ($days_back > 14) $show_only_odd = true; else $show_only_odd = false;
			
			while ($days_back > 0) {
				$days_back = $days_back - 1;
				$date = date("Y-m-d", strtotime("-".$days_back." days", $last_day));
				$short_date = date("m-d", strtotime("-".$days_back." days", $last_day));
				$days[] = $date;
				if($even && $show_only_odd) {
					$short_days[] = "";
				} else {
					$short_days[] = $short_date;
				}
				if ($even) $even = false; else $even = true;
			}
			
			$data[0] = array();
			$data[1] = array();
			$data[2] = array();
			
			foreach ($days as $d) {
				$total_visits = 0;
				foreach ($this->_get_all_tracked_ids() as $post_id) {
					$total_visits = $total_visits + $this->_get_num_views_per_day_and_id($d, $post_id, false);
				}
				
				$unique_visits = 0;
				foreach ($this->_get_all_tracked_ids() as $post_id) {
					$unique_visits = $unique_visits + $this->_get_num_views_per_day_and_id($d, $post_id);
				}
				$unique_visitors = $this->_get_unique_visitors($d);
				$data[0][] = $total_visits;
				$data[1][] = $unique_visits;
				$data[2][] = $unique_visitors;
			}
			return(array($data, $short_days));
			
		}
		
		/*
		 * Return img tag for Google Chart API
		 */
		function _get_chart_img_tag($type, $values, $labels, $caption=array(), $size="800x200") {
			
			// general setup
			$chart_urlprefix = "http://chart.apis.google.com/chart";
			$line_color = "D54E21";
			$fill_color = "DC7B5A";
			$secondary_line_color = "297A9E";
			$third_line_color = "888888";
			$bg_color = "F9F9F9";

			//determine max-value
			// find values
			if (is_array($values[0])) {
				
				$maxes = array();
				foreach ($values as $v) {
					$maxes[] = max($v);
				}
				$max_value = max($maxes);
				
				$google_value_array = array();
				foreach ($values as $v) {
					$google_value_array[] = implode(",", $v);
				}
				$google_values = implode("|", $google_value_array);

			} else {
				$max_value = max($values);
				$google_values = implode(",", $values);
			}
			
			if(!empty($caption)) {
				$caption_values = implode("|", $caption);
			}
			
			// find labels
			$google_labels = implode("|", $labels);
			
			// determine maximum value and chart scale
			$dim = split("x", $size);
			$width = $dim[0];
			if ($max_value > 2000) {
				$max_factor = 1000;
			} elseif ($max_value > 200) {
				$max_factor = 100;
			} else {
				$max_factor = 10;
			}
			$y_length = ceil($max_value / $max_factor) * $max_factor;
			$val1 = ceil($y_length / 4);
			$val2 = ceil($y_length / 2);
			$val3 = ceil($y_length / 4 * 3);
			
			// determine number of values and attach grid accordingly
			if (is_array($values[0])) {
				$grid_factor = 100 / (count($values[0]) - 1);
				$bar_width = floor ( ( $width / count($values[0]) / 2 ) - 10);
			} else {
				$grid_factor = 100 / (count($values) - 1);
				$bar_width = floor ( ( $width / count($values) ) - 10 );	
			}
			
			// Build parameters
			$params = "cht=".$type;
			$params .= "&chd=t:".$google_values;
			$params .= '&chs='.$size;
			$params .= "&chds=0,".$y_length;
			if(isset($caption_values)) $params .= "&chdl=".$caption_values;
			if ($type == "bvs" || $type == "bvg") {
				$params .= "&chco=".$line_color.",".$fill_color;
				$params .= "&chbh=".$bar_width;
			} else {
				//$params .= "&chm=D,".$line_color.",0,0,4,1|D,".$secondary_line_color.",1,0,4,1|D,".$third_line_color.",2,0,4,1|B,".$fill_color.",0,0,0";
				$params .= "&chm=D,".$line_color.",0,0,3,1|D,".$secondary_line_color.",1,0,3,1|D,".$third_line_color.",2,0,3,1";
				//$params .= "&chm=B,".$fill_color.",0,0,0";
				$params .= "&chco=".$line_color.",".$secondary_line_color.",".$third_line_color;
				$params .= "&chg=".$grid_factor.",25";
			}
			$params .= "&chf=bg,s,".$bg_color;
			$params .= "&chxt=x,y";
			$params .= "&chxl=0:|".$google_labels."|1:|0|".$val1."|".$val2."|".$val3."|".$y_length;
			
			return "<img src=\"".$chart_urlprefix."?".$params."\" />";
		}
		
		
	}	
}

// Load the plugin
$pixelstats_plugin = new PixelstatsPlugin();

/*************************************************************
 * Template Functions / Tags / Dashboard Widget
 *************************************************************/

function get_pixelstats($unique=true) {
	global $pixelstats_plugin, $post;
	
	return $pixelstats_plugin->_get_pixelstats_for_id($post->ID, $unique);
	
}

function pixelstats_widget() {
	global $pixelstats_plugin;
	print($pixelstats_plugin->_display_views_per_day("350", "7", date("Y-m-d", strtotime("-1 day"))));
	?><p><a href="?page=pixelstats" class="button">View all</a><br /></p><?php
	
}
?>
