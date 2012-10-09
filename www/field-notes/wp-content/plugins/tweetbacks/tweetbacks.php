<?php
/*
Plugin Name: Tweetbacks
Version: 1.5.3
Plugin URI: http://yoast.com/wordpress/tweetbacks/
Description: Show the tweets about your posts and pages as comments on your blog!
Author: Joost de Valk
Author URI: http://yoast.com

Copyright 2009  (email: joost@yoast.com)

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
/*
 * Admin User Interface
 */

if ( is_admin() && ! class_exists( 'Tweetbacks_Admin' ) ) {
	
	class Tweetbacks_Admin {

		function add_config_page() {
			global $wpdb;
			if ( function_exists('add_submenu_page') ) {
				add_options_page('Tweetbacks for WordPress Configuration', 'Tweetbacks', 9, basename(__FILE__), array('Tweetbacks_Admin','config_page'));
				add_filter( 'plugin_action_links', array( 'Tweetbacks_Admin', 'filter_plugin_actions'), 10, 2 );
				add_filter( 'ozh_adminmenu_icon', array( 'Tweetbacks_Admin', 'add_ozh_adminmenu_icon' ) );				
			}
		} 

		function add_ozh_adminmenu_icon( $hook ) {
			static $twbicon;
			if (!$twbicon) {
				$twbicon = WP_CONTENT_URL . '/plugins/' . plugin_basename(dirname(__FILE__)). '/twitter.png';
			}
			if ($hook == 'tweetbacks.php') return $twbicon;
			return $hook;
		}

		function filter_plugin_actions( $links, $file ){
			//Static so we don't call plugin_basename on every plugin row.
			static $this_plugin;
			if ( ! $this_plugin ) $this_plugin = plugin_basename(__FILE__);

			if ( $file == $this_plugin ){
				$settings_link = '<a href="options-general.php?page=tweetbacks.php">' . __('Settings') . '</a>';
				array_unshift( $links, $settings_link ); // before other links
			}
			return $links;
		}
		
		function config_page() {
			if (!current_user_can('manage_options')) die(__('You cannot edit the Tweetbacks options.'));

			// delete_option("tweetbacks");
			$options = get_option("tweetbacks");
			if (!is_array($options)) {
				$options = array();
				$options['updatetime'] = 15;
				add_option("tweetbacks",$options);
			}

			if ( isset($_POST['submit']) ) {
				check_admin_referer('tweetbacks-config');
				// Settings
				if (isset($_POST['filterusers'])) {
					$options['filterusers'] = strtolower(str_replace(" ","",$_POST['filterusers']));
				}
				if (isset($_POST['updatetime']) && is_numeric($_POST['updatetime'])) {
					$options['updatetime'] = $_POST['updatetime'];
					if ($options['updatetime'] < 5) {
						$options['updatetime'] = 5;
					}
				}
				if (isset($_POST['updatetime']) && $_POST['updatetime'] == "") {
					$options['updatetime'] = 15;
				}
				if (isset($_POST['filterretweets'])) {
					$options['filterretweets'] = true;
				} else {
					$options['filterretweets'] = false;
				}
                                if (isset($_POST['autoapprovetweets'])) {
                                        $options['autoapprovetweets'] = true;
                                } else {
                                        $options['autoapprovetweets'] = false;
                                }

				
				update_option("tweetbacks",$options);
			}

			if ( isset($_POST['cleanupsubmit']) ) {
				check_admin_referer('tweetbacks-cleanup');
				// Clean up
				if (isset($_POST['cleanup'])) {
					global $wpdb, $table_prefix;
					$query = 'DELETE FROM '.$table_prefix.'postmeta WHERE meta_key = "twittercomments" OR meta_key = "tweetcount" OR meta_key = "tweetbackscheck"';
					if (isset($_POST['cleanshorturls'])) {
						$query .= ' OR meta_key = "shorturls"';
					}
					$wpdb->query($query); 
					$wpdb->query('DELETE FROM '.$table_prefix.'comments WHERE comment_author_email LIKE "twitter:%"'); 
					echo "<div id=\"message\" class=\"updated fade\"><p>TweetBacks data deleted.</p></div>\n";
				}
			}
?>
			<div class="wrap">
				<h2>TweetBacks Configuration</h2>
				<form action="<?php $PHP_SELF ?>" method="post" id="tweetbacks-conf">
					<table class="form-table" style="width:100%;">
					<?php
					if ( function_exists('wp_nonce_field') )
						wp_nonce_field('tweetbacks-config');
					?>
						<tr>
							<th>
								<label for="filterusers"><strong>Twitter usernames to filter: </strong></label><br/>
								<small>All tweets by these users will not show up as comments anymore, from the moment you add them to this list. If you want to remove old comments, clean the DB below.</small>
							</th>
							<td valign="top"><input style="width:300px;" type="text" name="filterusers" value="<?php if (isset($options['filterusers'])) { echo $options['filterusers']; } ?>" id="filterusers"/> (separate with comments)</td>
						</tr>
						<tr>
							<th>
								<label for="updatetime"><strong>Minutes between updates:</strong></label><br/>
								<small>Set lower to find tweets faster, higher to have less load on your webserver. This can not be set lower than 5, to avoid spamming the Twitter Search API, default is 15.</small>
							</th>
							<td valign="top"><input style="width:60px;" type="text" name="updatetime" value="<?php if (isset($options['updatetime'])) { echo $options['updatetime']; } ?>" id="updatetime"/>
						</tr>
						<tr>
							<th>
								<label for="filterretweets"><strong>Filter out retweets:</strong></label><br/>
								<small>If checked, all tweets starting with "RT", "Retweet" or "Retweeting" are filtered out, they are counted in the tweetcount though.</small>
							</th>
							<td valign="top"><input type="checkbox" name="filterretweets" <?php if ($options['filterretweets']) { echo 'checked="checked"'; } ?> id="filterretweets"/>
						 						</tr>


                                                <tr>
                                                        <th>
                                                                <label for="autoapprovetweets"><strong>Automatically approve tweets:</strong></label><br/>
                                                                <small>If checked, all tweets will be automatically approved. This could lead to showing weird messages on your blog, but can become cumbersome on high traffic blogs.</small>
                                                        </th>
                                                        <td valign="top"><input type="checkbox" name="autoapprovetweets" <?php if ($options['autoapprovetweets']) { echo 'checked="checked"'; } ?> id="autoapprovetweets"/>
                                                </tr>



					</table>
					<p style="border:0;" class="submit"><input type="submit" name="submit" value="Submit" /></p>					
				</form>

				<h2>Uninstall</h2>
				<form action="" method="post" id="tweetbacks-cleanup">
					<?php if ( function_exists('wp_nonce_field') )
						wp_nonce_field('tweetbacks-cleanup');  ?>
					
					<table class="form-table" style="width:100%;">
					<tr>
						<th scope="row" style="width:400px;" valign="top">
							<p><label for="uninstall">Clean up? Check this box, and click the button. That will delete all tweets from your DB. Use with GREAT caution!</label></p>
						</th>
						<td>
							<input type="checkbox" name="cleanup" id="cleanup"/>Clean up<br/>
							<input type="checkbox" name="cleanshorturls" id="cleanshorturls"/>Remove shorturl's too (only do this when you're having issues)<br/>
						</td>
					</tr>							
					</table>
					<p style="border:0;" class="submit"><input type="submit" name="cleanupsubmit" value="Clean Up!" /></p>					
				</form>
			</div>
			<?php
		} // end config_page()

	} // end class Tweetbacks_Admin

	// adds the menu item to the admin interface
	add_action('admin_menu', array('Tweetbacks_Admin','add_config_page'));

} //endif

