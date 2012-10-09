<?php

/*
Plugin Name: Simply RSS Fetcher
Version: 1.2.1
Plugin URI: http://rick.jinlabs.com/code/simply-rss-fetcher/
Description: Displays the items of a desired RSS feed. Based on <a href="http://cavemonkey50.com/code/pownce/">Pownce for Wordpress</a> by <a href="http://cavemonkey50.com/">Cavemonkey50</a>.
Author: Ricardo Gonz&aacute;lez
Author URI: http://rick.jinlabs.com/
*/

/*  Copyright 2007  Ricardo Gonz·lez Castro (rick[at]jinlabs.com)

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
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/


//define('MAGPIE_CACHE_AGE', 120);
define('MAGPIE_CACHE_ON', 0); //2.7 Cache Bug
define('MAGPIE_INPUT_ENCODING', 'UTF-8');
define('MAGPIE_OUTPUT_ENCODING', 'UTF-8');

$srssfetcher_options['widget_fields']['title'] = array('label'=>'Title:', 'type'=>'text', 'default'=>'');
$srssfetcher_options['widget_fields']['rss'] = array('label'=>'RSS Feed:', 'type'=>'text', 'default'=>'');
$srssfetcher_options['widget_fields']['num'] = array('label'=>'Number of links:', 'type'=>'text', 'default'=>'5');
$srssfetcher_options['widget_fields']['update'] = array('label'=>'Show timestamps:', 'type'=>'checkbox', 'default'=>true);
$srssfetcher_options['widget_fields']['linked'] = array('label'=>'Linked:', 'type'=>'checkbox', 'default'=>true);
$srssfetcher_options['widget_fields']['encode_utf8'] = array('label'=>'UTF8 Encode:', 'type'=>'checkbox', 'default'=>false);


$srssfetcher_options['prefix'] = 'srssfetcher';

// Display srssfetcher messages
function srssfetcher($rss = '', $num = 5, $list = true, $update = true, $linked  = true, $encode_utf8 = false) {

	global $srssfetcher_options;
	include_once(ABSPATH . WPINC . '/rss.php');
	
	$messages = fetch_rss($rss);

	if ($list) echo '<ul class="srssfetcher">';
	
	if ($rss == '') {
		if ($list) echo '<li>';
		echo 'RSS not configured';
		if ($list) echo '</li>';
	} else {
			if ( empty($messages->items) ) {
				if ($list) echo '<li>';
				echo 'No feed items.';
				if ($list) echo '</li>';
			} else {
				foreach ( $messages->items as $message ) {
          
          $msg = $message['title'];
          if($encode_utf8) $msg = utf8_encode($msg);
					$link = $message['link'];
				
					if ($list) echo '<li class="srssfetcher-item">'; elseif ($num != 1) echo '<p class="srssfetcher-message">';
					
          if($linked ) $msg = '<a href="'.$link.'" class="srssfetcher-link">'.$msg.'</a>';  // Puts a link to the posts
  
          echo $msg;
        
          if($update) {				
            $time = strtotime($message['pubdate']);
            
            if ( ( abs( time() - $time) ) < 86400 )
              $h_time = sprintf( __('%s ago'), human_time_diff( $time ) );
            else
              $h_time = date(__('Y/m/d'), $time);

            echo sprintf( '%s',' <span class="srssfetcher-timestamp"><abbr title="' . date(__('Y/m/d H:i:s'), $time) . '">' . $h_time . '</abbr></span>' );
           }            

					if ($list) echo '</li>'; elseif ($num != 1) echo '</p>';
				
					$i++;
					if ( $i >= $num ) break;
				}
			}
			
			if ($list) echo '</ul>';
		}
	}

// Simply RSS Fetcher widget stuff
function widget_srssfetcher_init() {

	if ( !function_exists('register_sidebar_widget') )
		return;
	
	$check_options = get_option('widget_srssfetcher');
  if ($check_options['number']=='') {
    $check_options['number'] = 1;
    update_option('widget_srssfetcher', $check_options);
  }
	function widget_srssfetcher($args, $number = 1) {

		global $srssfetcher_options;
		
		// $args is an array of strings that help widgets to conform to
		// the active theme: before_widget, before_title, after_widget,
		// and after_title are the array keys. Default tags: li and h2.
		extract($args);

		// Each widget can store its own options. We keep strings here.
		include_once(ABSPATH . WPINC . '/rss.php');
		$options = get_option('widget_srssfetcher');
		
		// fill options with default values if value is not set
		$item = $options[$number];
		foreach($srssfetcher_options['widget_fields'] as $key => $field) {
			if (! isset($item[$key])) {
				$item[$key] = $field['default'];
			}
		}
		
		$messages = fetch_rss($rss);


		// These lines generate our output.
		echo $before_widget . $before_title . $item['title'] . $after_title;
		srssfetcher($item['rss'], $item['num'], true, $item['update'], $item['linked'], $item['encode_utf8']);
		echo $after_widget;
				
	}

	// This is the function that outputs the form to let the users edit
	// the widget's title. It's an optional feature that users cry for.
	function widget_srssfetcher_control($number) {
	
		global $srssfetcher_options;

		// Get our options and see if we're handling a form submission.
		$options = get_option('widget_srssfetcher');
		if ( isset($_POST['srssfetcher-submit']) ) {

			foreach($srssfetcher_options['widget_fields'] as $key => $field) {
				$options[$number][$key] = $field['default'];
				$field_name = sprintf('%s_%s_%s', $srssfetcher_options['prefix'], $key, $number);

				if ($field['type'] == 'text') {
					$options[$number][$key] = strip_tags(stripslashes($_POST[$field_name]));
				} elseif ($field['type'] == 'checkbox') {
					$options[$number][$key] = isset($_POST[$field_name]);
				}
			}

			update_option('widget_srssfetcher', $options);
		}

		foreach($srssfetcher_options['widget_fields'] as $key => $field) {
			
			$field_name = sprintf('%s_%s_%s', $srssfetcher_options['prefix'], $key, $number);
			$field_checked = '';
			if ($field['type'] == 'text') {
				$field_value = htmlspecialchars($options[$number][$key], ENT_QUOTES);
			} elseif ($field['type'] == 'checkbox') {
				$field_value = 1;
				if (! empty($options[$number][$key])) {
					$field_checked = 'checked="checked"';
				}
			}
			
			printf('<p style="text-align:right;" class="srssfetcher_field"><label for="%s">%s <input id="%s" name="%s" type="%s" value="%s" class="%s" %s /></label></p>',
				$field_name, __($field['label']), $field_name, $field_name, $field['type'], $field_value, $field['type'], $field_checked);
		}

		echo '<input type="hidden" id="srssfetcher-submit" name="srssfetcher-submit" value="1" />';
	}
	
	function widget_srssfetcher_setup() {
		$options = $newoptions = get_option('widget_srssfetcher');
		
		if ( isset($_POST['srssfetcher-number-submit']) ) {
			$number = (int) $_POST['srssfetcher-number'];
			$newoptions['number'] = $number;
		}
		
		if ( $options != $newoptions ) {
			update_option('widget_srssfetcher', $newoptions);
			widget_srssfetcher_register();
		}
	}
	
	
	function widget_srssfetcher_page() {
		$options = $newoptions = get_option('widget_srssfetcher');
	?>
		<div class="wrap">
			<form method="POST">
				<h2><?php _e('srssfetcher Widgets'); ?></h2>
				<p style="line-height: 30px;"><?php _e('How many srssfetcher widgets would you like?'); ?>
				<select id="srssfetcher-number" name="srssfetcher-number" value="<?php echo $options['number']; ?>">
	<?php for ( $i = 1; $i < 10; ++$i ) echo "<option value='$i' ".($options['number']==$i ? "selected='selected'" : '').">$i</option>"; ?>
				</select>
				<span class="submit"><input type="submit" name="srssfetcher-number-submit" id="srssfetcher-number-submit" value="<?php echo attribute_escape(__('Save')); ?>" /></span></p>
			</form>
		</div>
	<?php
	}
	
	
	function widget_srssfetcher_register() {
		
		$options = get_option('widget_srssfetcher');
		$dims = array('width' => 300, 'height' => 300);
		$class = array('classname' => 'widget_srssfetcher');

		for ($i = 1; $i <= 9; $i++) {
			$name = sprintf(__('Simple RSS Fetcher #%d'), $i);
			$id = "srssfetcher-$i"; // Never never never translate an id
			wp_register_sidebar_widget($id, $name, $i <= $options['number'] ? 'widget_srssfetcher' : /* unregister */ '', $class, $i);
			wp_register_widget_control($id, $name, $i <= $options['number'] ? 'widget_srssfetcher_control' : /* unregister */ '', $dims, $i);
		}
		
		add_action('sidebar_admin_setup', 'widget_srssfetcher_setup');
		add_action('sidebar_admin_page', 'widget_srssfetcher_page');
	}

	widget_srssfetcher_register();
}

// Run our code later in case this loads prior to any required plugins.
add_action('widgets_init', 'widget_srssfetcher_init');

?>