<?php
add_action('admin_menu', 'ts_add_options_page');

function ts_add_options_page() {
	add_options_page(__('Tweet Stats', 'tweet_stats'), __('Tweet Stats', 'tweet_stats'), 8, __FILE__, 'ts_options');
}

function ts_options() {
	global $ts_options, $wpdb;

	if (empty($ts_options)) {
		$ts_options = get_option('ts_options');
	}
		
	if (!empty($_POST['ts_generate'])) {
		check_admin_referer('tweet-stats');
	
		$processed = ts_generate_tweetbacks($_POST['nr_posts']);
	
		if ($processed == -1) {
			echo '<div id="message" class="updated fade"><p>' . __('The tweetback plugin is not activated. Please activate it first.', 'tweet_stats') . '</p></div>' . "\n";		
		} else if ($processed == 0) {
			echo '<div id="message" class="updated fade"><p>' . __('Tweetbacks for all posts have been generated, no need to use the import function any longer.', 'tweet_stats') . '</p></div>' . "\n";		
		} else {
			echo '<div id="message" class="updated fade"><p>' . __('Tweetbacks imported successfully.', 'tweet_stats') . '</p></div>' . "\n";		
		}
	} 
	
	$sql = "SELECT count(*) FROM $wpdb->posts WHERE $wpdb->posts.post_status = 'publish'";

	$total_posts = $wpdb->get_var($sql);

	$sql = "SELECT count(*) FROM $wpdb->posts LEFT JOIN $wpdb->postmeta ON ($wpdb->posts.ID = $wpdb->postmeta.post_id AND $wpdb->postmeta.meta_key = 'tweetbackscheck') 
			WHERE $wpdb->posts.post_status = 'publish' AND $wpdb->postmeta.post_id IS NULL";

	$unprocessed_posts = $wpdb->get_var($sql);

	$recommended_posts = ($unprocessed_posts > 50 ? 50 : $unprocessed_posts);
	
	$sql = "SELECT SUM($wpdb->postmeta.meta_value) FROM $wpdb->postmeta WHERE $wpdb->postmeta.meta_key = 'tweetcount'";
			
	$total_tweetbacks = (int) $wpdb->get_var($sql);
	?>
	<div class="wrap">
	<h2><?php _e('Tweet Stats Options', 'tweet_stats'); ?></h2>
	<?php if ($unprocessed_posts): ?>
	<div class="updated">
	<p><?php _e('By default, the tweetbacks plugin does not generate tweetbacks for posts that haven\'t yet been viewed since the plugin was installed.', 'tweet_stats'); ?></p>
	<p><?php _e('This means that the "most tweeted posts"" widget won\'t return the correct values at first. (How can it know the most popular posts if only a few have tweetbacks added?', 'tweet_stats'); ?></p>
	<p><?php _e('I recommend that you just wait a little or navigate the site yourself to generate tweetbacks for older posts.', 'tweet_stats'); ?></p>
	<p><?php _e('Nevertheless, for those that really want to generate all tweetbacks immediately, I have included the option.', 'tweet_stats'); ?></p>
	<p><?php _e('Be warned however, this is a long process. The process stops for 3 seconds between every post so as to give time to breathe.', 'tweet_stats'); ?></p>
	<p style="font-weight:bold;"><?php _e('Do not close the browser window whilst this is running!', 'tweet_stats'); ?></p>
	</div>
	<form action="<?php echo $_SERVER['REQUEST_URI']; ?>" method="post">
		<?php wp_nonce_field('tweet-stats'); ?>
		<p>
			<?php _e('Retrieve tweetbacks for ', 'tweet_stats'); ?> 
			<input type="text" name="nr_posts" size="4" value="<?php echo $recommended_posts; ?>" /> <?php _e('posts', 'tweet_stats'); ?> 
			<input type="submit" name="ts_generate" value="<?php _e('Fetch!', 'tweet_stats'); ?>" /> <i><?php _e('Do this in batches! Don\'t processs all your posts in 1 go.', 'tweet_stats'); ?></i>
		</p>
	</form>
	<?php elseif (empty($_POST['ts_generate'])): ?>
	<div class="updated fade"><p><?php _e('Your tweetbacks have been imported successfully.', 'tweet_stats'); ?></p></div>
	<?php endif; ?>
	<h3><?php _e('Stats', 'tweet_stats'); ?>
	<table style="padding-top:10px;">
	<tr><td style="width:150px;"><?php _e('Unprocessed posts:', 'tweet_stats'); ?></td><td><?php echo $unprocessed_posts; ?></td></tr>
	<tr><td><?php _e('Total posts:', 'tweet_stats'); ?></td><td><?php echo $total_posts; ?></td></tr>
	<tr><td><?php _e('Total tweetbacks:', 'tweet_stats'); ?></td><td><?php echo $total_tweetbacks; ?></td></tr>
	</table>
	<h3><?php _e('Tweet Stats Widgets', 'tweet_stats'); ?></h3>
	<p><?php _e('The widgets can be found', 'tweet_stats'); ?> <a href="widgets.php"><?php _e('here', 'tweet_stats'); ?></a>.</p>
	<h3><?php _e('Acknowledgements', 'tweet_stats'); ?></h3>
	<p>
		Subscribe to my blog at <a href="http://www.improvingtheweb.com">Improving The Web</a>: <a href="http://rss.improvingtheweb.com/improvingtheweb/wVZp">RSS</a> | <a href="http://twitter.com/improvingtheweb">Twitter</a> 
		(I've got alot more plugins coming!)
		Thanks go out to <a href="http://www.danzarrella.com">Danzarrella</a> and <a href="http://yoast.com">Yoast</a>.
	</p>
	</div>
	<?php
}

function ts_generate_tweetbacks($max=50, $sleep=3) {	
	set_time_limit(0);
	ignore_user_abort();
		
	global $wpdb, $wp_query, $post, $ts_options;
	
	if (empty($ts_options)) {
		$ts_options = get_option('ts_options');
	}
		
	$processed = 0;	
	
	if (!$max) {
		$max = 50;
	} else {
		$max = (int) $max;
	}
	
	if (!function_exists('yoast_get_tweetbacks')) {
		return -1;
	}
	
	$sql = "SELECT $wpdb->posts.* FROM $wpdb->posts LEFT JOIN $wpdb->postmeta ON ($wpdb->posts.ID = $wpdb->postmeta.post_id AND $wpdb->postmeta.meta_key = 'tweetbackscheck') 
			WHERE $wpdb->posts.post_status = 'publish' AND $wpdb->postmeta.post_id IS NULL LIMIT $max";
		
	$results = $wpdb->get_results($sql);
	
	if ($results) {
		foreach ($results as $post) {
			if ($post->post_type == 'post') {
				$wp_query->is_single = true;
				$wp_query->is_page	 = false;
			} else {
				$wp_query->is_single = false;
				$wp_query->is_page   = true;
			}
			yoast_get_tweetbacks();
			$processed++;
			sleep($sleep);
		}
	}
	
	$wp_query->is_single = false;
	$wp_query->is_page   = false;
	
	if (isset($ts_options['mt_cache']) || isset($ts_options['rt_cache'])) {
		unset($ts_options['mt_cache']);
		unset($ts_options['mt_cache_date']);
		unset($ts_options['rt_cache']);
		unset($ts_options['rt_cache_date']);
		
		update_option('ts_options', $ts_options);
	}
	
	return $processed;
}
?>