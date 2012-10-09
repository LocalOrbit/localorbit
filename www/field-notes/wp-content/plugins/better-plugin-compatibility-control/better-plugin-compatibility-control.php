<?php
/**
 * The main plugin file
 *
 * @package WordPress_Plugins
 * @subpackage BetterPluginCompatibilityControl
 */
 
/*
Plugin Name: Better Plugin Compatibility Control
Version: 1.0.1
Plugin URI: http://www.schloebe.de/wordpress/better-plugin-compatibility-control-plugin/
Description: Adds version compatibility info to the plugins page to inform the admin at a glance if a plugin is compatible with the current WP version.
Author: Oliver Schl&ouml;be
Author URI: http://www.schloebe.de/


Copyright 2008 Oliver Schlöbe (email : scripts@schloebe.de)

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
define("BPCC_VERSION", "1.0.1");

/**
 * Define the global var AMEISWP25, returning bool if at least WP 2.3 is running
 */
define('BPCCISWP25', version_compare($GLOBALS['wp_version'], '2.3', '>='));

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

	/**
 	* The BetterPluginCompatibilityControl class constructor
 	* initializing required stuff for the plugin
 	*
 	* @since 1.0
 	* @author scripts@schloebe.de
 	*/
	function betterplugincompatibilitycontrol() {
		if ( !BPCCISWP25 ) {
			add_action('admin_notices', array(&$this, 'wpVersion25Failed'));
			return;
		}
		
		if ( is_admin() ) {
			add_action('init', array(&$this, 'bpcc_load_textdomain'));
			add_action('init', array(&$this, 'bpcc_init'));
		}
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
		add_filter('plugin_action_links', array(&$this, 'bpcc_pluginversioninfo'), 10, 2);
		
		if( $pagenow == 'plugins.php' && is_admin() ) {
			add_action('admin_head', array(&$this, 'bpcc_css_admin_header'));
			add_action('admin_head', wp_enqueue_script( 'jquery' ) && version_compare($GLOBALS['wp_version'], '2.7.99', '<') );
			if( version_compare($GLOBALS['wp_version'], '2.5', '>') && version_compare($GLOBALS['wp_version'], '2.5.9', '<') ) {
				add_action('admin_head', wp_enqueue_script( 'bpcc_dom', BPCC_PLUGINFULLURL . "js/bbpc_dom.2.5.js", array('jquery'), BPCC_VERSION ) );
			}
			if( version_compare($GLOBALS['wp_version'], '2.5.9', '>') && version_compare($GLOBALS['wp_version'], '2.7.99', '<') ) {
				add_action('admin_head', wp_enqueue_script( 'bpcc_dom', BPCC_PLUGINFULLURL . "js/bbpc_dom.2.6.js", array('jquery'), BPCC_VERSION ) );
			}
			if( version_compare($GLOBALS['wp_version'], '2.7.99', '>') ) {
				add_action('admin_head', wp_enqueue_script( 'bpcc_dom', BPCC_PLUGINFULLURL . "js/bbpc_dom.2.8.js", array('jquery'), BPCC_VERSION ) );
			}
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
	font-size: 9px !important;
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
	font-size: 9px !important;
	padding: 0px;
	text-decoration: none;
	font-weight: 200;
	height: 8px;
}

.bpcc_red {
	border-color: #CF6B6B;
	background: url(' . BPCC_PLUGINFULLURL . 'img/info.gif) left center no-repeat;
	color: #A35457;
	padding-left: 7px;
}

.bpcc_green {
	border-color: #A4CF6B;
	color: #81A354;
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
		$bpcc_readme = WP_PLUGIN_DIR . '/' . dirname( $file ) . '/' . 'readme.txt';
		if( file_exists( $bpcc_readme ) ) {
			$fp = @fopen( $bpcc_readme, 'r' );
			$pluginver_data = @fread( $fp, 8192 );
			fclose( $fp );
			preg_match( '|Requires at least:(.*)|i', $pluginver_data, $plugin_minversion );
			preg_match( '|Tested up to:(.*)|i', $pluginver_data, $plugin_maxversion );
			
			$addminverclass = ( version_compare(trim( $plugin_minversion[1] ), $GLOBALS['wp_version'], '>') ) ? ' bpcc_red' : ' bpcc_green';
			$addminvertitle = ( version_compare(trim( $plugin_minversion[1] ), $GLOBALS['wp_version'], '>') ) ? __('Warning: This plugin has not been tested with your current version of WordPress.', 'better-plugin-compatibility-control') : __('This plugin has been tested successfully with your current version of WordPress.', 'better-plugin-compatibility-control');
			$addminverinfo = (count( $plugin_minversion )>0) ? '<span class="bpcc_minversion' . $addminverclass . '" title="' . $addminvertitle . '">' . trim( $plugin_minversion[1] ) . '</span>' : '<span class="bpcc_minversion" title="' . __('No compatibility info for this plugin available.', 'better-plugin-compatibility-control') . '">' . __('N/A', 'better-plugin-compatibility-control') . '</span>';
			
			$addmaxverclass = ( version_compare(trim( $plugin_maxversion[1] ), $GLOBALS['wp_version'], '<') ) ? ' bpcc_red' : ' bpcc_green';
			$addminvertitle = ( version_compare(trim( $plugin_maxversion[1] ), $GLOBALS['wp_version'], '<') ) ? __('Warning: This plugin has not been tested with your current version of WordPress.', 'better-plugin-compatibility-control') : __('This plugin has been tested successfully with your current version of WordPress.', 'better-plugin-compatibility-control');
			$addmaxverinfo = (count( $plugin_maxversion )>0) ? '<span class="bpcc_maxversion' . $addmaxverclass . '" title="' . $addminvertitle . '">' . trim( $plugin_maxversion[1] ) . '</span>' : '<span class="bpcc_maxversion" title="' . __('No compatibility info for this plugin available.', 'better-plugin-compatibility-control') . '">' . __('N/A', 'better-plugin-compatibility-control') . '</span>';
			
			$addverinfo = '<span class="bpcc_wrapper">' . $addminverinfo . ' &ndash; ' . $addmaxverinfo . '</span>';
		} else {
			$addverinfo = '<span class="bpcc_wrapper"><span class="bpcc_maxversion" title="' . __('No readme.txt file for this plugin found. Contact the plugin author!', 'better-plugin-compatibility-control') . '">' . __('No readme.txt found', 'better-plugin-compatibility-control') . '</span></span>';
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
 	* if required WP version is less than 2.5
 	*
 	* @since 1.0
 	* @author scripts@schloebe.de
 	*/
	function wpVersion25Failed() {
		echo "<div id='wpversionfailedmessage' class='error fade'><p>" . __('Better Plugin Compatibility Control requires at least WordPress 2.5!', 'better-plugin-compatibility-control') . "</p></div>";
	}
	
}

if ( class_exists('BetterPluginCompatibilityControl') ) {
	$betterplugincompatibilitycontrol = new BetterPluginCompatibilityControl();
}
?>