add_filter('get_avatar', 'tweetbacks_get_avatar', 21, 5);

function tweetbacks_get_avatar($avatar, $id_or_email, $size, $default, $alt) {
  global $wpdb;
  if (!empty($id_or_email->user_id)) {
		if ( substr(stripslashes($id_or_email->comment_author_email),0,8) == "twitter:") {
			$default = str_replace("twitter:","http://s3.amazonaws.com/twitter_production/profile_images/",$id_or_email->comment_author_email);
			$avatar = "<img alt='{$safe_alt}' src='{$default}' class='avatar avatar-{$size} photo avatar-default' height='{$size}' width='{$size}' />";
		}
  }
  return $avatar;
}

function yoast_check_shorturl($tweet,$shorturls) {	
	foreach ($shorturls as $key => $shorturl) {
		if (strpos($tweet,$shorturl) !== false) {
			return true;
		}
	}
	return false;
}

function create_query($shorturl, $queries) {	
	$ls = strlen($shorturl);
	if ($ls < 14) {
		return $queries;
	}
	$i = 0;
	while ($i < (count($queries) + 1)) {
		$ql = strlen($queries[$i]);
		if ($queries[$i] == "") {
			$queries[$i] = $shorturl;
			return $queries;
		} elseif ( (120 - $ql) > ($ls + 4)) {
			$queries[$i] .= " OR ".$shorturl;
			return $queries;
		} else {
			$i++;
		}
	}
}

