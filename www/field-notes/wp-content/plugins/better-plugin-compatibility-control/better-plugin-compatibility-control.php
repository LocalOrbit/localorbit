<?php
/**
 * The main plugin file
 *
 * @package WordPress_Plugins
 * @subpackage BetterPluginCompatibilityControl
 */
 
/*
Plugin Name: Better Plugin Compatibility Control
Version: 3.5.1
Plugin URI: http://www.schloebe.de/wordpress/better-plugin-compatibility-control-plugin/
Description: Adds version compatibility info to the plugins page to inform the admin at a glance if a plugin is compatible with the current WP version.
Author: Oliver Schl&ouml;be
Author URI: http://www.schloebe.de/


Copyright 2008-2013 Oliver Schlöbe (email : scripts@schloebe.de)

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


/**
 * Pre-2.6 compatibility
 */
if ( !defined( 'WP_CONTENT_URL' ) )
	define( 'WP_CONTENT_URL', get_option( 'siteurl' ) . '/wp-content' );
if ( !defined( 'WP_CONTENT_DIR' ) )
	define( 'WP_CONTENT_DIR', ABSPATH . 'wp-content' );
if ( !defined( 'WP_PLUGIN_URL' ) )
	define( 'WP_PLUGIN_URL', WP_CONTENT_URL. '/plugins' );
if ( !defined( 'WP_PLUGIN_DIR' ) )
	define( 'WP_PLUGIN_DIR', WP_CONTENT_DIR . '/plugins' );

/**
 * Define the plugin version
 */
define("BPCC_VERSION", "3.5.1");

/**
 * Define the global var AMEISWP25, returning bool if at least WP 2.3 is running
 */
define('BPCCISWP28', version_compare($GLOBALS['wp_version'], '2.7.999', '>='));

/**
 * Define the plugin path slug
 */
define("BPCC_PLUGINPATH", "/" . plugin_basename( dirname(__FILE__) ) . "/");

/**
 * Define the plugin full url
 */
define("BPCC_PLUGINFULLURL", WP_PLUGIN_URL . BPCC_PLUGINPATH );

/**
 * Define the plugin full directory
 */
define("BPCC_PLUGINFULLDIR", WP_PLUGIN_DIR . BPCC_PLUGINPATH );


/** 
* The BetterPluginCompatibilityControl class
*
* @package WordPress_Plugins
* @subpackage BetterPluginCompatibilityControl
* @since 1.0
* @author scripts@schloebe.de
*/
class BetterPluginCompatibilityControl {
	const VERSION_OFFSET = 1;
	
	/**
 	* The BetterPluginCompatibilityControl class constructor
 	* initializing required stuff for the plugin
 	*
 	* @since 1.0
 	* @author scripts@schloebe.de
 	*/
	function betterplugincompatibilitycontrol() {
		if ( !BPCCISWP28 ) {
			add_action('admin_notices', array(&$this, 'wpVersionFailed'));
			return;
		}
		
		add_action('admin_init', array(&$this, 'bpcc_load_textdomain'));
		add_action('admin_init', array(&$this, 'bpcc_init'));
	}
	
	
	/**
 	* Initialize and load the plugin stuff
 	*
 	* @since 1.0
 	* @uses $pagenow
 	* @author scripts@schloebe.de
 	*/
	function bpcc_init() {
		global $pagenow;
		if ( !function_exists("add_action") ) return;
		
		if((defined('WP_ALLOW_MULTISITE') && WP_ALLOW_MULTISITE && is_network_admin())) {
			add_filter('network_admin_plugin_action_links', array(&$this, 'bpcc_pluginversioninfo'), 10, 2);
			if( current_user_can( 'manage_network_plugins' ) ) {
				add_filter('plugin_action_links', array(&$this, 'bpcc_pluginversioninfo'), 10, 2);
			}
		} else {
			if( current_user_can( 'install_plugins' ) ) {
				add_filter('plugin_action_links', array(&$this, 'bpcc_pluginversioninfo'), 10, 2);
			}
		}
		
		if( $pagenow == 'plugins.php' ) {
			function bpcc_enqueue_scripts() {
				if( version_compare($GLOBALS['wp_version'], '2.7.99', '>') && version_compare($GLOBALS['wp_version'], '3.0.99', '<') ) {
					wp_enqueue_script( 'bpcc_dom', BPCC_PLUGINFULLURL . "js/bbpc_dom.2.8.js", array('jquery'), BPCC_VERSION );
				} else {
					wp_enqueue_script( 'bpcc_dom', BPCC_PLUGINFULLURL . "js/bbpc_dom.3.1.js", array('jquery'), BPCC_VERSION );
				}
			}
			
			add_action('admin_head', array(&$this, 'bpcc_css_admin_header'));
			add_action('admin_enqueue_scripts', 'bpcc_enqueue_scripts' );
		}
	}


