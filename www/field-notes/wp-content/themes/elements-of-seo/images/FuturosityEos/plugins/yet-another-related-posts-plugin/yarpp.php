<?php
/*
Plugin Name: Yet Another Related Posts Plugin
Plugin URI: http://mitcho.com/code/yarpp/
Description: Returns a list of the related entries based on keyword matches, limited by a certain relatedness threshold. Like the tried and true Related Posts plugins’Äîjust better!
Version: 1.5.1
Author: mitcho (Michael Yoshitaka Erlewine)
*/

require_once('includes.php');
require_once('magic.php');
require_once('related-functions.php');

add_action('admin_head','yarpp_admin_menu');
add_action('admin_print_scripts','yarpp_upgrade_check');
add_filter('the_content','yarpp_default');
register_activation_hook(__FILE__,'yarpp_activate');

?>