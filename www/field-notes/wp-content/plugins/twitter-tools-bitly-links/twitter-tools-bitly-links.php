<?php /*

**************************************************************************

Plugin Name:  Twitter Tools: bit.ly Links
Plugin URI:   http://www.viper007bond.com/wordpress-plugins/twitter-tools-bitly-links/
Version:      1.1.2
Description:  Makes the links that <a href="http://wordpress.org/extend/plugins/twitter-tools/">Twitter Tools</a> posts to Twitter be API-created <a href="http://bit.ly/">bit.ly</a> links so you can track the number of clicks and such via your bit.ly account. Requires PHP 5.2.0+.
Author:       Viper007Bond
Author URI:   http://www.viper007bond.com/

**************************************************************************/

class TwitterToolsBitlyLinks {

	// Initalize the plugin by registering the hooks
	function __construct() {
		// Twitter Tools v2.0+ supports this natively. Don't do anything if that sub-plugin is active.
		if ( function_exists('aktt_bitly_shorten_url') )
			return false;

		// Load localization domain
		load_plugin_textdomain( 'twitter-tools-bitly-links', false, '/twitter-tools-bitly-links/localization' );

		// This plugin requires PHP 5.2.0+ and WordPress 2.7+
		if ( function_exists('json_decode') && function_exists('wp_remote_retrieve_body') ) {
			// Register options
			add_option( 'viper_ttbl_login' );
			add_option( 'viper_ttbl_apikey' );

			// Register hooks
			add_action( 'admin_menu',               array(&$this, 'register_settings_page') );
			add_action( 'wp_ajax_viper_ttbl_check', array(&$this, 'ajax_authentication_check') );
			add_filter( 'whitelist_options',        array(&$this, 'whitelist_options') );
			add_filter( 'tweet_blog_post_url',      array(&$this, 'modify_url') );

			// Make sure the user has filled in their login and API key
			$login  = trim( get_option('viper_ttbl_login') );
			$apikey = trim( get_option('viper_ttbl_apikey') );
			if ( ( !$login || !$apikey ) && current_user_can('manage_options') )
				add_action( 'admin_notices',        array(&$this, 'settings_warn') );
		}

		// Old version of PHP or WordPress? Let the user know.
		elseif ( current_user_can('activate_plugins') ) {
			add_action( 'admin_notices',            array(&$this, 'old_version_warning') );
		}
	}


	// Register the settings page
	function register_settings_page() {
		add_options_page( __('Twitter Tools: bit.ly Links', 'twitter-tools-bitly-links'), __('Twitter Tools: bit.ly', 'twitter-tools-bitly-links'), 'manage_options', 'twitter-tools-bitly-links', array(&$this, 'settings_page') );
	}


	// Whitelist the options to allow saving via options.php
	function whitelist_options( $whitelist_options ) {
		$whitelist_options['twitter-tools-bitly-links'] = array( 'viper_ttbl_login', 'viper_ttbl_apikey' );

		return $whitelist_options;
	}


	// Warn about an old version of PHP or WordPress
	function old_version_warning() {
		global $wp_version;
		echo '<div class="error"><p>' . sprintf( __( '<strong>Twitter Tools: bit.ly Links:</strong> You do not meet the minimum requirements of PHP %1$s and WordPress %2$s. You are currently using PHP %3$s and WordPress %4$s.', 'vipers-video-quicktags' ), '5.2.0', '2.7', PHP_VERSION, $wp_version ) . "</p></div>\n";
	}


	// Display a notice telling the user to fill in their bit.ly details
	function settings_warn() {
		echo '<div class="error"><p>' . sprintf( __( '<strong>Twitter Tools: bit.ly Links:</strong> You must fill in your bit.ly details on the <a href="%s">settings page</a> in order for this plugin to function.', 'vipers-video-quicktags' ), admin_url('options-general.php?page=twitter-tools-bitly-links') ) . "</p></div>\n";
	}


	// Modify the URL being sent to Twitter by Twitter Tools
	function modify_url( $url ) {

		// Make sure the user has filled in their login and API key
		$login  = urlencode( strtolower( trim( get_option('viper_ttbl_login') ) ) );
		$apikey = urlencode( trim( get_option('viper_ttbl_apikey') ) );
		if ( empty($login) || empty($apikey) )
			return $url;

		// Tell bit.ly to shorten the URL for us
		$response = wp_remote_retrieve_body( wp_remote_get( "http://api.bit.ly/shorten?version=2.0.1&format=json&history=1&login={$login}&apiKey={$apikey}&longUrl=" . urlencode( $url ) ) );

		if ( empty($response) )
			return $url;

		// Decode the response from bit.ly
		if ( !$response = json_decode( $response, true ) )
			return $url;

		if ( !isset($response['errorCode']) || 0 != $response['errorCode'] || empty($response['results']) || empty($response['results'][$url]) || empty($response['results'][$url]['shortUrl']) )
			return $url;

		return $response['results'][$url]['shortUrl'];
	}


