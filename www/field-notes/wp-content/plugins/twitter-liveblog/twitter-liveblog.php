<?php
/*
Plugin Name: Twitter LiveBlog
Plugin URI: http://www.docstrangelove.com/wordpress-plugins/
Description: A liveblogging plugin that lets you liveblog on your Wordpress blog using <a href="http://twitter.com">Twitter</a>. After activating this Plugin you must visit the <a href="options-general.php?page=twitter-liveblog.php">options page</a> and configure settings to enable liveblogging.
Version: 1.1.2
Author: Mashuqur Rahman
Author URI: http://www.docstrangelove.com/about/
*/

/*  Copyright 2009 Mashuqur Rahman  (email : strangelove@docstrangelove.com)

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

    This program is inspired by and benefits from the excellent 
    Tweeter Tools plugin (http://alexking.org/projects/wordpress)
    written by Alex King (http://alexking.org)
*/

define('MASHTLB_API_USER_TIMELINE', 'http://twitter.com/statuses/user_timeline.json');

register_activation_hook( __FILE__, 'mashtlb_install' ); 
add_action('mashtlb_twitter_event', 'mashtlb_update_tweets');

function mashtlb_install() {
	global $wpdb;

	$liveblog_install = new mashtlb_liveblog;

	foreach ($liveblog_install->options as $option) {
		add_option('mashtlb_'.$option, $liveblog_install->$option);
	}
	add_option('aktt_update_hash', '');
	//update_option('mashtlb_last_tweet_created_at', gmt_from_blog_time(time()));
	
	$liveblog_install->init();
	$liveblog_install->schedule_next_event();
}

register_deactivation_hook(__FILE__, 'mashtlb_uninstall');

function mashtlb_uninstall() 
{
	wp_clear_scheduled_hook('mashtlb_twitter_event');
}


function mashtlb_login_test($username, $password) 
{
	require_once(ABSPATH.WPINC.'/class-snoopy.php');
	$snoop = new Snoopy;
	$snoop->agent = 'Twitter LiveBlog http://www.docstrangelove.com/wordpress-plugins/';
	$snoop->user = $username;
	$snoop->pass = $password;
	$snoop->fetch(MASHTLB_API_USER_TIMELINE);
	if (strpos($snoop->response_code, '200')) {
		return ('Login succeeded, youre good to go.');
	} else {
		$json = new Services_JSON();
		$results = $json->decode($snoop->results);
		return sprintf(__('Sorry, login failed. Error message from Twitter: %s', 'twitter-tools'), $results->error);
	}
}

function mashtlb_update_tweets() {

	$liveblog = new mashtlb_liveblog;
	
	if (!$liveblog->start_tweet_processing())
	{
		return;
	}

	require_once(ABSPATH.WPINC.'/class-snoopy.php');
	$snoop = new Snoopy;
	$snoop->agent = 'Twitter LiveBlog http://www.docstrangelove.com/wordpress-plugins/';
	$snoop->user = $liveblog->twitter_username;
	$snoop->pass = $liveblog->twitter_password;
	$snoop->fetch(MASHTLB_API_USER_TIMELINE);

	if (!strpos($snoop->response_code, '200')) 
	{
		$liveblog->end_tweet_processing();
		return;
	}

	$data = $snoop->results;

	if (!$liveblog->is_new_tweets($data))
	{
		$liveblog->end_tweet_processing();
		return;
	}
	
	$json = new Services_JSON();
	$tweets = array_reverse($json->decode($data));
	
	if (is_array($tweets) && count($tweets) > 0) {
		foreach ($tweets as $tw_data) 
		{
			if (empty($tw_data->in_reply_to_status_id)) 
			{
				$tweet = new mashtlb_tweet($tw_data->id, $tw_data->text);
				$tweet->tw_created_at = $tweet->twdate_to_time($tw_data->created_at);

				if($tweet->tw_created_at > $liveblog->last_tweet_created_at)
				{
					if($liveblog->is_liveblogging())
					{

						if(strstr($tweet->tw_text, '//NLB//'))
						{
							$liveblog->end_post($tweet);
							$liveblog->start_new_post($tweet);
						}
						else if(strstr($tweet->tw_text, '//ELB//'))
						{
							$liveblog->end_post($tweet);
						}
						else
						{
							$liveblog->add_tweet($tweet);
						}
				
					}
					else
					{
						if(strstr($tweet->tw_text, '//NLB//'))
						{
							$liveblog->start_new_post($tweet);

						}
					}
				}
			}			
		}

		if($liveblog->is_liveblogging())
		{
			$liveblog->save_post();
		}
	}
	$liveblog->end_tweet_processing();
}


function mashtlb_tweets_check()
{
		print('<br>Testing Testing');

  mashtlb_update_tweets();
  print('<br>Testing Testing');
}

class mashtlb_liveblog
{
	function mashtlb_liveblog()
	{
		$this->options = array
		(
			'twitter_username'
			,'twitter_password'
			,'blog_post_tags'
			,'blog_post_author'
			,'blog_post_category'
			,'twitter_interval'
			,'twitter_liveblog_interval'
			,'time_format'
			,'tweet_prefix'
			,'update_hash'
			,'last_tweet_download'
			,'doing_tweet_download'
			,'liveblog_post_id'
			,'last_tweet_id'
			,'last_tweet_text'
			,'last_tweet_created_at'
		);
		
		$this->twitter_username = '';
		$this->twitter_password = '';
		$this->blog_post_tags = '';	
		$this->blog_post_author = '1';
		$this->blog_post_category = '1';
		$this->twitter_interval = '10';
		$this->twitter_liveblog_interval = '2';
		$this->time_format = 'g:i:s A';
		$this->tweet_prefix = '';
		
		$this->update_hash = '';
		$this->last_tweet_download = '';
		$this->doing_tweet_download = '0';

		$this->liveblog_post_id = '';
		$this->last_tweet_id = '0';
		$this->last_tweet_text = '';
		$this->last_tweet_created_at = '';

		$this->tweet_text = '';
	}