function parse_twitter_search_results($post_id,$results,$shorturls,$tweetcount) {
	global $wpdb;
	$rss = new MagpieRSS($results);
	
	$options = get_option("tweetbacks");
	$filterusers = explode(",",$options['filterusers']);
	
	$i = 0;
	
	$twittercomments 	= get_post_meta($post_id,"twittercomments",true);
	if (!is_array($twittercomments)) {
		$twittercomments = array();
		add_post_meta($post_id,"twittercomments",$twittercomments,true);
		add_post_meta($post_id,"tweetcount",0,true);	
	}
	$oldtwittercomments = $twittercomments;

	$tweetcount 		= get_post_meta($post_id,"tweetcount",true);
	$oldtweetcount		= $tweetcount;	
	
	if (isset($rss->items)) {
		while ($i < count($rss->items)) {
			$r = $rss->items[$i];

			$retweet 	= preg_match('/^(rt|retweet|retweeting)[ :].*/i',$r['title']);
			$id 		= str_replace("tag:search.twitter.com,2005:","",$r['id']);
			
			// Get the Twitter username, so 
			$twitterusername = strtolower(str_replace("http://twitter.com/","",$r['author_uri']));
			if ( yoast_check_shorturl($r['title'],$shorturls) && !in_array($twitterusername,$filterusers) && ($retweet == 0 || !$options['filterretweets']) ) {
				$commentdata = array();
				$commentdata['comment_post_ID'] = $post_id;
				$commentdata['comment_author'] = $r['author_name'];
	
				// Remove long S3 URL as to not hit max size of 100 in DB, restored upon get_avatar
				$email = addslashes(str_replace("http://s3.amazonaws.com/twitter_production/profile_images/","twitter:",$r['link_image']));
				// Remove "default" Twitter avatar
				$email = str_replace("http://static.twitter.com/images/default_profile_normal.png","twitter:",$email);
				// Switch out normal jpg for bigger jpg
				$email = str_replace("_normal","_bigger",$email);
	
				$commentdata['comment_author_email'] = $email;
				$commentdata['comment_author_url'] = $r['link'];

				// Decided not to strip out URL: $commentdata['comment_content'] = trim(str_replace($shorturl,"",$r['title']));
				$commentdata['comment_content'] = trim($r['title']);
	
				// Make Twitter ID's clickable
				$pattern	= '/\@([a-zA-Z0-9_]+)/';
				$replace	= '<a rel="nofollow" href="http://twitter.com/'.strtolower('\1').'">@\1</a>';
				$commentdata['comment_content'] = preg_replace($pattern,$replace,$commentdata['comment_content']);	
	
				if (isset($options['autoapprovetweets']) && $options['autoapprovetweets'] == true)
					$commentdata['comment_approved'] = '1';
				else
                                        $commentdata['comment_approved'] = '0';


				$commentdata['comment_type'] = "tweetback";
				$commentdata['comment_date'] = gmdate("Y-m-d H:i:s", strtotime($r['published']));

				if ($commentdata['comment_content'] != "") {
					// Make sure we don't store twitter comments twice.
					if (!array_key_exists($id, $twittercomments) || (!$options['filterretweets'] && $twittercomments[$id] == "retweet")) {
						if( null == $wpdb->get_var( "SELECT comment_author_url FROM {$wpdb->comments} WHERE comment_post_ID = {$commentdata[ 'comment_post_ID' ]} AND comment_author_url = '{$r[ 'link' ]}'" ) ) {
							$twittercomments[$id] = wp_insert_comment($commentdata);
							echo "<!--".$r['link']." added-->\n";
							$tweetcount++;
						} 
					} else {
						// echo "<!--".$r['link']." skipped-->\n";
					}
				}
			} elseif ($retweet > 0) {
				if (array_key_exists($id, $twittercomments)) {
					$commentid = $twittercomments[$id];
					wp_delete_comment($commentid);
					unset($twittercomments[$id]);
				}
				$tweetcount++;
				$twittercomments[$id] = "retweet";
			} else {
				if (array_key_exists($id, $twittercomments)) {
					$commentid = $twittercomments[$id];
					wp_delete_comment($commentid);
					unset($twittercomments[$id]);
					$tweetcount--;
				}
			}
			$i++;
		}
	}
	if ($oldtwittercomments != $twittercomments) {
		update_post_meta($post_id,"twittercomments",$twittercomments);
		update_post_meta($post_id,"tweetcount",$tweetcount);
		if (function_exists('wp_cache_post_change')) {
			wp_cache_post_change($post_id);
		}
	}
}

