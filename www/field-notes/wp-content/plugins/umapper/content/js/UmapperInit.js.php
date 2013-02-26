<?php
/* 
 * Used to pass server-side parameters to JS scripts
 * This file is a dependency for any other UMapper JS files, so we can be
 * pretty safe with assuming that once defined here variables would be
 * available in other JS files as well.
 */

// make sure that we have access to WP core functions
if (!function_exists('add_action')) {
    //require_once dirname(__FILE__) . '/../../../../../wp-config.php';
    require_once dirname(__FILE__) . '/../../../../../wp-load.php';
    require_once dirname(__FILE__) . '/../../../../../wp-admin/admin.php';
}

// make sure that unathorized requests are ignored
if ( function_exists('current_user_can') && !current_user_can('manage_options') ) die(__('Cheatin&#8217; uh?'));
if (! user_can_access_admin_page()) wp_die( __('You do not have sufficient permissions to access this page.') );

require_once dirname(__FILE__) . '/../../lib/Umapper/Plugin.php';
?>

// general options
var UmapperOptions  = function(){}
UmapperOptions.prototype = {
    pluginUri : '<?php echo Umapper_Plugin::getPluginUri();?>',
    rpcUri : '<?php echo Umapper_Plugin::getPluginUri();?>proxy.php?url=http://www.umapper.com/services/xmlrpc/',
    rpcKey : '<?php echo get_option('umapper_api_key');?>',
    rpcToken : '<?php echo get_option('umapper_token');?>'
};
umapperOptions  = new UmapperOptions ();


// pre-load images
new Image().src = '<?php echo Umapper_Plugin::getPluginUri();?>content/img/indicator.gif';
new Image().src = '<?php echo Umapper_Plugin::getPluginUri();?>content/img/indicator_m.gif';


