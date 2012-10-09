<?php
/*
Plugin Name: Wordpress BlockYou
Plugin URI: http://no.url.yet.
Description: A plugin used to block IP addresses from accessing your blog, and then redirect them to a URL of your choice. Useful for RickRolling, etc.
Version: 1.0
Author: Jules Robinson
Author URI: http://www.thiswebhost.com
*/

/*  Copyright 2008  Jules Robinson  (email : jules@thiswebhost.com)

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

# Function called on deactivation of plugin.
function uninit_blockyou_options() {
	# Destroy wordpress options
	delete_option('blockyou_ips');
	delete_option('blockyou_url');
	# Remove all wp-blockyou from the .htaccess file
	clean_blockyou_htaccess();
}

# Set deactivation hook:
register_deactivation_hook(__FILE__, 'uninit_blockyou_options' );

# Set up the Admin menu:
function modify_menu() {
	add_options_page(
	'WP-BlockYou', // Page title
	'WP-BlockYou Settings', // Sub-menu title
	'manage_options', // Access
	__FILE__,
	'admin_blockyou_options' // Function to show options
	);
}
# Add menu to WP Settings
add_action('admin_menu', 'modify_menu');

# Function called when the options page is accessed
function admin_blockyou_options() {
	?>
	<div class="wrap"><h2>WP-BlockYou Settings</h2><?php
	if ($_REQUEST['submit']) {
		update_blockyou_options();
	}
	print_blockyou_form();
	?>
	</div><?php
}

# Function to actually wrote the .htaccess file, etc:
function update_blockyou_options() {
	if (empty($_REQUEST['ips']) or empty($_REQUEST['url'])) {
		?>
		<div id="message" class="error fade">
		<p>You can't leave this form empty! If you want to clear all settings and remove the blocks, simply deactivate the plugin.</p>
		</div>
		<?php
	}
	else {
		if (isset($_REQUEST['ips'])) {
			$ips = str_replace("\r\n", "<br />", $_REQUEST['ips']);
			$url = $_REQUEST['url'];
			update_option('blockyou_ips', $ips);
			update_option('blockyou_url', $url);
			$result = rebuild_blockyou_htaccess();
		}
		if (empty($result)) {
		?>
		<div id="message" class="updated fade">
		<p>Options successfully saved.</p>
		</div><?php
		}
		else {
		?>
		<div id="message" class="error fade">
		<p><?php echo $result; ?></p>
		</div>
		<?php
		}
	}
}

# Function to print the user form for settings:
function print_blockyou_form() {
	$currentips = str_replace("<br />", "\n", get_option('blockyou_ips'));
	$currenturl = get_option('blockyou_url');
	?>
	<p><strong>Wordpress BlockYou</strong> is a plugin created to block certain IP addresses from accessing your blog. Why would you want to do this? Maybe you have a friend that you want to Rick Roll for fun? Maybe you have a user who's been blocked from posting comments, but you don't want them visiting the blog any more? Block them all here!</p>
	<br />
	<form method="post">
	<table class="form-table">
	<tr valign="top">
	<th scope="row">IP Address Blacklist:</th>
	<td>
	<p>These are the list of IP addresses that will be redirected to the URL below. One IP address per line.</p>
	<p>
	<textarea name="ips" cols="60" rows="10" id="blacklist_keys" style="width: 98%; font-size: 12px;" class="code"><?php echo $currentips; ?></textarea>
	</p>
	</td>
	</tr>
	<tr valign="top">
	<th scope="row">URL:</th>
	<td>
	The URL that blacklisted IP addresses will get redirected to:<br />
	<input name="url" type="text" id="siteurl" value="<?=$currenturl?>" size="40" class="code">
	</td>
	</tr>
	</table>
	<p class="submit"><input type="submit" name="submit" value="Save Changes" /></p>
	</form>
	<?php
}

function rebuild_blockyou_htaccess() {
	# Work out where the .htaccess file is going to be placed and create the filename and path:
	$temppath = explode('wp-content', __FILE__);
	$htfile = $temppath['0'] . ".htaccess";
	# Check if the file exists to read from, otherwise there's no point continuing...
	if (is_writable($htfile)) {
		$content = file_get_contents($htfile);
		// Check if we have existing wp-blockyou in the htaccess file
		// If so, we can safely remove this and start again/rebuild it.
		if (preg_match("/start wp-blockyou/i", $content)) {
			# Remove the existing config:
			$content = preg_replace("/# start wp-blockyou(.*?)# end wp-blockyou/s", "", $content);
		}
		# Now we can rebuild our new configuration:
		$content .= "\n# start wp-blockyou\n";
		$ips = nl2br(get_option('blockyou_ips'));
		$iparray = explode('<br />', $ips);
		foreach ($iparray as $key => $ip) {
			if (!empty($ip)) {
				# Check that the IP addresses are valid:
				trim($ip);
				$ip = str_replace("\n", "", $ip);
				if (!validateIpAddress($ip)) {
					removeIPFromList($ip);
					$error = "One or more IP addresses are invalid and have been removed from the list. Please resubmit the form.";
				}
				if ($ip == $_SERVER['REMOTE_ADDR']) {
					removeIPFromList($ip);
					$error = "Cannot add your own IP to the block list. If you want to test the plugin, ask a friend. I've removed your IP from the list so please resubmit the form.";
				}
				$content .= "Deny from $ip\n";
			}
		}
		$content .= "ErrorDocument 403 " . get_option('blockyou_url') . "\n";
		$content .= "# end wp-blockyou";
		if (!isset($error)) {
			$outputhandler = fopen($htfile, 'w');
			# Strip additional double newlines from content
			$content = str_replace("\n\n", "\n", $content);
			fwrite($outputhandler, $content);
			fclose($outputhandler);
			return false;
		}
	}
	else {
		// File isn't there, so let's not bother reading anything:
		$error = "Could not open $htfile for writing. Please check the file exists and is writeable (chmod 666).";
		return $error;
	}

}

# Function called on plugin deactivation that removes all wp-blockyou lines from the .htaccess file:
function clean_blockyou_htaccess() {
	# Work out where the .htaccess file is going to be placed:
	$temppath = explode('wp-content', __FILE__);
	# Make filename:
	$htfile = $temppath['0'] . ".htaccess";
	# Open up existing content and store in variable, so we don't overwrite anything important like permalink structures:
	$content = @file_get_contents($htfile);
	# Remove all our wp-blockyou lines from content in variable
	$content = @preg_replace("/# start wp-blockyou(.*?)# end wp-blockyou/s", "", $content);
	# Remove additional newlines
	$content = @str_replace("\n\n", "\n", $content);
	# Open .htaccess file for writing:
	$outputhandler = @fopen($htfile, 'w');
	# Write new .htaccess file with wp-blockyou removed
	@fwrite($outputhandler, $content);
	# Close .htaccess file
	@fclose($outputhandler);
}

function validateIpAddress($ip_addr)
{
	//first of all the format of the ip address is matched
	if(preg_match("/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/",$ip_addr))
	{
		//now all the intger values are separated
		$parts=explode(".",$ip_addr);
		//now we need to check each part can range from 0-255
		foreach($parts as $ip_parts)
		{
			if(intval($ip_parts)>255 || intval($ip_parts)<0)
			return false; //if number is not within range of 0-255
		}
		return true;
	}
	else
	return false; //if format of ip address doesn't matches
}

function removeIPFromList($ip) {
	$ips = nl2br(get_option('blockyou_ips'));
	$iparray = explode('<br />', $ips);
	foreach ($iparray as $key => $ipaddy) {
		if ($iparray[$key] == $ip) { unset($iparray[$key]); }
		else {
			$newips .= $ipaddy . "\n";
		}
	}
	# Should have clean array now, so let's turn it back into a string:
	update_option('blockyou_ips', $newips);
}
?>