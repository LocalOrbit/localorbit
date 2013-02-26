<?php
/**
 * WPZOOM_Theme_Updater Class
 *
 * @package WPZOOM
 * @subpackage Theme_Updater
 */

class WPZOOM_Theme_Updater {
    /**
     * Returns local theme version
     *
     * @return string
     */
    public static function get_local_version() {
        return WPZOOM::$themeVersion;
    }

    /**
     * Returns current theme version pulled from WPZOOM server.
     *
     * @return string
     */
    public static function get_remote_version() {
        global $wp_version;

        $url  = 'http://wploy.wpzoom.com/changelog/' . WPZOOM::$theme_raw_name;

        $options = array(
            'timeout'    => 3,
            'user-agent' => 'WordPress/' . $wp_version . '; ' . home_url( '/' )
        );

        $response = wp_remote_get($url, $options);

        if (is_wp_error($response) || 200 != wp_remote_retrieve_response_code($response)) {
            return 'Can\'t contact WPZOOM server. Please try again later.';
        }
        
        $changelog = trim(wp_remote_retrieve_body($response));
        $changelog = maybe_unserialize($changelog);

        $changelog = preg_split("/(\r\n|\n|\r)/", $changelog);

        foreach ($changelog as $line) {
            if (preg_match("/((?:\d+(?!\.\*)\.)+)(\d+)?(\.\*)?/i", $line, $matches)) {
                $version = $matches[0];
                break;
            }
        }

        return $version;
    }

    /**
     * Checks if new theme version is available
     *
     * @return bool true if new version if remote version is higher than local
     */
    public function has_update() {
        $remoteVersion = self::get_remote_version();
        $localVersion  = self::get_local_version();

        if (preg_match('/[0-9]*\.?[0-9]+/', $remoteVersion)) {
            if (version_compare($localVersion, $remoteVersion, '<')) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Adds notifications if there are new theme version available.
     * Runs on time a day
     *
     * @return void
     */
    public static function check_update() {
        $lastChecked = (int) option::get('theme_last_checked');
        $temp_version = get_transient('wpzoom_temp_theme_version');
        
        // force a check if we think theme was updated
        if (!$temp_version) {
            set_transient('wpzoom_temp_theme_version', WPZOOM::$themeVersion);
        } else {
            if (version_compare($temp_version, WPZOOM::$themeVersion, '!=')) {
                $lastChecked = 0;
                set_transient('wpzoom_temp_theme_version', WPZOOM::$themeVersion);
            }
        }

        if ($lastChecked == 0 || ($lastChecked + 60 * 60 * 24) < time()) {
            if (self::has_update()) {
                option::set('theme_status', 'needs_update');
            } else {
                option::delete('theme_status');
            }
            option::set('theme_last_checked', time());
        }

        if (option::get('theme_status') == 'needs_update') {
            add_action('admin_notices', array(__CLASS__, 'notification'));
        }
    }

    /**
     * wp-admin global notification about new theme version release
     * 
     * @return void
     */
    public static function notification() {
        if (isset(WPZOOM::$config['tf_url'])) {
            $update_url = WPZOOM::$config['tf_url'];
        } else {
            $update_url = 'http://wpzoom.com/themes/' . WPZOOM::$theme_raw_name;
        }

        echo '<div class="zoomfw-theme update-nag">';
        echo 'A new version of <a href="' . $update_url . '">' . WPZOOM::$themeName . '</a> theme is available. ';
        echo '<u><a href="http://wploy.wpzoom.com/changelog/' . WPZOOM::$theme_raw_name . '?TB_iframe=true" class="thickbox thickbox-preview">Check out what\'s new</a></u> or visit our tutorial on <u><a href="http://www.wpzoom.com/tutorial/how-to-update-a-wpzoom-theme/">updating themes</a></u>.'; 
        echo ' <input type="button" class="close button" value="Hide" /></div>';
    }
}
