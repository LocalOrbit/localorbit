<?php
/*
Plugin Name: Ozh' Admin Drop Down Menu
Plugin URI: http://planetozh.com/blog/my-projects/wordpress-admin-menu-drop-down-css/
Description: All admin links available in a neat horizontal drop down menu. Saves lots of screen real estate! <strong>For WordPress 3.5+</strong>
Version: 3.6.5
Author: Ozh
Author URI: http://ozh.org/
*/

/* Release History :
 * 1.0:       Initial release
 * 1.1:       Tiger Admin compatibility !
 * 1.2:       Multiple Page Plugin (ex: Akismet) compatibility and minor CSS improvements
 * 1.3:       Fix for plugins with subfolders on Windows WP installs
 * 1.3.1:     Minor CSS tweaks
 * 2.0:       Complete rewrite for WordPress 2.5
 * 2.0.1:     Fixed: Bug with uploader
 * 2.0.2:     Improved: Compatibility with admin custom CSS (some colors are now dynamically picked)
              Fixed: Bug with submenu under plugin toplevel menus
              Fixed: WP's internal behavior or rewriting the "Manage" link according to the current "Write" page and vice-versa (makes sense?:)
			  Added: Option to display original submenu, per popular demand
 * 2.0.3:     Fixed: CSS bug with uploader, again. Grrrr.
 * 2.1:		  Added: WordPress Mu compatibility \o/
              Fixed: CSS issues with IE7, thanks Stuart
			  Added: Ability to dynamically resize menu on two lines when too many entries.
			  Added: Option to set max number of submenu entries before switching to horizontal display
 * 2.2:		  Fixed: Compatibilty with WP 2.6 (thanks to Matt Robenolt from ydekproductions.com for saving me some time:)
			  Added: Option page
			  Improved: Compatibility with handheld devices
			  Improved: File structure for minimal memory footprint
 * 2.2.1:     Improved: Some CSS tweaks (thanks to Dan Rubin)
			  Improved: The comment bubble now points to moderation
			  Improved: Compatibility with Fluency (and even fixing stuff on the Fluency side)
 * 2.2.1.1:   Fixed: A depecrated function was in! (Thanks Scribu)
 			  Added: A small LOLZ on the Option page :)
 * 2.3:       Added: hooks! HOOKS!! API to allow other plugins to interact more easily. This is l33t.
 			  Added: CSS classes and ids to all menu elements
			  Added: Optional icons for menu elements
			  Added: Ready for translation
 * 2.3.1:     Fixed: Was always showing plugin special icons even with icons disabled
 * 2.3.2:     Fixed: Top level links could be wrong
 * 2.3.4:     Improved: Compatibility with Fluency yet again
 			  Improved: Smarter submenu breaking with too long lists (now columns)
			  Improved: Better handling of POST on plugin page
			  Fixed: Bug with Safari and the resize menu stuff
			  Added: French and Italian translations
			  Improved: Support for WordPress Mu with specific icons
 * 2.3.4.1:   Fixed, or maybe not: same bug with Safari on Mac. This browser is a crap, Safari users I pity you.
 * 2.3.4.2:   Fixed: potential incompatibility with plugins using post-admin.php
 * 3.0:       Yet another complete rework for WP 2.7.
 * 3.0.1:     Fixed: #screen-meta positioning in MSIE6
              Updated: Translation .pot file
 * 3.0.2:     Added: option for solid color menu bar
 * 3.1:       Fixed: bug with top level plugin menus that would sometime lead to no other link shown in menu (thanks to Robert from afineforum.net)
 * 3.1.1:     Fixed: translation file was not loaded. Sorry translators! :)
              Removed: some unneeded vars causing notices in logs
 * 3.1.1.1:   Added: zh_CN (thanks Rui Shen!)
 * 3.1.1.2:   Added: it_IT (thanks Gianni Diurno!)
 * 3.1.1.3:   Added: es_ES (thanks Karin Sequen!)
 * 3.1.2:     Added: k0_KR (thanks Jong-In Kim!)
              Fixed: a few strings were not localized (thanks Karin Sequen!)
 * 3.1.2.1:   Fixed: missing tag (thanks Nick Romney)
 * 3.1.2.2:   Updated: ko_KR (thanks Jong-In Kim!)
 * 3.1.3:     Updated: missing strings from the .pot file. Oh god I hate this fucking i18n process. Sorry all translators.
              Fixed: compatibility with WP 2.8 (loading scripts on the option page)
 * 3.1.3.1:   Added: tr_TR (thanks Baris Unver!)
              Updated: ko_KR (thanks Jong-In Kim!)
 * 3.1.3.2:   Updated: es_ES (thanks Karin Sequen!)
 * 3.1.3.3:   Fixed: Javascript error in the color picker preventing from saving color scheme
 * 3.1.3.3.7: Updated: it_IT (thanks Gianni Diurno!)
              Laughed: at this totally 31337 version number. Next laugh at 6.6.6 :)
 * 3.2:       Added: RTL support for funky locales such as Arabic or Hebrew - thanks for feedback to Sudar Muthu, Narayanan Hariharan, Mena Hanna, Amiad
              Added: de_DE (thanks Frasier Crane)
			  Fixed: Compatibility with WP 2.8 (missing icon)
 * 3.2.1:     Added: ru_RU (thanks Fat Cow!)
 * 3.2.2:     Added: pt_BR (thanks Renato Tavares!)
 * 3.2.3:     Fixed: Missing icon for WP 2.8
 * 3.2.4:     Updated: tr_TR (thanks Baris Unver!)
 * 3.3:       Improved: compatibility with 2.8 (action links in Plugins page, better filter for custom icons thanks to Stephen Rider)
              Fixed: Dashboard disappearing with 2.8
 * 3.3.1:     Added: el (thanks friedlich!)
 * 3.3.2:     Added: be_BY (thanks ilyuha!)
              Fixed: silly toggling of the "Display Favorites" option (thanks johnbillion!)
			  Improved: display with crappy IE8 (thanks Octav!)
 * 3.3.3:     Added: he_IL (thanks Amiad Bareli!)
 * 3.3.4:     Added: ro_RO (thanks Octav!)
              Added: uk_UA (thanks wpp.pp.ua)
 * 3.3.5:     Added: uk (thanks Jurko Chervony!)
 * 3.3.6:     Minor cosmetic change to backend (twitter links)
 * 3.3.7:     Fixed: javascript error occurence (thanks Jaume !)
 * 3.3.8:     Added: zh_TW (thanks Paogray !)
 * 3.3.9:     Fixed: the failed fixed of 3.3.7
 * 3.3.10:    Fixed: stupid way of inserting Farbtastic all over the place (thanks olov !)
 * 3.3.11:    Added: cs_CZ (thanks Honza!)
 * 3.4:       Fixed: compatibility with WP 3.0
              Improved: JS to resize-recolumn submenus
 * 3.4.1:     Fixed: crappy red border for test I left in the CSS
 * 3.4.2:     Fixed: mod_security potential issue causing CSS to not load
 * 3.4.3:     Fixed: CSS & JS now loading in compliance with admin SSL pref
 * 3.4.4:     Updated: zh_TW (thanks Joan Wang!)
 * 3.4.5:     Fixed: reintroduced filters removed by accident in november 2008.
 * 3.4.99:    Updated: Quick compatibility with WP 3.1 (missing icons)
              Fixed: (some?) notices when debug mode on
 * 3.5:       Updated: finished compat with WP 3.1 (added missing icons + proper init hooks used)
              Fixed: JS bug introduced with WP 3.1 when resizing menus
 * 3.5.1:     Added: nl_NL (thanks Cees van den Heuvel)
 * 3.5.2:     Added: version constant
 * 3.5.3:     Removed: a console.debug might be problematic
 * 3.5.4:     Fixed: deprecated function calls removed
 * 3.6:       Fixed: Compatibility with WP 3.2
              Fixed: useless double slash in image URLs in .css.php
 * 3.6.1:     Added: Filter for global config array
 * 3.6.2:     Fixed: compatibility with WP 3.3 (thanks brasofilo!)
 * 3.6.3:     Fixed: compatibility with Chrome 17 (thanks Samuel Aguilera!)
              Fixed: bug if user has not admin capability and option "Minimal Mode" is checked (thanks Ed!)
 * 3.6.4:     Fixed: compatibility with WP 3.5 (thanks Samuel Aguilera again!)
 * 3.6.5:     Added: sk_SK (thanks Branco Radenovich)
 */


