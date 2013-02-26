<?php
/**
 * WPZOOM Framework Integration
 */

require_once WPZOOM_INC . "/wpzoom.php";
require_once WPZOOM_INC . "/components/option.php";

/* Initialize WPZOOM Framework */
WPZOOM::init();

/* Only WordPress dashboard needs these files */
if (is_admin()) {
    require_once WPZOOM_INC . "/components/medialib-uploader.php";
    require_once WPZOOM_INC . "/components/admin/admin.php";
    require_once WPZOOM_INC . "/components/admin/settings-fields.php";
    require_once WPZOOM_INC . "/components/admin/settings-interface.php";
    require_once WPZOOM_INC . "/components/admin/settings-page.php";
    require_once WPZOOM_INC . "/components/dashboard/dashboard.php";

    require_once WPZOOM_INC . "/components/updater/updater.php";
    require_once WPZOOM_INC . "/components/updater/framework-updater.php";
    require_once WPZOOM_INC . "/components/updater/theme-updater.php";
}

/* Video API */
require_once WPZOOM_INC . "/components/video-api.php";
if (is_admin()) {
    require_once WPZOOM_INC . "/components/video-thumb.php";
}

/* Load get the image file only when it's not installed as a plugin */
if (!function_exists('get_the_image')) {
    require_once WPZOOM_INC . "/components/get-the-image.php";
}

/* Require shortcodes */
if (option::is_on('framework_shortcodes_enable')) {
    require_once WPZOOM_INC . "/components/shortcodes/shortcodes.php";
    require_once WPZOOM_INC . "/components/shortcodes/init.php";
}

/* wzslider */
if (option::is_on('framework_wzslider_enable')) {
    require_once WPZOOM_INC . "/components/shortcodes/wzslider.php";
}

require_once WPZOOM_INC . "/components/theme/ui.php";

if (!is_admin()) {
    require_once WPZOOM_INC . "/components/theme/theme.php";
    WPZOOM_Theme::init();
}
