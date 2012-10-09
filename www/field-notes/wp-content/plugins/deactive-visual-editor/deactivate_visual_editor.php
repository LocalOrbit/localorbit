<?php
/*
Plugin Name: Deactivate Visual Editor
Plugin URI: http://plugindve.wordpress.com/
Plugin Description: Deactivates the visual editor for specific pages or posts.
Use: Set custom field 'deactivate_visual_editor' to true.
Version: 0.1
Author: J. Matt Fields
Author URI: http://
*/


/*
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

*/ 

function deactivate_visual_editor() {
  global $wp_rich_edit;

  $post_id = $_GET['post'];
  $value = get_post_meta($post_id, 'deactivate_visual_editor', true);;
  if($value == 'true')
    $wp_rich_edit = false;

}

// Wordpress Hooks
add_action('load-page.php', 'deactivate_visual_editor');
add_action('load-post.php', 'deactivate_visual_editor');
?>