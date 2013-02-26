<?php
/**
 * Manage media uploaded file.
 *
 * There are many filters in here for media. Plugins can extend functionality
 * by hooking into the filters.
 *
 * @package WordPress
 * @subpackage Administration
 */

/** Load WordPress Bootstrap */
require_once(dirname(__FILE__) . '/../../../wp-load.php');
/** Load WordPress Administration Bootstrap */
require_once(dirname(__FILE__) . '/../../../wp-admin/admin.php');

if (!current_user_can('manage_options'))
wp_die(__('You do not have sufficient permissions to access this page.', 'umapper'));

@header('Content-Type: ' . get_option('html_type') . '; charset=' . get_option('blog_charset'));

// IDs should be integers
$ID = isset($ID) ? (int) $ID : 0;
$post_id = isset($post_id)? (int) $post_id : 0;

// Require an ID for the edit screen
if ( isset($action) && $action == 'edit' && !$ID )
wp_die(__("You are not allowed to be here"));

// prepare page load
wp_enqueue_script('jquery-ui-core');
wp_enqueue_script('jquery-ui-tabs');
wp_enqueue_script('jquery-ui-dialog');
//wp_enqueue_script('UmapperJqueryEffects', Umapper_Plugin::getPluginUri() . 'content/js/jquery-effects-1.7.2.min.js', false, '1.0');

// single action is required here
do_action('media_upload_umapper');
?>
