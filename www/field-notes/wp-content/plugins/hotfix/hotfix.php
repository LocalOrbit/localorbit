<?php
/*
Plugin Name: Hotfix
Description: Provides "hotfixes" for selected WordPress bugs, so you don't have to wait for the next WordPress core release. Keep the plugin updated!
Version: 1.0
Author: Mark Jaquith
Author URI: http://coveredwebservices.com/
*/

// This bootstraps everything
WP_Hotfix_Controller::init();

class WP_Hotfix_Controller {
	function init() {
		add_action( 'init', 'wp_hotfix_init' );
		register_activation_hook(   __FILE__, array( __CLASS__, 'activate'   ) );
		register_deactivation_hook( __FILE__, array( __CLASS__, 'deactivate' ) );
	}
	function activate() {
		add_option( 'hotfix_version', '1' );
		register_uninstall_hook( __FILE__, array( __CLASS__, 'uninstall' ) );
	}
	function deactivate() {
		delete_option( 'hotfix_version' );
	}
	function uninstall() {
		self::deactivate(); // The same, for now
	}
}

function wp_hotfix_init() {
	global $wp_version;

	$hotfixes = array();

	switch ( $wp_version ) {
		case '3.5' :
			$hotfixes = array( '350_twentytwelve' );
			break;
		case '3.4.2' :
			$hotfixes = array( '342_custom_fields' );
			break;
		case '3.3' :
			$hotfixes = array( '330_no_wp_print_styles_in_admin', '330_no_json_encode_load_scripts' );
			break;
		case '3.1.3' :
			$hotfixes = array( '313_post_status_query_string' );
			break;
		case '3.1' :
			$hotfixes = array( '310_parsed_tax_query' );
			break;
		case '3.0.5' :
			$hotfixes = array( '305_comment_text_kses' );
			break;
	}

	$hotfixes = apply_filters( 'wp_hotfixes', $hotfixes );

	foreach ( (array) $hotfixes as $hotfix ) {
		call_user_func( 'wp_hotfix_' . $hotfix );
	}
}

/* And now, the hotfixes */

function wp_hotfix_305_comment_text_kses() {
	remove_filter( 'comment_text', 'wp_kses_data' );
	if ( is_admin() )
		add_filter( 'comment_text', 'wp_kses_post' );
}

function wp_hotfix_310_parsed_tax_query() {
	add_filter( 'pre_get_posts', 'wp_hotfix_310_parsed_tax_query_pre_get_posts' );
}

	function wp_hotfix_310_parsed_tax_query_pre_get_posts( $q ) {
		@$q->parsed_tax_query = false; // Force it to be re-parsed.
		return $q;
	}

function wp_hotfix_313_post_status_query_string() {
	add_filter( 'request', 'wp_hotfix_313_post_status_query_string_request' );
}

	function wp_hotfix_313_post_status_query_string_request( $qvs ) {
		if ( isset( $qvs['post_status'] ) && is_array( $qvs['post_status'] ) )
			$qvs['post_status'] = implode( ',', $qvs['post_status'] );
		return $qvs;
	}

if ( ! function_exists( 'json_encode' ) ) {
	function json_encode( $string ) {
		global $wp_hotfix_json;

		if ( ! is_a( $wp_hotfix_json, 'Services_JSON' ) ) {
			require_once( dirname( __FILE__ ) . '/inc/class-json.php' );
			$wp_hotfix_json = new Services_JSON();
		}

		return $wp_hotfix_json->encodeUnsafe( $string );
	}
}

if ( ! function_exists( 'json_decode' ) && ! function_exists( '_json_decode_object_helper' ) ) {
	function json_decode( $string, $assoc_array = false ) {
		global $wp_hotfix_json;

		if ( ! is_a( $wp_hotfix_json, 'Services_JSON' ) ) {
			require_once( dirname( __FILE__ ) . '/inc/class-json.php' );
			$wp_hotfix_json = new Services_JSON();
		}

		$res = $wp_hotfix_json->decode( $string );
		if ( $assoc_array )
			$res = _json_decode_object_helper( $res );
		return $res;
	}
	function _json_decode_object_helper($data) {
		if ( is_object($data) )
			$data = get_object_vars($data);
		return is_array($data) ? array_map(__FUNCTION__, $data) : $data;
	}
}