	function init()
	{
		foreach ($this->options as $option) 
		{
			$this->$option = get_option('mashtlb_'.$option);
		}	
	}
	
	function schedule_next_event()
	{
		wp_clear_scheduled_hook('mashtlb_twitter_event');
		wp_schedule_single_event(time()+ $this->tweet_download_interval(), 'mashtlb_twitter_event');
	}
	
	function populate_settings() 
	{
		foreach ($this->options as $option) 
		{
			if (isset($_POST['mashtlb_'.$option])) 
			{
				$this->$option = stripslashes($_POST['mashtlb_'.$option]);
			}
		}
	}
	
	function update_settings() 
	{
		foreach ($this->options as $option) 
		{
			update_option('mashtlb_'.$option, $this->$option);
		}
	}

	function start_new_post($tweet)
	{
		if ($this->last_tweet_created_at < $tweet->tw_created_at)
		{
				
			$this->liveblog_post_id = $this->insert_new_post($this->get_post_title($tweet->tw_text));
			$this->last_tweet_id = $tweet->tw_id;
			$this->last_tweet_text = $tweet->tw_text;
			$this->last_tweet_created_at = $tweet->tw_created_at;

			update_option('mashtlb_liveblog_post_id', $this->liveblog_post_id);
			update_option('mashtlb_last_tweet_id', $this->last_tweet_id);
			update_option('mashtlb_last_tweet_text', $this->last_tweet_text);
			update_option('mashtlb_last_tweet_created_at', $this->last_tweet_created_at);
			
		}
	}
	
	function insert_new_post($title)
	{
		global $wpdb;

		$post_data = array(
			'post_content' => $wpdb->escape(''),
			'post_title' => $wpdb->escape($title),
			'post_category' => array($this->blog_post_category),
			'post_status' => 'draft',
			'post_author' => $wpdb->escape($this->blog_post_author)
		);

		$post_id = wp_insert_post($post_data);
		add_post_meta($post_id, 'aktt_tweeted', '1', true); // to prevent Twitter Tools from notifying Twitter
		wp_set_post_tags($post_id, $this->blog_post_tags);
		wp_publish_post($post_id);
		return $post_id;
	}
	
	function get_post_title($post_title)
	{
		if (strlen($post_title) > 7)
		{
			return trim(substr($post_title, 7));
		}
		
		return $this->default_post_title();
		
	}
	
	function default_post_title()
	{
		return 'Live Blogging';
	}
	
	function end_post($tweet)
	{
		//
		// Write buffered tweets to the post
		//
		$this->save_post();
				
		$this->liveblog_post_id = '';
		$this->last_tweet_id = $tweet->tw_id;
		$this->last_tweet_text = $tweet->tw_text;
		$this->last_tweet_created_at = $tweet->tw_created_at;

		update_option('mashtlb_liveblog_post_id', '');
		update_option('mashtlb_last_tweet_id', $this->last_tweet_id);
		update_option('mashtlb_last_tweet_text', $this->last_tweet_text);
		update_option('mashtlb_last_tweet_created_at', $this->last_tweet_created_at);

	}

	function add_tweet($tweet)
	{
			$this->last_tweet_id = $tweet->tw_id;
			$this->last_tweet_text = $tweet->tw_text;
			$this->last_tweet_created_at = $tweet->tw_created_at;
			update_option('mashtlb_last_tweet_id', $this->last_tweet_id);
			update_option('mashtlb_last_tweet_text', $this->last_tweet_text);
			update_option('mashtlb_last_tweet_created_at', $this->last_tweet_created_at);

			$this->tweet_text = $this->tweet_text.'<br><strong>'.date($this->get_time_format(), blog_time_from_gmt($this->last_tweet_created_at)).'</strong>: '.make_clickable($tweet->tw_text).'<br/>';
	}

	function get_time_format()
	{
		if (strlen($this->time_format) == 0)
		{
			return 'g:i:s A';
		}
		
		return $this->time_format;
	}
	
	function is_liveblogging()
	{
		if (strlen($this->liveblog_post_id) == 0)
		{
			return false;
		}
		
		return true;
	}

	function save_post()
	{
		global $wpdb;
		$post_data = get_post($this->liveblog_post_id); 
		$previous_post_content = $post_data->post_content;
		
		$post_data = array(
			'ID' => $this->liveblog_post_id,
			'post_content' => $wpdb->escape($previous_post_content . $this->tweet_text)
		);
		wp_update_post($post_data);
		
		//
		// Empty the tweet buffer
		//
		$this->tweet_text = '';
	}
	
	function is_new_tweets($data)
	{
		$hash = md5($data);
		if ($hash == $this->update_hash) 
		{
			update_option('mashtlb_last_tweet_download', time());
			update_option('mashtlb_doing_tweet_download', '0');

			return false;
		}

		update_option('mashtlb_update_hash', $hash);
		return true;
	}

	function tweet_download_interval()
	{
		if ($this->is_liveblogging())
		{
			return (intval(get_option('mashtlb_twitter_liveblog_interval'))*60);
		}
		return (intval(get_option('mashtlb_twitter_interval'))*60);
	}

	function start_tweet_processing() 
	{
		$this->init();
		$this->schedule_next_event();
		
		// check to see if username and password have been set
		if (empty($this->twitter_username) || empty($this->twitter_password)) 
		{
			return false;
		}
		
		// let the last update run for interval minutes
		
		if (time() - intval(get_option('mashtlb_doing_tweet_download')) < $this->tweet_download_interval()) 
		{
			return false;
		}
		
		/*
		// wait interval between downloads
		if (time() - intval(get_option('mashtlb_last_tweet_download')) < $this->tweet_download_interval()) 
		{
			return false;
		}
		*/
		
		update_option('mashtlb_doing_tweet_download', time());
		
		return true;
	}

