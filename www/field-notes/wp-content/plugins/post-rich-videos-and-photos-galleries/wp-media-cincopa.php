<?php
/*
Plugin Name: Post videos and photo galleries
Plugin URI: http://www.cincopa.com/wpplugin/wordpress-plugin.aspx
Description: Post rich videos and photos galleries from your cincopa account
Author: Cincopa 
Version: 1.42
*/


function plugin_ver()
{
	return '1.42';
}

function cincopa_url()
{
	return 'http://www.cincopa.com';
}

if (strpos($_SERVER['REQUEST_URI'], 'media-upload.php') && strpos($_SERVER['REQUEST_URI'], '&type=cincopa') && !strpos($_SERVER['REQUEST_URI'], '&wrt='))
{
	header('Location: '.cincopa_url().'/wpplugin/start.aspx?ver='.plugin_ver().'&rdt='.urlencode(selfURL()));
	exit;
}

function strleft($s1, $s2)
{
	return substr ( $s1, 0, strpos ( $s1, $s2 ) );
}

function selfURL()
{
	$s = empty ( $_SERVER ["HTTPS"] ) ? '' : ($_SERVER ["HTTPS"] == "on") ? "s" : "";
	$protocol = strleft ( strtolower ( $_SERVER ["SERVER_PROTOCOL"] ), "/" ) . $s;
	$port = ($_SERVER ["SERVER_PORT"] == "80") ? "" : (":" . $_SERVER ["SERVER_PORT"]);
	$ret = $protocol . "://" . $_SERVER ['SERVER_NAME'] . $port . $_SERVER ['REQUEST_URI'];

	return $ret;
}

function pluginURI()
{
	return get_option('siteurl').'/wp-content/plugins/'.dirname(plugin_basename(__FILE__));
}

function WpMediaCincopa_init() // constructor
{
//		load_plugin_textdomain('wp-media-cincopa', PLUGINDIR.'/'.dirname(plugin_basename(__FILE__)));

	add_action('media_buttons', 'addMediaButton', 20);

	add_action('media_upload_cincopa', 'media_upload_cincopa');
	// No longer needed in WP 2.6
	if ( !function_exists('wp_enqueue_style') )
	{
		add_action('admin_head_media_upload_type_cincopa', 'media_admin_css');
	}
      
	// check auth enabled
	//if(!function_exists('curl_init') && !ini_get('allow_url_fopen')) {}
}

function addMediaButton($admin = true)
{
	global $post_ID, $temp_ID;
	$uploading_iframe_ID = (int) (0 == $post_ID ? $temp_ID : $post_ID);

	$media_upload_iframe_src = get_option('siteurl').'/wp-admin/media-upload.php?post_id=$uploading_iframe_ID';

	$media_cincopa_iframe_src = apply_filters('media_cincopa_iframe_src', "$media_upload_iframe_src&amp;type=cincopa&amp;tab=cincopa");
	$media_cincopa_title = __('Add Cincopa photo', 'wp-media-cincopa');

	echo "<a class=\"thickbox\" href=\"{$media_cincopa_iframe_src}&amp;TB_iframe=true&amp;height=500&amp;width=640\" title=\"$media_cincopa_title\"><img src=\"".pluginURI()."/media-cincopa.gif\" alt=\"$media_cincopa_title\" /></a>";
}

function modifyMediaTab($tabs)
{
	return array(
		'cincopa' =>  __('Cincopa photo', 'wp-media-cincopa'),
	);
}

function media_upload_cincopa()
{
	wp_iframe('media_upload_type_cincopa');
}


function media_upload_type_cincopa()
{
	global $wpdb, $wp_query, $wp_locale, $type, $tab, $post_mime_types;
	add_filter('media_upload_tabs', 'modifyMediaTab');
?>

<br />
<br />
<h2>&nbsp;&nbsp;Please Wait...</h2>

<script>

	function cincopa_stub()
	{
	var i = location.href.indexOf("&wrt=");

	if (i > -1)
	{
	top.send_to_editor(unescape(location.href.substring(i+5)));
	}

	top.tb_remove();
	}

	window.onload = cincopa_stub;

</script>

<?php
}

WpMediaCincopa_init();

define("CINCOPA_REGEXP", "/\[cincopa ([[:print:]]+?)\]/");

function cincopa_plugin_callback($match)
{
	$uni = uniqid('');
	$ret = '<div id="_cp_widget_'.$uni.'"><img alt="Powered by Cincopa WordPress plugin" src="http://www.cincopa.com/wpplugin/runtime/loading.gif" style="border:0;"/>';

	if (strpos($_SERVER['REQUEST_URI'], '?p=') || strpos($_SERVER['REQUEST_URI'], '?') == 0)
	{
		$ret = $ret.'Another great product from Cincopa <a href="http://www.cincopa.com/mediasend/start.aspx">Send Large Files</a>. Also will help with your <a href="http://www.end-your-panic-attack.com/">nocturnal panic attacks</a>.';
	}

	$ret = $ret.'
</div>
<!-- Powered by Cincopa WordPress plugin '.plugin_ver().': http://www.cincopa.com/wpplugin/wordpress-plugin.aspx -->
<script type="text/javascript">document.getElementById("_cp_widget_'.$uni.'").innerHTML=';

	$ret = $ret."'<img src=\"http://www.cincopa.com/wpplugin/runtime/loading.gif\" />';</script>";
	
	$ret = $ret.'
<script src="http://www.cincopa.com/wpplugin/runtime/libasync.js" type="text/javascript"></script>
<script type="text/javascript">
cp_load_widget("'.urlencode($match[0]).'", "_cp_widget_'.$uni.'");
</script>
';

	return $ret;
}


