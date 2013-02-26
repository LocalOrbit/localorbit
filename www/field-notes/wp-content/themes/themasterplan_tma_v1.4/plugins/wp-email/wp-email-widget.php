<?php
/*
Plugin Name: WP-EMail Widget
Plugin URI: http://lesterchan.net/portfolio/programming/php/
Description: Adds a EMail Widget to display most emailed posts and/or pages on your sidebar. You will need to activate WP-EMail first.
Version: 2.40
Author: Lester 'GaMerZ' Chan
Author URI: http://lesterchan.net
*/


/*  
	Copyright 2008  Lester Chan  (email : lesterchan@gmail.com)

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


### Function: Init WP-EMail Widget
function widget_email_init() {
	if (!function_exists('register_sidebar_widget')) {
		return;
	}

	### Function: WP-EMail Most EMailed Widget
	function widget_email_most_emailed($args) {
		extract($args);
		$options = get_option('widget_email_most_emailed');
		$title = htmlspecialchars(stripslashes($options['title']));		
		if (function_exists('get_mostemailed')) {
			echo $before_widget.$before_title.$title.$after_title;
			echo '<ul>'."\n";
			get_mostemailed($options['mode'], $options['limit'], $options['chars']);
			echo '</ul>'."\n";
			echo $after_widget;
		}		
	}

	### Function: WP-EMail Most EMailed Widget Options
	function widget_email_most_emailed_options() {
		$options = get_option('widget_email_most_emailed');
		if (!is_array($options)) {
			$options = array('title' => __('Most Emailed', 'wp-email'), 'mode' => 'post', 'limit' => 10, 'chars' => 200);
		}
		if ($_POST['most_emailed-submit']) {
			$options['title'] = strip_tags($_POST['most_emailed-title']);
			$options['mode'] = strip_tags($_POST['most_emailed-mode']);
			$options['limit'] = intval($_POST['most_emailed-limit']);
			$options['chars'] = intval($_POST['most_emailed-chars']);
			update_option('widget_email_most_emailed', $options);
		}
		echo '<p><label for="most_emailed-title">';
		_e('Title', 'wp-email');
		echo ': </label><input type="text" id="most_emailed-title" name="most_emailed-title" value="'.htmlspecialchars(stripslashes($options['title'])).'" /></p>'."\n";
		echo '<p><label for="most_emailed-mode">';
		_e('Show Views For: ', 'wp-email');
		echo ' </label>'."\n";
		echo '<select id="most_emailed-mode" name="most_emailed-mode" size="1">'."\n";
		echo '<option value="both"';
		selected('both', $options['mode']);
		echo '>';
		_e('Posts &amp; Pages', 'wp-email');
		echo '</option>'."\n";
		echo '<option value="post"';
		selected('post', $options['mode']);
		echo '>';
		_e('Posts', 'wp-email');
		echo '</option>'."\n";
		echo '<option value="page"';
		selected('page', $options['mode']);
		echo '>';
		_e('Pages', 'wp-email');
		echo '</option>'."\n";
		echo '</select>&nbsp;&nbsp;';
		_e('Only', 'wp-email');
		echo '</p>'."\n";
		echo '<p><label for="most_emailed-limit">';
		_e('Limit', 'wp-email');
		echo ': </label><input type="text" id="most_emailed-limit" name="most_emailed-limit" value="'.intval($options['limit']).'" size="3" /></p>'."\n";
		echo '<p><label for="most_emailed-chars">';
		_e('Post Title Length (Characters)', 'wp-email');
		echo ': </label><input type="text" id="most_emailed-chars" name="most_emailed-chars" value="'.intval($options['chars']).'" size="5" />&nbsp;&nbsp;'."\n";
		_e('(<strong>0</strong> to disable)', 'wp-email');
		echo '</p>'."\n";
		echo '<input type="hidden" id="most_emailed-submit" name="most_emailed-submit" value="1" />'."\n";
	}
	// Register Widgets
	register_sidebar_widget(array('Most Emailed', 'wp-email'), 'widget_email_most_emailed');
	register_widget_control(array('Most Emailed', 'wp-email'), 'widget_email_most_emailed_options', 400, 200);
}


### Function: Load The WP-EMail Widget
add_action('plugins_loaded', 'widget_email_init')
?>