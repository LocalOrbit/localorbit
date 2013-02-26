<?php

/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information by
 * visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */

define('AUTH_KEY', '!%L]ml|H|a-y<)EWk:y;>+UgmP:@uC|Qeg VXV}:7M?p N9Xku`x=]n>xgL!?');
define('SECURE_AUTH_KEY', 'sa}!.4cH>D1FWCu4@41b[u>XhSJsQ~xW%WM-1A.mG(-T-Cb;rmL,w~o%s');
define('LOGGED_IN_KEY', 'vcp~,9dJ56pL80aapU/ec}A*kFpgfaN4rPaMLWPj3E:[3Z6/8FsZ2H1.dYS]p0');
define('NONCE_KEY', 'nIu=`+g-&>qffQL{&P{RxYNs+$$zqNg_8h|`h+f+];Sd_4@(z');

if(strpos($_SERVER['HTTP_HOST'],'dev') !== false)
{
	define('DB_NAME', 'localorb_wordpress_dev');
	define('WP_HOME','http://dev.localorb.it/field-notes');
	define('WP_SITEURL','http://dev.localorb.it/field-notes');
	define('DB_USER', 'localorb_www');
	define('DB_PASSWORD', 'localorb_www_dev');
	define('DB_HOST', 'localhost');
}
else if(strpos($_SERVER['HTTP_HOST'],'newui') !== false)
{
	define('DB_NAME', 'localorb_wordpress_newui');
	define('WP_HOME','http://newui.localorb.it/field-notes');
	define('WP_SITEURL','http://newui.localorb.it/field-notes');
	define('DB_USER', 'localorb_www');
	define('DB_PASSWORD', 'l0cal1sdab3st');
	define('DB_HOST', 'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com');
}
else if(strpos($_SERVER['HTTP_HOST'],'qa') !== false)
{
	define('DB_NAME', 'localorb_wordpress_qa');
	define('WP_HOME','http://qa.localorb.it/field-notes');
	define('WP_SITEURL','http://qa.localorb.it/field-notes');
	define('DB_USER', 'localorb_www');
	define('DB_PASSWORD', 'l0cal1sdab3st');
	define('DB_HOST', 'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com');
}
else if(strpos($_SERVER['HTTP_HOST'],'testing') !== false)
{
	define('DB_NAME', 'localorb_wordpress_testing');
	define('WP_HOME','http://testing.localorb.it/field-notes');
	define('WP_SITEURL','http://testing.localorb.it/field-notes');
	define('DB_USER', 'localorb_www');
	define('DB_PASSWORD', 'l0cal1sdab3st');
	define('DB_HOST', 'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com');
}
else
{
	define('DB_NAME', 'localorb_wordpress_production');
	define('WP_HOME','http://www.localorb.it/field-notes');
	define('WP_SITEURL','http://www.localorb.it/field-notes');
	define('DB_USER', 'localorb_www');
	define('DB_PASSWORD', 'l0cal1sdab3st');
	define('DB_HOST', 'localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com');
}

	//~ define('DB_USER', 'localorb_www');
	//~ define('DB_NAME', 'localorb_wpdev');
	//~ define('DB_PASSWORD', 'nAvAswu4');
	//~ define('AUTH_KEY', '!%L]ml|H|a-y<)EWk:y;>+UgmP:@uC|Qeg VXV}:7M?p N9Xku`x=]n>xgL!?');
	//~ define('SECURE_AUTH_KEY', 'sa}!.4cH>D1FWCu4@41b[u>XhSJsQ~xW%WM-1A.mG(-T-Cb;rmL,w~o%s');
	//~ define('LOGGED_IN_KEY', 'vcp~,9dJ56pL80aapU/ec}A*kFpgfaN4rPaMLWPj3E:[3Z6/8FsZ2H1.dYS]p0');
	//~ define('NONCE_KEY', 'nIu=`+g-&>qffQL{&P{RxYNs+$$zqNg_8h|`h+f+];Sd_4@(z');


/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'aw1_';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress.  A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de.mo to wp-content/languages and set WPLANG to 'de' to enable German
 * language support.
 */
define ('WPLANG', '');

/* That's all, stop editing! Happy blogging. */

/** WordPress absolute path to the Wordpress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
?>
