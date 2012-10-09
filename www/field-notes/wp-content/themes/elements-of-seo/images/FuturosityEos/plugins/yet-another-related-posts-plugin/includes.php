<?php

// here's a list of all the options YARPP uses (except version), as well as their default values, sans the yarpp_ prefix, split up into binary options and value options. These arrays are used in updating settings (options.php) and other tasks.
$yarpp_value_options = array('threshold' => 5,
				'limit' => 5,
				'excerpt_length' => 10,
				'before_title' => '<li>',
				'after_title' => '</li>',
				'before_post' => '<small>',
				'after_post' => '</small>',
				'before_related' => '<p>Related posts:<ol>',
				'after_related' => '</ol></p>',
				'no_results' => '<p>No related posts.</p>');
$yarpp_binary_options = array('past_only' => true,
				'show_score' => true,
				'show_excerpt' => false,
				'show_pass_post' => false,
				'cross_relate' => false,
				'auto_display' => true);

function yarpp_enabled() {
	global $wpdb;
	$indexdata = $wpdb->get_results("show index from $wpdb->posts");
	foreach ($indexdata as $index) {
		if ($index->Key_name == 'post_related') return 1;
	}
	return 0;
}

function yarpp_activate() {
	global $yarpp_version, $wpdb, $yarpp_binary_options, $yarpp_value_options;
	$yarpp_options = array_merge($yarpp_binary_options, $yarpp_value_options);
	foreach (array_keys($yarpp_options) as $option) {
		add_option('yarpp_'.$option,$yarpp_options[$option]);
	}
	if (!yarpp_enabled()) {
		$wpdb->query("ALTER TABLE $wpdb->posts ADD FULLTEXT `post_related` ( `post_name` , `post_content` )");
	}
	add_option('yarpp_version','1.5.1');
	update_option('yarpp_version','1.5.1');
	return 1;
}

function yarpp_upgrade_check() {
	if (get_option('threshold') and get_option('limit') and get_option('len')) {
		yarpp_activate(); // just to make sure, in case the plugin was just replaced and not deactivated / activated
		echo '<div id="message" class="updated fade" style="background-color: rgb(207, 235, 247);"><h3>An important message from YARPP:</h3><p>Thank you for upgrading to YARPP 1.5. YARPP 1.5 adds "simple installation" which automagically prints a simple related posts display at the end of each single entry (permalink) page without tinkering with any theme files. As a previous YARPP user, you probably have already edited your theme files to your liking, so this "automatic display" feature has been turned off.</p><p>If you would like to use "automatic display," remove <code>related_posts</code> from your <code>single.php</code> file and turn on automatic display in the YARPP options. Make sure to adjust the new prefix and suffix preferences to your liking as well.</p><p>For more information, check out the <a href="http://mitcho.com/code/yarpp/">YARPP documentation</a>. (This message will not be displayed again.)</p></div>';
		yarpp_upgrade_one_five();
	}
}

function yarpp_admin_menu() {
   if (function_exists('add_submenu_page')) add_submenu_page('options-general.php', 'Related Posts (YARPP)', 'Related Posts (YARPP)', 8, 'yet-another-related-posts-plugin/options.php');
}

function yarpp_default($content) {
	global $wpdb, $post, $user_level;
	if (get_option('yarpp_auto_display') and is_single()) {
		return $content."\n\n".yarpp_related(array('post'),array(),false);
	} else {
		return $content;
	}
}



/* apply_filters_without() is a dirty, dirty HACK.
It is used here to avoid a loop in apply_filters('the_content') > yarpp_default() > yarpp_related() > current_post_keywords() > apply_filters('the_content'). The code is straight up stolen from wp-includes/plugin.php and, with the exception of the single hack line below, should match what happens in plugin.php . */
function apply_filters_without($tag, $string, $without) {
	global $wp_filter, $merged_filters;

	if ( !isset( $merged_filters[ $tag ] ) )
		merge_filters($tag);

	if ( !isset($wp_filter[$tag]) )
		return $string;

	reset( $wp_filter[ $tag ] );

	$args = func_get_args();

	do{
		foreach( (array) current($wp_filter[$tag]) as $the_ )
			if ( !is_null($the_['function']) and $the_['function'] != $without ){ //HACK!
				$args[1] = $string;
				$string = call_user_func_array($the_['function'], array_slice($args, 1, (int) $the_['accepted_args']));
			}

	} while ( next($wp_filter[$tag]) !== false );

	return $string;
}

// upgrade to 1.5!
function yarpp_upgrade_one_five() {
	global $wpdb;
	$migrate_options = array('past_only','show_score','show_excerpt','show_pass_post','cross_relate','limit','threshold','before_title','after_title','before_post','after_post');
	foreach ($migrate_options as $option) {
		if (get_option($option)) {
			update_option('yarpp_'.$option,get_option($option));
			delete_option($option);
		}
	}
	// len is one option where we actually change the name of the option
	update_option('yarpp_excerpt_length',get_option('len'));
	delete_option('len');

	// override these defaults for those who upgrade from < 1.5
	update_option('yarpp_auto_display',false);
	update_option('yarpp_before_related','');
	update_option('yarpp_after_related','');
	unset($yarpp_version);
}

?>