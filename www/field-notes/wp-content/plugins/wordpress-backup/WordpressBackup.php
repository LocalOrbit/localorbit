<?php
/*
Plugin Name: Wordpress Backup (by BTE)
Plugin URI: http://www.blogtrafficexchange.com/wordpress-backup
Description: Backup the upload directory (images), current theme directory, and plugins directory to a zip file.  Zip files optionally sent to email. <a href="options-general.php?page=BTE_WB_admin.php">Configuration options are here.</a> 
Version: 1.5.2
Author: Blog Traffic Exchange
Author URI: http://www.blogtrafficexchange.com/
Donate: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2282479
License: GNU GPL
*/
/*  Copyright 2008-2009  Blog Traffic Exchange (email : kevin@blogtrafficexchange.com)

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
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
if(! class_exists('PclZip')) {
	if (!defined('WP_ADMIN_DIR')) {
		define( 'WP_ADMIN_DIR', ABSPATH.'wp-admin/');
	}
	if (file_exists(WP_ADMIN_DIR.'includes/class-pclzip.php')) {
		require_once(WP_ADMIN_DIR.'includes/class-pclzip.php');		
	} else {
		require_once('lib/pclzip/pclzip.lib.php');		
	}
}
require_once('BTE_WB_admin.php');
 
define ('BTE_WB_DEBUG', false); 
define ('BTE_WB_1_HOUR', 60*60); 
define ('BTE_WB_1_DAY', 24*BTE_WB_1_HOUR); 
define ('BTE_WB_1_WEEK', 7*BTE_WB_1_DAY); 
define ('BTE_WB_INTERVAL', BTE_WB_1_DAY); 
if (!defined('WP_CONTENT_DIR')) {
	define( 'WP_CONTENT_DIR', ABSPATH.'wp-content');
}
if (!defined('WP_PLUGIN_DIR')) {
	define('WP_PLUGIN_DIR', WP_CONTENT_DIR.'/plugins');
}
if (!defined('WP_UPLOAD_DIR')) {
	$upload_path = get_option("upload_path");
	if (strpos($upload_path,'/')===0) {	
		define('WP_UPLOAD_DIR', $upload_path);
	} else {
		define('WP_UPLOAD_DIR', ABSPATH.$upload_path);	
	}
}
if (!defined('BTE_WB_DIR')) {
	define('BTE_WB_DIR', WP_CONTENT_DIR.'/bte-wb');
}
if ( ! defined( 'WP_CONTENT_URL' ) )
      define( 'WP_CONTENT_URL', get_option( 'siteurl' ) . '/wp-content' );
if (!defined('BTE_WB_URL')) {
	define('BTE_WB_URL', WP_CONTENT_URL.'/bte-wb');
}
if (!defined('WP_TEMPLATE_DIR')) {
	define('WP_TEMPLATE_DIR', get_template_directory());
}

register_activation_hook(__FILE__, 'bte_wb_activate');
register_deactivation_hook(__FILE__, 'bte_wb_deactivate');
add_action('init', 'bte_wb_wordpress_backup');
add_action('admin_menu', 'bte_wb_options_setup');
add_action('admin_head', 'bte_wb_head_admin');


function bte_wb_deactivate() {
	delete_option('bte_wb_last_backup_uploads');
	delete_option('bte_wb_last_backup_theme');
	delete_option('bte_wb_last_backup_plugin');
}

function bte_wb_activate() {
	add_option('bte_wb_plugin_dir',WP_PLUGIN_DIR);
	add_option('bte_wb_upload_dir',WP_UPLOAD_DIR);
	add_option('bte_wb_template_dir',WP_TEMPLATE_DIR);
	add_option('bte_wb_backup_dir',BTE_WB_DIR);
	add_option('bte_wb_backup_url',BTE_WB_URL);
	add_option('bte_wb_last_backup_uploads',0);
	add_option('bte_wb_last_backup_theme',0);
	add_option('bte_wb_last_backup_plugin',0);
	add_option('bte_wb_interval',BTE_WB_INTERVAL);
	add_option('bte_wb_email',"");
	if(!is_dir(BTE_WB_DIR)) {
		mkdir(BTE_WB_DIR);
	}
}

function bte_wb_wordpress_backup () {
	$bte_wb_dir = get_option("bte_wb_backup_dir");
	if (@is_dir(stripslashes($bte_wb_dir)) && @is_writable(stripslashes($bte_wb_dir))) {
		if (@is_dir(stripslashes(get_option("bte_wb_upload_dir"))) && (bte_wb_is_time('bte_wb_last_backup_uploads') || !file_exists($bte_wb_dir.'/uploads.zip'))) {
			$now = time();
			bte_wb_backup(get_option("bte_wb_upload_dir"),"uploads",date('Y-m-d H:i:s',$now),'bte_wb_last_backup_uploads',$now);
		} else if (@is_dir(stripslashes(get_option("bte_wb_template_dir"))) && (bte_wb_is_time('bte_wb_last_backup_theme')  || !file_exists($bte_wb_dir.'/themes.zip'))) {
			$now = time();
			bte_wb_backup(get_option("bte_wb_template_dir"),"themes",date('Y-m-d H:i:s',$now),'bte_wb_last_backup_theme',$now);
		} else if (@is_dir(stripslashes(get_option("bte_wb_plugin_dir"))) && (bte_wb_is_time('bte_wb_last_backup_plugin')  || !file_exists($bte_wb_dir.'/plugins.zip'))) {
			$now = time();
			bte_wb_backup(get_option("bte_wb_plugin_dir"),"plugins",date('Y-m-d H:i:s',$now),'bte_wb_last_backup_plugin',$now);
		}				
	}
}

function bte_wb_backup ($dir,$loc,$date,$option,$now) {
	$bte_wb_dir = get_option("bte_wb_backup_dir");
	if (BTE_WB_DEBUG) {
		error_log("[".date('Y-m-d H:i:s')."][bte_wb_wordpressbakcup] dir: ".$dir);		
		error_log("[".date('Y-m-d H:i:s')."][bte_wb_wordpressbakcup] loc: ".$loc);		
	}
	
	$v_remove = $dir;
	if (substr($dir, 1,1) == ':') {
		$v_remove = substr($dir, 2);
  	}	
  	$archive = new PclZip("$bte_wb_dir/$loc.zip");
  	if ($archive->create($dir,PCLZIP_OPT_REMOVE_PATH, $v_remove, PCLZIP_OPT_ADD_PATH, $loc) == 0) {
		error_log("[".date('Y-m-d H:i:s')."][bte_wb_wordpressbakcup] Error creating zip $bte_wb_dir/$loc.zip: ".$archive->errorInfo(true));
  	} else {
		update_option($option, $now);
		//chmod("$bte_wb_dir/$loc.zip",666);
  		bte_wb_mailbackup($loc,"$bte_wb_dir/$loc.zip",$date);
  	}
}

function bte_wb_format_size($rawSize) {
	if($rawSize / 1073741824 > 1) 
		return round($rawSize/1073741824, 1) . ' GiB';
	else if ($rawSize / 1048576 > 1)
		return round($rawSize/1048576, 1) . ' MiB';
	else if ($rawSize / 1024 > 1)
		return round($rawSize/1024, 1) . ' KiB';
	else
		return round($rawSize, 1) . ' bytes';
}


function bte_wb_mailbackup ($loc,$file_path,$file_date) {
	if (BTE_WB_DEBUG) {
		error_log("[".date('Y-m-d H:i:s')."][bte_wb_wordpressbakcup] mailing file: ".$file_path);		
	}
	$backup_email = get_option('bte_wb_email');
	if (BTE_WB_DEBUG) {
		error_log("[".date('Y-m-d H:i:s')."][bte_wb_wordpressbakcup] email: ".$backup_email);		
	}
	if(!empty($backup_email)) {
		$file_size = bte_wb_format_size(filesize($file_path));
		$file_data = chunk_split(base64_encode(file_get_contents($file_path)));
		$mail_subject = sprintf(__('%s %s Backup File For %s', 'WordpressBackup'), get_bloginfo('name'), $loc, $file_date);
		$mail_header = 'From: '.get_bloginfo('name').' Administrator <'.get_option('admin_email').'>';
		$random_time = md5(time());
		$mime_boundary = "==BTE_WB_Wordpress_Backup- $random_time";
		$mail_header .= "\nMIME-Version: 1.0\n" .
						"Content-Type: multipart/mixed;\n" .
						" boundary=\"{$mime_boundary}\"";
		$mail_message = __('Website Name:', 'WordpressBackup').' '.get_bloginfo('name')."\n".
						__('Website URL:', 'WordpressBackup').' '.get_bloginfo('siteurl')."\n".
						__('Backup File Name:', 'WordpressBackup').' '.$loc.".zip\n".
						__('Backup File Date:', 'WordpressBackup').' '.$file_date."\n".
						__('Backup File Size:', 'WordpressBackup').' '.$file_size."\n\n".
						__('With Regards,', 'WordpressBackup')."\n".
						get_bloginfo('name').' '. __('Administrator', 'WordpressBackup')."\n".
						get_bloginfo('siteurl')."\n\n".
						__('Powered by Blog Traffic Exchange plugin Wordpress Backup:', 'WordpressBackup')." http://www.blogtrafficexchange.com/wordpress-backup";
	
		$mail_message = "This is a multi-part message in MIME format.\n\n" .
						"--{$mime_boundary}\n" .
						"Content-Type: text/plain; charset=\"utf-8\"\n" .
						"Content-Transfer-Encoding: 7bit\n\n".$mail_message."\n\n";				
	
		$mail_message .= "--{$mime_boundary}\n" .
						"Content-Type: application/octet-stream;\n" .
						" name=\"{$loc}\"\n" .
						"Content-Disposition: attachment;\n" .
						" filename=\"{$loc}.zip\"\n" .
						"Content-Transfer-Encoding: base64\n\n" .
						$file_data."\n\n--{$mime_boundary}--\n";	
		mail($backup_email, $mail_subject, $mail_message, $mail_header);		
	}
}

function bte_wb_is_time ($option) {
	$last = get_option($option);		
	$interval = get_option('bte_wb_interval');		
	if (!(isset($interval) && is_numeric($interval))) {
		$interval = BTE_WB_INTERVAL;
	}
	if (false === $last) {
		$ret = 1;
	} else if (is_numeric($last)) { 
		$ret = ( (time() - $last) > ($interval));
	}
	return $ret;
}