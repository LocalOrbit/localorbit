<?php
/*
Plugin Name: Google Reader Subscription List
Version: 1
Author: Timothy Broder
Description: Lists a users subscribed Google Reader feeds
*/

/*  Copyright 2009  Timothy Broder (email : timothy.broder@gmail.com)

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


if (!class_exists('GoogleReaderSubList')) {	
	class GoogleReaderSubList {
		
		var $show_list							= 'show-google-reader-sub-list';		//the hook in a page
		var $login 									= '';
		var $pass 									= '';
		var $source 								= 'wordpress-google-reader-sub-list-';		//the source the api sees when logging into Google
		var $service 								= 'reader';			
		var $login_url 							= 'https://www.google.com/accounts/ServiceLoginAuth?service=mail';	//URL to login to google
		var $subscription_list_url 	= 'http://www.google.com/reader/api/0/subscription/list';	//URL that holds a users subscriptions
		
		function GoogleReaderSubList() {
			$options 			= $this->get_admin_options();
			$this->login 	= $options['google_login'];
			$this->pass 	= $options['google_pass'];

			$this->source = $this->source . $this->login;
		}
				
		function show_sub_list() {
			$stop = false;
			if ($this->login == '' || $this->login == null) {
				echo 'Google login not set<br />';
				$stop = true;
			}
			if ($this->pass == '' || $this->pass == null) {
				echo 'Google password not set<br />';
				$stop = true;
			}
			
			//check to see if the zend plugin has been installed and activated
			//http://wordpress.org/extend/plugins/zend-framework/
			if (!(defined('WP_ZEND_FRAMEWORK') && WP_ZEND_FRAMEWORK)) {
				echo 'The <a href="http://wordpress.org/extend/plugins/zend-framework/" target="_blank">Zend Framework Plugin</a> is not active.  Please install and activate it.';
				$stop = true;
			}
			if ($stop) {
				return;
			}
						
			$client = new Zend_Http_Client($this->login_url);
			
			//connect, authenticate, and handshake with Google
			$client->setCookieJar()
				->setMethod(Zend_Http_Client::POST)
				->setParameterPost(array(
					'continue'             => $this->subscription_list_url,
					'service'              => 'reader',
					'niu'                  => 1,
					'hl'                   => 'en',
					'Email'        		  	 => $this->login,
					'Passwd'               => $this->pass,
					'PersistentCookie'     => 'yes',
					'asts'                 => ''
				));
				

			//$error_level = error_reporting();
			//error_reporting(1);
			$response = $client->request('POST');
			$client->setUri($this->subscription_list_url)->setMethod(Zend_Http_Client::GET);
			$response = $client->request()->getBody();
			
			if ($client->request()->getStatus() == 400) {
				?>Unable to login with supplied Google login/password<?
				return;
			}
			
			//error_reporting($error_level);
			
			//got the feed, parse it
			$feed = simplexml_load_string($response);
			
			$hashmap = array();
			
			//organize the feeds by tag			
			foreach ($feed->list->object as $e) {
				$url = $e->string[0]; 
				$title = $e->string[1];
				$cat = $e->list->object->string[1];
				
				//make sure a feed is filed somewhere
				if ($cat == '') {
					$cat = 'unfiled';
				}
				$t = $hashmap["$cat"];

				//a category hasn't been used before
				if ($t == null) {
					$t = array($e);
					$hashmap["$cat"] = $t;
				}
				//category has been used before
				else {
					array_push($t, $e);
					$hashmap["$cat"] = $t;
				}
			}

			//sort the categories
			ksort($hashmap);

			//output
			?>
			<p>Tags: 
				<? 
				$endKey = end(array_keys($hashmap));
				foreach ($hashmap as $cat=>$t) {
					echo "<a href='#$cat'>$cat</a>";
					if ($cat != $endKey) {
						echo ', ';
					}
				}
				?>
			</p><?
			
			foreach ($hashmap as $cat=>$t) {
				echo "<a name='$cat'></a>";
				echo "<b>$cat</b><br/>";				
				foreach ($t as $e) {
					list($feed, $url) = split('feed/', $e->string[0]); 
					$title = $e->string[1];
				
					echo "<a href='$url' target='_blank'>$title</a><br />";
					
				}
				echo '<br />';
			}
		}
		
		function addContent($content) {	
			// Only do this if this is a page and it has the appropriate custom field
			if (is_page()) {
				$cust_field_values = get_post_custom_values($this->show_list);
				if ($cust_field_values != NULL) {
					if (defined('WP_ZEND_FRAMEWORK') && WP_ZEND_FRAMEWORK) {
						require_once 'Zend/Loader.php';
						Zend_Loader::loadClass('Zend_Http_Client');
					}
					$content = $this->show_sub_list();
				}
			}
			return $content;
		}
		
		function init() {
			$this->get_admin_options();
		}		
		
		function get_admin_options() {
			$admin_options = array('google_login' => '',	
				'google_pass' => '',
				'use_accordion' => 'true');
			$options = get_option($this->adminOptionName);
			if (!empty($options)) {
				foreach ($options as $key => $option) {
					$admin_options[$key] = $option;
				}
			}
			update_option($this->admin_optionsName, $admin_options);
			return $admin_options;
		}
		
		function printAdminPage() {
			$options = $this->get_admin_options();
			
			if (isset($_POST['update_greader_sub_list_settings'])) {
				if (isset($_POST['greader_sub_list_login'])) {
					$options['google_login'] = $_POST['greader_sub_list_login'];
				}
				if (isset($_POST['greader_sub_list_pass'])) {
					$options['google_pass'] = $_POST['greader_sub_list_pass'];
				}
				
				update_option($this->admin_optionsName, $options);
				echo '<div class="updated"><p><strong>' .  _e('Settings Updated.', 'GoogleReaderSubList'). '</strong></p></div>';
				
			}
			//$submit = _e('Update Settings', 'GoogleReaderSubList');
			
			echo "<div class='wrap'>
				<form method='post' action='" . $_SERVER['REQUEST_URI'] . "'>
					<h2>Google Reader Subscription List</h2>
					<h3>Google Login</h3>
					<input type='text' name='greader_sub_list_login' value='";
			echo _e(apply_filters('format_to_edit', $options['google_login']), 'GoogleReaderSubList');
			echo "' />
					<h3>Google Password</h3>
					<input type='password' name='greader_sub_list_pass' value='";
			echo _e(apply_filters('format_to_edit', $options['google_pass']), 'GoogleReaderSubList');
			echo "' />
					<div class='submit'>
						<input type='submit' name='update_greader_sub_list_settings' value='";
			echo _e('Update Settings', 'GoogleReaderSubList');
			echo "'/>
					</div>
				</form>
			</div>";
		}
	}
}

if (class_exists('GoogleReaderSubList')) {	
	$greader_sub_list = new GoogleReaderSubList();
}

if (!function_exists('greader_sub_list_ap')) {
	function greader_sub_list_ap() {
		global $greader_sub_list;
		if (!isset($greader_sub_list)) {
			return;
		}
		if (function_exists('add_options_page')) {
			add_options_page('gReader Subscriptions', 'gReader Subscriptions', 9, basename(__FILE__), array(&$greader_sub_list, 'printAdminPage'));
		}
	}	
}

if (isset($greader_sub_list)) {
	add_action('admin_menu', 'greader_sub_list_ap');
	add_action('activate_google-raeder-list/google-reader-list.php', array(&$greader_sub_list, 'init'));	
	add_filter('the_content', array(&$greader_sub_list, 'addContent'), '7');
}