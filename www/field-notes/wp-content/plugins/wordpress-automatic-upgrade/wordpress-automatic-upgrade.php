<?php
/*
Plugin Name: Wordpress Automatic Upgrade
Plugin URI: http://techie-buzz.com/wordpress-plugins/wordpress-automatic-upgrade-12-release.html
Description: Wordpress Automatic Upgrade allows a user to automatically upgrade the wordpress installation to the latest one provided by wordpress.org using the 5 steps provided in the wordpress upgrade instructions. Go to <a href="edit.php?page=wordpress-automatic-upgrade/wordpress-automatic-upgrade.php">Wordpress Automatic Upgrade</a> to upgrade your installation Thanks to <a href="http://www.ronalfy.com">Ronald Huereca</a>  for making the plugin run in automatic mode.
Version: 1.2.5
Author: Keith Dsouza
Author URI: http://techie-buzz.com/

Wordpress automatic upgrade upgrades your wordpress installation by doing the following steps.

1. Backs up the files and makes available a link to download it.
2. Backs up the database and makes available a link to download it.
3. Downloads the latest files from http://wordpress.org/latest.zip and unzips it.
4. Puts the site in maintenance mode.
5. De-activates all active plugins and remembers it.
6. Upgrades wordpress files.
7. Gives you a link that will open in a new window to upgrade installation.
8. Re-activates the plugins.

The plugin can  also can be run in a automated mode where in you do not have to click on any links to go to the next step.

Usage Instructions
-------------------------

Go to Manage -> Automatic Upgrade and either click on the link provided to run or use the automated version link to let the plugin run in a automated way.

Change Log
---------------

@version 0.4
1. Added a prelim check before starting the process to check whether or not we can write files to the server
2. Checks if previous version files were not cleared
3. If we cannot write the files to server asking user for ftp credentials so that we can make the permission changes
4. Fixed bug where task status was not reported on error thus showing a db error to the user
5. Fixed a bug where open_basedir restriction is on for a website hosted as virtual folder

@version 0.5

1. Fixed bugs where user had a www folder with full write permissions but the public_html folder was not writable.
2. Fixed issue where while writing there were ftp errors while creating backup directory but still plugin said all ready to go
3. Fixed issue where plugins were not activating even if one plugin threw an error.
4. Fixed other issues with html and reporting

@version 0.6
bug fixes for security

@version 0.7
fixes for blogs that have the wordpress setup in a different directory and run the blog on a different directory

@version 0.8
Fix for database table name changes in WordPress 2.3 this should only affect blogs that are running WordPress 2.3 while running the Automatic Upgrade.

@version 1.0
Finally out for a release version as it has worked with more than 10 releases of WordPress updates

This version basically fixes a issue with automatic plugin updates caused due to PCLZip library which is included used by WordPress plugin update code
now checks in place to see that while plugins are being updated we silently drop the library inclusion

@version 1.1
Changed short tags to use full php tags which was breaking activation of the plugin when short tags were disabled on the server end.

@version 1.2

Fixed a major issue where plugins were not being activated after the upgrade was done. This bug was only seen in WordPress 2.5 and above since they clear out the cookies after the upgrade has comepleted.
Changed all the urls to use wpurl instead of using siteurl
Isolated view of the WordPress Automatic Updated Link to only the Administartors of the blog
Uses Snoopy to downloading updates.
Added a Nag to Update using WPAU
Removed Automated Update mode
Several other minor bug fixes

@1.2.0.1
updated user debug messages

@1.2.0.2
change snoopy class name to internal to fix a issue with snoopy being loaded after WP loaded and no checks in place

@1.2.1
Allows users to skip db and file backups since several users with big databases have
reported for this feature

@1.2.2
Added nag to cleanup files from previous upgrade
Does not write the log file to disk anymore
Fixed a issue for including wp-config file

@1.2.3
Updated the code to display nag on WordPress 2.7 and above
Fixed an issue which disallowed core updates to occur when WPAU was updated in WP 2.7 and above

Thanks to all who reported the bugs and helped me make this plugin better, if you still see any bugs please email me at dsouza.keith@gmail.com

Copyright 2007  Keith Dsouza  (email : dsouza.keith at gmail.com)

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


@define('WPAU_PAGE', 'wordpress-automatic-upgrade/wordpress-automatic-upgrade.php');
@define('WPAU_BACKUP_DIR', 'wpau-backup');
@define('WPAU_FILES_ZIP', 'wpau-files-bak');
@define('WPAU_DB_ZIP', 'wpau-db-backup');
@define('WPAU_LOG_FILE', 'wpau-log-data.txt');
@define('WPAU_PLUGIN_TABLE', 'wpau_active_plugins_info');
@define('WPAU_LOG_TABLE', 'wpau_upgrade_log');
@define('WPAU_PLUGIN', 'wordpress-automatic-upgrade/wordpress-automatic-upgrade.php');

	#session_start();
	$serverSoft = $_SERVER['SERVER_SOFTWARE'];
	$isNix = true;
	if(stristr($serverSoft, "win32") !== false) {
		$isNix = false;
	}

	if($isNix)
		@define('WPAU_FILEPATH', 'wp-content/plugins/wordpress-automatic-upgrade');
	else
		@define('WPAU_FILEPATH', 'wp-content\plugins\wordpress-automatic-upgrade');

	//the logger class
	require_once('wpau_helper.class.php');


	$wpauDirPath = get_bloginfo('wpurl') . WPAU_FILEPATH;
	$wpauFileDirPath = ABSPATH. WPAU_FILEPATH;
	$wpAbsPath = ABSPATH;
	$wpIncludeDirs = array('wp-admin', 'wp-includes');
	$wpAllowedExt = array('zip');
	$theFuncComplete = false;
	$wpauMessage = '';
	$isAutomated = false;

	$task_list = array(
		'files',
		'backupdbopt',
		'backupdb',
		'newversionoption',
		'getlatestfiles',
		'maintmode',
		'de-plugin',
		'upgrade',
		're-plugin',
	);


	$task_description = array(
		'Backs up all the current files from the wordpress installation',
		'Shows you the options to backup your database',
		'Backs up the database file',
		'Shows you the options to upload latest files',
		'Downloads / Uploads the latest files for wordpress',
		'Puts the site into maintenance mode',
		'De-activates all the plugins',
		'Upgrades all the installation files',
		'Re-activates all the plugins that were active earlier'
	);

	$automated_task_list = array(
		'files',
		'backupdb',
		'getlatestfiles',
		'maintmode',
		'de-plugin',
		'upgrade',
		're-plugin'
	);
  
  $skip_tasks_list = array (
    'backupdbopt',
    'files'
  );

	$automated_task_description = array(
		'Backs up all the current files from the wordpress installation',
		'Backs up the database file',
		'Downloads / Uploads the latest files for wordpress',
		'Puts the site into maintenance mode',
		'De-activates all the plugins',
		'Upgrades all the installation files',
		'Re-activates all the plugins that were active earlier',
		'Cleans up all the upgradation files'
	);

	if( isset($_REQUEST['task']) ) {
		$task = $_REQUEST['task'];
	}



	if (isset($wpdb)) {
		wpau_init();
	}


	function wpau_manage_page() {
		//add_menu_page('Automatic Upgrade', 'Automatic Upgrade', 0, 'wordpress-automatic-upgrade/wordpress-automatic-upgrade.php' , 'wp_automatic_upgrade');
		add_submenu_page('edit.php', 'Automatic Upgrade', 'Automatic Upgrade', 10, 'wordpress-automatic-upgrade/wordpress-automatic-upgrade.php', 'wp_automatic_upgrade');
	}
  
  function wpau_add_nag($msg) {
	  global $wp_version;
    $requires_update = false;
    $new_wp_version = "";
    //2.7 and above use a diff way to get upgrade nag
    if($wp_version >= 2.7) {
      $update_array = get_core_updates();
      
      if(is_array($update_array)) {
        if('upgrade' == $update_array[0]->response) {
          $requires_update = true;
          $new_wp_version = $update_array[0]->current;
        }
      }
    }
    else {
      $cur = get_option( 'update_core' );
    	if ( isset( $cur->response ) || 'upgrade' == $cur->response ) {
  	    $requires_update = true;
      }
    }
    
    //check if files cleanup is require only if
    //update is not available
    //else update will handle it automatically
    if(!$requires_update) {
      require_once('wpau_prelimcheck.class.php');
      $prelimCheck = new wpauPrelimHelper();
  	  if($prelimCheck->checkCleanUpRequired()) {
        $cllink = 'edit.php?page='.WPAU_PAGE.'&task=cleanup&returnhome=1';
        if(function_exists('wp_nonce_url') ) {
      		$cllink = wp_nonce_url($cllink, 'wordpress_automatic_upgrade');
    	  }
  	    if ( current_user_can('manage_options') ) {
  	      $msg = sprintf( __('You have not cleaned up the files from last upgrade. Please <a href="%1$s">Click Here</a> to cleanup the files, and disable this nag.'), $cllink );
          echo "<div id='update-nag'>$msg</div>";
  	    }	
  	  }
      unset($prelimCheck);
	    return false;
    }
    else {
      $uplink = 'edit.php?page='.WPAU_PAGE;
      if(function_exists('wp_nonce_url') ) {
    		$uplink = wp_nonce_url($uplink, 'wordpress_automatic_upgrade');
  	  }
      if ( current_user_can('manage_options') ) {
  	    $msg = sprintf( __('<a href="%1$s">Click Here</a> to Automatically Upgrade WordPress to latest Version %2$s.'), $uplink, $new_wp_version );
  	    echo "<div id='update-nag'>$msg</div>";
  	  }
    }
    
  
  	
  }

	function wp_automatic_upgrade() {
		if( ! user_can_access_admin_page()) {
			return false;
		}

		if(isset($_REQUEST['_wpnonce']) ) {
			if(function_exists('check_admin_referer')) {
				check_admin_referer('wordpress_automatic_upgrade');
			}
		}

		global $task;
		switch($task) {
			case 'start':
				show_upgrade_start();
				break;
			case 'files':
				wpau_backup_files();
				break;
      case 'skipfiles':
				wpau_skip_backup_files();
				break;
			case 'backupdbopt':
				wpau_backup_db_options();
				break;
      case 'skipbackupdbopt':
				wpau_skip_backup_db();
				break;
			case 'backupdb':
				wpau_backup_db();
				break;
			case 'newversionoption':
				wpau_show_new_version_forms();
				break;
			case 'getlatestfiles':
				wpau_get_latest_version();
				break;
			case 'maintmode':
				wpau_site_down();
				break;
			case 'de-plugin':
				wpau_deactivate_plugins();
				break;
			case 'upgrade':
				wpau_upgrade_installation();
				break;
			case 'updatedb':
				wpau_update_database();
				break;
			case 're-plugin':
				wpau_reactivate_plugins();
				break;
			case 'cleanup':
				wpau_cleanup();
				break;
			case 'done':
				wpau_show_backup_log();
				break;
			case 'logs':
				wpau_show_log();
				break;
			case 'prelimopts':
				wpau_prelim_opts_and_sanatize();
				break;
      case 'skiptask':
        wpau_skip_task();
			default:
				wpau_run_prelims();
				break;
		}
	}

	/** adds the initial task to the database **/
	function wpauPersistNoLog($isUpdate, $showOutput = false, $automated = false) {
		if(isset($_REQUEST['_wpnonce']) ) {
			if(function_exists('check_admin_referer')) {
				check_admin_referer('wordpress_automatic_upgrade');
			}
		}
		global $isAutomated;
		$isAutomated = $automated;
		wpauPersist($isUpdate, '', false, '', $showOutput);
	}

	/** logs the output for a current task **/
	function wpauPersist($isUpdate, $theLog = '', $funcComplete = false, $message = '', $showOutput = true) {
		global $task, $wpdb, $task_list, $automated_task_list, $task_description, $automated_task_description, $isAutomated, $theFuncComplete;
		$datetime = date('Y-m-d H:i:s');
		if($isAutomated) {
			$currentPos = $task - 1;
			$taskname = $automated_task_list[$currentPos];
			$currentTaskDescription = $automated_task_description[$currentPos];
		}
		else {
			$currentPos = array_search($task, $task_list);
			$currentTaskDescription = $task_description[$currentPos];
			$taskname = $task;
		}

		if(! $isUpdate) {
			checkEntryAndDelete($task);
			//ok this is the first time the task is called so run a insert on the db
			$wpdb->query('INSERT into '.WPAU_LOG_TABLE.' (task_name, task_status, task_description, task_log, start_date)
						values (\''.$taskname.'\', 0, \''.$currentTaskDescription.'\' , \'\', \''.$datetime.'\')');
			return;
		}
		else {
			if($theFuncComplete == true)
				$functionStatus = 1;
			else
				$functionStatus = 0;

			$wpdb->query('UPDATE '.WPAU_LOG_TABLE.' set task_status = '.$functionStatus.', task_log = \''.mysql_real_escape_string($theLog).'\', end_date = \''.$datetime.'\' where task_name = \''.mysql_real_escape_string($taskname).'\'');
			if($isAutomated) return $theFuncComplete;
			if($theFuncComplete) {
				getWpauNextPage($task, $message, $showOutput);
			}
			else {
				$link = 'edit.php?page='.WPAU_PAGE.'&task=logs';
				if(function_exists('wp_nonce_url') ) {
					 $link = wp_nonce_url($link, 'wordpress_automatic_upgrade');
				}
				echo 'We could not complete the upgrade please try again later, <a href="'.$link.'">click here</a> to check the logs.';
			}
		}
	}
  
	/** start html **/
	function wpauStartHtml() {
?>
<div align="left" style="margin-left:30px;">
    <br/>
    <br/>
    <div>
        <strong style="font-size:20px;">Wordpress automatic upgrade</strong>
        <p>
            Upgrades your wordpress installation automatically. If this plugin helped you, you can contribute towards plugin development by <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=dsouza.keith@gmail.com&currency_code=&amount=&return=&item_name=WordPress+Plugin+Development+Donation" target="_blank" title="Opens in New Window">Donating to me</a>.
        </p>
        <p>
            <strong>
                <u>
                    TASK OUTPUT
                </u>
            </strong>
        </p>
        <?php
	}

	/** end html **/
	function wpauEndHtml() {
        ?>
    </div>
</div>
<div style="clear:both">
</div>
<?php
	}

	/** if we are re-running the task we need to clear up old logs **/
	function checkEntryAndDelete($task) {
		//sometimes we need to retry tasks so we do it here such that we do not have duplicate entry for same task
		global $wpdb;
		$logs = $wpdb->get_results('SELECT id  from '.WPAU_LOG_TABLE.' where task_name = \''.$task.'\'');
		if(count($logs) > 0) {
			$wpdb->query('DELETE from '.WPAU_LOG_TABLE.' where task_name = \''.$task.'\'');
		}
	}

	/** clears all the upgraded data from the tables **/
	function clearUpgradeData() {
		global $wpdb;
		wpau_init();
		$wpdb->query('truncate table '. WPAU_LOG_TABLE);
		$wpdb->query('truncate table '. WPAU_PLUGIN_TABLE);
	}

	/** builds the output and creates a link to the next task if any exists **/
	function getWpauNextPage($task, $message, $showOutput = true) {
		global $task_list, $task_description, $theFuncComplete, $skip_tasks_list;
		//ensure multiple checks so that if previous task is not complete we
		//do not do the next step as all are inter-dependent
		$currentPos = array_search($task, $task_list);

		$currentTaskDescription = $task_description[$currentPos];

		//check if we have more tasks
		if($currentPos + 1 < count($task_list)) {
			$nextTask = $task_list[$currentPos + 1];
			$nextTaskDescription = $task_description[$currentPos + 1];
		}
		else {
			$nextTask = 'done';
			$nextTaskDescription = 'Congratulations your wordpress upgrade is complete.';
		}
		$nextLink = 'edit.php?page='.WPAU_PAGE.'&task='.$nextTask;
		if(function_exists('wp_nonce_url') && "re-plugin" != $nextTask ) {
			 $nextLink = wp_nonce_url($nextLink, 'wordpress_automatic_upgrade');
		}
		if($currentPost > count($task_list) || $currentPos < 0 ) {
			$link = 'edit.php?page='.WPAU_PAGE;
			if(function_exists('wp_nonce_url') ) {
				 $link = wp_nonce_url($link, 'wordpress_automatic_upgrade');
			}
			$message .= 'Sorry you came across a weird task that was not to be there. Please <a href="'.$link.'">click here</a> to restart again once more';
			$theFuncComplete = false;
		}

		if($showOutput && $theFuncComplete) {
			wpauStartHtml();
			echo '<strong>'.$message.'</strong>';
			echo "<hr /><strong>TASK STATUS</strong><br /><hr />";
			echo '<strong>We succesfully completed the task which</strong>, '.$currentTaskDescription.'. <br /><br />
			<strong>Next Task -></strong> '.$nextTaskDescription.'
			<br /><br />Please <a href="'.$nextLink.'">CLICK HERE</a> to go to the next task.';
      //check if this can be skipped and add a link for it
      if(in_array($nextTask, $skip_tasks_list)) {
        $skipLink = 'edit.php?page='.WPAU_PAGE.'&task=skip'.$nextTask;
		    if(function_exists('wp_nonce_url')) {
			   $skipLink = wp_nonce_url($skipLink, 'wordpress_automatic_upgrade');
		    }
        echo '<br /><a href="'.$skipLink.'">Click here</a> to skip this task.';
      }
			wpauEndHtml();
		}
		else if (! $theFuncComplete) {
			wpauStartHtml();
			echo '<strong>Sorry something went wrong we cannot continue further with this process</strong>';
			$link = 'edit.php?page='.WPAU_PAGE;
			if(function_exists('wp_nonce_url') ) {
				 $link = wp_nonce_url($link, 'wordpress_automatic_upgrade');
			}
			echo '<p>Please <a href="'.$link.'">click here</a> to start over again</p>';
			wpauEndHtml();
		}

	}

	function wpau_show_reactivate_plugins($automated = false) {
		echo 'Congratulations!!! All the files have been upgraded to the latest version. Please <a href="'.get_bloginfo('wpurl').'/wp-admin/upgrade.php" target="_blank">CLICK HERE TO COMPLETE DATABASE UPGRADE</a> (opens in new window and will show you a upgrade link only if database has to be upgraded) and come back here to reactivate your plugins<br>';
		$link = 'edit.php?page='.WPAU_PAGE.'&task=re-plugin';
    //skip this for now
		/*if(function_exists('wp_nonce_url') ) {
			 $link = wp_nonce_url($link, 'wordpress_automatic_upgrade');
		}*/
		echo '<strong><a href="'.$link.'">PLEASE CLICK HERE TO RE-ACTIVATE YOUR PLUGINS. AFTER YOU HAVE UPGRADED DATABASE</a></strong>';
	}

	/** runs thorough preliminary checks to see if we can run WPAU on the user's server **/
	function wpau_run_prelims() {
		global $wbAbsPath, $isNix, $wpdb;
		$count = $wpdb->get_results('SELECT count(*) as counter from '.WPAU_LOG_TABLE);
		if($counter > 0) {
			if($count->counter > 0)
				clearUpgradeData();
		}

		//clearUpgradeData();
		$extra = '';
		require_once('wpau_prelimcheck.class.php');
		wpauStartHtml();
		echo "<hr /><strong>TASK STATUS</strong><br />";
		echo "We conducted some preliminary checks on your server. Below is the output<hr />";
		$canWPAURun = true;
		$ftpError = false;
		$allClear = true;
		$message = '';
		$severeError = '';
		$prelimCheck = new wpauPrelimHelper();
    
    //new check to see if upgrade is required

    if( ! $prelimCheck->runUpgradeRequiredCheck()) {
     echo "<strong>Congratulations!!! Your WordPress version is already up to date.</strong><br /><br />";
     if($prelimCheck->checkCleanUpRequired()) {
			echo 'There are some old files from previous installation. Please <a href="edit.php?page='.WPAU_PAGE.'&task=cleanup&returnhome=1">click here to run the clean up process before continuing<br>';
		 }
      unset($prelimCheck);
      wpauEndHtml();
      return false; 
    }

		if($prelimCheck->checkCleanUpRequired()) {
			echo 'Seems you have not completed the clean up process from last upgrade. Please <a href="edit.php?page='.WPAU_PAGE.'&task=cleanup&returnhome=1">click here to run the clean up process before continuing<br>';
			wpauEndHtml();
			unset($prelimCheck);
			return false;
		}

		if(! $prelimCheck->runFTPPrelimChecks()) {
			$message .= 'Server does not allow us to write to your wordpress directory<br />
			In order to continue you need to do one of the two things<br />';
			$ftpError = true;
			$allClear = false;
		}
		else if(ini_get('safe_mode')) {
			//safe mode man cannot run
			$severeError =  'Your server is running in safe mode. WPAU cannot continue in safe mode. Please ask your system administrator to change the setting to disble running in safe mode';
			$canWPAURun = false;
		}
		else if (!function_exists('gzopen')) {
			//urgh no zip support can't run
			$severeError =  'Oops your server does not support zip functions which is core to some of the funcionalities of this plugin. Sorry but we cannot continue. Please ask your server administrator to turn on zip support';
			$canWPAURun = false;
		}

		if(! $prelimCheck->canMakeBackupDir) {
			$extra = "mbd=true";
		}
		//site is running in safe mode so we cannot continue
		if(! $canWPAURun) {
			echo '<p style="color:red;font-weight:bold">'. $severeError.'</p>';
			echo '</p>';
			wpauEndHtml();
			unset($prelimCheck);
			return false;
		}

		/**
			ok seems the site is having the ftp issue, show up the form to the user
			this happens when the ftp user and web users are different on a shared
			server running multiple sites
		**/
		if( $ftpError) {
			echo '<p style="color:red;font-weight:bold">'. $message.'</p>';
?>
<ol>
    <li>
        Provide us with your FTP credentials
    </li>
</ol>
<p>
    <strong>Note:</strong>
    We do not store your FTP information with us due to security reasons. Your ftp credentials will only be used to make your site writable by this plugin. You only have to do this once.
</p>
<p>
    What is your FTP Base Directory. 
    If you have installed wordpress inside <strong>public_html</strong>
    folder then your base ftp directory is <strong>/public_html</strong>
    <br/>
    If your you have installed your wordpress in <strong>public_html/wpau</strong>
    folder then your base ftp directory is <strong>/public_html/wpau</strong>
    <br/>
    If you install the wordpress into the root directory then your base directory will be <strong>/</strong>
    <br/>
</p>
<form method="post" name="getftp" action="edit.php?page=<?php echo WPAU_PAGE; ?>&task=prelimopts&<?php echo $extra; ?>">
    <?php
		if(function_exists('wp_nonce_field')) {
			wp_nonce_field('wordpress_automatic_upgrade');
		}
    ?>
    <table class="editform" width="500" cellspacing="2" cellpadding="5" align="left">
        <tr>
            <td colspan="2">
                <strong>Provide your FTP Credentials</strong>
            </td>
        </tr>
        <tr>
            <td>
                <label for="disclosurepolicy-title">
                    FTP Username
                </label>
            </td>
            <td>
                <input type="text" id="wpau-ftpuser" name="wpau-ftpuser" value="" style="width: 95%"/>
            </td>
        </tr>
        <tr>
            <td>
                <label for="disclosurepolicy-title">
                    FTP Password
                </label>
            </td>
            <td>
                <input type="password" id="wpau-ftppass" name="wpau-ftppass" value="" style="width: 95%"/>
            </td>
        </tr>
        <tr>
            <td>
                <label for="disclosurepolicy-title">
                    FTP Base Directory (The root dir where wordpress is installed)
                </label>
            </td>
            <td>
                <input type="text" id="wpau-ftpbasedir" name="wpau-ftpbasedir" value="" style="width: 95%"/>
            </td>
        </tr>
        <tr>
            <td>
                <label for="disclosurepolicy-title">
                    FTP Host
                </label>
            </td>
            <td>
                <input type="text" id="wpau-ftphost" name="wpau-ftphost" value="" style="width: 95%"/>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <input type="submit" name="wpau-submit" id="wpau-submit" value="Let's Go" />
            </td>
        </tr>
    </table>
</form>
<?php
		}
		else if($allClear) {
			$link = 'edit.php?page='.WPAU_PAGE.'&task=files';
      $linkskip = 'edit.php?page='.WPAU_PAGE.'&task=skipfiles';
			if(function_exists('wp_nonce_url') ) {
				 $link = wp_nonce_url($link, 'wordpress_automatic_upgrade');
         $linkskip = wp_nonce_url($linkskip, 'wordpress_automatic_upgrade');
			}
			echo 'Great the preliminiary checks of your server is complete and WPAU is ready to roll. <a href="'.$link.'"><strong>Click here</strong></a> so that we can start the upgrade.';
      echo '<br />The first step will backup files, <a href="'.$linkskip.'">click here</a> to skip it.';
?>
<div id="wpau-file-download">
</div>
<div id="wpau-db-download">
</div>
<div id="wpau-update-db">
</div>
<!--You may also choose the <a href="#" id="wpau-automated">automated version</a>.-->
<div id="wpau-status-bar">
    <div id="wpau-status-bar-indicator">
    </div>
</div>
<div id="wpau-status-message">
</div>
</div>
<?php
		}
?>
<?php
		wpauEndHtml();
		unset($prelimCheck);
	}

	/** gets the information entered by the user and sanitizes the server files so that we can run the
	WPAU plugin without any errors **/
	function wpau_prelim_opts_and_sanatize() {
		global $wbAbsPath, $isNix;

		$options = get_settings('wpau-params');
		if ( $_POST['wpau-submit'] ) {
			$wpau_ftp['ftpuser'] = strip_tags(stripslashes($_POST['wpau-ftpuser']));
			$wpau_ftp['ftppass'] = strip_tags(stripslashes($_POST['wpau-ftppass']));
			$wpau_ftp['ftphost'] = strip_tags(stripslashes($_POST['wpau-ftphost']));
			$wpau_ftp['ftpbasedir'] = strip_tags(stripslashes($_POST['wpau-ftpbasedir']));
			//only saves it temporarily so that we can run post upgrade steps
			if ( $options != $wpau_ftp ) {
				$options = $wpau_ftp;
				update_option('wpau-params', $options);
			}
		}

		require_once('wpau_prelimcheck.class.php');
		$prelimCheck = new wpauPrelimHelper();
		$prelimCheck->ftpUser = $wpau_ftp['ftpuser'];
		$prelimCheck->ftpPass = $wpau_ftp['ftppass'];
		$prelimCheck->ftpHost = $wpau_ftp['ftphost'];
		$prelimCheck->ftpBaseDir = $wpau_ftp['ftpbasedir'];
		$prelimCheck->checkFtpMode();
		if($prelimCheck->checkFTPCredentials()) {
			$makeBackUpDir = $_REQUEST['mbd'];
			if($prelimCheck->runFTPOperation()) {
				if('true' == $makeBackUpDir) {
					if(! $prelimCheck->makeBackupDir()) {
						wpauStartHtml();
						echo '<strong>Oops we cannot run the WordPress Automatic Update on your site. We are currently trying to fix issues for systems like yours and will release a new version shortly.</strong>';
						wpauEndHtml();
						return false;
					}
				}
				wpauStartHtml();
				$link = 'edit.php?page='.WPAU_PAGE.'&task=files';
				if(function_exists('wp_nonce_url') ) {
					 $link = wp_nonce_url($link, 'wordpress_automatic_upgrade');
				}
				echo 'Great all done WPAU is ready to roll. <a href="'.$link.'">Click here</a> so that we can start the upgrade.';
?>
<div id="wpau-file-download">
</div>
<div id="wpau-db-download">
</div>
<div id="wpau-update-db">
</div>
<!--You may also choose the <a href="#" id="wpau-automated">automated version</a>.-->
<div id="wpau-status-bar">
    <div id="wpau-status-bar-indicator">
    </div>
</div>
<div id="wpau-status-message">
</div>
</div>
<?php
				wpauEndHtml();
			}
		}
		else {
			wpauStartHtml();
			echo '<p style="color:red;font-weight:bold">Oops!!!!! We are unable to connect to the ftp site with the data your provided, could you cross check and give us the data again</p>';
?>
<ol>
    <li>
        Provide us with your FTP credentials
    </li>
</ol>
<p>
    <strong>Note:</strong>
    We do not store your FTP information with us due to security reasons. Your ftp credentials will only be used to make your site writable by this plugin. You only have to do this once.
</p>
<p>
    What is your FTP Base Directory. 
    If you have installed wordpress inside <strong>public_html</strong>
    folder then your base ftp directory is <strong>/public_html</strong>
    <br/>
    If your you have installed your wordpress in <strong>public_html/wpau</strong>
    folder then your base ftp directory is <strong>/public_html/wpau</strong>
    <br/>
    If you install the wordpress into the root directory then your base directory will be <strong>/</strong>
    <br/>
</p>
<form method="post" name="getftp" action="edit.php?page=<?php echo WPAU_PAGE; ?>&task=prelimopts">
    <?php
		if(function_exists('wp_nonce_field')) {
			wp_nonce_field('wordpress_automatic_upgrade');
		}
    ?>
    <table class="editform" width="500" cellspacing="2" cellpadding="5" align="left">
        <tr>
            <td colspan="2">
                <strong>Provide your FTP Credentials</strong>
            </td>
        </tr>
        <tr>
            <td>
                <label for="disclosurepolicy-title">
                    FTP Username
                </label>
            </td>
            <td>
                <input type="text" id="wpau-ftpuser" name="wpau-ftpuser" value="" style="width: 95%"/>
            </td>
        </tr>
        <tr>
            <td>
                <label for="disclosurepolicy-title">
                    FTP Password
                </label>
            </td>
            <td>
                <input type="password" id="wpau-ftppass" name="wpau-ftppass" value="" style="width: 95%"/>
            </td>
        </tr>
        <tr>
            <td>
                <label for="disclosurepolicy-title">
                    FTP Base Directory (The root dir where wordpress is installed)
                </label>
            </td>
            <td>
                <input type="text" id="wpau-ftpbasedir" name="wpau-ftpbasedir" value="" style="width: 95%"/>
            </td>
        </tr>
        <tr>
            <td>
                <label for="disclosurepolicy-title">
                    FTP Host
                </label>
            </td>
            <td>
                <input type="text" id="wpau-ftphost" name="wpau-ftphost" value="" style="width: 95%"/>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <input type="submit" name="wpau-submit" id="wpau-submit" value="Let's Go" />
            </td>
        </tr>
    </table>
</form>
<?php
			wpauEndHtml();
		}
	}
  
  function wpau_skip_backup_files($automated = false) {
    
    if(!current_user_can('edit_files')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
    global $task, $theFuncComplete;
    $task = "files";
    wpauPersistNoLog(false, false, $automated);
		$message = '<span style="color:red">File Backup Skipped</span><br />';
    $theFuncComplete = true;
    wpauPersist(true, $zipFuncs->loggedData, $theFuncComplete, $message, true);
    if($automated) { return $theFuncComplete; }
  }
  
  function wpau_skip_backup_db($automated = false) {
    
    if(!current_user_can('edit_files')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
    global $task, $theFuncComplete;
    $task = "backupdb";
    wpauPersistNoLog(false, false, $automated);
		$message = '<span style="color:red">Database Backup Skipped</span><br />';
    $theFuncComplete = true;
    wpauPersist(true, $zipFuncs->loggedData, $theFuncComplete, $message, true);
    if($automated) { return $theFuncComplete; }
  }

	/**
	* FUnction to back up the existing wordpress installation files
	**/
	function wpau_backup_files($automated = false) {
		if(!current_user_can('edit_files')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		global $wpauDirPath, $wpAbsPath, $theFuncComplete, $isNix, $wpIncludeDirs;
		$wpauHelper = new wpauHelper;
		$dirName = trailingslashit(ABSPATH);
		$dirName = $dirName . WPAU_BACKUP_DIR;
		$dirName = trailingslashit($dirName);
		if(! is_dir($dirName)) {
			mkdir ($dirName);
			chmod($dirName, 0757);
			$wpauHelper->createIndexes();
		}
		else {
			$wpauHelper->createIndexes();
			@chmod($dirName, 0757);
		}

		wpauPersistNoLog(false, false, $automated);
		$message = '';
		require_once('wpau_zip.class.php');
		$extension = '.zip';
		$zipFuncs = new wpauZipFuncs($wpAbsPath, $isNix, WPAU_FILES_ZIP, WPAU_BACKUP_DIR, $wpIncludeDirs, $extension);
		$zipFuncs->createArchive();
		if($zipFuncs->isFileWritten) {
			$message = '<br />The files been have been succesfully backed up. <a href="'.get_bloginfo('wpurl').'/'.WPAU_BACKUP_DIR.'/'.$_SESSION['filesbakname'].'">DOWNLOAD IT</a> BEFORE YOU CAN GO AHEAD. <br/>CONTINUE ONLY after verifying that the files have been downloaded<br />';
			$theFuncComplete = true;
		}
		else {
			$message = 'The files could not be backed up, cannot continue with the operation';
			$theFuncComplete = false;
		}
		wpauPersist(true, $zipFuncs->loggedData, $theFuncComplete, $message, true);
		unset($zipFuncs);
		unset($wpauHelper);
		if($automated) { return $theFuncComplete; }
	}

	/**
	Shows the database backup options
	Taken from the plugin Wordpress Database backup created byAustin Matzko.
	**/
	function wpau_backup_db_options() {
		if(!current_user_can('edit_files')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		global $wpAbsPath, $isNix, $theFuncComplete;
		wpauPersistNoLog(false, false, $automated);
		$backupDir = WPAU_BACKUP_DIR;
		require_once('wpau_db_backup.class.php');
		$wpauDbBackup = new wpauBackup($backupDir);
		$wpauDbBackup->backup_menu();
		$message = '<br />Table selection complete, please go ahead to complete your database backup<br />';
		$theFuncComplete = true;
		wpauPersist(true, $wpauDbBackup->loggedData, $theFuncComplete, $message, false);
		unset($wpauDbBackup);
	}

	/**
	Backs up the database tables and saves it to a file
	Taken from the plugin Wordpress Database backup created byAustin Matzko.
	**/
	function wpau_backup_db($automated = false) {
		if( ! current_user_can('manage_options')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		global $wpAbsPath, $isNix, $theFuncComplete;
		wpauPersistNoLog(false, false, $automated);
		$backupDir = WPAU_BACKUP_DIR;
		$wpauHelper = new wpauHelper;
		$backupFile = WPAU_DB_ZIP . $wpauHelper->random(). '.zip';
		$_SESSION['dbbakname'] = $backupFile;
		unset($wpauHelper);
		require_once('wpau_db_backup.class.php');
		$wpauDbBackup = new wpauBackup($backupDir);
		if($wpauDbBackup->perform_backup($automated)) {
			if($wpauDbBackup->zip_backup($backupFile)) {
				$theFuncComplete = true;
				$message = 'The database has been succesfully backed up. <a href="'.get_bloginfo('wpurl').'/'.WPAU_BACKUP_DIR.'/'.$_SESSION['dbbakname'].'">DOWNLOAD IT</a> BEFORE YOU CAN GO AHEAD. <br/>CONTINUE ONLY after verifying that the files have been downloaded<br />';
			}
			else {
				$theFuncComplete = false;
				$message = 'Could not backup your database files, cannot continue with the further process';
			}
		}
		else {
			$theFuncComplete = false;
			$message = 'Could not backup your database files, cannot continue with the further process';
		}
		wpauPersist(true, $wpauDbBackup->loggedData, $theFuncComplete, $message, true);
		unset($wpauDbBackup);
		if($automated) { return $theFuncComplete; }
	}

/**
	* Function to show user an option whether to download files from wordpress site
	* or allow them to upload a file from their local machine
	**/
	function wpau_show_new_version_forms() {
		global $theFuncComplete;
		$theFuncComplete = true;

		wpauPersistNoLog(false, false, false);
	?>
<script type="text/javascript" language="JavaScript">
    function showUpload(layerName){
        document.getElementById(layerName).style.visibility = 'visible';
        document.getElementById(layerName).style.display = 'inline';
    }
    
    function hideUpload(layerName){
        document.getElementById(layerName).style.visibility = 'hidden';
        document.getElementById(layerName).style.display = 'none';
    }
</script>
<div style="padding:left:20px;margin-left:30px;">
    <br/>
    <br/>
    <span><strong>Get or upload the latest version of Wordpress</strong></span>
    <p>
        Ok we are all set with the backups. If you do not have the backup files downloaded, you can download the files backup and the database backup.
    </p>
    <p>
        To continue with the next step we need to get the upgrade files. You can choose from two options
        <ol>
            <li>
                Allow us to automatically download the files from Wordpress using the following url
                <br/>
                http://wordpress.org/latest.zip
            </li>
            <li>
                WordPress in your language (Coming SOON).
            </li>
        </ol>
    </p>
    <p>
        Please complete the form below so we can start the process
    </p>
    <p>
        NOTE: THIS WILL TAKE BETWEEN 10-300 SECONDS, PLEASE DO NOT REFRESH THE PAGE.
    </p>
    <p>
        <form name="wpaunewversion" method="post" enctype="multipart/form-data" action="edit.php?page=<?php echo WPAU_PAGE ?>&task=getlatestfiles">
            <?php
		if(function_exists('wp_nonce_field')) {
			wp_nonce_field('wordpress_automatic_upgrade');
		}
            ?>
            <input type="Radio" name="subtask" value="wp-latest-ver" checked="checked" onchange="hideUpload('fileupload');"/><strong>Get the Latest Version from wordpress.org</strong>
            (recommended)
            <br/>
            <input type="Radio" name="subtask" value="wp-upped-ver" onchange="showUpload('fileupload');" disabled="true" />WordPress in your language. Coming Soon.
            <br/>
            <br/>
            <div id="fileupload" style="visibility:hidden;display:none;">
                <input type="File" name="thefile" accept="application/x-zip-compressed" />Choose the file to be uploaded
                <br/>
                <br/>
            </div>
            <input type="Submit" name="doversiondownload" value="Lets GO" />
        </form>
    </p>
</div>
<?php
		$loggedData = '';
		//$message = 'Select the option to start the files download';
		wpauPersist(true, $loggedData, $theFuncComplete, $message, false);
	}

	/**
	* Function to download the latest version from wordpress.org
	**/
	function wpau_get_latest_version($automated = false) {
		if( ! current_user_can('edit_files')) {
			echo 'Oops sorry you are not authorized to do this';
			return false;
		}
		global $wpAbsPath, $isNix, $theFuncComplete;
		wpauPersistNoLog(false, false, $automated);
		require_once('wpau_upgrade.class.php');
		$upgradeHelper = new wpauUpgradeHelper($wpAbsPath, $isNix, WPAU_BACKUP_DIR, ABSPATH);
		$subtask = 'wp-latest-ver';
		if( isset($_REQUEST['subtask']) ) {
			$subtask = $_REQUEST['subtask'];
		}
		if(strcasecmp($subtask, 'wp-upped-ver')) {
			if (ini_get('allow_url_fopen') == '1') {
				$downloadURL = 'http://wordpress.org/latest.zip';
				if($upgradeHelper->getFilesFromWP($downloadURL)) {
					$upgradeHelper->recursive_chmod_directory(ABSPATH . WPAU_BACKUP_DIR);
					$theFuncComplete = true;
					$message = 'Successfully downloaded and unzipped all files from '.$downloadURL.'<br />';
				}
				else {
					$theFuncComplete = false;
					$message = 'Could not download and unzip the files from '.$downloadURL.'<br />';
				}
			}
			else {
				$url = 'www.wordpress.org';
				$filename = 'latest.zip';
				if($upgradeHelper->downloadFilesFromWP($url, $filename)) {
					$upgradeHelper->recursive_chmod_directory(ABSPATH . WPAU_BACKUP_DIR);
					$theFuncComplete = true;
					$message = 'Successfully downloaded and unzipped all files from '.$downloadURL.'<br />';
				}
				else {
					$theFuncComplete = false;
					$message = 'Could not download and unzip the files from '.$downloadURL.'<br />';
				}
			}
		}
		else {
			//read and upload the user file
			if($upgradeHelper->getUploadedFilesFromUser($_FILES)) {
				$theFuncComplete = true;
				$message = 'Successfully uploaded and unzipped all files <br />';
			}
			else {
				$theFuncComplete = false;
				$message = 'Could not upload and unzip all files <br />';
			}
		}
		wpauPersist(true, $upgradeHelper->loggedData, $theFuncComplete, $message, true);
		unset($upgradeHelper);
		if($automated) { return $theFuncComplete; }
	}

	/**
	* Function to show site downtime
	**/
	function wpau_site_down($automated = false) {
		if(!current_user_can('edit_files')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		global $wpauFileDirPath, $wpAbsPath, $isNix, $theFuncComplete;
		wpauPersistNoLog(false, false, $automated);
		require_once('wpau_upgrade.class.php');
		$upgradeHelper = new wpauUpgradeHelper($wpAbsPath, $isNix, WPAU_BACKUP_DIR, ABSPATH);
		if($upgradeHelper->doMaintenanceMode($wpauFileDirPath, 'temp-index.php')) {
			$theFuncComplete = true;
			$message = 'The site has been put into maintenance mode, <a href="'.get_bloginfo('wpurl').'" target="_blank">click here</a> (Opens in new window) to confirm';
		}
		else {
			$theFuncComplete = false;
			$message = 'The site could not be put into maintenance mode.';
		}
		wpauPersist(true, $upgradeHelper->loggedData, $theFuncComplete, $message, true);
		unset($upgradeHelper);
		if($automated) { return $theFuncComplete; }
	}

	/**
	* Function to de-activate all plugins
	**/
	function wpau_deactivate_plugins($automated = false) {
		if(!current_user_can('edit_plugins')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		global $theFuncComplete;
		wpauPersistNoLog(false, false, $automated);
		$thePlugs = array();
		require_once('wpau_plugin.class.php');
		$path = "../";
		if ($automated) { $path = "../../"; }
		$currentPlugs = get_option('active_plugins');
		foreach($currentPlugs as $plugin) {

			if ( wpau_validate_file($path.$plugin) ) {
				//another wp guys check
				if (in_array($plugin, $currentPlugs)) {
					array_push($thePlugs, $plugin);
				}
			}
		}
		$wpauPluginsHandler = new wpauPluginHandler($thePlugs);
		if($wpauPluginsHandler->deActivatePlugins()) {
			$theFuncComplete = true;
			$message = 'All the plugins have been de-activated, except for <strong>Wordpress automatic upgrade</strong> plugin.';
		}
		else {
			$theFuncComplete = false;
			$message = 'The plugins could not be de-activated. Please click here to manually de-activate the plugin. Please do not de-activate the <strong>Wordpress automatic upgrade</strong> plugin';
		}
		wpauPersist(true, $wpauPluginsHandler->loggedData, $theFuncComplete, $message, true);
		unset($wpauPluginsHandler);
		if($automated) { return $theFuncComplete; }
	}

	/**
	* Function to upgrade the latest files and run the upgrade.php
	**/
	function wpau_upgrade_installation($automated = false) {
		if(!current_user_can('edit_files')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		global $wpAbsPath, $isNix, $theFuncComplete;
		wpauPersistNoLog(false, false, $automated);
		require_once('wpau_upgrade.class.php');
		$upgradeHelper = new wpauUpgradeHelper($wpAbsPath, $isNix, WPAU_BACKUP_DIR, ABSPATH);
		if($upgradeHelper->upgradeFiles()) {
			$theFuncComplete = true;
			$message = 'Congratulations!!! All the files have been upgraded to the latest version. Please <a href="'.get_bloginfo('wpurl').'/wp-admin/upgrade.php" target="_blank">CLICK HERE TO COMPLETE THE FINAL STEP</a> (opens in new window and will show you a upgrade link only if database has to be upgraded) and come back here to reactivate your plugins';
      $message .= 'Note: While re-activating plugins WordPress may log you out, but do not worry WPAU will take care of the logout and finish the upgrade like normal once you login, just remember to stay in this window and click on the link to re-activate your plugins.';
		}
		else {
			$theFuncComplete = false;
			$message = 'Oops!! we could not upgrade your files. All the files have been reverted to the older version.';
		}

		wpauPersist(true, $upgradeHelper->loggedData, $theFuncComplete, $message, true);
		unset($upgradeHelper);
		if($automated) { return $theFuncComplete; }
	}

	function wpau_update_database($automated = false) {
		if(!current_user_can('edit_files')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		global $wpAbsPath, $isNix, $theFuncComplete;
		wpauPersistNoLog(false, false, $automated);
		require_once('wpau_upgrade.class.php');
		$upgradeHelper = new wpauUpgradeHelper($wpAbsPath, $isNix, WPAU_BACKUP_DIR, ABSPATH);
		if($upgradeHelper->updateDatabase()) {
			$theFuncComplete = true;
			$message = 'Your WordPress database has been successfully upgraded!';
		}
		else {
			$theFuncComplete = false;
			$message = 'Your wordpress database could not be upgraded succesfully. <a href="'.get_bloginfo('wpurl').'/wp-admin/upgrade.php" target="_blank">Click here</a> to manually upgrade before re-activating the plugins.';
		}
		wpauPersist(true, $upgradeHelper->loggedData, $theFuncComplete, $message, true);
		unset($upgradeHelper);
		if($automated) { return $theFuncComplete; }
	}

	/**
	* Function to activate the plugins
	**/
	function wpau_reactivate_plugins($automated = false) {
		if(!current_user_can('edit_plugins')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		global $theFuncComplete, $wpdb;
		wpauPersistNoLog(false, false, $automated);
		require_once('wpau_plugin.class.php');
		$thePlugs = array();
		$wpauPluginsHandler = new wpauPluginHandler($thePlugs);
		if($wpauPluginsHandler->reActivatePlugins($automated)) {
			$plugins = $wpdb->get_results("select plugin_name from ".WPAU_PLUGIN_TABLE." where fatal_plugin = 1");
			if(count($plugins) > 0)  {
				foreach($plugins as $plugin) {
					$message .= '<span style="color:red">The Plugin <strong>'.$plugin->plugin_name.'</strong> could not be activated succesfully. You will need to activate it manually.</span><br>';
				}
			}
			else {
				$message = 'The plugins have been reactivated succesfully';
			}
			$theFuncComplete = true;
		}
		else {
			$theFuncComplete = true;
			$message = 'The plugin could not be activated, please activate the plugins manually';
		}
		$wpau_ftp = get_settings('wpau-params');
		if($wpau_ftp['ftpuser'] != '') {
			do_ftp_sanitize_operations($wpau_ftp);
		}
		$wpau_ftp['ftpuser'] = '';
		$wpau_ftp['ftppass'] = '';
		$wpau_ftp['ftphost'] = '';
		$wpau_ftp['ftpbasedir'] = '';
		//remove the ftp information from the db
		update_option('wpau-params', $wpau_ftp);

		wpauPersist(true, $wpauPluginsHandler->loggedData, $theFuncComplete, $message, true);
		unset($wpauPluginsHandler);
		if($automated) { return $theFuncComplete; }
	}

	function do_ftp_sanitize_operations($wpau_ftp, $automated = false) {
		require_once('wpau_prelimcheck.class.php');
		$prelimCheck = new wpauPrelimHelper(ABSPATH, $isNix, true);
		$prelimCheck->ftpUser = $wpau_ftp['ftpuser'];
		$prelimCheck->ftpPass = $wpau_ftp['ftppass'];
		$prelimCheck->ftpHost = $wpau_ftp['ftphost'];
		$prelimCheck->ftpBaseDir = $wpau_ftp['ftpbasedir'];
		$prelimCheck->checkFtpMode();
		if($prelimCheck->checkFTPCredentials()) {
			$prelimCheck->runFTPOperation();
		}
		unset($prelimCheck);
	}

	/** cleans up all the upgradation files**/
	function wpau_cleanup($automated = false) {
		if(!current_user_can('edit_files')) {
				echo 'Oops sorry you are not authorized to do this';
				return false;
		}
		global $wpAbsPath, $isNix, $theFuncComplete;
		$loggedData =  '<strong>Congratulations your wordpress upgrade is complete</strong>';
		require_once('wpau_upgrade.class.php');
		$upgradeHelper = new wpauUpgradeHelper($wpAbsPath, $isNix, WPAU_BACKUP_DIR, ABSPATH);
		$upgradeHelper->cleanUpProcess();
		$returnHome = $_REQUEST['returnhome'];
		if($returnHome) {
			unset($upgradeHelper);
			//the wp_redirect does not work on some sites
			//as we already included header above while loading the plugin use plain old js
			//wp_redirect('edit.php?page='.WPAU_PAGE);
?>
<script language="JavaScript" type="text/javascript">
    window.location = "<?php echo 'edit.php?page='.WPAU_PAGE;?>";
</script>
<?php
		}

		$loggedData .= '<p>We have cleaned up all your upgradation files</p>';
		$message = '<p>We have cleaned up all your upgradation files</p>';
		wpauStartHtml();
		$theFuncComplete = true;
		echo '<strong>'.$message.'</strong>';
		echo "<hr /><strong>TASK STATUS</strong><br /><hr />";
		echo $loggedData.'<br /><br />';
		unset($upgradeHelper);
		wpauEndHtml();
		if($automated) { return $theFuncComplete; }
	}

	/**
	* Function to show the log for the upgrade
	**/
	function wpau_show_backup_log($automated = false) {
		global $wpdb;
		$logData = '';
		wpauStartHtml();
		echo '<strong>Congratulations!!! Your Wordpresss installation has been upgraded.</strong>';
		echo '<br /><strong>Please download your backup files if you have not done it.</strong><br />';
		echo '<a href="'.get_bloginfo('wpurl').'/'.WPAU_BACKUP_DIR.'/'.$_SESSION['filesbakname'].'">DOWNLOAD FILES BACKUP</a><br />';
		echo '<a href="'.get_bloginfo('wpurl').'/'.WPAU_BACKUP_DIR.'/'.$_SESSION['dbbakname'].'">DOWNLOAD DATABASE BACKUP</a><br />';
		echo 'Don\'t forget to run  <a href="'.get_bloginfo('wpurl').'/wp-admin/upgrade.php" target="_blank">Database Upgrade</a> if you have not done it.';
		echo 'You can <a href="edit.php?page='.WPAU_PAGE.'&task=cleanup">Clean up</a> the ugradation files once your done';
		echo "<hr /><strong>Below is the log for the upgradation</strong><br /><hr />";
		$logData = getDBLog();
		/*$wpauHelper = new wpauHelper;
		$dirName = trailingslashit(ABSPATH);
		$dirName = trailingslashit($dirName);
		if($wpauHelper->writeLogToDisk($dirName, WPAU_LOG_FILE, $logData)) {
			echo '<strong>Click <a href="'.get_bloginfo('wpurl').'/'.WPAU_LOG_FILE.'" target="_blank">here</a> to download the log file</strong><br>';
		}
		unset($wpauHelper);*/
		echo $logData;
		wpauEndHtml();
	}

	/**
	* Function to show the log on failure
	**/
	function wpau_show_log($automated = false) {
		global $wpdb;
		$logData = '';
		wpauStartHtml();
		echo '<strong>Some problems did not allow us to upgrade your blog. This most likely ocurred due to file permission issues, you can find a workaround for the issue by visiting <a href="http://forum.techie-buzz.com/topic.php?id=46&page&replies=1" target="_blank" title="Opens in new Window">this forum post on WPAU forums</a>.<br /><br />If that does not solve your problem please post on the forum and I will definitely take a look at the issue.</strong>';
		echo "<hr /><strong>Below is the log for the upgradation</strong><br /><hr />";
		echo getDBLog();
		wpauEndHtml();
	}

	function getDBLog() {
		global $wpdb;
		$logData = '';
		$logged = $wpdb->get_results('SELECT task_name, task_status, task_description, task_log, start_date, end_date from  '.WPAU_LOG_TABLE);
		if(count($logged) > 0) {
			foreach($logged as $log) {
				$taskStatus = $log->task_status;
				if($taskStatus) { $taskStatus = 'Complete'; }
				else { $taskStatus = '<span style="color:red">Failed</span>'; }
				$logData .= '<strong>Task Name:</strong>  '. $log->task_name.'<br>';
				$logData .= '<strong>Task Description:</strong> '. $log->task_description.'<br>';
				$logData .= '<strong>Task Status:</strong> '. $taskStatus.'<br>';
				$logData .= '<strong>Task Start Date:</strong> '. $log->start_date.'<br>';
				$logData .= '<strong>Task End Date:</strong> '. $log->end_date.'<br>';
				$logData .= '<strong>Task Log:</strong> '. $log->task_log.'<br><br>';
			}
		}
		return $logData;
	}

	/** show start instructions **/
	function show_upgrade_start() {
	?>
<div style="padding:left:20px;margin-left:30px;">
    <br/>
    <br/>
    <span><strong>Starting Wordpress automatic update. <a href="edit.php?page=<?php echo WPAU_PAGE ?>&task=prelim">Click to begin</a>. Here is what we will do</strong></span>
    <ol>
        <li>
            Checks if your server is able to run the process. 
            <br/>
            If not asks you to provide your FTP details.
            <br/>
            If its running in safe mode this plugin cannot run.
        </li>
        <li>
            Backup your current files and make if available for you to download
        </li>
        <li>
            Backup your database and make it available for you to download
        </li>
        <li>
            Get the latest files via one of the ways below
            <ul>
                <li>
                    Automatically download files from the location OR
                </li>
                <li>
                    You can provide us with the latest downloaded version. (DOES NOT WORK IN THIS VERSION)
                </li>
            </ul>
        </li>
        <li>
            Deactivate your plugins and remember it
        </li>
        <li>
            Make your site offline
        </li>
        <li>
            Upgrade your files
        </li>
        <li>
            Activate your plugins
        </li>
        <li>
            Make your site online
        </li>
        <li>
            Provide you with a upgradation log
        </li>
    </ol>
    <span><strong><a href="edit.php?page=<?php echo WPAU_PAGE ?>&task=files">Click to begin now</a></strong></span>
    <div>
        <div id="wpau-file-download">
        </div>
        <div id="wpau-db-download">
        </div>
        <div id="wpau-update-db">
        </div>
        You may also choose the <a href="#" id="wpau-automated">automated version</a>.
        <div id="wpau-status-bar">
            <div id="wpau-status-bar-indicator">
            </div>
        </div>
        <div id="wpau-status-message">
        </div>
    </div>
</div>
<?php
	}

	function install() {
		global $wpdb;
		$result = mysql_query("DROP TABLE if exists `wpau_active_plugins_info`");
		$result = mysql_query("
			CREATE TABLE `wpau_active_plugins_info` (
			  `id` int(4) NOT NULL auto_increment,
			  `plugin_name` varchar(255) NOT NULL default '',
			  `plugin_status` varchar(255) NOT NULL default '',
				`plugin_deactive_response` smallint(2) NULL default '0',
				`plugin_reactive_response` smallint(2) NULL default '0',
				`fatal_plugin` smallint(2) NULL default '0',
			  PRIMARY KEY  (`id`)
			) TYPE=MyISAM;
		") or die(mysql_error().' on line: '.__LINE__);

		if (!$result) {
			return false;
		}

		$result = mysql_query("DROP TABLE if exists `wpau_upgrade_log`");
		$result = mysql_query("
			CREATE TABLE `wpau_upgrade_log` (
			  `id` int(4) NOT NULL auto_increment,
			  `task_name` varchar(150) NOT NULL default '',
			  `task_status` varchar(150) NOT NULL default '',
			  `task_description` varchar(150) NOT NULL default '',
			  `task_log` text,
			  `start_date` datetime NOT NULL default '0000-00-00 00:00:00',
			  `end_date` datetime default NULL,
			  PRIMARY KEY  (`id`)
			) TYPE=MyISAM;
		") or die(mysql_error().' on line: '.__LINE__);

			if (!$result) {
				return false;
			}

	}


	function wpau_validate_file($file, $allowed_files = '') {
		if ( false !== strpos($file, './'))
			return 1;

		if (':' == substr($file,1,1))
			return 2;

		if ( !empty($allowed_files) && (! in_array($file, $allowed_files)) )
			return 3;

		return 0;
	}

	/**
	* checks to see if everything is set first up so that it can be logged properly
	**/
	function wpau_init() {
		global $wpdb, $table_prefix;
		$wpdb->upgrade_log = $table_prefix.'upgrade_log';
		$wpdb->active_plugins_info = $table_prefix.'active_plugins_info';

		if (isset($_GET['activate']) && $_GET['activate'] == 'true') {
			$result = mysql_list_tables(DB_NAME);
			$tables = array();
			while ($row = mysql_fetch_row($result)) {
				$tables[] = $row[0];
			}
			if (!in_array($wpdb->upgrade_log, $tables) && !in_array($wpdb->active_plugins_info, $tables)) {
				install();
			}
		}
	}

	/**
	* Adds in the necessary JavaScript files for the automated version
	**/
	function wpau_add_scripts() {
		if (function_exists('wp_enqueue_script') && function_exists('wp_register_script')) {
			wp_register_script('jquery', get_bloginfo('wpurl') . '/wp-content/plugins/wordpress-automatic-upgrade/js/jquery.js');
			wp_enqueue_script('wpau_auto_update', get_bloginfo('wpurl') . '/wp-content/plugins/wordpress-automatic-upgrade/js/wp-wpau.js.php', array('jquery'), '0.1');
		} else {
			wpau_add_scripts_legacy();
		}
	}
	function wpau_add_scripts_legacy() {
		if (function_exists('wp_enqueue_script') && function_exists('wp_register_script')) { wpau_add_scripts(); return; }
		print('<script type="text/javascript" src="'.get_bloginfo('wpurl') . '/wp-content/plugins/wordpress-automatic-upgrade/js/jquery.js"></script>'."\n");
		print('<script type="text/javascript" src="'.get_bloginfo('wpurl') . '/wp-content/plugins/wordpress-automatic-upgrade/js/wp-wpau.js.php"></script>'."\n");
	}
	add_action('admin_print_scripts', 'wpau_add_scripts');
	add_action('admin_head', 'wpau_add_scripts_legacy');
	add_action('admin_menu', 'wpau_manage_page');
  add_action('admin_notices', 'wpau_add_nag', 3 );

?>
