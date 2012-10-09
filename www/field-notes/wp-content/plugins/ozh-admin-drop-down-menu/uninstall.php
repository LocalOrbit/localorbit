<?php
/*
Part of Plugin: Ozh' Admin Drop Down Menu
Uninstall procedure (Removes the plugin cleanly in WP 2.7+)
http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/
*/

// Make sure that we are uninstalling
if ( !defined('WP_UNINSTALL_PLUGIN') ) {
    exit();
}

// Leave no trail
delete_option('ozh_adminmenu');