function wp_hotfix_330_no_wp_print_styles_in_admin() {
	add_action( 'admin_init', 'wp_hotfix_330_no_wp_print_styles_in_admin_remove', 999 );
}

function wp_hotfix_330_no_wp_print_styles_in_admin_remove() {
	remove_all_actions( 'wp_print_styles' );
}

function wp_hotfix_330_no_json_encode_load_scripts() {
	$functions = get_defined_functions();
	if ( in_array( 'json_encode', $functions['internal'] ) )
		return;

	if ( ! defined( 'CONCATENATE_SCRIPTS' ) )
		define( 'CONCATENATE_SCRIPTS', false );
}

function wp_hotfix_342_custom_fields() {
	add_action( 'admin_footer-post.php',     'wp_hotfix_342_custom_fields_action' );
	add_action( 'admin_footer-post-new.php', 'wp_hotfix_342_custom_fields_action' );
}

function wp_hotfix_342_custom_fields_action() {
	?><script>
	jQuery(document).ready( function($) {
		$('#postcustomstuff').on('hover focus', '#addmetasub, #updatemeta', function() {
			$(this).attr('id', 'meta-add-submit');
		});
	});
	</script>
	<?php
}

function wp_hotfix_350_twentytwelve() {
	add_action( 'pre_http_request', 'wp_hotfix_350_twentytwelve_pre_http_request', 10, 3 );
	add_action( 'load-themes.php', 'wp_hotfix_350_twentytwelve_themes_php' );
	add_action( 'load-update-core.php', 'wp_hotfix_350_twentytwelve_update_core_php', 9 );
}

function wp_hotfix_350_twentytwelve_update_core_php() {
	if ( ! empty( $_GET['action'] ) )
		return;

	$theme = wp_get_theme('twentytwelve');
	if ( ! $theme->exists() || ! $theme->errors() )
		return;

	delete_site_transient( 'update_themes' );
}

function wp_hotfix_350_twentytwelve_themes_php() {
	$theme = wp_get_theme('twentytwelve');
	if ( ! $theme->exists() || ! $theme->errors() )
		return;

	// Non-English installs weren't affected. Saves us the need to translate!
	if ( 'en_US' != get_locale() )
		return;

	if ( current_user_can( 'update_themes' ) )
		add_action( 'admin_notices', 'wp_hotfix_350_twentytwelve_notice' );
}

function wp_hotfix_350_twentytwelve_notice() {
	printf( '<div class="error"><p><strong>Looking for Twenty Twelve?</strong> You will need to first update it at <a href="%s">Dashboard &rarr; Updates</a>.</p></div>',
		self_admin_url( 'update-core.php' ) );
}

function wp_hotfix_350_twentytwelve_pre_http_request( $return, $args, $url ) {
	if ( $url != 'http://api.wordpress.org/themes/update-check/1.0/' )
		return $return;

	if ( ! empty( $args['_twentytwelve_hijack'] ) )
		return $return;

	$theme = wp_get_theme('twentytwelve');
	if ( ! $theme->exists() || ! $theme->errors() )
		return $return;

	$args['_twentytwelve_hijack'] = true;

	$themes = unserialize( $args['body']['themes'] );
	$themes['twentytwelve'] = array(
		'Name'       => 'Twenty Twelve',
		'Title'      => 'Twenty Twelve',
		'Version'    => '1.0',
		'Author'     => 'the WordPress team',
		'Author URI' => 'http://wordpress.org/',
		'Template'   => 'twentytwelve',
		'Stylesheet' => 'twentytwelve',
	);
	$args['body']['themes'] = serialize( $themes );
	return wp_remote_post( $url, $args );
}

