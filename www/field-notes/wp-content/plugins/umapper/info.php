<?php
/*
Plugin Name: UMapper
Plugin URI: http://wordpress.org/extend/plugins/umapper/
Description: Universal mapping platform, which  makes it a snap to create engaging maps and add them to your blog posts.
Version: 2.2.9
Author: UMapper
Author URI: http://www.umapper.com/
*/

/*  Copyright 2008  umapper  (email : support@afcomponents.com)

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

/*
    Many thanks goes to yuji.od for his flickr plugin, from which many truly
    great ideas are borrowed. If you like flickr, make sure you check out his
    plugin - http://factage.com/yu-ji/tag/wp-media-flickr
*/

/**
 * Make sure that plugin DIR is in include_path
 */
set_include_path(realpath(dirname(__FILE__)) . PATH_SEPARATOR . get_include_path());

/**
 * Plugin functionality
 */
require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . 'Umapper.php';

/**
 * Zend_Debug
 */
require_once 'Zend/Debug.php';

/**
 * Umapper_Patterns_Delegator
 */
require_once 'Umapper/Patterns/Delegator.php';

/**
 * Object instantination is enough, hooks are registered in plugin constructor
 */
$umapper = new Wordpress_Umapper();
