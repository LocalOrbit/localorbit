<?php
/**
 * WPZOOM Theme Functions
 *
 * Don't edit this file until you know what you're doing. If you mind to add 
 * functions and other hacks please use functions/user/ folder instead and 
 * functions/user/functions.php file, those files are intend for that and
 * will never be overwritten in case of a framework update.
 */

/**
 * Paths to WPZOOM Theme Functions
 */
define("FUNC_INC", get_template_directory() . "/functions");

define("WPZOOM_INC", FUNC_INC . "/wpzoom");
define("THEME_INC", FUNC_INC . "/theme");
define("USER_INC", FUNC_INC . "/user");

/** WPZOOM Framework Core */
require_once WPZOOM_INC . "/init.php";

/** WPZOOM Theme */
require_once THEME_INC . "/functions.php";
require_once THEME_INC . "/sidebar.php";
require_once THEME_INC . "/post-options.php";

/* Theme widgets */
require_once THEME_INC . "/widgets/recentposts.php";
require_once THEME_INC . "/widgets/recentcomments.php";
require_once THEME_INC . "/widgets/popularposts.php";
require_once THEME_INC . "/widgets/flickrwidget.php";
require_once THEME_INC . "/widgets/social.php";
require_once THEME_INC . "/widgets/facebook-like-box.php";
require_once THEME_INC . "/widgets/twitter.php";

/** User functions */
require_once USER_INC . "/functions.php";