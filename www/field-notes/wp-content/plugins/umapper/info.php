<?php
/*
Plugin Name: UMapper
Plugin URI: http://wordpress.org/extend/plugins/umapper/
Description: Universal mapping platform. [<a href="options-general.php?page=Umapper.php">Configuration Page</a>]
Version: 3.1.5
Author: Victor Farazdagi
Author URI: http://www.umapper.com/
*/

require_once dirname(__FILE__) . '/lib/Umapper/Plugin.php';

// make sure that plugin is notified of activation and deactivation
register_activation_hook(__FILE__, array(Umapper_Plugin::getInstance(), 'activate'));
register_deactivation_hook(__FILE__, array(Umapper_Plugin::getInstance(), 'deactivate'));

Umapper_Plugin::main();
