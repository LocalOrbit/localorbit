<?php

/**
 * WPZOOM Framework Options Manager
 *
 * @category WPZOOM
 */
class option {
    public static $options = array();
    public static $evoOptions;
    
    private static $prefix = "wpzoom_";

    public static function init() {
        self::loadOptions();
    }

    public static function set($name, $value) {
        update_option(self::$prefix . $name, $value);
        self::$options[$name] = $value;

        return $value;
    }
    
    public static function get($name, $echo = false) {
        $result = null;
        if (isset(self::$options[$name])) {
            $result = self::$options[$name];
        }
        
        if (!$result) {
            $result = get_option(self::$prefix . $name);
        }
        if (!$result) {
            return;
        }

        if (!$echo) {
            return $result;
        }

        echo $result;
    }
    
    public static function delete($name) {
        $args = func_get_args();
        $num = count($args);
        
        if ($num == 1) {
            return (delete_option(self::$prefix . $args[0]) ? true : false);
        } elseif (count($args) > 1) {
            foreach ($args as $option) {
                if (!delete_option(self::$prefix . $option))
                    return false;
            }
            return true;
        }
        return false;
    }

    public static function is_on($name) {
        return (self::get($name) === 'on');
    } 

    private static function loadOptions() {
        self::$options = self::getOptions();
    }
    
    public static function getOptions() {
        $themeOptions = include(FUNC_INC . "/theme/options.php");
        $wpzoomOptions = include(WPZOOM_INC . "/options.php");
        
        self::$evoOptions = array_merge_recursive($themeOptions, $wpzoomOptions);
        
        foreach(self::$evoOptions as $name => $options) {
            $name = explode("id", $name);
            if (isset($name[1]) && $name[1] != "") {
                $rOptions[] = $options;
            }
        }

        foreach ($rOptions as $column) {
            foreach ($column as $row) {
                if (isset($row['id'])) {
                    $id = $row['id'];
                } else {
                    continue;
                }

                $ignored = array('misc_export', 'misc_export_widgets', 'misc_debug');
                if (in_array($id, $ignored)) continue;

                $fetched_option = get_option(self::$prefix . $id);

                if ($fetched_option === false) {
                    $globalOptions[$id] = isset($row['std']) ? $row['std'] : '';
                    update_option(self::$prefix . $id, $globalOptions[$id]);
                } else {
                    $globalOptions[$id] = $fetched_option;
                }
            }
        }
        
        return $globalOptions;
    }
    
    public static function setupOptions($xoptions, $decode = false) {
        if ($decode) {
            $xoptions = unserialize(stripslashes(base64_decode($xoptions)));
        }

        $themeOptions = include(FUNC_INC . '/theme/options.php');
        $wpzoomOptions = include(WPZOOM_INC . '/options.php');
        
        self::$evoOptions = array_merge_recursive($themeOptions, $wpzoomOptions);
        
        foreach(self::$evoOptions as $name => $options) {
            $name = explode("id", $name);
            if (isset($name[1]) && $name[1] != "") {
                $rOptions[] = $options;
            }
        }

        foreach ($rOptions as $column) {
            foreach ($column as $row) {
                $ignored = array('preheader', 'startsub', 'endsub');
                if (in_array($row['type'], $ignored)) continue;

                $id = $row['id'];
                
                self::set($id, $xoptions[$id]);
            }
        }

    }
    
    public static function reset() {
        global $wpdb;
        
        $query = "DELETE FROM $wpdb->options WHERE option_name LIKE '" . self::$prefix . "%'";
        $wpdb->query($query);
        
        if (isset($_GET['page'])) {
            $send = $_GET['page'];
            header("Location: admin.php?page=$send");
        }
    }
    
    public static function getWidgetOptions() {
            global $wpdb;
        
            $q = "SELECT * FROM $wpdb->options WHERE option_name LIKE 'widget_%'";
            $q = $wpdb->get_results($q);
        
            $widgetOptions = array();
        
            foreach($q as $option) {
                $widgetOptions[$option->option_name] = maybe_unserialize($option->option_value);
            }
        
            //Get sidebar widgets locations
            $widgetOptions['sidebars_widgets'] = get_option('sidebars_widgets');
        
            return $widgetOptions;
    }
    
    public static function setupWidgetOptions($options, $decode = false) {
        if ($decode) {
            $options = unserialize(stripslashes(base64_decode($options)));
        }
        
        if (!is_array($options)) {
            return false;
        }
        
        foreach($options as $id => $option) {
            update_option($id, $option);
        }
    }

    public static function export_options() {
        return base64_encode(serialize(self::getOptions()));
    }

    public static function export_widgets() {
        return base64_encode(serialize(self::getWidgetOptions()));
    }

    public static function get_empty() {
        return '';
    }
}