	function end_tweet_processing() 
	{
		update_option('mashtlb_last_tweet_download', time());
		update_option('mashtlb_doing_tweet_download', '0');		
	}
}

function blog_time_from_gmt($gmttime)
{
	return $gmttime + (get_option('gmt_offset') * 3600);
}

function gmt_from_blog_time($blogtime)
{
	return $blogtime - (get_option('gmt_offset') * 3600);
}

class mashtlb_tweet {
	function mashtlb_tweet(
		$tw_id = ''
		, $tw_text = ''
		, $tw_created_at = ''
	) 
      {
		$this->tw_created_at = $tw_created_at;
		$this->tw_text = $tw_text;
		$this->tw_id = $tw_id;
	}
	
	function twdate_to_time($date) {
		$parts = explode(' ', $date);
		$date = strtotime($parts[1].' '.$parts[2].', '.$parts[5].' '.$parts[3]);
		return $date;
	}

}

// Create a option page for settings
add_action('admin_menu', 'add_mashtlb_option_page' );

// Hook in the options page function
function add_mashtlb_option_page() 
{
	global $wpdb;
	add_options_page('Twitter LiveBlog Options', 'Twitter LiveBlog', 8, basename(__FILE__), 'mashtlb_options_page');
}



function mashtlb_options_page() 
{
	$liveblog = new mashtlb_liveblog;
	$liveblog->init();
	
	$updated_text = '';
	
	if ( isset( $_POST['mashtlb_update_settings'] ) ) 
	{
		$liveblog->populate_settings();
		$liveblog->update_settings();
		
		//
		// Set up scheduled event to check for tweets. The first check does not occur until
		// options are saved. Each subsequent event is scheduled during the next twitter check.
		$liveblog->schedule_next_event();
	
		$updated_text = '<div class="updated"><p><strong>Twitter LiveBlog options updated.</strong></p></div>';	
	//	wp_redirect(get_bloginfo('wpurl').'/wp-admin/options-general.php?page=twitter-liveblog.php&updated=true');
	//	die();
	}
	
	$categories = get_categories('hide_empty=0');
	$cat_options = '';
	foreach ($categories as $category) 
	{
		// WP < 2.3 compatibility
		!empty($category->term_id) ? $cat_id = $category->term_id : $cat_id = $category->cat_ID;
		!empty($category->name) ? $cat_name = $category->name : $cat_name = $category->cat_name;
		if ($cat_id == $liveblog->blog_post_category) 
		{
			$selected = 'selected="selected"';
		}
		else 
		{
			$selected = '';
		}
		$cat_options .= "\n\t<option value='$cat_id' $selected>$cat_name</option>";
	}
	
	$authors = get_users_of_blog();
	$author_options = '';
	foreach ($authors as $user) {
		$usero = new WP_User($user->user_id);
		$author = $usero->data;
		// Only list users who are allowed to publish
		if (! $usero->has_cap('publish_posts')) 
		{
			continue;
		}
		if ($author->ID == $liveblog->blog_post_author) 
		{
			$selected = 'selected="selected"';
		}
		else {
			$selected = '';
		}
		$author_options .= "\n\t<option value='$author->ID' $selected>$author->user_nicename</option>";
	}
	
	$twitter_intervals = array('2','5','10','15','30');
	$twitter_interval_options = '';
	foreach ($twitter_intervals as $twitter_interval) {
		if ($twitter_interval == $liveblog->twitter_interval) 
		{
			$selected = 'selected="selected"';
		}
		else {
			$selected = '';
		}
		$twitter_interval_options .= "\n\t<option value='$twitter_interval' $selected>$twitter_interval</option>";
	}
	
	$twitter_liveblog_intervals = array('1','2','3','4','5','10','15','30');
	$twitter_liveblog_interval_options = '';
	foreach ($twitter_liveblog_intervals as $twitter_liveblog_interval) {
		if ($twitter_liveblog_interval == $liveblog->twitter_liveblog_interval) 
		{
			$selected = 'selected="selected"';
		}
		else {
			$selected = '';
		}
		$twitter_liveblog_interval_options .= "\n\t<option value='$twitter_liveblog_interval' $selected>$twitter_liveblog_interval</option>";
	}
		
	print('
			<style type="text/css">
					#mashtlb_twitterliveblog .options {
						overflow: hidden;
						border: none;
					}
					#mashtlb_twitterliveblog .option {
						overflow: hidden;
						border-bottom: solid 1px #ccc;
						padding-bottom: 9px;
						padding-top: 9px;
					}
					#mashtlb_twitterliveblog .option label {
						display: block;
						float: left;
						width: 200px;
						margin-right: 24px;
						text-align: right;
					}
					#mashtlb_twitterliveblog .option span {
						display: block;
						float: left;
						margin-left: 230px;
						margin-top: 6px;
						clear: left;
					}
					#mashtlb_twitterliveblog select,
					#mashtlb_twitterliveblog input {
						float: left;
						display: block;
						margin-right: 6px;
					}
					#mashtlb_twitterliveblog p.submit {
						overflow: hidden;
					}
					#mashtlb_twitterliveblog .option span {
						color: #666;
						display: block;
					}
			</style>
			
			<div class="wrap" id="mashtlb_options_page">
				<h2>'.__('Twitter LiveBlog Options', 'twitter-liveblog').'</h2>
				'.$updated_text.'
				<form id="mashtlb_twitterliveblog" name="mashtlb_twitterliveblog" action="'.get_bloginfo('wpurl').'/wp-admin/options-general.php?page=twitter-liveblog.php" method="post">
					<fieldset class="options">
						<div class="option">
							<label for="mashtlb_twitter_username">'.__('Twitter Username', 'twitter-liveblog').'/'.__('Password', 'twitter-liveblog').'</label>
							<input type="text" size="25" name="mashtlb_twitter_username" id="mashtlb_twitter_username" value="'.$liveblog->twitter_username.'" autocomplete="off" />
							<input type="password" size="25" name="mashtlb_twitter_password" id="mashtlb_twitter_password" value="'.$liveblog->twitter_password.'" autocomplete="off" />
						</div>
	

						<div class="option">
							<label for="mashtlb_blog_post_category">'.__('Category for liveblog posts:', 'twitter-liveblog').'</label>
							<select name="mashtlb_blog_post_category" id="mashtlb_blog_post_category">'.$cat_options.'</select>
						</div>
						<div class="option">
							<label for="mashtlb_blog_post_tags">'.__('Tag(s) for liveblog posts:', 'twitter-liveblog').'</label>
							<input name="mashtlb_blog_post_tags" id="mashtlb_blog_post_tags" value="'.$liveblog->blog_post_tags.'">
							<span>'._('Separate multiple tags with commas.').'</span>
						</div>
						<div class="option">
							<label for="mashtlb_blog_post_author">'.__('Author for liveblog posts:', 'twitter-liveblog').'</label>
							<select name="mashtlb_blog_post_author" id="mashtlb_blog_post_author">'.$author_options.'</select>
						</div>
						<div class="option">
							<label for="mashtlb_twitter_interval">'.__('Check Twitter for new liveblog posts (in minutes):', 'twitter-liveblog').'</label>
							<select name="mashtlb_twitter_interval" id="mashtlb_twitter_interval">'.$twitter_interval_options.'</select>
						</div>
						<div class="option">
							<label for="mashtlb_twitter_liveblog_interval">'.__('Check Twitter during liveblog (in minutes):', 'twitter-liveblog').'</label>
							<select name="mashtlb_twitter_liveblog_interval" id="mashtlb_twitter_liveblog_interval">'.$twitter_liveblog_interval_options.'</select>
						</div>
					</fieldset>
					<p class="submit">
						<input type="submit" name="mashtlb_update_settings" value="Update Options" />
					</p>
				</form>
			</div>
	');
}