define( 'OZH_MENU_VER', '3.6.5' );
 
/***** Hook things in when visiting an admin page. When viewing a blog page, nothing even loads in memory. ****/
if ( is_admin() ){
	global $wp_ozh_adminmenu;
	require_once(dirname(__FILE__).'/inc/core.php');
	add_action('admin_init', 'wp_ozh_adminmenu_init', -1000);	// Init plugin defaults or read options
	add_action('admin_menu', 'wp_ozh_adminmenu_add_page', -999); // Add option page
	add_action('admin_head', 'wp_ozh_adminmenu_head', 999); // Insert CSS & JS in <head>
	add_action('in_admin_footer', 'wp_ozh_adminmenu_footer'); // Add unobstrusive credits in footer
	add_filter('plugin_action_links_'.plugin_basename(__FILE__), 'wp_ozh_adminmenu_plugin_actions', -10); // Add Config link to plugin list
	add_filter('ozh_adminmenu_icon_ozh_admin_menu', 'wp_ozh_adminmenu_customicon'); // This plugin will have its own icon of course
	add_filter('in_admin_header', 'wp_ozh_adminmenu', -9999); // Add the new admin menu right after the header area. Make sure we're first.
}

// Make sure it's WP 3.5+ only
function wp_ozh_adminmenu_check(){
	global $wp_version;
	if ( version_compare($wp_version, '3.5', '<') ) {
		deactivate_plugins( basename(__FILE__) );
		wp_die("Sorry, this plugin requires WordPress 3.5 at least");
	}
}
register_activation_hook(__FILE__, 'wp_ozh_adminmenu_check');

