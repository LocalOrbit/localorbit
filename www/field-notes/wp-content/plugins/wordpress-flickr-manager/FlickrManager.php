<?php
/*
Plugin Name: Flickr Manager
Plugin URI: http://tgardner.net/
Description: Handles uploading, modifying images on Flickr, and insertion into posts.
Version: 2.3
Author: Trent Gardner
Author URI: http://tgardner.net/

Copyright 2007  Trent Gardner  (email : trent.gardner@gmail.com)

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

if(version_compare(PHP_VERSION, '4.4.0') < 0) 
	die(sprintf(__('You are currently running %s and you must have at least PHP 4.4.x in order to use Flickr Manager!', 'flickr-manager'), PHP_VERSION));

if(class_exists('FlickrManager')) return;
require_once(dirname(__FILE__) . '/FlickrCore.php');

class FlickrSettings {
	
	var $settings;
	
	function getSettings() {
		global $flickr_manager;
		if(empty($this->settings)) $this->settings = get_option($flickr_manager->plugin_option);
		return $this->settings;
	}
	
	function getSetting($name) {
		global $flickr_manager;
		if(empty($this->settings)) $this->getSettings();
		return $this->settings[$name];
	}
	
	function saveSetting($name, $value) {
		global $flickr_manager;
		if(empty($this->settings)) $this->getSettings();
		$this->settings[$name] = $value;
		update_option($flickr_manager->plugin_option, $this->settings);
	}
	
}

class FlickrManager extends FlickrCore {
	
	var $db_table;
	var $plugin_directory;
	var $plugin_filename;
	var $plugin_option = 'wfm-settings';
	var $plugin_domain = 'flickr-manager';
	
	
	
	function FlickrManager() {
		global $wpdb;
		
		$this->db_table = $wpdb->prefix . "flickr";
		
		$this->plugin_directory = dirname(plugin_basename(__FILE__));
		$this->plugin_filename = basename(__FILE__);
		
		register_activation_hook( __FILE__, array(&$this, 'install') );
		
		add_action('admin_menu', array(&$this, 'add_menus'));
		add_action('init', array(&$this,'add_scripts'));
		add_action('wp_head', array(&$this, 'add_headers'));
		add_action('admin_print_styles', array($this, 'add_admin_headers'));
		add_action('edit_page_form', array(&$this, 'add_flickr_panel'));
		add_action('edit_form_advanced', array(&$this, 'add_flickr_panel'));
		
		add_filter('the_content', array(&$this, 'filterContent'));
		
		/*
		 * Wordpress 2.5 - New media button support
		 */
		add_action('media_buttons', array($this, 'addMediaButton'), 20);
		add_action('media_upload_flickr', array($this, 'wfm_create_iframe'));
		add_action('media_upload_flickr_public', array($this, 'wfm_create_iframe'));
		add_action('media_upload_flickr_upload', array($this, 'wfm_create_iframe'));
		add_action('media_upload_flickr_sets', array($this, 'wfm_create_iframe'));
		
		/*
		 * Load locale settings
		 */
		load_plugin_textdomain($this->plugin_domain, PLUGINDIR . '/' . $this->plugin_directory . '/lang');
		
		/*
		 * Create Shortcodes
		 */
		add_shortcode('flickr', array(&$this, 'image_shortcode'));
		add_shortcode('flickrset', array(&$this, 'set_shortcode'));
	}
	
	
	
	function install() {
		global $wpdb;
		
		if($wpdb->get_var("SHOW TABLES LIKE '$this->db_table'") == $this->db_table) {
			$results = $wpdb->get_results("select * from $this->db_table");
			$settings = array();
			foreach ($results as $setting) {
				$settings[$setting->name] = $setting->value;
			}
			
			if(get_option($this->plugin_option)) {
				update_option($this->plugin_option, $settings);
			} else {
				add_option($this->plugin_option, $settings);
			}
			
			$wpdb->query("drop table $this->db_table");
		} elseif (!get_option($this->plugin_option)) {
			add_option($this->plugin_option, array());
		}
	}
	
	
	
	function add_menus() {
		// Add a new submenu under Options
		add_options_page('Flickr Options', 'Flickr', 5, __FILE__, array(&$this, 'options_page'));
		
		// Add a new submenu under Manage
		add_management_page('Flickr Management', 'Flickr', 5, __FILE__, array(&$this, 'manage_page'));
	}
	
	
	
	function options_page() {
		global $flickr_settings;
		
		if(!empty($_REQUEST['action'])) : 
			switch ($_REQUEST['action']) :
				
				case 'token':
					if(function_exists('check_admin_referer'))
						check_admin_referer('flickr-manager-options_token');
					
					if($frob = $flickr_settings->getSetting('frob')) {
						$token = $this->call('flickr.auth.getToken', array('frob' => $frob), true);
						if($token['stat'] == 'ok') {
							$flickr_settings->saveSetting('token', $token['auth']['token']['_content']);
							$flickr_settings->saveSetting('nsid', $token['auth']['user']['nsid']);
							$flickr_settings->saveSetting('username', $token['auth']['user']['username']);
						}
					}
					break;
				
				case 'logout':
					if(function_exists('check_admin_referer'))
						check_admin_referer('flickr-manager-options_logout');
					
					update_option($this->plugin_option, array());
					$flickr_settings = new FlickrSettings();
					
					break;
				
				case 'save':
					if(function_exists('check_admin_referer'))
						check_admin_referer('flickr-manager-options_save');
					
					$_REQUEST['wfm-per_page'] = (empty($_REQUEST['wfm-per_page']) || !is_numeric($_REQUEST['wfm-per_page']) || 
												intval($_REQUEST['wfm-per_page']) < 5) ? 5 : $_REQUEST['wfm-per_page'];
					
					$flickr_settings->saveSetting('per_page', $_REQUEST['wfm-per_page']);
					$flickr_settings->saveSetting('new_window', $_REQUEST['wfm-new_window']);
					$flickr_settings->saveSetting('lightbox_default', $_REQUEST['wfm-lbox_default']);
					$flickr_settings->saveSetting('lightbox_enable', $_REQUEST['wfm-lbox_enable']);
					$flickr_settings->saveSetting('image_viewer', $_REQUEST['wfm-js-viewer']);
					$flickr_settings->saveSetting('before_wrap', $_REQUEST['wfm-insert-before']);
					$flickr_settings->saveSetting('after_wrap', $_REQUEST['wfm-insert-after']);
					$flickr_settings->saveSetting('upload_level', $_REQUEST['wfm-upload-level']);
					$flickr_settings->saveSetting('flickr_link', $_REQUEST['wfm-flickr_link']);
					$flickr_settings->saveSetting('privacy_filter', $_REQUEST['wfm-privacy']);
					$flickr_settings->saveSetting('hide_copyright', $_REQUEST['wfm-copyright']);
					
					break;
				
			endswitch;
		endif;
		
		if(($token = $flickr_settings->getSetting('token')))
			$auth_status = $this->call('flickr.auth.checkToken', array('auth_token' => $token), true);
		?>
		
		<div class="wrap">
		
			<?php if($_REQUEST['action'] == 'save') : ?>
					
				<div id="message" class="updated fade">
					<p><strong><?php _e('Options Saved!', 'flickr-manager') ?></strong></p>
				</div>
			
			<?php endif; ?>
			
			<div id="icon-options-general" class="icon32"><br /></div>
			<h2><?php _e('Flickr Manager Settings', 'flickr-manager') ?></h2>
			
			<?php if(empty($token) || $auth_status['stat'] != 'ok') : ?>
			
			<!-- Begin Authentication -->
			
			<?php
			$frob = $this->call('flickr.auth.getFrob', array(), true);
			$frob = $frob['frob']['_content'];
			$flickr_settings->saveSetting('frob', $frob);
			?>
			
			<div align="center">
				<h3><?php _e('Step', 'flickr-manager') ?> 1:</h3>
				<input type="button" value="<?php _e('Authenticate', 'flickr-manager') ?>" onclick="window.open('<?php echo $this->getAuthUrl($frob, 'delete'); ?>')" style="background: url( images/fade-butt.png ); border: 3px double #999; border-left-color: #ccc; border-top-color: #ccc; color: #333; padding: 0.25em; font-size: 1.5em;" />
				
				<h3><?php _e('Step', 'flickr-manager') ?> 2:</h3>
				<form method="post" action="<?php echo str_replace( '%7E', '~', $_SERVER['REQUEST_URI']); ?>">
					<?php 
					if ( function_exists('wp_nonce_field') )
						wp_nonce_field('flickr-manager-options_token');
					?>
					<input type="hidden" name="action" value="token" />
					<input type="submit" name="Submit" value="<?php _e('Finish &raquo;', 'flickr-manager') ?>" style="background: url( images/fade-butt.png ); border: 3px double #999; border-left-color: #ccc; border-top-color: #ccc; color: #333; padding: 0.25em; font-size: 1.5em;" />
				</form>
			</div>
			
			<?php else : ?>
			
			<!-- Display options -->
			<div style="text-align: center;">
				<form method="post" action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?>">
					<?php 
					if ( function_exists('wp_nonce_field') )
						wp_nonce_field('flickr-manager-options_logout');
					?>
					<input type="hidden" name="action" value="logout" />
					<p class="submit">
						<input type="submit" name="Submit" value="<?php _e('Logout &raquo;', 'flickr-manager') ?>" class="button submit" style="font-size: 1.4em;" />
					</p>
				</form>
			</div>
			
			<?php
			$info = $this->call('flickr.people.getInfo', array('user_id' => $flickr_settings->getSetting('nsid')));
			
			if($info['stat'] == 'ok') :
				$flickr_settings->saveSetting('is_pro', $info['person']['ispro']);
				
				if(intval($info['person']['iconserver']) > 0) 
					$photo_url = "http://farm{$info['person']['iconfarm']}.static.flickr.com/{$info['person']['iconserver']}/buddyicons/{$info['person']['nsid']}.jpg";
				else $photo_url = 'http://www.flickr.com/images/buddyicon.jpg';
			?>
				
				<h3><?php 
				_e('User Information', 'flickr-manager');
				 
				if($info['person']['ispro'] != 0) 
					echo ' <img src="' . $this->getAbsoluteUrl() . '/images/badge_pro.gif" alt="Pro" style="vertical-align: middle;" />'; 
				?></h3>
				
				<table border="0">
					<tr>
						<th></th>
						<td><?php echo "<img src=\"$photo_url\" alt=\"You\" />"; ?></td>
					</tr>
					<tr>
						<th scope="row" style="width: 130px; text-align: left;"><?php 
							_e('Username', 'flickr-manager') ?>:
						</th>
						<td><?php echo $info['person']['username']['_content']; ?></td>
					</tr>
					<tr>
						<th scope="row" style="width: 130px; text-align: left;"><?php 
							_e('User ID', 'flickr-manager') ?>:
						</th>
						<td><?php echo $info['person']['nsid']; ?></td>
					</tr>
					<tr>
						<th scope="row" style="width: 130px; text-align: left;"><?php 
							_e('Real Name', 'flickr-manager') ?>:
						</th>
						<td><?php echo $info['person']['realname']['_content']; ?></td>
					</tr>
					<tr>
						<th scope="row" style="width: 130px; text-align: left;"><?php 
							_e('Photo URL', 'flickr-manager') ?>:
						</th>
						<td>
							<a href="<?php echo $info['person']['photosurl']['_content']; ?>">
								<?php echo $info['person']['photosurl']['_content']; ?>
							</a>
						</td>
					</tr>
					<tr>
						<th scope="row" style="width: 130px; text-align: left;"><?php 
							_e('Profile URL', 'flickr-manager') ?>:
						</th>
						<td>
							<a href="<?php echo $info['person']['profileurl']['_content']; ?>">
								<?php echo $info['person']['profileurl']['_content']; ?>
							</a>
						</td>
					</tr>
					<tr>
						<th scope="row" style="width: 130px; text-align: left;"><?php 
							_e('# Photos', 'flickr-manager') ?>:
						</th>
						<td><?php echo $info['person']['photos']['count']['_content']; ?></td>
					</tr>
				</table>
				
				<p>&nbsp;</p>
			
			<?php endif; ?>
			
			<!-- BEGIN OPTIONS -->
			<?php
			
			// Load Options
			$settings = $flickr_settings->getSettings();
			$_REQUEST['wfm-per_page'] = (empty($_REQUEST['wfm-per_page']) || !is_numeric($_REQUEST['wfm-per_page']) || 
										 intval($_REQUEST['wfm-per_page']) < 5) ? 5 : $_REQUEST['wfm-per_page'];
			$_REQUEST['wfm-per_page'] = (!empty($settings['per_page'])) ? $settings['per_page'] : $_REQUEST['wfm-per_page'];
			$_REQUEST['wfm-new_window'] = $settings['new_window'];
			
			$_REQUEST['wfm-limit'] = $settings['browse_check'];
			$_REQUEST['wfm-limit-size'] = $settings['browse_size'];
			$_REQUEST['wfm-upload-level'] = (!empty($settings['upload_level'])) ? $settings['upload_level'] : "6";
			
			$_REQUEST['wfm-lbox_enable'] = $settings['lightbox_enable'];
			$_REQUEST['wfm-lbox_default'] = (!empty($settings['lightbox_default'])) ? $settings['lightbox_default'] : "medium";
			$_REQUEST['wfm-js-viewer'] = (!empty($settings['image_viewer'])) ? $settings['image_viewer'] : "medium";
			
			$_REQUEST['wfm-insert-before'] = $settings['before_wrap'];
			$_REQUEST['wfm-insert-after'] = $settings['after_wrap'];
			$_REQUEST['wfm-flickr_link'] = $settings['flickr_link'];
			$_REQUEST['wfm-privacy'] = $settings['privacy_filter'];
			$_REQUEST['wfm-copyright'] = $settings['hide_copyright'];
			?>
			
			<form method="post" action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?>">
				<?php 
				if ( function_exists('wp_nonce_field') )
					wp_nonce_field('flickr-manager-options_save');
				?>
				<input type="hidden" name="action" value="save" />
				
				<h3 class="underline"><?php
				_e('Media Panel Settings', 'flickr-manager'); 
				?></h3>
				
				<table class="form-table">
					<tbody>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-privacy">
									<?php _e('Hide private photos', 'flickr-manager'); ?>
								</label>
							</th>
							<td>
								<input type="checkbox" name="wfm-privacy" id="wfm-privacy" value="true" <?php if($_REQUEST['wfm-privacy'] == "true") echo 'checked="checked" '; ?>/>
							</td>
						</tr>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-per_page">
									<?php _e('Photos per page', 'flickr-manager'); ?>
								</label>
							</th>
							<td>
								<input type="text" name="wfm-per_page" id="wfm-per_page" value="<?php echo $_REQUEST['wfm-per_page']; ?>" size="4" />
							</td>
						</tr>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-copyright">
									<?php _e('Hide public copyright information when browsing', 'flickr-manager'); ?>
								</label>
							</th>
							<td>
								<input type="checkbox" name="wfm-copyright" id="wfm-copyright" value="true" <?php if($_REQUEST['wfm-copyright'] == "true") echo 'checked="checked" '; ?>/>
							</td>
						</tr>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-lbox_enable"><?php _e('Enable image viewer by default', 'flickr-manager') ?></label>
							</th>
							<td>
								<input type="checkbox" name="wfm-lbox_enable" id="wfm-lbox_enable" value="true" <?php if($_REQUEST['wfm-lbox_enable'] == "true") echo 'checked="checked" '; ?>/>
							</td>
						</tr>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-lbox_default"><?php _e('Default image viewer size', 'flickr-manager') ?></label>
							</th>
							<td>
								<select name="wfm-lbox_default" id="wfm-lbox_default">
								<?php
								$sizes = array(	"small" => __('Small', 'flickr-manager'), 
												"medium" => __('Medium', 'flickr-manager'), 
												"large" => __('Large', 'flickr-manager') );
										
								if($settings['is_pro'] == '1') $sizes = array_merge($sizes, array('original' => __("Original", 'flickr-manager')));
								
								foreach ($sizes as $k => $size) {
									echo "<option value=\"$k\"";
									if($_REQUEST['wfm-lbox_default'] == $k) echo ' selected="selected" ';
									echo ">" . ucfirst($size) . "</option>\n";
								}
								?>
								</select>
							</td>
						</tr>
					</tbody>
				</table>
				<br /><br />
				
				<h3 class="underline"><?php _e('Global Settings', 'flickr-manager'); ?></h3>
				
				<table class="form-table">
					<tbody>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-upload-level">
									<?php _e('User upload level', 'flickr-manager'); ?>
								</label>
							</th>
							<td>
								<select name="wfm-upload-level" id="wfm-upload-level">
									<?php 
									$options = array( 10 	=> __('Administrator', 'flickr-manager'),
													  6		=> __('Editor', 'flickr-manager'),
													  4		=> __('Author', 'flickr-manager'),
													  2		=> __('Contributer', 'flickr-manager'));
													  
									foreach($options as $k => $v) {
										echo "<option value=\"$k\" ";
										if($_REQUEST['wfm-upload-level'] == strval($k))	echo 'selected="selected"';
										echo '>' . htmlspecialchars($v) . '</option>';
									}
									?>
								</select>
							</td>
						</tr>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-new_window">
									<?php _e('Open Flickr pages in a new window', 'flickr-manager') ?>
								</label>
							</th>
							<td>
								<input type="checkbox" name="wfm-new_window" id="wfm-new_window" value="true" <?php if($_REQUEST['wfm-new_window'] == "true") echo 'checked="checked" '; ?>/>
							</td>
						</tr>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-js-viewer">
									<?php _e('Image Viewer', 'flickr-manager'); ?>
								</label>
							</th>
							<td>
								<select name="wfm-js-viewer" id="wfm-js-viewer">
									<?php 
									$options = array( 'disabled'	=> __('Disabled', 'flickr-manager'),
													  'lightbox'	=> 'Lightbox',
													  'highslide'	=> 'Highslide');
									
									foreach($options as $k => $v) {
										echo "<option value=\"$k\" ";
										if($_REQUEST['wfm-js-viewer'] == strval($k)) echo 'selected="selected"';
										echo '>' . htmlspecialchars($v) . '</option>';
									}
									?>
								</select>
							</td>
						</tr>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-flickr_link"><?php _e('Include Flickr link in caption', 'flickr-manager') ?></label>
							</th>
							<td>
								<input type="checkbox" name="wfm-flickr_link" id="wfm-flickr_link" value="true" <?php if($_REQUEST['wfm-flickr_link'] == "true") echo 'checked="checked" '; ?>/>
							</td>
						</tr>
						<tr valign="top">
							<th scope="row">
								<label for="wfm-insert-before">
									<?php _e('Wrap photos with HTML', 'flickr-manager'); ?>
								</label>
							</th>
							<td>
								<table>
									<tbody>
										<tr valign="top">
											<th style="font-size: 13px; padding-bottom: 2px; padding-top: 0px;">
												<label for="wfm-insert-before"><?php _e('Before Image', 'flickr-manager') ?></label>
											</th>
											<th style="font-size: 13px; padding-bottom: 2px; padding-top: 0px;">
												<label for="wfm-insert-after"><?php _e('After Image', 'flickr-manager') ?></label>
											</th>
										</tr>
										<tr valign="top">
											<td>
												<textarea name="wfm-insert-before" rows="5" cols="30" id="wfm-insert-before" style="overflow: auto;"><?php echo stripslashes($_REQUEST['wfm-insert-before']); ?></textarea>
											</td>
											<td>
												<textarea name="wfm-insert-after" rows="5" cols="30" id="wfm-insert-after" style="overflow: auto;"><?php echo stripslashes($_REQUEST['wfm-insert-after']); ?></textarea>
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
					</tbody>
				</table>
				
				<p class="submit">
					<input class="button-primary" type="submit" value="<?php _e('Save Changes', 'flickr-manager') ?>" name="Submit"/>
				</p>
				
			</form>
			<!-- END OPTIONS -->
			
			<?php endif; ?>
			
			<h2>Like this plugin?</h2>
			Why not do any of the following:
			<ul style="list-style-position: outside; list-style: disc; margin: 10px 20px; vertical-align: top; padding-left: 5px;">
				<li><a href="http://tgardner.net/wordpress-flickr-manager/">Link</a> 
				to it so other folks can find out about it.</li>
				<li><a href="http://wordpress.org/extend/plugins/wordpress-flickr-manager/">Give it a good rating</a> 
				on WordPress.org.</li>
				<li>
					<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=trent%2egardner%40gmail%2ecom&lc=AU&currency_code=AUD">
					Donate a token of your appreciation</a>.
				</li>
			</ul>
			
			<h2>Need Support?</h2>
			<p>If you have any problems or good ideas, please talk about them in the 
			<a href="http://support.tgardner.net/forum.php?id=1">support forums</a>.</p>
			
			
		</div>
		
		<?php
	}
	
	
	
	function manage_page() {
		global $flickr_settings;
		$token = $flickr_settings->getSetting('token');
		if(empty($token)) {
			echo '<div class="wrap"><h3>' . __('Error: Please authenticate through ', 'flickr-manager') . '<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3></div>\n";
			return;
		} else {
			$auth_status = $this->call('flickr.auth.checkToken', array('auth_token' => $token), true);
			if($auth_status['stat'] != 'ok') {
				echo '<div class="wrap"><h3>' . __('Error: Please authenticate through ', 'flickr-manager') . '<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3></div>\n";
				return;
			}
		}
		
		switch($_REQUEST['action']) {
			case 'upload':
				/* Perform file upload */
				if($_FILES['uploadPhoto']['error'] == 0) {
					
					$params = array('auth_token' => $token, 'photo' => '@'.$_FILES['uploadPhoto']['tmp_name']);
					$rsp = $this->upload($params);
					
					if($rsp !== false) {
					
						$xml_parser = xml_parser_create();
						xml_parse_into_struct($xml_parser, $rsp, $vals, $index);
						xml_parser_free($xml_parser);
						
						$pid = $vals[$index['PHOTOID'][0]]['value'];
						
						if(!empty($pid)) {
							$_REQUEST['pid'] = $pid;
							$_REQUEST['action'] = 'edit';
						}
						
					}
					
				}
				break;
			
			case 'modify':
				/* Perform modify */
				$params = array('photo_id' => $_REQUEST['pid'], 
								'title' => $_REQUEST['ftitle'],
								'description' => $_REQUEST['description'],
								'auth_token' => $token);
				
				$this->post('flickr.photos.setMeta', $params, true);
				
				$params = array('photo_id' => $_REQUEST['pid'], 
								'tags' => $_REQUEST['tags'],
								'auth_token' => $token);
				
				$this->post('flickr.photos.setTags', $params, true);
				
				$is_public = ($_REQUEST['public'] == '1') ? 1 : 0;
				$is_friend = ($_REQUEST['friend'] == '1') ? 1 : 0;
				$is_family = ($_REQUEST['family'] == '1') ? 1 : 0;
				$params = array('photo_id' => $_REQUEST['pid'], 
								'is_public' => $is_public,
								'is_friend' => $is_friend,
								'is_family' => $is_family,
								'perm_comment' => '3',
								'perm_addmeta' => '0',
								'auth_token' => $token);
				
				$this->post('flickr.photos.setPerms', $params, true);
				
				$_REQUEST['action'] = 'default';
				break;
				
			case 'delete': 
				/* Perform delete */
				$params = array('auth_token' => $token, 'photo_id' => $_REQUEST['pid']);
				$this->post('flickr.photos.delete', $params, true);
				
				$_REQUEST['action'] = 'default';
				break;
		}
		?>
		
		<div id="icon-tools" class="icon32"><br /></div>
		
		<div class="wrap">
	
			<h2><?php _e('Manage Flickr Photos', 'flickr-manager'); ?></h2>
			
			<form enctype="multipart/form-data" method="post" action="<?php echo str_replace( '%7E', '~', $_SERVER['REQUEST_URI']); ?>" style="padding: 0px 20px;">
				<h3><?php _e('Upload Photo', 'flickr-manager'); ?></h3>
				
				<p class="submit" style="text-align: left;">
					<label><?php _e('Upload Photo', 'flickr-manager'); ?>:
						<input type="file" name="uploadPhoto" id="uploadPhoto" />
					</label>
					<input type="submit" name="Submit" value="<?php _e('Upload &raquo;', 'flickr-manager') ?>" />
					<input type="hidden" name="action" value="upload" />
				</p>
			</form>
			
			<div style="padding: 0px 20px;">
				
				<?php
				switch($_REQUEST['action']) {
					case 'edit':
						$params = array('photo_id' => $_REQUEST['pid'], 'auth_token' => $token);
						$photo = $this->call('flickr.photos.getInfo',$params, true);
						?>
						
						<h3><?php _e('Modify Photo', 'flickr-manager'); ?></h3>
						<a href="<?php echo "{$_SERVER['PHP_SELF']}?page={$_REQUEST['page']}"; ?>" ><?php _e('&laquo; Back', 'flickr-manager'); ?></a><br /><br />
						
						<!-- Begin modification of inidividual photo -->
						
						<div align="center">
							<img src="<?php echo $this->getPhotoUrl($photo['photo'],"medium"); ?>" alt="<?php echo $photo['photo']['title']['_content']; ?>" /><br />
							
							<form method="post" action="<?php echo str_replace( '%7E', '~', $_SERVER['REQUEST_URI']); ?>" style="width: 650px;">
								<table>
									<tr>
										<td width="130px"><label for="ftitle"><?php _e('Title', 'flickr-manager'); ?>:</label></td>
										<td><input type="text" name="ftitle" id="ftitle" value="<?php echo $photo['photo']['title']['_content']; ?>" style="width:300px;" /></td>
									</tr>
									<tr>
										<td><?php _e('Permissions', 'flickr-manager'); ?>:</td>
										<td>
										<label><input name="public" type="checkbox" id="public" value="1" <?php if($photo['photo']['visibility']['ispublic'] == '1') echo 'checked="checked" '; ?>/> <?php _e('Public', 'flickr-manager'); ?></label>
										<label><input name="friend" type="checkbox" id="friend" value="1" <?php if($photo['photo']['visibility']['isfriend'] == '1') echo 'checked="checked" '; ?>/> <?php _e('Friends', 'flickr-manager'); ?></label>
										<label><input name="family" type="checkbox" id="family" value="1" <?php if($photo['photo']['visibility']['isfamily'] == '1') echo 'checked="checked" '; ?>/> <?php _e('Family', 'flickr-manager'); ?></label>
										</td>
									</tr>
									<tr>
										<td><label for="tags"><?php _e('Tags', 'flickr-manager'); ?>:</label></td>
										<td><input type="text" name="tags" id="tags" value="<?php 
										foreach($photo['photo']['tags']['tag'] as $tag) {
											echo "{$tag['raw']} ";
										}
										?>" style="width:500px;" /></td>
									</tr>
									<tr>
										<td valign="top"><label for="description"><?php _e('Description', 'flickr-manager'); ?>:</label></td>
										<td><textarea name="description" id="description" style="width:500px; height:100px;"><?php echo $photo['photo']['description']['_content']; ?></textarea></td>
									</tr>
								</table>
								<input type="hidden" name="action" value="modify" />
								<input type="hidden" name="pid" value="<?php echo $_REQUEST['pid']; ?>" />
								<input type="submit" name="submit" value="Submit" />
								<input type="reset" name="reset" value="Reset" />
							</form>
						</div>
						
						<?php
						break;
						
					default:
						$page = (isset($_REQUEST['fpage'])) ? $_REQUEST['fpage'] : '1';
						$per_page = (isset($_REQUEST['fper_page'])) ? $_REQUEST['fper_page'] : '10';
						$nsid = $flickr_settings->getSetting('nsid');
						$params = array('user_id' => $nsid, 'per_page' => $per_page, 'page' => $page, 'auth_token' => $token);
						$photos = $this->call('flickr.photos.search', $params, true);
						$pages = $photos['photos']['pages'];
						?>
						
						<h3><?php _e('Manage Photos', 'flickr-manager'); ?>:</h3>
						<p><b><?php _e('Add images to your posts with', 'flickr-manager'); ?> [flickr pid="&lt;photo-id&gt;" size="&lt;size&gt;"]</b></p>
						<!-- Default management section -->
						
						<div style="text-align: center;">
						<table style="margin-left: auto; margin-right: auto;" class="widefat">
							<thead>
								<tr>
									<th width="130px" style="text-align: center;">ID</th>
									<th width="100px" style="text-align: center;"><?php _e('Thumbnail', 'flickr-manager'); ?></th>
									<th width="200px" style="text-align: center;"><?php _e('Title', 'flickr-manager'); ?></th>
									<th width="170px" style="text-align: center;"><?php _e('Action', 'flickr-manager'); ?></th>
								</tr>
							</thead>
							
							<tbody id="the-list">
							
							<?php 
							$count = 0;
							foreach ($photos['photos']['photo'] as $photo) : 
								$count++;
							?>
							
							<tr <?php if($count % 2 > 0) echo "class='alternate'"; ?>>
								<td align="center"><?php echo $photo['id']; ?></td>
								<td align="center"><img src="<?php echo $this->getPhotoUrl($photo,"square"); ?>" alt="<?php echo $photo['title']; ?>" /></td>
								<td align="center"><?php echo $photo['title']; ?></td>
								<td align="center"><a href="http://www.flickr.com/photos/<?php echo "$nsid/{$photo['id']}/"; ?>" target="_blank"><?php _e('View', 'flickr-manager'); ?></a> / 
								<a href="<?php echo "{$_SERVER['PHP_SELF']}?page={$_REQUEST['page']}&amp;action=edit&amp;pid={$photo['id']}"; ?>"><?php _e('Modify', 'flickr-manager'); ?></a> / 
								<a href="<?php echo "{$_SERVER['PHP_SELF']}?page={$_REQUEST['page']}&amp;action=delete&amp;pid={$photo['id']}"; ?>" onclick="return confirm('<?php _e('Are you sure you want to delete this?', 'flickr-manager'); ?>');"><?php _e('Delete', 'flickr-manager'); ?></a>
								</td>
							</tr>
							
							<?php endforeach; ?>
							
							</tbody>
							
						</table>
						
						<?php if (intval($page) > 1) : ?>
				
							<a href="<?php echo "{$_SERVER['PHP_SELF']}?page={$_REQUEST['page']}&amp;fpage=".(intval($page) - 1)."&amp;fper_page=$per_page"; ?>"><?php _e('&laquo; Previous', 'flickr-manager'); ?></a>
							
						<?php endif; ?>
						
						<?php for($i=1; $i<=$pages; $i++) : ?>
							
							<?php if($i != intval($page)) : ?>
							
							<a href="<?php echo "{$_SERVER['PHP_SELF']}?page={$_REQUEST['page']}&amp;fpage=$i&amp;fper_page=$per_page"; ?>"><?php echo $i; ?></a>
							
							<?php else : 
								echo "<b>$i</b>";
								
							endif; ?>
							
						<?php endfor; ?>
						
						<?php if (intval($page) < $pages) : ?>
						
							<a href="<?php echo "{$_SERVER['PHP_SELF']}?page={$_REQUEST['page']}&amp;fpage=".(intval($page) + 1)."&amp;fper_page=$per_page"; ?>"><?php _e('Next &raquo;', 'flickr-manager'); ?></a>
							
						<?php endif; ?>
						
						</div>
						
						<?php
						break;
				}
				?>
			</div>
			
		</div>
		
		<?php
	}
	
	
	
	function image_shortcode($attr) {
		global $flickr_settings;
		
		$token = $flickr_settings->getSetting('token');
		$params = array('photo_id' => $attr['pid'], 'auth_token' => $token);
		$photo = $this->call('flickr.photos.getInfo',$params, true);
		$url = $this->getPhotoUrl($photo['photo'], $attr['size']);
		return $flickr_settings->getSetting('before_wrap') . "<a href=\"{$photo['photo']['urls']['url'][0]['_content']}\">
					<img src=\"$url\" alt=\"{$photo['photo']['title']['_content']}\" />
				</a>" . $flickr_settings->getSetting('after_wrap');
	}
	
	
	
	function set_shortcode($attr) {
		global $flickr_settings;
		
		$token = $flickr_settings->getSetting('token');
		$params = array('photoset_id' => $attr['id'], 'auth_token' => $token, 'extras' => 'original_format');
		
		if($flickr_settings->getSetting('privacy_filter') == 'true') $params = array_merge($params, array('privacy_filter' => 1));
		
		$photoset = $this->call('flickr.photosets.getPhotos',$params, true);
		
		$html = '';
		foreach ($photoset['photoset']['photo'] as $photo) {
			$html .= $flickr_settings->getSetting('before_wrap') . "<a href=\"http://www.flickr.com/photos/{$photoset['photoset']['owner']}/{$photo['id']}/\" title=\"{$photo['title']}\" ";
			if($attr['overlay'] == 'true') $html .= "rel=\"flickr-mgr[{$attr['id']}]\" ";
			$html .= "class=\"flickr-image\" >\n";
			$html .= '	<img src="' . $this->getPhotoUrl($photo, $attr['thumbnail']) . "\" alt=\"{$photo['title']}\" ";
			if($attr['overlay'] == 'true') $html .= "class=\"flickr-{$attr['size']}\" ";
			if($attr['size'] == 'original') $html .= 'longdesc="' . $this->getPhotoUrl($photo, 'original') . '" ';
			$html .= "/>\n</a>\n" . $flickr_settings->getSetting('after_wrap');;
		}
		
		return $html;
	}
	
	
	
	function filterContent($content) {
		$content = preg_replace_callback("/\[img\:(\d+),(.+)\]/", array(&$this, 'filterCallback'), $content);
		$content = preg_replace_callback("/\[imgset\:(\d+),(.+),(.+)\]/", array(&$this, 'filterSets'), $content);
		return $content;
	}
	
	
	
	function filterSets($match) {
		return do_shortcode("[flickrset id=\"{$match[1]}\" thumbnail=\"{$match[2]}\" overlay=\"{$match[3]}\" size=\"medium\" ]");
	}
	
	
	
	function filterCallback($match) {
		return do_shortcode("[flickr pid=\"{$match[1]}\" size=\"{$match[2]}\" ]");
	}
	
	
	
	function add_scripts() {
		global $flickr_settings;
		
		$filename = array_shift(explode('?', basename($_SERVER['REQUEST_URI'])));
		if($filename == 'media-upload.php' && strstr($_SERVER['REQUEST_URI'], 'type=flickr')) {
			wp_enqueue_script('wfm-media-panel', $this->getAbsoluteUrl() . '/js/media-panel.php', array('jquery'));
			return;
		} elseif($filename == "post.php" || $filename == "page.php" || $filename == "post-new.php" || $filename == "page-new.php") {
			if(version_compare($wp_version, '2.5') < 0)
				wp_enqueue_script('wfm-legacy-js', $this->getAbsoluteUrl() . '/js/flickr-js.php', array('jquery'));
		}
		
		// Register recent photo's widget
		if(function_exists('register_sidebar_widget'))
			register_sidebar_widget('Recent Flickr Photos', array($this, 'widget_recent_flickr'));
			
		if(function_exists('register_widget_control'))
			register_widget_control ( 'Recent Flickr Photos', array($this, 'widget_recent_flickr_control'));
		
		if(is_admin()) return;
		$image_viewer = $flickr_settings->getSetting('image_viewer');
		$image_viewer = (!empty($image_viewer)) ? $image_viewer : 'lightbox';
		
		switch($image_viewer){
			case 'highslide':	
				wp_enqueue_script('highslide',$this->getAbsoluteUrl(). '/js/highslide.packed.js', array('jquery'));
				wp_enqueue_script('wfm-hs',$this->getAbsoluteUrl(). '/js/wfm-hs.php');			
			break;
			case 'lightbox':		
				wp_enqueue_script('jquery-lightbox',$this->getAbsoluteUrl(). '/js/jquery.lightbox.js', array('jquery'));
				wp_enqueue_script('wfm-lightbox',$this->getAbsoluteUrl(). '/js/wfm-lightbox.php');					
			break;
		}
		$GLOBALS['image_viewer'] = $image_viewer;
	}
	
	
	
	function add_headers() {
		switch($GLOBALS['image_viewer']){
			case 'highslide':
			?>

<!-- WFM INSERT HIGHSLIDE FILES -->
<link rel="stylesheet" href="<?php echo $this->getAbsoluteUrl(); ?>/css/highslide.css" type="text/css" />
<!-- WFM END INSERT -->

			<?php			
			break;
			case 'lightbox':
			?>

<!-- WFM INSERT LIGHTBOX FILES -->
<link rel="stylesheet" href="<?php echo $this->getAbsoluteUrl(); ?>/css/lightbox.css" type="text/css" />
<!-- WFM END INSERT -->

			<?php
			break;
		}
	}
	
	
	
	function getAbsoluteUrl() {
		return get_option('siteurl') . "/wp-content/plugins/" . $this->plugin_directory;
	}
	
	
	
	function add_admin_headers() {
		global $wp_version;
		
		$filename = array_shift(explode('?', basename($_SERVER['REQUEST_URI'])));
		if($filename == 'media-upload.php' && strstr($_SERVER['REQUEST_URI'], 'type=flickr')) {
			wp_admin_css('css/media');
	    	?>
	    	<link rel="stylesheet" href="<?php echo $this->getAbsoluteUrl(); ?>/css/media_panel.css" type="text/css" media="screen" />
			<?php 
			return;
		}
		if($filename != "post.php" && $filename != "page.php" && $filename != "post-new.php" && $filename != "page-new.php") return;
		
		if(version_compare($wp_version, '2.5') > 0) return; 
		?>
		
		<link rel="stylesheet" href="<?php echo $this->getAbsoluteUrl(); ?>/css/admin_style.css" type="text/css" />
		
	<?php
	}
	
	
	
	function add_flickr_panel() {
		global $wp_version;
		
		if(version_compare($wp_version, '2.5') > 0) return;
		?>

		<div class="dbx-box postbox" id="flickr-insert-widget">
		
			<h3 class="dbx-handle">Flickr Manager</h3>
			
			<div id="flickr-content" class="dbx-content inside">
			
				<div id="flickr-menu">
					<a href="#?faction=upload" title="<?php _e('Upload Photo', 'flickr-manager') ?>"><?php _e('Upload Photo', 'flickr-manager') ?></a>
					<a href="#?faction=browse" id="fbrowse-photos" title="<?php _e('Browse Photos', 'flickr-manager') ?>"><?php _e('Browse Photos', 'flickr-manager') ?></a>
					<div id="scope-block">
					<label><input type="radio" name="fscope" id="flickr-personal" value="Personal" checked="checked" onchange="executeLink(document.getElementById('fbrowse-photos'),'flickr-ajax');" /> Personal</label>
					<label><input type="radio" name="fscope" id="flickr-public" value="Public" onchange="executeLink(document.getElementById('fbrowse-photos'),'flickr-ajax');" /> Public</label>
					</div>
					<div style="clear: both; height: 1%;"></div>
				</div>
				<div id="flickr-ajax"></div>
				
			</div>
			
		</div>
		
		<div style="clear: both;">&nbsp;</div>
		
		<?php
	}
	
	
	
	/********************************************************************
	 *********** NEW WORDPRESS 2.5 MEDIA BUTTON IMPLEMENTATION **********
	 ********************************************************************/
	function addMediaButton() {
		global $post_ID, $temp_ID;
		$uploading_iframe_ID = (int) (0 == $post_ID ? $temp_ID : $post_ID);
		$media_upload_iframe_src = "media-upload.php?post_id=$uploading_iframe_ID";

		$flickr_upload_iframe_src = apply_filters('media_flickr_iframe_src', "$media_upload_iframe_src&amp;type=flickr");
		$flickr_title = __('Add Flickr Photo', 'flickr-manager');

		$link_markup = "<a href=\"{$flickr_upload_iframe_src}&amp;tab=flickr&amp;TB_iframe=true&amp;height=500&amp;width=640\" class=\"thickbox\" title=\"$flickr_title\"><img src=\"".$this->getAbsoluteUrl()."/images/flickr-media.gif\" alt=\"$flickr_title\" /></a>\n";

		echo $link_markup;
        
	}
	
	
	
	function wfm_create_iframe() {
		wp_iframe(array($this, 'wfm_media_content'));
	}
	
	
	
	function modifyMediaTab($tabs) {
        return array(
            'flickr' =>  __('My Photos', 'flickr-manager'),
        	'flickr_sets' => __('My Photosets', 'flickr-manager'),
        	'flickr_public' => __('Public Photos', 'flickr-manager'),
        	'flickr_upload' => __('Flickr Upload', 'flickr-manager')
        );
    }
    
    
    
	function wfm_media_content() {
		global $flickr_settings, $tab, $type;
		
		switch($_REQUEST['faction']) {
	   		case 'delete':
	   			if(function_exists('check_admin_referer'))
					check_admin_referer('flickr-manager-panel_delete');
				
	   			$token = $flickr_settings->getSetting('token');
				$params = array('auth_token' => $token, 'photo_id' => $_REQUEST['photo_id']);
				$rsp = $this->post('flickr.photos.delete', $params, true);
				
				$_REQUEST['faction'] = '';
	   		break;
	   	}
	   	
	   	if(strpos($_SERVER['REQUEST_URI'], '&faction') > 0)
	   		$_SERVER['REQUEST_URI'] = substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '&faction'));
		if (strpos($_SERVER['REQUEST_URI'], '&wfm-') > 0)
	   		$_SERVER['REQUEST_URI'] = substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '&wfm-'));
	   	
		add_filter('media_upload_tabs', array(&$this, 'modifyMediaTab'));
		
		media_upload_header(); 
		
	    switch ($tab) {
	    	case 'flickr_upload':
	    		$this->upload_panel();
	    		break;
	    	case 'flickr_public':
	    		$this->public_browse_panel();
	    		break;
	    	case 'flickr_sets':
	    		$this->sets_browse_panel();
	    		break;
	    	default:
	    		$this->personal_browse_panel();
	    		break;
	    }
	    
	}
    
	
	
    function public_browse_panel() {
    	global $type, $tab, $flickr_settings;
    	
    	if(substr($_SERVER['REQUEST_URI'], -1) == '&') 
    		$_SERVER['REQUEST_URI'] = substr($_SERVER['REQUEST_URI'], 0, strlen($_SERVER['REQUEST_URI']) - 1);
    	?>
    	
		<form id="flickr-form" class="media-upload-form type-form validate" action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?>">
			<input type="hidden" id="wfm-ajax-url" value="<?php echo $this->getAbsoluteUrl(); ?>" />
			<?php
			$settings = $flickr_settings->getSettings();
			if(empty($settings['per_page'])) $settings['per_page'] = '5';
			if(empty($settings['lightbox_default'])) $settings['lightbox_default'] = 'medium';
			
			if(!empty($settings['token'])) {
				$params = array('auth_token' => $settings['token']);
				$auth_status = $this->call('flickr.auth.checkToken',$params, true);
				if($auth_status['stat'] != 'ok') {
					echo '<h3>'. __('Error: Please authenticate through ', 'flickr-manager') .'<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3>";
					return;
				}
			} else {
				echo '<h3>'. __('Error: Please authenticate through ', 'flickr-manager') .'<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3>";
				return;
			}
			
			switch($_REQUEST['faction']) :
				case 'info_page':
					?>
					<div id="wfm-close-block" class="right">
						<label><input type="checkbox" name="wfm-close" id="wfm-close" value="true" checked="checked" /> <?php _e('Close on insert', 'flickr-manager'); ?></label>
					</div>
					<h3 id="wfm-media-header">
						<a href="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']) . "&amp;wfm-page={$_REQUEST['wfm-page']}&amp;wfm-filter={$_REQUEST['wfm-filter']}"; ?>" title="<?php _e('Back to Public Photos', 'flickr-manager'); ?>">
							&laquo; <?php _e('Back to Public Photos', 'flickr-manager'); ?>
						</a>
					</h3>
					<?php 
					$this->info_page($_REQUEST['pid']);
				break;
				default:
			?>
			
			<h3 id="wfm-media-header"><?php _e('Public Photos', 'flickr-manager'); ?></h3>
			<div id="wfm-browse-content">
				<?php
				// Load Settings
				$page = (empty($_REQUEST['wfm-page'])) ? '1' : $_REQUEST['wfm-page'];
				
				$params = array('extras'	=> 'license,owner_name,original_format',
								'per_page'	=> $flickr_settings->getSetting('per_page'),
								'page' 		=> $page,
								'media'		=> 'photos');
				
				if(!empty($_REQUEST['wfm-filter'])) $params = array_merge($params,array('text' => $_REQUEST['wfm-filter'], 'sort' => 'relevance'));
				
				$licences = $this->call('flickr.photos.licenses.getInfo',array());
				$licence_search = implode(',', range(1,count($licences['licenses']['license']) - 1));
				
				$params = array_merge($params, array('license' => $licence_search));
				
				$photos = $this->call('flickr.photos.search', $params, true);
				if(is_array($photos['photos']['photo']) && count($photos['photos']['photo']) > 0) : 
			
					// Display Photos
					foreach ($photos['photos']['photo'] as $photo) : 
					?>
					
						<div class="flickr-img <?php if($settings['hide_copyright'] == 'true') echo 'personal'; ?>" id="flickr-<?php echo $photo['id']; ?>">
							
							<a href="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']) . "&amp;wfm-page=$page&amp;wfm-filter={$_REQUEST['wfm-filter']}&amp;faction=info_page&amp;pid={$photo['id']}"; ?>" title="<?php echo 'Insert ' . htmlspecialchars($photo['title']); ?>">
								<img src="<?php echo $this->getPhotoUrl($photo, 'square'); ?>" alt="<?php echo htmlspecialchars($photo['title']); ?>" <?php 
									if($flickr_settings->getSetting('is_pro') == '1') echo 'longdesc="' . $this->getPhotoUrl($photo, 'original') . '"';
								?> />
							</a>
							
							<?php 
							if($settings['hide_copyright'] != 'true') {
								foreach ($licences['licenses']['license'] as $licence) {
									if($licence['id'] == $photo['license']) {
										if($licence['url'] == '') $licence['url'] = "http://www.flickr.com/people/{$photo['owner']}/";
										echo "<br /><small><a href='{$licence['url']}' title='{$licence['name']}' rel='license' id='license-{$photo['id']}' onclick='return false;'><img src='".$this->getAbsoluteUrl()."/images/creative_commons_bw.gif' alt='{$licence['name']}'/></a> by {$photo['ownername']}</small>";
									}
								}
							}
							?>
						</div>
					
					<?php 
					endforeach; 
				
				else : ?>
				
					<div class="error">
						<h3><?php _e('No photos found', 'flickr-manager'); ?></h3>
					</div>
				
				<?php 
				endif; ?>
			</div>
			<div id="wfm-dashboard">
				
				<div id="wfm-navigation" class="right">
					<?php $this->paginate(floatval($page), $photos['photos']['pages']); ?>
				</div>
			
				<input type="text" name="wfm-filter" id="wfm-filter" value="<?php echo $_REQUEST['wfm-filter']; ?>" />
				<input type="submit" class="button" name="button" value="<?php _e('Search', 'flickr-manager'); ?>" id="wfm-filter-submit" />
				
			</div>
			<?php
				break;
			endswitch;
			?>
		</form>
		<?php
    }
	
    
    
    function personal_browse_panel() {
    	global $type, $tab, $flickr_settings;
    	
    	if($_REQUEST['faction'] == 'Save') $_REQUEST['pid'] = $this->save_info();
    	if(substr($_SERVER['REQUEST_URI'], -1) == '&') 
    		$_SERVER['REQUEST_URI'] = substr($_SERVER['REQUEST_URI'], 0, strlen($_SERVER['REQUEST_URI']) - 1);
    	?>
    	
		<form id="flickr-form" name="personal" method="post" class="media-upload-form type-form validate" enctype="multipart/form-data" action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?>">			
			<input type="hidden" id="wfm-ajax-url" value="<?php echo $this->getAbsoluteUrl(); ?>" />
		
			<?php
			$settings = $flickr_settings->getSettings();
			if(empty($settings['per_page'])) $settings['per_page'] = '5';
			
			if(!empty($settings['token'])) {
				$params = array('auth_token' => $settings['token']);
				$auth_status = $this->call('flickr.auth.checkToken',$params, true);
				if($auth_status['stat'] != 'ok') {
					echo '<h3>'. __('Error: Please authenticate through ', 'flickr-manager') .'<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3>";
					return;
				}
			} else {
				echo '<h3>'. __('Error: Please authenticate through ', 'flickr-manager') .'<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3>";
				return;
			}
			
			switch($_REQUEST['faction']) :
				case 'info_page':
					?>
					<div id="wfm-close-block" class="right">
						<label for="wfm-close"><input type="checkbox" name="wfm-close" id="wfm-close" value="true" checked="checked" /> <?php _e('Close on insert', 'flickr-manager'); ?></label>
					</div>
					<h3 id="wfm-media-header">
						<a href="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']) . "&amp;wfm-page={$_REQUEST['wfm-page']}&amp;wfm-filter={$_REQUEST['wfm-filter']}"; ?>" title="<?php _e('Back to My Photos', 'flickr-manager'); ?>">
							&laquo; <?php _e('Back to My Photos', 'flickr-manager'); ?>
						</a>
					</h3>
					<?php 
					$this->info_page($_REQUEST['pid']);
				break;
				default:
			?>
			<h3 id="wfm-media-header"><?php _e('My Photos', 'flickr-manager'); ?></h3>
			
			<div id="wfm-browse-content">
				<?php
				// Load Settings
				$page = (empty($_REQUEST['wfm-page'])) ? '1' : $_REQUEST['wfm-page'];
				
				$params = array('extras'	=> 'license,owner_name,original_format',
								'per_page'	=> $flickr_settings->getSetting('per_page'),
								'page' 		=> $page,
								'media'		=> 'photos',
								'user_id' 	=> $settings['nsid'],
								'auth_token'=> $settings['token'] );
				
				if($settings['privacy_filter'] == 'true') $params = array_merge($params, array('privacy_filter' => 1));
				
				if(!empty($_REQUEST['wfm-filter'])) $params = array_merge($params, array('text' => $_REQUEST['wfm-filter'], 'sort' => 'relevance'));
				
				$photos = $this->call('flickr.photos.search', $params, true);
				
				if(is_array($photos['photos']['photo']) && count($photos['photos']['photo']) > 0) : 
			
					// Display Photos
					foreach ($photos['photos']['photo'] as $photo) : 
					?>
					
						<div class="flickr-img personal" id="flickr-<?php echo $photo['id']; ?>">
							
							<a href="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']) . "&amp;wfm-page=$page&amp;wfm-filter={$_REQUEST['wfm-filter']}&amp;faction=info_page&amp;pid={$photo['id']}"; ?>" title="<?php echo 'Insert ' . htmlspecialchars($photo['title']); ?>">
								<img src="<?php echo $this->getPhotoUrl($photo, 'square'); ?>" alt="<?php echo htmlspecialchars($photo['title']); ?>" <?php 
									if($flickr_settings->getSetting('is_pro') == '1') echo 'longdesc="' . $this->getPhotoUrl($photo, 'original') . '"';
								?> />
							</a>
							
						</div>
					
					<?php 
					endforeach; 
				
				else : ?>
				
					<div class="error">
						<h3><?php _e('No photos found', 'flickr-manager'); ?></h3>
					</div>
				
				<?php 
				endif; ?>
			</div>
			
			<div id="wfm-dashboard">
				
				<div id="wfm-navigation" class="right">
					<?php $this->paginate(floatval($page), $photos['photos']['pages']); ?>
				</div>
			
				<input type="text" name="wfm-filter" id="wfm-filter" value="<?php echo $_REQUEST['wfm-filter']; ?>" />
				<input type="submit" class="button" name="button" value="<?php _e('Search', 'flickr-manager'); ?>" id="wfm-filter-submit" />
				
			</div>
			<?php 
				break;
			endswitch;
			?>
		</form>
		
		<?php 
    }
    
    
    
    function overlay_settings($sizes = false) {
    	global $flickr_settings;
    	?>
    	<div id="wfm-overlay">
						
			<label><input type="checkbox" id="wfm-lightbox" name="wfm-lightbox" value="true" <?php if($flickr_settings->getSetting('lightbox_enable') == "true") echo 'checked="checked"'; ?>/>
			<?php _e('Javascript Viewer', 'flickr-manager'); ?></label>
			<div class="settings">
				<div class="right">
					<label><?php _e('Create Gallery', 'flickr-manager'); ?> <input type="checkbox" name="wfm-insert-set" id="wfm-insert-set" value="true" <?php if($_REQUEST['wfm-insert-set'] == "true") echo 'checked="checked"'; ?> /></label> 
					<label id="wfm-set-name-label"><?php _e('Name', 'flickr-manager'); ?>: <input type="text" name="wfm-set-name" id="wfm-set-name" value="<?php echo $_REQUEST['wfm-set-name']; ?>" style="padding: 2px;" /></label>
				</div>
				<label> <?php _e('Size', 'flickr-manager'); ?>: <select name="wfm-lbsize" id="wfm-lbsize">
				<?php
				if(!$sizes || empty($sizes)) {
					$lightbox_sizes = array("small" => __('Small', 'flickr-manager'), 
											"medium" => __('Medium', 'flickr-manager'), 
											"large" => __('Large', 'flickr-manager'));
					
					if($flickr_settings->getSetting('is_pro') == '1') 
						$lightbox_sizes = array_merge($lightbox_sizes, array('original' => __("Original", 'flickr-manager')));
				} else {
					$lightbox_sizes = array();
					foreach($sizes as $size)
						$lightbox_sizes = array_merge($lightbox_sizes, array(strtolower($size) => ucfirst($size)));
				}
				
				foreach ($lightbox_sizes as $k => $size) {
					echo "<option value=\"$k\"";
					if($flickr_settings->getSetting('lightbox_default') == $k) echo ' selected="selected" ';
					echo ">" . ucfirst($size) . "</option>\n";
				}
				?>
				</select></label>
			</div>
		
		</div>
		<?php 
    }
    
    
    
    function upload_panel() {
    	global $flickr_settings, $userdata;
    	
    	$pid = $this->save_info();
    	$token = $flickr_settings->getSetting('token');
		if(isset($_FILES['uploadPhoto'])) {
			if(function_exists('check_admin_referer'))
				check_admin_referer('flickr-manager-panel_upload');
			
			/* Perform file upload */
			$file = $_FILES['uploadPhoto'];
			if($file['error'] == 0) {
				
				$params = array('auth_token' => $token, 'photo' => '@'.$file['tmp_name']);
				if(isset($_POST['photoTitle']) && !empty($_POST['photoTitle'])) $params = array_merge($params,array('title' => $_POST['photoTitle']));
				if(isset($_POST['photoTags']) && !empty($_POST['photoTags'])) $params = array_merge($params,array('tags' => $_POST['photoTags']));
				if(isset($_POST['photoDesc']) && !empty($_POST['photoDesc'])) $params = array_merge($params,array('description' => $_POST['photoDesc']));
				$rsp = $this->upload($params);
				
			}
		}
		?>
		
		<form id="flickr-form" method="post" class="media-upload-form type-form validate" enctype="multipart/form-data" action="<?php echo $_SERVER['REQUEST_URI']; ?>">
			<?php 
   			if(!empty($rsp)) {
				preg_match('/stat="(.+)"/', $rsp, $stat);
				if(isset($stat[1]) && $stat[1] == 'ok') {
					preg_match('/<photoid>(\d+)<\/photoid>/', $rsp, $pid);
					$pid = floatval($pid[1]);
					?>
					
					<div id="upload-success" class="updated fade">
						<p><?php _e('Image successfully uploaded', 'flickr-manager'); ?>!</p>
					</div>
					
					<?php 
				} elseif(isset($stat[1]) && $stat[1] == 'fail') {
					preg_match('/code="(\d+)" msg="(.+)"/', $rsp, $err);
					echo '<div class="error" id="upload-error">';
					_e('An error occurred while trying to upload your photo', 'flickr-manager');
					echo ':<p>' . $err[1] . ': ' . $err[2] . '</p></div>';
				} else {
					echo '<div class="error" id="upload-error">';
					echo htmlspecialchars($rsp);
					echo '</div>';
				}
			}
			?>
			
			<h3 id="wfm-media-header"><?php _e('Upload Photo', 'flickr-manager'); ?></h3>
	    	
	    	<?php
			if(!empty($token)) {
				$params = array('auth_token' => $token);
				$auth_status = $this->call('flickr.auth.checkToken',$params, true);
				if($auth_status['stat'] != 'ok') {
					echo '<h3>' . __('Error: Please authenticate through ', 'flickr-manager') . '<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3>";
					return;
				}
			} else {
				echo '<h3>' . __('Error: Please authenticate through ', 'flickr-manager') . '<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3>";
				return;
			}
			
			get_currentuserinfo();
			$upload_level = $flickr_settings->getSetting('upload_level');
			if(intval($userdata->user_level) < intval($upload_level)) {
				_e('You do not have permission to upload photos to this stream, you may adjust this in the settings page!', 'flickr-manager');
				return;
			}
			
			if($_REQUEST['faction'] == 'info_page' && empty($pid)) $_REQUEST['faction'] = '';
			
			switch($_REQUEST['faction']) :
				case 'info_page':
					
					$this->info_page($pid);
					
				break;
				default:
					if ( function_exists('wp_nonce_field') )
						wp_nonce_field('flickr-manager-panel_upload');
			?>
			
			<table id="wfm-upload-table">
				<tbody>
					<tr>
						<th scope="row">
							<label for="uploadPhoto"><?php _e('Photo', 'flickr-manager'); ?>:</label>
						</th>
						<td>
							<div class="fileInputWidth">
								<input type="file" name="uploadPhoto" class="input" id="uploadPhoto" size="37" />
							</div>
						</td>
					</tr>
					<tr>
						<th scope="row"><label for="photoTitle"><?php _e('Title', 'flickr-manager'); ?>:</label></th>
						<td><input type="text" class="input" name="photoTitle" id="flickrTitle" /></td>
					</tr>
					<tr>
						<th scope="row"><label for="photoTags"><?php _e('Tags', 'flickr-manager'); ?>:</label></th>
						<td><input type="text" class="input" name="photoTags" id="flickrTags" /> <sup>*<?php _e('Space separated list', 'flickr-manager'); ?></sup></td>
					</tr>
					<tr>
						<th scope="row"><label for="photoDesc"><?php _e('Description', 'flickr-manager'); ?>:</label></th>
						<td><textarea name="photoDesc" class="input" id="flickrDesc" rows="4"></textarea></td>
					</tr>
				</tbody>
			</table>
			<p class="submit" style="text-align:right">
				<input type="submit" name="Submit" class="button submit" value="<?php _e('Upload &raquo;', 'flickr-manager'); ?>" onclick="cancelAction = false;" />
				<input type="hidden" name="faction" id="flickr-action" value="info_page" />
			</p>
			
		</form>
		
		<?php 
			break;
		endswitch;
    }
    
    
    
    function info_page($photo_id) {
    	global $flickr_settings;
		$settings = $flickr_settings->getSettings();
    	$photo = $this->call('flickr.photos.getInfo', array('photo_id' => $photo_id, 'auth_token' => $settings['token']), true);
    	
    	if ( function_exists('wp_nonce_field') )
			wp_nonce_field('flickr-manager-panel_info');
    	?>
		
		<input type="hidden" name="wfm-page" value="<?php echo $_REQUEST['wfm-page']; ?>" />
		<input type="hidden" name="wfm-filter" value="<?php echo $_REQUEST['wfm-filter']; ?>" />
		<input type="hidden" name="wfm-photoset" value="<?php echo $_REQUEST['wfm-photoset']; ?>" />
    	<input type="hidden" name="wfm-auth_token" id="wfm-auth_token" value="<?php echo $settings['token']; ?>" />
		<input type="hidden" name="wfm-blank" id="wfm-blank" value="<?php echo $settings['new_window']; ?>" />
		<input type="hidden" name="wfm-insert-before" id="wfm-insert-before" value="<?php 
			$settings['before_wrap'] = str_replace("\n", "", $settings['before_wrap']);
			echo rawurlencode(stripslashes($settings['before_wrap']));
		?>" />
		<input type="hidden" name="wfm-insert-after" id="wfm-insert-after" value="<?php 
			$settings['after_wrap'] = str_replace("\n", "", $settings['after_wrap']);
			echo rawurlencode(stripslashes($settings['after_wrap']));
		?>" />
		<table class="describe">
			<thead class="media-item-info">
				<tr>
					<td class="A1B1" rowspan="4">
						<img src="<?php echo $this->getPhotoUrl($photo['photo'], 'thumbnail'); ?>" alt="<?php echo htmlspecialchars($photo['photo']['title']['_content']); ?>" />
					</td>
					<td>
						<?php echo basename($this->getPhotoUrl($photo['photo'], 'medium')); ?>
					</td>
				</tr>
				<tr>
					<td>
						image/jpg
					</td>
				</tr>
				<tr>
					<td>
						<?php echo htmlspecialchars(date('Y-m-d H:i:s', intval($photo['photo']['dateuploaded']))); ?>
					</td>
				</tr>
				<tr><td></td></tr>
			</thead>
			<tbody>
				<tr class="post_title form-required">
					<th class="label" valign="top" scope="row">
						<label for="flickr-title">
							<span class="alignleft"><?php _e('Title', 'flickr-manager'); ?></span>
							<span class="alignright">
								<abbr class="required" title="required">*</abbr>
							</span>
							<br class="clear"/>
						</label>
					</th>
					<td class="field">
						<input id="flickr-title" type="text" value="<?php echo htmlspecialchars($photo['photo']['title']['_content']); ?>" name="flickr-title" />
					</td>
				</tr>
				<tr class="post_tags">
					<th class="label" valign="top" scope="row">
						<label for="flickr-tags">
							<?php _e('Tags', 'flickr-manager'); ?>
						</label>
					</th>
					<td class="field">
						<input type="text" id="flickr-tags" name="flickr-tags" value="<?php 
						foreach($photo['photo']['tags']['tag'] as $tag) {
							echo "{$tag['raw']} ";
						}
						?>" />
						<p class="help">*<?php _e('Space separated list', 'flickr-manager'); ?></p>
					</td>
				</tr>
				<tr class="post_content">
					<th class="label" valign="top" scope="row">
						<label for="flickr-description">
							<?php _e('Description', 'flickr-manager'); ?>
						</label>
					</th>
					<td class="field">
						<textarea id="flickr-description" name="flickr-description" rows="" cols=""><?php 
							echo htmlspecialchars(trim($photo['photo']['description']['_content'])); 
						?></textarea>
					</td>
				</tr>
				<tr class="url">
					<th class="label" valign="top" scope="row">
						<label for="flickr-link">
							<?php _e('Link URL', 'flickr-manager'); ?>
						</label>
					</th>
					<td class="field">
						<?php echo htmlspecialchars($photo['photo']['urls']['url'][0]['_content']); ?>
						<input type="hidden" name="flickr-link" id="flickr-link" value="<?php 
							echo htmlspecialchars($photo['photo']['urls']['url'][0]['_content']); 
						?>" />
					</td>
				</tr>
				<?php if($photo['photo']['owner']['nsid'] != $settings['nsid']) : ?>
				<tr class="license">
					<th class="label" valign="top" scope="row">
						<label for="licence">
							<?php _e('License', 'flickr-manager'); ?>
						</label>
					</th>
					<td class="field">
						<?php 
						$licences = $this->call('flickr.photos.licenses.getInfo',array());
						foreach ($licences['licenses']['license'] as $licence) {
							if($licence['id'] == $photo['photo']['license']) {
								echo '<a href="' . $licence['url'] . '" id="licence">' . $licence['name'] . '</a> by ' . htmlspecialchars($photo['photo']['owner']['username']);
							}
						}
						?>
						<input type="hidden" id="owner" value="<?php echo $photo['photo']['owner']['nsid'] . "|". htmlspecialchars($photo['photo']['owner']['username']); ?>" />
					</td>
				</tr>
				<?php endif; ?>
				<tr class="align">
					<th class="label" valign="top" scope="row">
						<label for="flickr-align-none">
							<?php _e('Alignment', 'flickr-manager'); ?>
						</label>
					</th>
					<td class="field">
						<input id="flickr-align-none" type="radio" checked="checked" value="none" name="flickr-align" />
						<label class="align image-align-none-label" for="flickr-align-none"><?php _e('None', 'flickr-manager'); ?></label>
						<input id="flickr-align-left" type="radio" value="left" name="flickr-align" />
						<label class="align image-align-left-label" for="flickr-align-left"><?php _e('Left', 'flickr-manager'); ?></label>
						<input id="flickr-align-center" type="radio" value="center" name="flickr-align" />
						<label class="align image-align-center-label" for="flickr-align-center"><?php _e('Center', 'flickr-manager'); ?></label>
						<input id="flickr-align-right" type="radio" value="right" name="flickr-align" />
						<label class="align image-align-right-label" for="flickr-align-right"><?php _e('Right', 'flickr-manager'); ?></label>
					</td>
				</tr>
				<tr class="image-size">
					<th class="label" valign="top" scope="row">
						<label for="image-size-thumbnail" style="margin: 0;">
							<?php _e('Size', 'flickr-manager'); ?>
						</label>
					</th>
					<td class="field">
						<?php 
						$token = $flickr_settings->getSetting('token');
						$params = array('auth_token' => $token, 'photo_id' => $photo_id);
						$sizes = $this->call('flickr.photos.getSizes', $params, true);
						
						$lightbox_sizes = array();
						foreach($sizes['sizes']['size'] as $size) :
							if($size['label'] != "Square" && $size['label'] != "Thumbnail")
								array_push($lightbox_sizes, $size['label']);
						?>
						
						<div class="image-size-item">
							<input id="image-size-<?php echo strtolower($size['label']); ?>" type="radio" value="<?php echo strtolower($size['label']); ?>" name="flickr-size" <?php if(strtolower($size['label']) == 'thumbnail') echo 'checked="checked"'; ?> />
							<label for="image-size-<?php echo strtolower($size['label']); ?>"><?php echo $size['label']; ?></label>
							<label class="help" for="image-size-<?php echo strtolower($size['label']); ?>">(<?php echo $size['width']; ?> &times; <?php echo $size['height']; ?>)</label>
							<input type="hidden" id="<?php echo strtolower($size['label']); ?>-url" name="<?php echo strtolower($size['label']); ?>-url" value="<?php echo $this->getPhotoUrl($photo['photo'], $size['label']); ?>" />
						</div>
						
						<?php endforeach; ?>
					</td>
				</tr>
				<tr class="submit">
					<td></td>
					<td class="savesend">
						<input type="hidden" value="<?php echo $photo_id; ?>" name="photo_id" />
						<input class="button" type="submit" value="<?php _e('Insert into Post', 'flickr-manager'); ?>" name="send" id="flickr-insert" />
						<?php if($photo['photo']['owner']['nsid'] == $settings['nsid']) : ?>
						<input class="button" type="submit" value="<?php _e('Save', 'flickr-manager'); ?>" name="save" id="flickr-save" />
						<input type="hidden" value="Save" name="faction" />
						<?php 
						$link = "{$_SERVER['REQUEST_URI']}&faction=delete&photo_id=$photo_id";
						$link = ( function_exists('wp_nonce_url') ) ? wp_nonce_url($link, 'flickr-manager-panel_delete') : $link;
						?>
						<a class="del-link" id="flickr-delete" onclick="return confirm('<?php _e('Are you sure you want to delete this?', 'flickr-manager'); ?>');" href="<?php echo $link; ?>"><?php _e('Delete', 'flickr-manager'); ?></a>
						<?php endif; ?>
					</td>
				</tr>
			</tbody>
		</table>
		
		<div id="wfm-options">
			<?php $this->overlay_settings($lightbox_sizes); ?>
		</div>
		<?php 	
    }
    
    
    
    function insert_set($photoset_id) {
    	global $flickr_settings;
		$settings = $flickr_settings->getSettings();
    	$photoset = $this->call('flickr.photosets.getInfo', array('photoset_id' => $photoset_id, 'auth_token' => $settings['token']), true);
    	?> 
    	
		<input type="hidden" name="wfm-photoset" id="wfm-photoset" value="<?php echo $photoset_id; ?>" />
    	<input type="hidden" name="wfm-auth_token" id="wfm-auth_token" value="<?php echo $settings['token']; ?>" />
		<input type="hidden" name="wfm-blank" id="wfm-blank" value="<?php echo $settings['new_window']; ?>" />
		<input type="hidden" name="wfm-insert-before" id="wfm-insert-before" value="<?php 
			$settings['before_wrap'] = str_replace("\n", "", $settings['before_wrap']);
			echo rawurlencode(stripslashes($settings['before_wrap']));
		?>" />
		<input type="hidden" name="wfm-insert-after" id="wfm-insert-after" value="<?php 
			$settings['after_wrap'] = str_replace("\n", "", $settings['after_wrap']);
			echo rawurlencode(stripslashes($settings['after_wrap']));
		?>" />
		<table class="describe">
			<thead class="media-item-info">
				<tr>
					<td class="A1B1" style="text-align: center;" colspan="2">
						<?php 
						$params = array('photoset_id'	 => $_REQUEST['wfm-photoset'],
										'extras'		 => 'original_format,date_upload,owner_name',
										'per_page'		 => 6,
										'page'			 => 1);
						
						if($settings['privacy_filter'] == 'true') $params = array_merge($params, array('privacy_filter' => 1));
						
						$photos = $this->call('flickr.photosets.getPhotos', $params, true);
						$photos['photos'] = $photos['photoset'];
						unset($photos['photoset']);
						foreach($photos['photos']['photo'] as $photo) :
						?>
						<img src="<?php echo $this->getPhotoUrl($photo, 'square'); ?>" alt="<?php echo htmlspecialchars($photo['title']); ?>" <?php 
							if($flickr_settings->getSetting('is_pro') == '1') echo 'longdesc="' . $this->getPhotoUrl($photo, 'original') . '"';
						?> />
						<?php endforeach; ?>
					</td>
				</tr>
			</thead>
			<tbody>
				<tr class="image-title">
					<th class="label" valign="top" scope="row">
						<label><?php _e('Title', 'flickr-manager'); ?></label>
					</th>
					<td class="field">
						<?php echo htmlspecialchars($photoset['photoset']['title']['_content']); ?>
					</td>
				</tr>
				<tr class="image-description">
					<th class="label" valign="top" scope="row">
						<label><?php _e('Description', 'flickr-manager'); ?></label>
					</th>
					<td class="field">
						<?php echo htmlspecialchars($photoset['photoset']['description']['_content']); ?>
					</td>
				</tr>
				<tr class="image-size">
					<th class="label" valign="top" scope="row">
						<label for="image-size-thumbnail" style="margin: 0;">
							<?php _e('Size', 'flickr-manager'); ?>
						</label>
					</th>
					<td class="field">
						<?php 
						$sizes = array( 'square' => __('Square', 'flickr-manager'),
										'thumbnail' => __('Thumbnail', 'flickr-manager'), 
										'small' => __('Small', 'flickr-manager'), 
										'medium' => __('Medium', 'flickr-manager'), 
										'large' => __('Large', 'flickr-manager'));
				
						if($flickr_settings->getSetting('is_pro') == '1') 
							$sizes = array_merge($sizes, array('original' => __('Original', 'flickr-manager')));
				
						
						foreach($sizes as $k => $size) :
						?>
						
						<div class="image-size-item">
							<input id="image-size-<?php echo $k; ?>" type="radio" value="<?php echo $k; ?>" name="flickr-size" <?php if($k == 'thumbnail') echo 'checked="checked"'; ?> />
							<label for="image-size-<?php echo $k; ?>"><?php echo $size; ?></label>
							<label class="help" for="image-size-<?php echo $k; ?>"><br />&nbsp;</label>
						</div>
						
						<?php endforeach; ?>
					</td>
				</tr>
				<tr class="submit">
					<td></td>
					<td class="savesend">
						<input class="button" type="button" value="<?php _e('Insert into Post', 'flickr-manager'); ?>" name="send" id="flickr-insert" onclick="insertSet();" />
					</td>
				</tr>
			</tbody>
		</table>
		
    	<div id="wfm-options">
			<?php $this->overlay_settings(); ?>
		</div>
    	<?php 
    }
    
    
    
	function save_info() {
		if($_REQUEST['faction'] != 'Save' || empty($_REQUEST['photo_id'])) return 0;
		
		if(function_exists('check_admin_referer'))
			check_admin_referer('flickr-manager-panel_info');
		
		global $flickr_settings;
		$token = $flickr_settings->getSetting('token');
		
		$params = array('photo_id' => $_REQUEST['photo_id'], 
						'title' => stripcslashes($_REQUEST['flickr-title']),
						'description' => stripcslashes($_REQUEST['flickr-description']),
						'auth_token' => $token);
		
		$rsp = $this->post('flickr.photos.setMeta', $params, true);
		
		$params = array('photo_id' => $_REQUEST['photo_id'], 
						'tags' => $_REQUEST['flickr-tags'],
						'auth_token' => $token);
		
		$this->post('flickr.photos.setTags', $params, true);
		
		$_REQUEST['faction'] = 'info_page';
		return $_REQUEST['photo_id'];
	}
    
	
	
    function paginate($page, $pages) {
    	if($page > 1) 
			echo "<a href=\"#?wfm-page=". ($page - 1) ."\">" . __('&laquo; Previous', 'flickr-manager') . "</a> ";
		
 		if($pages > 0) {
			echo '<a href="#?wfm-page=1" class="page ';
			if($page == 1) echo ' current';
			echo '">1</a> ';
		}
			
		if($page < 4 && $pages > 2) {
			echo "<a href=\"#?wfm-page=2\" class=\"page ";
			if($page == 2) echo 'current';
			echo '">2</a> ';
		}
		if($page < 4 && $pages > 3) {
			echo "<a href=\"#?wfm-page=3\" class=\"page ";
			if($page == 3) echo 'current';
			echo '">3</a> ';
			if($page == 3 && $pages > 4) 
				echo "<a href=\"#?wfm-page=4\" class=\"page\">4</a> ";
		} elseif( $page >= 4 ) {
			$linknum = $page - 5;
			if($linknum < 2) $linknum = 2;
			echo "<a href=\"#?wfm-page=$linknum\" class=\"page\">...</a> ";
			$linknum = $page - 1;
			echo "<a href=\"#?wfm-page=$linknum\" class=\"page\">$linknum</a> ";
			if($page < $pages)
				echo "<a href=\"#?wfm-page=$page\" class=\"page current\">$page</a> ";
				
			if($pages > $page + 1) {
				$linknum = $page + 1;
				echo "<a href=\"#?wfm-page=$linknum\" class=\"page\">$linknum</a> ";
			}
		}
		
		if($pages > $page + 2 || $page == 1 && $pages > 4) {
			$linknum = $page + 5;
			if($linknum >= $pages) $linknum = $page + 2;
			echo "<a href=\"#?wfm-page=$linknum\" class=\"page\">...</a> ";
		}

		if($pages > 1) {
			echo "<a href=\"#?wfm-page={$pages}\" class=\"page";
			if($page == $pages) echo ' current';
			echo "\">{$pages}</a>";
		}
		
		if($pages > 1 && $page < $pages) {
			$linknum = $page + 1;
			echo " <a href=\"#?wfm-page=$linknum\">" . __('Next &raquo;', 'flickr-manager') . "</a> ";
		}
    }
    
    
    
    function widget_recent_flickr($args) {
    	global $flickr_settings;
    	$settings = $flickr_settings->getSetting('recent_widget');
    	
    	extract($args);
    	echo $before_widget;
    	if(!empty($settings['title'])) {
	    	echo $before_title;
	    	echo '<a href="http://www.flickr.com/photos/' . $flickr_settings->getSetting('nsid') . '/">';
	    	echo '<img src="' . $this->getAbsoluteUrl() . '/images/flickr-media.gif" border="0" alt="Flickr" />';
	    	echo '</a> '; 
	    	echo $settings['title'];
	    	echo $after_title;
    	}
    	
    	$rel = $class = '';
    	if(!empty($settings['viewer']) && $settings['viewer'] != 'disable') {
    		$rel = ' rel="flickr-mgr[recent]" ';
    		$class = " class=\"flickr-{$settings['viewer']}\" ";
    	}
    	
    	$params = array('per_page'	=> $settings['photos'],
    					'user_id'	=> $flickr_settings->getSetting('nsid'),
    					'extras'	=> 'icon_server,original_format');
    	
    	$photos = $this->call('flickr.people.getPublicPhotos', $params);
    	
    	echo '<div style="text-align: center" id="wfm-recent-widget">';
    	
    	foreach ($photos['photos']['photo'] as $photo) {
    		echo "<a href=\"http://www.flickr.com/photos/{$photo['owner']}/{$photo['id']}/\" $rel title=\"" . htmlspecialchars($photo['title']) . '" class="flickr-image">';
    		if($settings['viewer'] == 'original') $class = ' class="flickr-original" longdesc="' . $this->getPhotoUrl($photo, 'original') . '" ';
    		echo '<img src="' . $this->getPhotoUrl($photo, 'square') . '" alt="' . htmlspecialchars($photo['title']) . "\" $class />";
    		echo '</a>';
    	}
    	
    	echo '</div>';
    	
    	echo $after_widget;
    }
    
    
    
    function widget_recent_flickr_control() {
    	global $flickr_settings;
    	
    	$settings = $flickr_settings->getSetting('recent_widget');
    	
    	if(isset($_REQUEST['flickr-title'])) $settings['title'] = $_REQUEST['flickr-title'];
    	elseif(!isset($settings['title'])) $settings['title'] = 'Recent Photos';
    	
    	if(isset($_REQUEST['flickr-photos'])) {
    		$settings['photos'] = $_REQUEST['flickr-photos'];
    		if(!is_numeric($settings['photos'])) $settings['photos'] = 10;
    	} elseif(!isset($settings['photos'])) $settings['photos'] = 10;
    	
    	if(isset($_REQUEST['flickr-viewer'])) $settings['viewer'] = $_REQUEST['flickr-viewer'];
    	elseif(!isset($settings['viewer'])) $settings['viewer'] = 'disable';
    	
    	$flickr_settings->saveSetting('recent_widget', $settings);
    	?>
    	<p>
    		<label for="flickr-title">
    			<?php _e('Title', 'flickr-manager'); ?>:
    			<input id="flickr-title" class="widefat" type="text" value="<?php echo htmlspecialchars($settings['title']); ?>" name="flickr-title" />
    		</label>
    	</p>
    	<p>
    		<label for="flickr-photos">
    			<?php _e('# Photos', 'flickr-manager'); ?>:
    			<input id="flickr-photos" class="widefat" type="text" value="<?php echo htmlspecialchars($settings['photos']); ?>" name="flickr-photos" />
    		</label>
    	</p>
    	<p>
    		<label for="flickr-viewer">
    			<?php _e('Image Viewer', 'flickr-manager'); ?>:
    			<select name="flickr-viewer" class="widefat" id="flickr-viewer">
    				<?php 
    				$options = array( 'disable'	=> __('Disable', 'flickr-manager'),
    								  'small'	=> __('Small', 'flickr-manager'), 
									  'medium'	=> __('Medium', 'flickr-manager'), 
									  'large'	=> __('Large', 'flickr-manager'));
    				
    				if($flickr_settings->getSetting('is_pro') == '1') 
    					$options = array_merge($options, array('original' => __('Original', 'flickr-manager')));
    					
    				foreach ($options as $k => $v) {
    					echo "<option value=\"$k\"";
    					if($settings['viewer'] == $k) echo ' selected="selected"';
    					echo '>' . htmlspecialchars($v) . '</option>';
    				}
    				?>
    			</select>
    			<small><?php _e('This option will determine the image loaded into the Javascript viewer.', 'flickr-manager');?></small>
    		</label>
    	</p>
    	<?php 
    }
    
    
    
    function sets_browse_panel() {
    	global $flickr_settings;
    	
    	if($_REQUEST['faction'] == 'Save') $_REQUEST['pid'] = $this->save_info();
    	if(substr($_SERVER['REQUEST_URI'], -1) == '&') 
    		$_SERVER['REQUEST_URI'] = substr($_SERVER['REQUEST_URI'], 0, strlen($_SERVER['REQUEST_URI']) - 1);
    	
    	$settings = $flickr_settings->getSettings();
    	$photosets = $this->call('flickr.photosets.getList', array('user_id' => $settings['nsid'], 'auth_token' => $settings['token']), true);
    	?>
    	
    	<form id="flickr-form" name="photosets" method="post" class="media-upload-form type-form validate" enctype="multipart/form-data" action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?>">
			<input type="hidden" id="wfm-ajax-url" value="<?php echo $this->getAbsoluteUrl(); ?>" />
			<input type="hidden" id="wfm-filter" name="wfm-filter" value="" />
			
			<?php
			$settings = $flickr_settings->getSettings();
			if(empty($settings['per_page'])) $settings['per_page'] = '5';
			
			if(!empty($settings['token'])) {
				$params = array('auth_token' => $settings['token']);
				$auth_status = $this->call('flickr.auth.checkToken',$params, true);
				if($auth_status['stat'] != 'ok') {
					echo '<h3>'. __('Error: Please authenticate through ', 'flickr-manager') .'<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3>";
					return;
				}
			} else {
				echo '<h3>'. __('Error: Please authenticate through ', 'flickr-manager') .'<a href="'.get_option('siteurl')."/wp-admin/options-general.php?page=$this->plugin_directory/$this->plugin_filename\">Settings->Flickr</a></h3>";
				return;
			}
			
			switch($_REQUEST['faction']) :
				case 'info_page':
					?>
					<div id="wfm-close-block" class="right">
						<label for="wfm-close"><input type="checkbox" name="wfm-close" id="wfm-close" value="true" checked="checked" /> <?php _e('Close on insert', 'flickr-manager'); ?></label>
					</div>
					<h3 id="wfm-media-header">
						<a href="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']) . "&amp;wfm-page={$_REQUEST['wfm-page']}&amp;wfm-photoset={$_REQUEST['wfm-photoset']}"; ?>" title="<?php _e('Back to My Photosets', 'flickr-manager'); ?>">
							&laquo; <?php _e('Back to My Photosets', 'flickr-manager'); ?>
						</a>
					</h3>
					<?php 
					$this->info_page($_REQUEST['pid']);
				break;
				case 'insert_set':
					?>
					<div id="wfm-close-block" class="right">
						<label for="wfm-close"><input type="checkbox" name="wfm-close" id="wfm-close" value="true" checked="checked" /> <?php _e('Close on insert', 'flickr-manager'); ?></label>
					</div>
					<h3 id="wfm-media-header">
						<a href="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']) . "&amp;wfm-page={$_REQUEST['wfm-page']}&amp;wfm-photoset={$_REQUEST['wfm-photoset']}"; ?>" title="<?php _e('Back to My Photosets', 'flickr-manager'); ?>">
							&laquo; <?php _e('Back to My Photosets', 'flickr-manager'); ?>
						</a>
					</h3>
					<?php 
					$this->insert_set($_REQUEST['wfm-photoset']);
				break;
				default:
			?>
			<h3 id="wfm-media-header"><?php _e('My Photosets', 'flickr-manager'); ?></h3>
			
			<div id="wfm-browse-content">
			<?php 
			if(empty($_REQUEST['wfm-photoset'])) $_REQUEST['wfm-photoset'] = $photosets['photosets']['photoset'][0]['id'];
			$page = (empty($_REQUEST['wfm-page'])) ? 1 : $_REQUEST['wfm-page'];
			$params = array('photoset_id'	 => $_REQUEST['wfm-photoset'],
							'extras'		 => 'original_format,date_upload,owner_name',
							'per_page'		 => $settings['per_page'],
							'page'			 => $page);
			
			if($settings['privacy_filter'] == 'true') $params = array_merge($params, array('privacy_filter' => 1));
			
			$photos = $this->call('flickr.photosets.getPhotos', $params, true);
			$photos['photos'] = $photos['photoset'];
			unset($photos['photoset']);
			$owner = $photos['photos']['owner'];
			
			if(is_array($photos['photos']['photo']) && count($photos['photos']['photo']) > 0) : 
				// Display Photos
				foreach ($photos['photos']['photo'] as $photo) : 
					$photo['owner'] = $owner;
			?>
				<div class="flickr-img personal" id="flickr-<?php echo $photo['id']; ?>">
					<a href="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']) . "&amp;wfm-page=$page&amp;wfm-photoset={$_REQUEST['wfm-photoset']}&amp;faction=info_page&amp;pid={$photo['id']}"; ?>" title="<?php echo 'Insert ' . htmlspecialchars($photo['title']); ?>">
						<img src="<?php echo $this->getPhotoUrl($photo, 'square'); ?>" alt="<?php echo htmlspecialchars($photo['title']); ?>" <?php 
							if($flickr_settings->getSetting('is_pro') == '1') echo 'longdesc="' . $this->getPhotoUrl($photo, 'original') . '"';
						?> />
					</a>
				</div>
			<?php 
				endforeach; 
			
			else : ?>
			
				<div class="error">
					<h3><?php _e('No photos found', 'flickr-manager'); ?></h3>
				</div>
			
			<?php 
			endif; ?>
			</div>
			
			<div id="wfm-dashboard">
				
				<div id="wfm-navigation" class="right">
					<?php $this->paginate(floatval($page), $photos['photos']['pages']); ?>
				</div>
				
				<?php if(count($photosets['photosets']['photoset']) > 0) : ?>
				<div id="wfm-set-block">
					<select name="wfm-photoset" id="wfm-photoset">
						<?php foreach ($photosets['photosets']['photoset'] as $photoset) : ?>
						<option value="<?php echo $photoset['id']; ?>" <?php if($_REQUEST['wfm-photoset'] == $photoset['id']) echo 'selected="selected"'; ?>><?php echo htmlspecialchars($photoset['title']['_content']); ?></option>
						<?php endforeach; ?>
					</select> 
					<input class="button" type="submit" value="<?php _e('Insert Set', 'flickr-manager'); ?>" id="addSet" name="addSet" />
				</div>
				
				<input type="hidden" name="faction" value="insert_set" />
				<?php endif; ?>
			</div>
			
			<?php 
				break;
			endswitch;
			?>
		</form>
    	 
    	<?php 
    }
    
}

global $flickr_manager, $flickr_settings;
$flickr_settings = new FlickrSettings();
$flickr_manager = new FlickrManager();
?>