	/**
	 * Writes the css stuff into page header needed for the plugin to look good
	 *
	 * @since 1.0
	 * @author scripts@schloebe.de
	 */
	function bpcc_css_admin_header() {
		echo '
<style type="text/css">
.bpcc_wrapper {
	display: none;
}

.bpcc_minversion {
	border-color: #bbb;
	color: #aaa;
	text-shadow: 0 1px 0 #FFFFFF;
	cursor: help;
	padding: 0px;
	text-decoration: none;
	font-weight: 200;
	height: 8px;
}

.bpcc_maxversion {
	border-color: #bbb;
	color: #aaa;
	text-shadow: 0 1px 0 #FFFFFF;
	cursor: help;
	padding: 0px;
	text-decoration: none;
	font-weight: 200;
	height: 8px;
}

.bpcc_red {
	border-color: #CF6B6B;
	background: url(' . BPCC_PLUGINFULLURL . 'img/info.gif) #FFF7F7 2px center no-repeat;
	color: #A35457;
	padding: 1px 2px;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
	padding-left: 9px;
}

.bpcc_green {
	border-color: #A4CF6B;
	color: #81A354;
	background: #F8FFEF;
	padding: 1px 2px;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
}
</style>' . "\n";
	}
	
	
	/**
 	* Add plugin version dependency info
 	*
 	* @since 1.0
 	* @author scripts@schloebe.de
 	*/
	function bpcc_pluginversioninfo( $links, $file ) {
		$minpluginver = $maxpluginver = '';
		$bpcc_readme = WP_PLUGIN_DIR . '/' . dirname( $file ) . '/' . 'readme.txt';
		if( file_exists( $bpcc_readme ) ) {	
			$fp = @fopen( $bpcc_readme, 'r' );
			$pluginver_data = @fread( $fp, 8192 );
			fclose( $fp );
			preg_match( '|Requires at least:(.*)|i', $pluginver_data, $plugin_minversion );
			preg_match( '|Tested up to:(.*)|i', $pluginver_data, $plugin_maxversion );

			$minpluginver = $plugin_minversion[self::VERSION_OFFSET];
			$maxpluginver = $plugin_maxversion[self::VERSION_OFFSET];
		} else {
			require_once(ABSPATH . 'wp-admin/includes/plugin-install.php');
			$info = plugins_api('plugin_information', array('fields' => array('tested' => true, 'requires' => true, 'rating' => false, 'downloaded' => false, 'downloadlink' => false, 'last_updated' => false, 'homepage' => false, 'tags' => false, 'sections' => false, 'compatibility' => false, 'author' => false, 'author_profile' => false, 'contributors' => false, 'added' => false), 'slug' => dirname( $file ) ));
			if (!is_wp_error ($info)) {
				$minpluginver = $info->requires;
				$maxpluginver = $info->tested;
			}
		}
		if( $minpluginver != '' || $maxpluginver != '' ) {
			$addminverclass = ( version_compare(trim( $minpluginver ), $GLOBALS['wp_version'], '>') ) ? ' bpcc_red' : ' bpcc_green';
			$addminvertitle = ( version_compare(trim( $minpluginver ), $GLOBALS['wp_version'], '>') ) ? __('Warning: This plugin has not been tested with your current version of WordPress.', 'better-plugin-compatibility-control') : __('This plugin has been tested successfully with your current version of WordPress.', 'better-plugin-compatibility-control');
			$addminverinfo = (count( $minpluginver )>0) ? '<span class="bpcc_minversion' . $addminverclass . '" title="' . $addminvertitle . '">' . trim( $minpluginver ) . '</span>' : '<span class="bpcc_minversion" title="' . __('No compatibility info for this plugin available.', 'better-plugin-compatibility-control') . '">' . __('N/A', 'better-plugin-compatibility-control') . '</span>';
			
			$addmaxverclass = ( version_compare(trim( $maxpluginver ), $GLOBALS['wp_version'], '<') ) ? ' bpcc_red' : ' bpcc_green';
			$addminvertitle = ( version_compare(trim( $maxpluginver ), $GLOBALS['wp_version'], '<') ) ? __('Warning: This plugin has not been tested with your current version of WordPress.', 'better-plugin-compatibility-control') : __('This plugin has been tested successfully with your current version of WordPress.', 'better-plugin-compatibility-control');
			$addmaxverinfo = (count( $maxpluginver )>0) ? '<span class="bpcc_maxversion' . $addmaxverclass . '" title="' . $addminvertitle . '">' . trim( $maxpluginver ) . '</span>' : '<span class="bpcc_maxversion" title="' . __('No compatibility info for this plugin available.', 'better-plugin-compatibility-control') . '">' . __('N/A', 'better-plugin-compatibility-control') . '</span>';
			
			$addverinfo = '<span class="bpcc_wrapper">' . $addminverinfo . ' &ndash; ' . $addmaxverinfo . '';
		} else {
			$addverinfo = '<span class="bpcc_wrapper"><span class="bpcc_maxversion" title="' . __('No readme.txt file for this plugin found. Contact the plugin author!', 'better-plugin-compatibility-control') . '">' . __('No compatibility data found', 'better-plugin-compatibility-control') . '</span></span>';
		}
		
		$links = array_merge( $links, array( $addverinfo ) );
		
		return $links;
	}
	
	
	/**
 	* Initialize and load the plugin textdomain
 	*
 	* @since 1.0
 	* @author scripts@schloebe.de
 	*/
	function bpcc_load_textdomain() {
		if ( function_exists('load_plugin_textdomain') ) {
			if ( !defined('WP_PLUGIN_DIR') ) {
       		 	load_plugin_textdomain('better-plugin-compatibility-control', str_replace( ABSPATH, '', dirname(__FILE__) ) . '/languages');
        	} else {
        		load_plugin_textdomain('better-plugin-compatibility-control', false, dirname(plugin_basename(__FILE__)) . '/languages');
        	}
		}
	}
	
	
	/**
 	* Checks for the version of WordPress,
 	* and adds a message to inform the user
 	* if required WP version is less than 2.8
 	*
 	* @since 1.0
 	* @author scripts@schloebe.de
 	*/
	function wpVersionFailed() {
		echo "<div id='wpversionfailedmessage' class='error fade'><p>" . __('Better Plugin Compatibility Control requires at least WordPress 2.8!', 'better-plugin-compatibility-control') . "</p></div>";
	}
	
}

if ( class_exists('BetterPluginCompatibilityControl') && is_admin() ) {
	$betterplugincompatibilitycontrol = new BetterPluginCompatibilityControl();
}
?>