function yoast_schedule_tweetbacks() {
	if (!is_single() && !is_page()) {
		return;
	}
	global $post;
	if (!isset($post->ID) || $post->ID == 0 || $post->ID == "") {
		return;
	} else {
		$post_id = $post->ID;		
	}

	$options = get_option("tweetbacks");
	$updatetime = ($options['updatetime'] * 60);
	$tweetbackscheck = get_post_meta($post_id,"tweetbackscheck",true);
	if( ( mktime() - $tweetbackscheck ) < $updatetime ) {
		return;
	}
	update_post_meta($post_id,"tweetbackscheck",mktime());

	if( !wp_next_scheduled( 'tweetbacks' ) ) {
		wp_clear_scheduled_hook( 'tweetbacks' );
		wp_schedule_single_event(time()+60, 'tweetbacks');
	}
	$post_ids = (array)get_option( 'get_tweetback_post_id' );
	if( !in_array( $post_id, $post_ids ) ) {
		$post_ids[ $post_id ] = $post_id;
		update_option( 'get_tweetback_post_id', $post_ids );
	}
}
add_action('wp_footer','yoast_schedule_tweetbacks');

function yoast_get_tweetbacks() {
	global $wpdb;
	$mutex = mt_rand();
	if( !$wpdb->query( "UPDATE {$wpdb->options} SET option_value='{$mutex}' WHERE option_name='tweetbacks_mutex'" ) )
		$wpdb->query( "INSERT INTO {$wpdb->options} ( `option_name`, `option_value`, `autoload` ) VALUES ( 'tweetbacks_mutex', '{$mutex}', 'no' )" );
	sleep(2*mt_rand( 1, 3 ) );
	$m = $wpdb->get_var( "SELECT option_value FROM {$wpdb->options} WHERE option_name='tweetbacks_mutex'" );
	if( $mutex != $m )
		return;

	$post_ids = (array)get_option( 'get_tweetback_post_id' );
	update_option( 'get_tweetback_post_id', array() );
	foreach( $post_ids as $post_id ) {
		yoast_get_tweetback( $post_id );
		sleep( 2 );
		@set_time_limit(60);
	}
}
function yoast_get_tweetback( $post_id ) {
	$options = get_option("tweetbacks");
	
	require_once(ABSPATH . WPINC . '/class-snoopy.php');
	require_once(ABSPATH . WPINC . '/rss.php');
	
	$permalink = get_permalink($post_id);
	if ($permalink == "")
		return false;
		
	$shorturls = get_post_meta($post_id,"shorturls",true);
	$oldshorturls = $shorturls;
	if (!is_array($shorturls)) {
		$shorturls = array();		
		add_post_meta($post_id,"shorturls",$shorturls,true);	
		add_post_meta($post_id,"tweetbackscheck","",true);
	}
	
	$snoopy = new Snoopy;
	$snoopy->agent = "TweetBack WP Plugin 1.5.2 by Joost de Valk";
	$snoopy->referer = $permalink;
	$snoopy->_fp_timeout = 1;
	
	// Add the permalink of the post itself, as it does not HAVE to be shortened sometimes.
	if (!isset($shorturls['permalink'])) {	
		$shorturls['permalink'] = $permalink;
	}
	
	if (!isset($shorturls['tinyurl'])) {	
		$result = $snoopy->fetch("http://tinyurl.com/api-create.php?url=".$permalink);
		if ($result && strpos($snoopy->response_code,"200") !== false && $snoopy->results!="" && strpos($snoopy->results,"http://tinyurl.com") === 0) {					
			$shorturls['tinyurl'] = trim($snoopy->results);
		} 
	}
	
	if (!isset($shorturls['isgd'])) {
		$result = $snoopy->fetch('http://is.gd/api.php?longurl=' . urlencode($permalink));
		if ($result && strpos($snoopy->response_code,"200") !== false && $snoopy->results!="" && strpos($snoopy->results,"http://is.gd/") === 0) {
			$shorturls['isgd'] = trim($snoopy->results);
		} 
	}

	if (!isset($shorturls['bitly']) || $shorturls['bitly'] == "http://bit.ly/1BOWLu") {
		$result = $snoopy->fetch('http://bit.ly/api?url=' . urlencode($permalink));
		if ($result && strpos($snoopy->response_code,"200") !== false && $snoopy->results!="" && strpos($snoopy->results,"http://bit.ly/") === 0 && $snoopy->results != "http://bit.ly/1BOWLu") {
			$shorturls['bitly'] = trim($snoopy->results);
		} 
	}

	if (!isset($shorturls['snipr']) || !isset($shorturls['snipurl']) || !isset($shorturls['snurl'])) {
		$result = $snoopy->fetch('http://snipr.com/site/snip?r=simple&link=' . urlencode($permalink));
		if ($result && strpos($snoopy->response_code,"200") !== false && $snoopy->results!="" && strpos($snoopy->results,"http://snipr.com/") === 0) {
			$shorturls['snipr'] = trim($snoopy->results);
			$shorturls['snurl'] = str_replace("snipr.com","snurl.com",trim($snoopy->results));
			$shorturls['snipurl'] = str_replace("snipr.com","snipurl.com",trim($snoopy->results));
		} 
	}
	
	if ($shorturls != $oldshorturls)
		update_post_meta($post_id,"shorturls",$shorturls);

	// Build the search query from all short URL's
	$queries = array();
	foreach($shorturls as $shorturl) {
		$queries = create_query($shorturl, $queries);
	}
	
	foreach ($queries as $query) {
		$result = $snoopy->fetch("http://search.twitter.com/search.atom?rpp=100&q=".urlencode($query));
		if ($result) {
			parse_twitter_search_results($post_id,$snoopy->results,$shorturls,$tweetcount);
		}
	}

	if ($tweetcount != $oldtweetcount) {
		update_post_meta($post_id,"tweetcount",$tweetcount);	
	}	
}
add_action('tweetbacks','yoast_get_tweetbacks');

?>