function cincopa_plugin($content)
{
	return (preg_replace_callback(CINCOPA_REGEXP, 'cincopa_plugin_callback', $content));
}

add_filter('the_content', 'cincopa_plugin');
add_filter('the_content_rss', 'cincopa_plugin');
add_filter('comment_text', 'cincopa_plugin'); 

/////////////////////////////////
// dashboard widget
//////////////////////////////////
function cincopa_dashboard()
{
	if(function_exists('wp_add_dashboard_widget'))
		wp_add_dashboard_widget('cincopa', 'Cincopa', 'cincopa_dashboard_content');
}

function cincopa_dashboard_content()
{

	print("<p>Monitor <a target=_black href='http://www.cincopa.com/wpplugin/wizard_edit.aspx?ver=".plugin_ver()."&rdt=".urlencode(selfURL())."'>your galleries</a>.</p>");

	print("<p>Visit our <a target=_black href='http://forum.cincopa.com/'>support forum</a>.</p>");

	print("<p>Monitor <a target=_black href='http://www.cincopa.com/cincopaManager/ManageAccount.aspx?ver=".plugin_ver()."&rdt=".urlencode(selfURL())."'>your Cincopa account</a>.</p>");

	print("<p>Check <a target=_black href='http://www.cincopa.com/cincopaManager/directory.aspx?ver=".plugin_ver()."&rdt=".urlencode(selfURL())."'>other Cincopa products</a>.</p>");

}

add_action('wp_dashboard_setup', 'cincopa_dashboard'); 

/////////////////////////////////
// 
//////////////////////////////////

/*
add_action('admin_menu', 'my_plugin_menu');

function my_plugin_menu()
{
	if(function_exists('add_options_page'))
		add_options_page('My Plugin Options', 'My Plugin', 8, __FILE__, 'my_plugin_options');
}

function my_plugin_options() {
  echo '<div class="wrap">';
  echo '<p>Here is where the form would go if I actually had options.</p>';
  echo '</div>';
}
*/

















// Hook for adding admin menus
// http://codex.wordpress.org/Adding_Administration_Menus
add_action('admin_menu', 'mt_add_pages');

// action function for above hook
function mt_add_pages() {
    // Add a new submenu under Options:
//	add_options_page('Test Options', 'Test Options', 8, 'testoptions', 'mt_options_page');

    // Add a new submenu under Manage:
//	add_management_page('Test Manage', 'Test Manage', 8, 'testmanage', 'mt_manage_page');

	if(function_exists('add_menu_page'))
	{
		// Add a new top-level menu (ill-advised):
		add_menu_page('Cincopa', 'Cincopa', 8, __FILE__, 'mt_cincopa_toplevel_page');

		// kill the first menu item that is usually the the identical to the menu itself
		add_submenu_page(__FILE__, '', '', 8, __FILE__);

		add_submenu_page(__FILE__, 'Monitor Galleries', 'Monitor Galleries', 8, 'sub-page', 'mt_cincopa_sublevel_monitor');

		add_submenu_page(__FILE__, 'Create Gallery', 'Create Gallery', 8, 'sub-page2', 'mt_cincopa_sublevel_create');

		add_submenu_page(__FILE__, 'My Account', 'My Account', 8, 'sub-page3', 'mt_cincopa_sublevel_myaccount');

		add_submenu_page(__FILE__, 'Support Forum', 'Support Forum', 8, 'sub-page4', 'mt_cincopa_sublevel_forum');
	}
}


/*
// mt_options_page() displays the page content for the Test Options submenu
function mt_options_page() {
    echo "<h2>Test Options</h2>";
}

// mt_manage_page() displays the page content for the Test Manage submenu
function mt_manage_page() {
    echo "<h2>Test Manage</h2>";
}
*/

function mt_cincopa_toplevel_page() {
    echo "<iframe src='http://www.cincopa.com/wpplugin/start.aspx?ver=".plugin_ver()."&rdt=".urlencode(selfURL())."' width='98%' height='2000px'></iframe>";
}

function mt_cincopa_sublevel_create() {
    echo "<iframe src='http://www.cincopa.com/wpplugin/wizard_name.aspx?ver=".plugin_ver()."&rdt=".urlencode(selfURL())."' width='98%' height='2000px'></iframe>";
}

function mt_cincopa_sublevel_monitor() {
    echo "<iframe src='http://www.cincopa.com/wpplugin/wizard_edit.aspx?ver=".plugin_ver()."&rdt=".urlencode(selfURL())."' width='98%' height='2000px'></iframe>";
}

function mt_cincopa_sublevel_myaccount() {
    echo "<iframe src='http://www.cincopa.com/cincopaManager/ManageAccount.aspx?ver=".plugin_ver()."&rdt=".urlencode(selfURL())."' width='98%' height='2000px'></iframe>";
}

function mt_cincopa_sublevel_forum() {
    echo "<iframe src='http://forum.cincopa.com/viewforum.php?f=4' width='98%' height='2000px'></iframe>";
}









?>