	// Settings page
	function settings_page() { ?>

<script type="text/javascript">
// <![CDATA[
	function viper_ttbl_ajax() {
		jQuery("#viper_ttbl_status").load("<?php echo admin_url('admin-ajax.php'); ?>?nocache=" + Math.random(), { action: "viper_ttbl_check", login: jQuery("#viper_ttbl_login").val(), apikey: jQuery("#viper_ttbl_apikey").val() });
	}
	jQuery(document).ready(function(){ viper_ttbl_ajax() });
	jQuery("body").change(function(){ viper_ttbl_ajax() }); // I couldn't get anything but "body" to work for some reason
// ]]>
</script>

<div class="wrap">
<?php screen_icon(); ?>
	<h2><?php _e( 'Twitter Tools: bit.ly Links Settings', 'twitter-tools-bitly-links' ); ?></h2>

	<form id="viper_ttbl_form" method="post" action="options.php">
<?php settings_fields('twitter-tools-bitly-links'); ?>

	<table class="form-table">
		<tr valign="top">
			<th scope="row"><label for="viper_ttbl_login"><?php _e( 'bit.ly Login', 'twitter-tools-bitly-links' ); ?></label></th>
			<td><input type="text" name="viper_ttbl_login" id="viper_ttbl_login" value="<?php form_option('viper_ttbl_login'); ?>" class="regular-text" /></td>
		</tr>
		<tr valign="top">
			<th scope="row"><label for="viper_ttbl_apikey"><?php _e( 'bit.ly API Key', 'twitter-tools-bitly-links' ); ?></label></th>
			<td>
				<input type="text" name="viper_ttbl_apikey" id="viper_ttbl_apikey" value="<?php form_option('viper_ttbl_apikey'); ?>" class="regular-text" />
				<span class="description"><?php printf( __( 'This can be found on your <a href="%s">account page</a>.', 'twitter-tools-bitly-links' ), 'http://bit.ly/account/' ); ?></span>
			</td>
		</tr>
		<tr valign="top" class="hide-if-no-js">
			<th scope="row"><?php _e( 'API Status', 'twitter-tools-bitly-links' ); ?></th>
			<td style="font-size:1em"><span id="viper_ttbl_status"><em>Checking...</em></span></td>
		</tr>
	</table>

	<p class="submit">
		<input type="submit" name="twitter-tools-bitly-links-submit" class="button-primary" value="<?php _e('Save Changes') ?>" />
	</p>

	</form>
</div>

<?php
	}


	// Check the authentication details via AJAX
	function ajax_authentication_check() {
		// Make sure the user has filled in their login and API key
		$login = $apikey = false;
		if ( !empty($_POST['login']) )
			$login  = urlencode( strtolower( trim( $_POST['login'] ) ) );
		if ( !empty($_POST['apikey']) )
			$apikey = urlencode( trim( $_POST['apikey'] ) );
		if ( empty($login) || empty($apikey) )
			exit();

		// Ask bit.ly for details about a random shortened URL in order to test the authentication details
		$response = wp_remote_retrieve_body( wp_remote_get( "http://api.bit.ly/expand?version=2.0.1&shortUrl=http://bit.ly/mnvj7&login={$login}&apiKey={$apikey}" ) );

		if ( empty($response) )
			exit( '<strong style="color:red">' . __('Failed to test credentials. Hmm.', 'twitter-tools-bitly-links') . '</strong>' );

		// Decode the response from bit.ly
		if ( !$response = json_decode( $response, true ) )
			exit( '<strong style="color:red">' . __('Failed to parse bit.ly API response. Hmm.', 'twitter-tools-bitly-links') . '</strong>' );

		if ( !isset($response['errorCode']) || 0 != $response['errorCode'] )
			exit( '<strong style="color:red">' . __('Your credentials are invalid. Please double-check them.', 'twitter-tools-bitly-links') . '</strong>' );

		exit( '<strong style="color:green">' . __('Your credentials are valid.', 'twitter-tools-bitly-links') . '</strong>' );
	}
}

// Start this plugin once all other plugins are fully loaded
add_action( 'init', 'TwitterToolsBitlyLinks' ); function TwitterToolsBitlyLinks() { global $TwitterToolsBitlyLinks; $TwitterToolsBitlyLinks = new TwitterToolsBitlyLinks(); }

?>