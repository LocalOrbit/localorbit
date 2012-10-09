<?php
/*
Plugin Name: Add drafts
Plugin URI: http://deceblog.net/2009/03/add-drafts-wordpress-plugin/
Description: Displays a box with the last 10 recent drafts in the edit post page
Version: 1.0
Author: Dan Stefancu
Author URI: http://deceblog.net/
*/

// This function tells WP to add a new "meta box"
function add_drafts_box() {
	$current_user = wp_get_current_user();
	if ($current_user->user_level > 5) {
		if ($GLOBALS['wp_version'] >= '2.7') { // WP 2.7+
			add_meta_box(
				'draft-posts', // id of the <div> we'll add
				'Drafts', //title
				'echo_drafts_box', // callback function that will echo the box content
				'post', // where to add the box: on "post", "page", or "link" page
				'side'
			);
		} else { //WP 2.5+
			add_meta_box(
				'draft-posts', // id of the <div> we'll add
				'Drafts', //title
				'echo_drafts_box', // callback function that will echo the box content
				'post' // where to add the box: on "post", "page", or "link" page
			);
		}
	}
}

function echo_drafts_box() { ?>
	<ul>
		<?php
		$myposts = get_posts('numberposts=10&post_status=draft');
		foreach($myposts as $post_draft) : ?>
			<li><a href="<?php echo get_edit_post_link($post_draft->ID); ?>"><?php echo get_the_title($post_draft->ID); ?></a></li>
		<?php endforeach; ?>
	</ul> 
	<?php 
}

if (is_admin()) {
	add_action('admin_menu', 'add_drafts_box');
}
?>