if (!class_exists('Services_JSON')) 
{

// PEAR JSON class

/**
* Converts to and from JSON format.
*
* JSON (JavaScript Object Notation) is a lightweight data-interchange
* format. It is easy for humans to read and write. It is easy for machines
* to parse and generate. It is based on a subset of the JavaScript
* Programming Language, Standard ECMA-262 3rd Edition - December 1999.
* This feature can also be found in  Python. JSON is a text format that is
* completely language independent but uses conventions that are familiar
* to programmers of the C-family of languages, including C, C++, C#, Java,
* JavaScript, Perl, TCL, and many others. These properties make JSON an
* ideal data-interchange language.
*
* This package provides a simple encoder and decoder for JSON notation. It
* is intended for use with client-side Javascript applications that make
* use of HTTPRequest to perform server communication functions - data can
* be encoded into JSON notation for use in a client-side javascript, or
* decoded from incoming Javascript requests. JSON format is native to
* Javascript, and can be directly eval()'ed with no further parsing
* overhead
*
* All strings should be in ASCII or UTF-8 format!
*
* LICENSE: Redistribution and use in source and binary forms, with or
* without modification, are permitted provided that the following
* conditions are met: Redistributions of source code must retain the
* above copyright notice, this list of conditions and the following
* disclaimer. Redistributions in binary form must reproduce the above
* copyright notice, this list of conditions and the following disclaimer
* in the documentation and/or other materials provided with the
* distribution.
*
* THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
* NO EVENT SHALL CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
* OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
* TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
* USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
* DAMAGE.
*
* @category
* @package     Services_JSON
* @author      Michal Migurski <mike-json@teczno.com>
* @author      Matt Knapp <mdknapp[at]gmail[dot]com>
* @author      Brett Stimmerman <brettstimmerman[at]gmail[dot]com>
* @copyright   2005 Michal Migurski
* @version     CVS: $Id: JSON.php,v 1.31 2006/06/28 05:54:17 migurski Exp $
* @license     http://www.opensource.org/licenses/bsd-license.php
* @link        http://pear.php.net/pepr/pepr-proposal-show.php?id=198
*/

/**
* Marker constant for Services_JSON::decode(), used to flag stack state
*/
define('SERVICES_JSON_SLICE',   1);

/**
* Marker constant for Services_JSON::decode(), used to flag stack state
*/
define('SERVICES_JSON_IN_STR',  2);

/**
* Marker constant for Services_JSON::decode(), used to flag stack state
*/
define('SERVICES_JSON_IN_ARR',  3);

/**
* Marker constant for Services_JSON::decode(), used to flag stack state
*/
define('SERVICES_JSON_IN_OBJ',  4);

/**
* Marker constant for Services_JSON::decode(), used to flag stack state
*/
define('SERVICES_JSON_IN_CMT', 5);

/**
* Behavior switch for Services_JSON::decode()
*/
define('SERVICES_JSON_LOOSE_TYPE', 16);

/**
* Behavior switch for Services_JSON::decode()
*/
define('SERVICES_JSON_SUPPRESS_ERRORS', 32);

/**
* Converts to and from JSON format.
*
* Brief example of use:
*
* <code>
* // create a new instance of Services_JSON
* $json = new Services_JSON();
*
* // convert a complexe value to JSON notation, and send it to the browser
* $value = array('foo', 'bar', array(1, 2, 'baz'), array(3, array(4)));
* $output = $json->encode($value);
*
* print($output);
* // prints: ["foo","bar",[1,2,"baz"],[3,[4]]]
*
* // accept incoming POST data, assumed to be in JSON notation
* $input = file_get_contents('php://input', 1000000);
* $value = $json->decode($input);
* </code>
*/
class Services_JSON
{
   /**
    * constructs a new JSON instance
    *
    * @param    int     $use    object behavior flags; combine with boolean-OR
    *
    *                           possible values:
    *                           - SERVICES_JSON_LOOSE_TYPE:  loose typing.
    *                                   "{...}" syntax creates associative arrays
    *                                   instead of objects in decode().
    *                           - SERVICES_JSON_SUPPRESS_ERRORS:  error suppression.
    *                                   Values which can't be encoded (e.g. resources)
    *                                   appear as NULL instead of throwing errors.
    *                                   By default, a deeply-nested resource will
    *                                   bubble up with an error, so all return values
    *                                   from encode() should be checked with isError()
    */
    function Services_JSON($use = 0)
    {
        $this->use = $use;
    }

 /**
    * convert a string from one UTF-16 char to one UTF-8 char
    *
    * Normally should be handled by mb_convert_encoding, but
    * provides a slower PHP-only method for installations
    * that lack the multibye string extension.
    *
    * @param    string  $utf16  UTF-16 character
    * @return   string  UTF-8 character
    * @access   private
    */
    function utf162utf8($utf16)
    {
        // oh please oh please oh please oh please oh please
        if(function_exists('mb_convert_encoding')) {
            return mb_convert_encoding($utf16, 'UTF-8', 'UTF-16');
        }

        $bytes = (ord($utf16{0}) << 8) | ord($utf16{1});

        switch(true) {
            case ((0x7F & $bytes) == $bytes):
                // this case should never be reached, because we are in ASCII range
                // see: http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                return chr(0x7F & $bytes);

            case (0x07FF & $bytes) == $bytes:
                // return a 2-byte UTF-8 character
                // see: http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                return chr(0xC0 | (($bytes >> 6) & 0x1F))
                     . chr(0x80 | ($bytes & 0x3F));

            case (0xFFFF & $bytes) == $bytes:
                // return a 3-byte UTF-8 character
                // see: http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                return chr(0xE0 | (($bytes >> 12) & 0x0F))
                     . chr(0x80 | (($bytes >> 6) & 0x3F))
                     . chr(0x80 | ($bytes & 0x3F));
        }

        // ignoring UTF-32 for now, sorry
        return '';
    }

   /**
    * convert a string from one UTF-8 char to one UTF-16 char
    *
    * Normally should be handled by mb_convert_encoding, but
    * provides a slower PHP-only method for installations
    * that lack the multibye string extension.
    *
    * @param    string  $utf8   UTF-8 character
    * @return   string  UTF-16 character
    * @access   private
    */
    function utf82utf16($utf8)
    {
        // oh please oh please oh please oh please oh please
        if(function_exists('mb_convert_encoding')) {
            return mb_convert_encoding($utf8, 'UTF-16', 'UTF-8');
        }

        switch(strlen($utf8)) {
            case 1:
                // this case should never be reached, because we are in ASCII range
                // see: http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                return $utf8;

            case 2:
                // return a UTF-16 character from a 2-byte UTF-8 char
                // see: http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                return chr(0x07 & (ord($utf8{0}) >> 2))
                     . chr((0xC0 & (ord($utf8{0}) << 6))
                         | (0x3F & ord($utf8{1})));

            case 3:
                // return a UTF-16 character from a 3-byte UTF-8 char
                // see: http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                return chr((0xF0 & (ord($utf8{0}) << 4))
                         | (0x0F & (ord($utf8{1}) >> 2)))
                     . chr((0xC0 & (ord($utf8{1}) << 6))
                         | (0x7F & ord($utf8{2})));
        }

        // ignoring UTF-32 for now, sorry
        return '';
    }

   /**
    * encodes an arbitrary variable into JSON format
    *
    * @param    mixed   $var    any number, boolean, string, array, or object to be encoded.
    *                           see argument 1 to Services_JSON() above for array-parsing behavior.
    *                           if var is a strng, note that encode() always expects it
    *                           to be in ASCII or UTF-8 format!
    *
    * @return   mixed   JSON string representation of input var or an error if a problem occurs
    * @access   public
    */
    function encode($var)
    {
        switch (gettype($var)) {
            case 'boolean':
                return $var ? 'true' : 'false';

            case 'NULL':
                return 'null';

            case 'integer':
                return (int) $var;

            case 'double':
            case 'float':
                return (float) $var;

            case 'string':
                // STRINGS ARE EXPECTED TO BE IN ASCII OR UTF-8 FORMAT
                $ascii = '';
                $strlen_var = strlen($var);

               /*
                * Iterate over every character in the string,
                * escaping with a slash or encoding to UTF-8 where necessary
                */
                for ($c = 0; $c < $strlen_var; ++$c) {

                    $ord_var_c = ord($var{$c});

                    switch (true) {
                        case $ord_var_c == 0x08:
                            $ascii .= '\b';
                            break;
                        case $ord_var_c == 0x09:
                            $ascii .= '\t';
                            break;
                        case $ord_var_c == 0x0A:
                            $ascii .= '\n';
                            break;
                        case $ord_var_c == 0x0C:
                            $ascii .= '\f';
                            break;
                        case $ord_var_c == 0x0D:
                            $ascii .= '\r';
                            break;

                        case $ord_var_c == 0x22:
                        case $ord_var_c == 0x2F:
                        case $ord_var_c == 0x5C:
                            // double quote, slash, slosh
                            $ascii .= '\\'.$var{$c};
                            break;

                        case (($ord_var_c >= 0x20) && ($ord_var_c <= 0x7F)):
                            // characters U-00000000 - U-0000007F (same as ASCII)
                            $ascii .= $var{$c};
                            break;

                        case (($ord_var_c & 0xE0) == 0xC0):
                            // characters U-00000080 - U-000007FF, mask 110XXXXX
                            // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                            $char = pack('C*', $ord_var_c, ord($var{$c + 1}));
                            $c += 1;
                            $utf16 = $this->utf82utf16($char);
                            $ascii .= sprintf('\u%04s', bin2hex($utf16));
                            break;

                        case (($ord_var_c & 0xF0) == 0xE0):
                            // characters U-00000800 - U-0000FFFF, mask 1110XXXX
                            // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                            $char = pack('C*', $ord_var_c,
                                         ord($var{$c + 1}),
                                         ord($var{$c + 2}));
                            $c += 2;
                            $utf16 = $this->utf82utf16($char);
                            $ascii .= sprintf('\u%04s', bin2hex($utf16));
                            break;

                        case (($ord_var_c & 0xF8) == 0xF0):
                            // characters U-00010000 - U-001FFFFF, mask 11110XXX
                            // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                            $char = pack('C*', $ord_var_c,
                                         ord($var{$c + 1}),
                                         ord($var{$c + 2}),
                                         ord($var{$c + 3}));
                            $c += 3;
                            $utf16 = $this->utf82utf16($char);
                            $ascii .= sprintf('\u%04s', bin2hex($utf16));
                            break;

                        case (($ord_var_c & 0xFC) == 0xF8):
                            // characters U-00200000 - U-03FFFFFF, mask 111110XX
                            // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                            $char = pack('C*', $ord_var_c,
                                         ord($var{$c + 1}),
                                         ord($var{$c + 2}),
                                         ord($var{$c + 3}),
                                         ord($var{$c + 4}));
                            $c += 4;
                            $utf16 = $this->utf82utf16($char);
                            $ascii .= sprintf('\u%04s', bin2hex($utf16));
                            break;

                        case (($ord_var_c & 0xFE) == 0xFC):
                            // characters U-04000000 - U-7FFFFFFF, mask 1111110X
                            // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                            $char = pack('C*', $ord_var_c,
                                         ord($var{$c + 1}),
                                         ord($var{$c + 2}),
                                         ord($var{$c + 3}),
                                         ord($var{$c + 4}),
                                         ord($var{$c + 5}));
                            $c += 5;
                            $utf16 = $this->utf82utf16($char);
                            $ascii .= sprintf('\u%04s', bin2hex($utf16));
                            break;
                    }
                }

                return '"'.$ascii.'"';

            case 'array':
               /*
                * As per JSON spec if any array key is not an integer
                * we must treat the the whole array as an object. We
                * also try to catch a sparsely populated associative
                * array with numeric keys here because some JS engines
                * will create an array with empty indexes up to
                * max_index which can cause memory issues and because
                * the keys, which may be relevant, will be remapped
                * otherwise.
                *
                * As per the ECMA and JSON specification an object may
                * have any string as a property. Unfortunately due to
                * a hole in the ECMA specification if the key is a
                * ECMA reserved word or starts with a digit the
                * parameter is only accessible using ECMAScript's
                * bracket notation.
                */

                // treat as a JSON object
                if (is_array($var) && count($var) && (array_keys($var) !== range(0, sizeof($var) - 1))) {
                    $properties = array_map(array($this, 'name_value'),
                                            array_keys($var),
                                            array_values($var));

                    foreach($properties as $property) {
                        if(Services_JSON::isError($property)) {
                            return $property;
                        }
                    }

                    return '{' . join(',', $properties) . '}';
                }

                // treat it like a regular array
                $elements = array_map(array($this, 'encode'), $var);

                foreach($elements as $element) {
                    if(Services_JSON::isError($element)) {
                        return $element;
                    }
                }

                return '[' . join(',', $elements) . ']';

            case 'object':
                $vars = get_object_vars($var);

                $properties = array_map(array($this, 'name_value'),
                                        array_keys($vars),
                                        array_values($vars));

                foreach($properties as $property) {
                    if(Services_JSON::isError($property)) {
                        return $property;
                    }
                }

                return '{' . join(',', $properties) . '}';

            default:
                return ($this->use & SERVICES_JSON_SUPPRESS_ERRORS)
                    ? 'null'
                    : new Services_JSON_Error(gettype($var)." can not be encoded as JSON string");
        }
    }

   /**
    * array-walking function for use in generating JSON-formatted name-value pairs
    *
    * @param    string  $name   name of key to use
    * @param    mixed   $value  reference to an array element to be encoded
    *
    * @return   string  JSON-formatted name-value pair, like '"name":value'
    * @access   private
    */
    function name_value($name, $value)
    {
        $encoded_value = $this->encode($value);

        if(Services_JSON::isError($encoded_value)) {
            return $encoded_value;
        }

        return $this->encode(strval($name)) . ':' . $encoded_value;
    }

   /**
    * reduce a string by removing leading and trailing comments and whitespace
    *
    * @param    $str    string      string value to strip of comments and whitespace
    *
    * @return   string  string value stripped of comments and whitespace
    * @access   private
    */
    function reduce_string($str)
    {
        $str = preg_replace(array(

                // eliminate single line comments in '// ...' form
                '#^\s*//(.+)$#m',

                // eliminate multi-line comments in '/* ... */' form, at start of string
                '#^\s*/\*(.+)\*/#Us',

                // eliminate multi-line comments in '/* ... */' form, at end of string
                '#/\*(.+)\*/\s*$#Us'

            ), '', $str);

        // eliminate extraneous space
        return trim($str);
    }

   /**
    * decodes a JSON string into appropriate variable
    *
    * @param    string  $str    JSON-formatted string
    *
    * @return   mixed   number, boolean, string, array, or object
    *                   corresponding to given JSON input string.
    *                   See argument 1 to Services_JSON() above for object-output behavior.
    *                   Note that decode() always returns strings
    *                   in ASCII or UTF-8 format!
    * @access   public
    */
    function decode($str)
    {
        $str = $this->reduce_string($str);

        switch (strtolower($str)) {
            case 'true':
                return true;

            case 'false':
                return false;

            case 'null':
                return null;

            default:
                $m = array();

                if (is_numeric($str)) {
                    // Lookie-loo, it's a number

                    // This would work on its own, but I'm trying to be
                    // good about returning integers where appropriate:
                    // return (float)$str;

                    // Return float or int, as appropriate
                    return ((float)$str == (integer)$str)
                        ? (integer)$str
                        : (float)$str;

                } elseif (preg_match('/^("|\').*(\1)$/s', $str, $m) && $m[1] == $m[2]) {
                    // STRINGS RETURNED IN UTF-8 FORMAT
                    $delim = substr($str, 0, 1);
                    $chrs = substr($str, 1, -1);
                    $utf8 = '';
                    $strlen_chrs = strlen($chrs);

                    for ($c = 0; $c < $strlen_chrs; ++$c) {

                        $substr_chrs_c_2 = substr($chrs, $c, 2);
                        $ord_chrs_c = ord($chrs{$c});

                        switch (true) {
                            case $substr_chrs_c_2 == '\b':
                                $utf8 .= chr(0x08);
                                ++$c;
                                break;
                            case $substr_chrs_c_2 == '\t':
                                $utf8 .= chr(0x09);
                                ++$c;
                                break;
                            case $substr_chrs_c_2 == '\n':
                                $utf8 .= chr(0x0A);
                                ++$c;
                                break;
                            case $substr_chrs_c_2 == '\f':
                                $utf8 .= chr(0x0C);
                                ++$c;
                                break;
                            case $substr_chrs_c_2 == '\r':
                                $utf8 .= chr(0x0D);
                                ++$c;
                                break;

                            case $substr_chrs_c_2 == '\\"':
                            case $substr_chrs_c_2 == '\\\'':
                            case $substr_chrs_c_2 == '\\\\':
                            case $substr_chrs_c_2 == '\\/':
                                if (($delim == '"' && $substr_chrs_c_2 != '\\\'') ||
                                   ($delim == "'" && $substr_chrs_c_2 != '\\"')) {
                                    $utf8 .= $chrs{++$c};
                                }
                                break;

                            case preg_match('/\\\u[0-9A-F]{4}/i', substr($chrs, $c, 6)):
                                // single, escaped unicode character
                                $utf16 = chr(hexdec(substr($chrs, ($c + 2), 2)))
                                       . chr(hexdec(substr($chrs, ($c + 4), 2)));
                                $utf8 .= $this->utf162utf8($utf16);
                                $c += 5;
                                break;

                            case ($ord_chrs_c >= 0x20) && ($ord_chrs_c <= 0x7F):
                                $utf8 .= $chrs{$c};
                                break;

                            case ($ord_chrs_c & 0xE0) == 0xC0:
                                // characters U-00000080 - U-000007FF, mask 110XXXXX
                                //see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                                $utf8 .= substr($chrs, $c, 2);
                                ++$c;
                                break;

                            case ($ord_chrs_c & 0xF0) == 0xE0:
                                // characters U-00000800 - U-0000FFFF, mask 1110XXXX
                                // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                                $utf8 .= substr($chrs, $c, 3);
                                $c += 2;
                                break;

                            case ($ord_chrs_c & 0xF8) == 0xF0:
                                // characters U-00010000 - U-001FFFFF, mask 11110XXX
                                // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                                $utf8 .= substr($chrs, $c, 4);
                                $c += 3;
                                break;

                            case ($ord_chrs_c & 0xFC) == 0xF8:
                                // characters U-00200000 - U-03FFFFFF, mask 111110XX
                                // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                                $utf8 .= substr($chrs, $c, 5);
                                $c += 4;
                                break;

                            case ($ord_chrs_c & 0xFE) == 0xFC:
                                // characters U-04000000 - U-7FFFFFFF, mask 1111110X
                                // see http://www.cl.cam.ac.uk/~mgk25/unicode.html#utf-8
                                $utf8 .= substr($chrs, $c, 6);
                                $c += 5;
                                break;

                        }

                    }

                    return $utf8;

                } elseif (preg_match('/^\[.*\]$/s', $str) || preg_match('/^\{.*\}$/s', $str)) {
                    // array, or object notation

                    if ($str{0} == '[') {
                        $stk = array(SERVICES_JSON_IN_ARR);
                        $arr = array();
                    } else {
                        if ($this->use & SERVICES_JSON_LOOSE_TYPE) {
                            $stk = array(SERVICES_JSON_IN_OBJ);
                            $obj = array();
                        } else {
                            $stk = array(SERVICES_JSON_IN_OBJ);
                            $obj = new stdClass();
                        }
                    }

                    array_push($stk, array('what'  => SERVICES_JSON_SLICE,
                                           'where' => 0,
                                           'delim' => false));

                    $chrs = substr($str, 1, -1);
                    $chrs = $this->reduce_string($chrs);

                    if ($chrs == '') {
                        if (reset($stk) == SERVICES_JSON_IN_ARR) {
                            return $arr;

                        } else {
                            return $obj;

                        }
                    }

                    //print("\nparsing {$chrs}\n");

                    $strlen_chrs = strlen($chrs);

                    for ($c = 0; $c <= $strlen_chrs; ++$c) {

                        $top = end($stk);
                        $substr_chrs_c_2 = substr($chrs, $c, 2);

                        if (($c == $strlen_chrs) || (($chrs{$c} == ',') && ($top['what'] == SERVICES_JSON_SLICE))) {
                            // found a comma that is not inside a string, array, etc.,
                            // OR we've reached the end of the character list
                            $slice = substr($chrs, $top['where'], ($c - $top['where']));
                            array_push($stk, array('what' => SERVICES_JSON_SLICE, 'where' => ($c + 1), 'delim' => false));
                            //print("Found split at {$c}: ".substr($chrs, $top['where'], (1 + $c - $top['where']))."\n");

                            if (reset($stk) == SERVICES_JSON_IN_ARR) {
                                // we are in an array, so just push an element onto the stack
                                array_push($arr, $this->decode($slice));

                            } elseif (reset($stk) == SERVICES_JSON_IN_OBJ) {
                                // we are in an object, so figure
                                // out the property name and set an
                                // element in an associative array,
                                // for now
                                $parts = array();
                                
                                if (preg_match('/^\s*(["\'].*[^\\\]["\'])\s*:\s*(\S.*),?$/Uis', $slice, $parts)) {
                                    // "name":value pair
                                    $key = $this->decode($parts[1]);
                                    $val = $this->decode($parts[2]);

                                    if ($this->use & SERVICES_JSON_LOOSE_TYPE) {
                                        $obj[$key] = $val;
                                    } else {
                                        $obj->$key = $val;
                                    }
                                } elseif (preg_match('/^\s*(\w+)\s*:\s*(\S.*),?$/Uis', $slice, $parts)) {
                                    // name:value pair, where name is unquoted
                                    $key = $parts[1];
                                    $val = $this->decode($parts[2]);

                                    if ($this->use & SERVICES_JSON_LOOSE_TYPE) {
                                        $obj[$key] = $val;
                                    } else {
                                        $obj->$key = $val;
                                    }
                                }

                            }

                        } elseif ((($chrs{$c} == '"') || ($chrs{$c} == "'")) && ($top['what'] != SERVICES_JSON_IN_STR)) {
                            // found a quote, and we are not inside a string
                            array_push($stk, array('what' => SERVICES_JSON_IN_STR, 'where' => $c, 'delim' => $chrs{$c}));
                            //print("Found start of string at {$c}\n");

                        } elseif (($chrs{$c} == $top['delim']) &&
                                 ($top['what'] == SERVICES_JSON_IN_STR) &&
                                 ((strlen(substr($chrs, 0, $c)) - strlen(rtrim(substr($chrs, 0, $c), '\\'))) % 2 != 1)) {
                            // found a quote, we're in a string, and it's not escaped
                            // we know that it's not escaped becase there is _not_ an
                            // odd number of backslashes at the end of the string so far
                            array_pop($stk);
                            //print("Found end of string at {$c}: ".substr($chrs, $top['where'], (1 + 1 + $c - $top['where']))."\n");

                        } elseif (($chrs{$c} == '[') &&
                                 in_array($top['what'], array(SERVICES_JSON_SLICE, SERVICES_JSON_IN_ARR, SERVICES_JSON_IN_OBJ))) {
                            // found a left-bracket, and we are in an array, object, or slice
                            array_push($stk, array('what' => SERVICES_JSON_IN_ARR, 'where' => $c, 'delim' => false));
                            //print("Found start of array at {$c}\n");

                        } elseif (($chrs{$c} == ']') && ($top['what'] == SERVICES_JSON_IN_ARR)) {
                            // found a right-bracket, and we're in an array
                            array_pop($stk);
                            //print("Found end of array at {$c}: ".substr($chrs, $top['where'], (1 + $c - $top['where']))."\n");

                        } elseif (($chrs{$c} == '{') &&
                                 in_array($top['what'], array(SERVICES_JSON_SLICE, SERVICES_JSON_IN_ARR, SERVICES_JSON_IN_OBJ))) {
                            // found a left-brace, and we are in an array, object, or slice
                            array_push($stk, array('what' => SERVICES_JSON_IN_OBJ, 'where' => $c, 'delim' => false));
                            //print("Found start of object at {$c}\n");

                        } elseif (($chrs{$c} == '}') && ($top['what'] == SERVICES_JSON_IN_OBJ)) {
                            // found a right-brace, and we're in an object
                            array_pop($stk);
                            //print("Found end of object at {$c}: ".substr($chrs, $top['where'], (1 + $c - $top['where']))."\n");

                        } elseif (($substr_chrs_c_2 == '/*') &&
                                 in_array($top['what'], array(SERVICES_JSON_SLICE, SERVICES_JSON_IN_ARR, SERVICES_JSON_IN_OBJ))) {
                            // found a comment start, and we are in an array, object, or slice
                            array_push($stk, array('what' => SERVICES_JSON_IN_CMT, 'where' => $c, 'delim' => false));
                            $c++;
                            //print("Found start of comment at {$c}\n");

                        } elseif (($substr_chrs_c_2 == '*/') && ($top['what'] == SERVICES_JSON_IN_CMT)) {
                            // found a comment end, and we're in one now
                            array_pop($stk);
                            $c++;

                            for ($i = $top['where']; $i <= $c; ++$i)
                                $chrs = substr_replace($chrs, ' ', $i, 1);

                            //print("Found end of comment at {$c}: ".substr($chrs, $top['where'], (1 + $c - $top['where']))."\n");

                        }

                    }

                    if (reset($stk) == SERVICES_JSON_IN_ARR) {
                        return $arr;

                    } elseif (reset($stk) == SERVICES_JSON_IN_OBJ) {
                        return $obj;

                    }

                }
        }
    }

    /**
     * @todo Ultimately, this should just call PEAR::isError()
     */
    function isError($data, $code = null)
    {
        if (class_exists('pear')) {
            return PEAR::isError($data, $code);
        } elseif (is_object($data) && (get_class($data) == 'services_json_error' ||
                                 is_subclass_of($data, 'services_json_error'))) {
            return true;
        }

        return false;
    }
}

if (class_exists('PEAR_Error')) {

    class Services_JSON_Error extends PEAR_Error
    {
        function Services_JSON_Error($message = 'unknown error', $code = null,
                                     $mode = null, $options = null, $userinfo = null)
        {
            parent::PEAR_Error($message, $code, $mode, $options, $userinfo);
        }
    }

} else {

    /**
     * @todo Ultimately, this class shall be descended from PEAR_Error
     */
    class Services_JSON_Error
    {
        function Services_JSON_Error($message = 'unknown error', $code = null,
                                     $mode = null, $options = null, $userinfo = null)
        {

        }
    }

}

}

?>