<?php 
/*
Plugin Name: Quick Admin Links
Plugin URI: http://www.4-14.org.uk/wordpress-plugins/quick-admin-links
Description: Widget to add useful admin links on every page, allowing you to add new posts/pages, edit existing posts/pages, go to the admin, or log out.
Author: Mark Barnes
Version: 0.11
Author URI: http://www.4-14.org.uk/

*/

add_action('widgets_init', 'qal_widget_init');

function qal_widget_init() {
	$class = array('classname' => 'qal_log_on', 'description' => 'Adds a simple log on link to the sidebar.');
	wp_register_sidebar_widget('qal-log-on', 'Log On', 'qal_log_on', $class);
	$class = array('classname' => 'qal_edit_links', 'description' => 'Adds useful admin links for logged in users on every page.');
	wp_register_sidebar_widget('qal-edit-links', 'Quick Admin Links', 'qal_edit_links', $class);
	$control_ops = array('display_log_on' => 0, 'display_create_post' => 0, 'display_create_page' => 0, 'display_admin_link' => 1, 'display_edit_link' => 1, 'display_log_off' => 1);
	wp_register_widget_control('qal-edit-links', 'Quick Admin Links', 'qal_edit_links_control', $control_ops);
}

function qal_edit_links ($args) {
	global $post, $user_ID;
	extract ($args);
	$options = get_option('qal_edit_links');
	extract ($options);
	$output = '';
	if (is_user_logged_in()) {
		if (is_single() && $display_edit_link)
			if (current_user_can('edit_others_posts') | (current_user_can('edit_posts') && $user_ID == $post->post_author))
				$output .= "\t<li><a href=\"".get_option('siteurl')."/wp-admin/post.php?action=edit&post={$post->ID}\">Edit Post</a></li>\r";
		if (is_page() && $display_edit_link)
			if (current_user_can('edit_others_pages') | (current_user_can('edit_pages') && $user_ID == $post->post_author))
				$output .= "\t<li><a href=\"".get_option('siteurl')."/wp-admin/page.php?action=edit&post={$post->ID}\">Edit Page</a></li>\r";
		if (current_user_can('edit_posts') && $display_create_post)
				$output .= "\t<li><a href=\"".get_option('siteurl')."/wp-admin/post-new.php\">New Post</a></li>\r";
		if (current_user_can('edit_pages') && $display_create_page)
				$output .= "\t<li><a href=\"".get_option('siteurl')."/wp-admin/page-new.php\">New Page</a></li>\r";
		if (current_user_can('edit_posts') && $display_admin_link)
			$output .= "\t<li><a href=\"".get_option('siteurl')."/wp-admin/\">Site Admin</a></li>\r";
		if ($display_log_off)
			$output .= "\t<li><a href=\"".wp_logout_url()."\">Log out</a></li>\r";
	} else {
		if ($display_log_on)
			$output .= 	"\t<li><a href=\"".wp_login_url()."\">Log on</a></li>\r";
	}
	if ($output != '') {
		echo $before_widget;
		echo "<ul class=\"quick-admin-links\">\r";
		echo $output;
		echo "</ul>\r";
		echo $after_widget;
	}
}

function qal_edit_links_control () {
	$options = $newoptions = get_option('qal_edit_links');
	if ($_POST["qal-submit"]) {
		$newoptions['display_log_on'] = (int) $_POST["qal-display-log-on"];
		$newoptions['display_create_post'] = (int) $_POST["qal-display-create-post"];
		$newoptions['display_create_page'] = (int) $_POST["qal-display-create-page"];
		$newoptions['display_admin_link'] = (int) $_POST["qal-display-admin-link"];
		$newoptions['display_edit_link'] = (int) $_POST["qal-display-edit-link"];
		$newoptions['display_log_off'] = (int) $_POST["qal-display-log-off"];
	}
	if ( $options != $newoptions ) {
		$options = $newoptions;
		update_option('qal_edit_links', $options);
	}
	if ($options !== FALSE)
		extract ($options);
?>
	<div style="text-align:right">
		<p><label for="qal-display-log-on">Display log-on:<input type="checkbox" id="qal-display-log-on" name="qal-display-log-on" <?php echo $display_log_on ? 'checked=checked' : '' ?> value="1" /></label></p>
		<p><label for="qal-display-edit-link">Display edit link:<input type="checkbox" id="qal-display-edit-link" name="qal-display-edit-link" <?php echo $display_edit_link ? 'checked=checked' : '' ?> value="1" /></label></p>
		<p><label for="qal-display-create-post">Display create post:<input type="checkbox" id="qal-display-create-post" name="qal-display-create-post" <?php echo $display_create_post ? 'checked=checked' : '' ?> value="1" /></label></p>
		<p><label for="qal-display-create-page">Display create page:<input type="checkbox" id="qal-display-create-page" name="qal-display-create-page" <?php echo $display_create_page ? 'checked=checked' : '' ?> value="1" /></label></p>
		<p><label for="qal-display-admin-link">Display admin link:<input type="checkbox" id="qal-display-admin-link" name="qal-display-admin-link" <?php echo $display_admin_link ? 'checked=checked' : '' ?> value="1" /></label></p>
		<p><label for="qal-display-log-off">Display log-off:<input type="checkbox" id="qal-display-log-off" name="qal-display-log-off" <?php echo $display_log_off ? 'checked=checked' : '' ?> value="1" /></label></p>
		<input type="hidden" id="qal-submit" name="qal-submit" value="1">
	</div>
<?php
}

function qal_log_on ($args) {
	if (!is_user_logged_in()) {
		extract ($args);
		echo $before_widget.$before_title.'Log on'.$after_title;
		echo "<ul class=\"qal-log-on\">\r";
		echo "\t<li><a href=\"".wp_login_url()."\">Log on</a></li>\r";
		echo "</ul>\r";
		echo $after_widget;
	}
}
?>