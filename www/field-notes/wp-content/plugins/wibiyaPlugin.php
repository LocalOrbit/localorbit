<?php
/*
Plugin Name: Wibiya Plugin
Plugin URI: http://www.wibiya.com
Description: wibiya wibar
Version: 1.0
Author: michaelD
*/
function filter_footer() {
    echo '<script src="http://toolbar.wibiya.com/toolbarLoader.php?toolbarId=10492" type="text/javascript"></script>';
}

add_action('get_footer', 'filter_footer');
?>