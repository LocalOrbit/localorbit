<?php
/*
Plugin Name: SMS Text Message
Plugin URI: http://semperfiwebdesign.com/plugins/sms-text-message/
Description: Allows opt in SMS text message updates.
Author: Michael Torbert
Version: .6.1
Author URI: http://semperfiwebdesign.com/
*/

/*
Copyright (C) 2008-2009 Michael Torbert, semperfiwebdesign.com (michael AT semperfiwebdesign DOT com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

if ( ! defined( 'WP_CONTENT_URL' ) )
      define( 'WP_CONTENT_URL', get_option( 'siteurl' ) . '/wp-content' );
if ( ! defined( 'WP_CONTENT_DIR' ) )
      define( 'WP_CONTENT_DIR', ABSPATH . 'wp-content' );
if ( ! defined( 'WP_PLUGIN_URL' ) )
      define( 'WP_PLUGIN_URL', WP_CONTENT_URL. '/plugins' );
if ( ! defined( 'WP_PLUGIN_DIR' ) )
      define( 'WP_PLUGIN_DIR', WP_CONTENT_DIR . '/plugins' );

require_once(WP_PLUGIN_DIR . "/sms-text-message/options.php");
require_once(WP_PLUGIN_DIR . "/sms-text-message/database.php");
require_once(WP_PLUGIN_DIR . "/sms-text-message/support.php");
require_once(WP_PLUGIN_DIR . "/sms-text-message/functions.php");
require_once(WP_PLUGIN_DIR . "/sms-text-message/subscribers.php");
require_once(WP_PLUGIN_DIR . "/sms-text-message/update.php");
if(!class_exists("SimplePie"))
{
	require_once(WP_PLUGIN_DIR . "/sms-text-message/simplepie.inc");
}

add_action("plugins_loaded", "mrt_sms_widget_init");
register_activation_hook(__FILE__,'mrt_sms_install');
add_action('admin_head', 'mrt_sms_admin_head');
//uppy();
function uppy(){
GLOBAL $wpdb;
//$table_name = $wpdb->prefix . "mrt_sms_list";

	//$update = "UPDATE " . $table_name . " SET number = 15555 WHERE id = 4";
	//echo $update;
	//$results = $wpdb->query($wpdb->prepare($update));
}

global $succfail;
global $mrt_submitted;

function testv(){echo "testccc";}
   global $succfail;
   if( $_POST['message'] != '' && $_POST['subject'] != ''){
   GLOBAL $wpdb;
global $mrt_submitted;
   $table_name = $wpdb->prefix . "mrt_sms_list";
   $result = $wpdb->get_results("SELECT number, carrier FROM " . $table_name);
   //echo $result['0'];

   foreach ($result as $results) {
      $sendnum = $results->number;
      $sentcar = $results->carrier;

      switch ($sentcar) {
         case "verizon":
            $carsuf = "@vtext.com";
            break;
         case "tmobile":
            $carsuf = "@tmomail.net";
            break;
         case "vmobile":
            $carsuf = "@vmobl.com";
            $break;
         case "cingular":
            $carsuf = "@cingularme.com";
            break;
         case "nextel":
            $carsuf = "@messaging.nextel.com";
            break;
         case "alltel":
            $carsuf = "@message.alltel.com";
            break;
         case "sprint":
            $carsuf = "@messaging.sprintpcs.com";
            break;
         case "attmob":
            $carsuf = "@txt.att.net";
            break;
         case "attwire":
            $carsuf = "@mobile.att.net";
            break;
         }	


$mrt_all_from = get_option( "mrt_sms_from" );

$body = $_POST['message'];
$subject = $_POST['subject'];
$to = $sendnum . $carsuf;
$headers = 'From: ' . $mrt_all_from . "\r\n" .
    'Reply-To: ' . $mrt_all_from . "\r\n" .
    'X-Mailer: PHP/';

if (mail($to, $subject, $body, $headers)) {
 $succfail = $succfail . "<font color='green'>Message successfully sent to " . $sendnum . "</font><br />";
 } else {
 $succfail = $succfail . "<font color='red'>Message delivery failed to " . $sendnum . "</font><br />";

}
}
}

if( $_POST['number'] != '' && $_POST['carrier'] != ''){

$mrt_sms_number = $_POST['number'];
$mrt_sms_carrier = $_POST['carrier'];

$mrt_sms_number = ereg_replace("[^0-9]", "", $mrt_sms_number);
$mrt_len = strlen($mrt_sms_number);
$mrt_sub_date = date('l, jFY h:i:s');

if ($mrt_len == 10){
GLOBAL $wpdb;
   $table_name = $wpdb->prefix . "mrt_sms_list";
$insert = "INSERT INTO " . $table_name .
            " (number, carrier, date) " .
            "VALUES ('" . $wpdb->escape($mrt_sms_number) . "','" . $wpdb->escape($mrt_sms_carrier) . "','" . $mrt_sub_date . "')";

      $results = $wpdb->query($wpdb->prepare( $insert ));
$mrt_submitted = "Success! Thank you for subscribing.";
}
elseif($mrt_len > 10){
$mrt_submitted = "<font color='red'>Too many digits.  Please enter only 10 digits for your phone number</font>";
}elseif($mrt_len < 10){
$mrt_submitted = "<font color='red'>Not enough digits.  Please enter a 10 digit phone number</font>";}


}
function mrt_sms_guts_widget()
{  //echo "<h2>Register for SMS Updates</h2>";
global $mrt_submitted;
global $mrt_sms_ll;
echo $mrt_submitted;
//testv();
?><form name='mrt_sub_form' id='mrt_sub_form' method='POST' action='<?= "http://" . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . "?" . $_SERVER['QUERY_STRING'] ?>'>
Phone number<br /><input name="number" type="text" /><br />
Carrier<br /><select name="carrier">
  <option value="verizon">Verizon</option>
  <option value="tmobile">T-Mobile</option>
  <option value="vmobile">Virgin Mobile</option>
  <option value="cingular">Cingular(GoPhone)</option>
  <option value="nextel">Nextel</option>
  <option value="alltel">Alltel</option>
  <option value="sprint">Sprint</option>
  <option value="attmob">AT&amp;T Mobility(Cingular)</option>
  <option value="attwire">AT&amp;T Wireless</option>
</select><br />
<?php echo $mrt_sms_ll; ?>
</form>
<?php }

add_action('admin_menu', 'mrt_add_menu');

function mrt_add_menu() {
   add_menu_page('SMS Text Message', 'SMS Text Message', 8, __FILE__, 'mrt_sms_main_control',WP_PLUGIN_URL . '/sms-text-message/sms-text-message.png');
   add_submenu_page(__FILE__, 'Options', 'Options', 8, 'Options', 'mrt_sms_options_page');
   add_submenu_page(__FILE__, 'Subscribers', 'Subscribers', 8, 'Subscribers', 'mrt_sms_subscribers_page');
   add_submenu_page(__FILE__, 'Support', 'Support', 8, 'Support', 'mrt_sms_support_page');
}

function mrt_sms_meta_box1(){
	global $succfail;
	$mrt_sms_maxlen = get_option('mrt_sms_max');
	        ?>



	<div style="padding: 10px;">

	<form name='mrt_send_sms_form' id='mrt_send_sms_form' method='POST' action='<?= "http://" . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . "?" . $_SERVER['QUERY_STRING'] ?>'>
	Send an SMS message to your subscribers here:
	<br /><br />
	Subject&nbsp;&nbsp;&nbsp;<input name="subject" type="text" size="23" /><br />
	Message&nbsp;<textarea maxlength="<?php echo $mrt_sms_maxlen; ?>" onkeyup="return ismaxlength(this)" onKeyPress=check_length(this.form,<?php echo $mrt_sms_maxlen; ?>); onKeyDown=check_length(this.form); name="message" rows="3"></textarea><br />
	<input size=5 value=<?php echo $mrt_sms_maxlen; ?> name=text_num> Characters Left<br />
	<span class="submit"><input type="submit" value="Send Message" /></span>

	</form>

	<?php 
	echo $succfail;
	$succfail = '';?>
	<br /><em>For comments, suggestions, bug reporting, etc please <a href="http://semperfiwebdesign.com/contact/">click here</a>.</em>
</div>
	<?php
}


function mrt_sms_meta_box2(){
	?>
	<div style="padding:10px;">
		<div style="font-size:13pt;text-align:center;">Highest</div>		<?php

			$feed = new SimplePie();


				$feed->set_feed_url('feed://donations.semperfiwebdesign.com/category/highest-donations/feed/');
				$feed->strip_htmltags(array('p'));
				$feed->set_cache_location(WP_PLUGIN_DIR . "/sms-text-message/");
				$feed->init();
			$feed->handle_content_type();
			?>
					<?php if ($feed->data): ?>
						<?php $items = $feed->get_items(); ?>

						<?php foreach($items as $item): ?>
	<p>
			<strong><?php echo $item->get_title(); ?></strong>
			<?php echo $item->get_content(); ?>
	</p>

						<?php endforeach; ?>

					<?php endif; ?>


		<div style="font-size:13pt;text-align:center;">Recent</div>		<?php

			$feed = new SimplePie();


				$feed->set_feed_url('feed://donations.semperfiwebdesign.com/category/sms-text-message/feed/');
				$feed->strip_htmltags(array('p'));
                                $feed->set_cache_location(WP_PLUGIN_DIR . "/sms-text-message/");

				$feed->init();
			$feed->handle_content_type();
			?>
					<?php if ($feed->data): ?>
						<?php $items = $feed->get_items(); ?>

						<?php foreach($items as $item): ?>
	<p>
			<strong><?php echo $item->get_title(); ?></strong>
			<?php echo $item->get_content(); ?>
	</p>

						<?php endforeach; ?>
						
							<div style="text-align:center"><em>This plugin is updated as a free service to the WordPress community.  Donations of any size are appreciated.</em>
							<br /><br />
							<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mrtorbert%40gmail%2ecom&item_name=Support%20WordPress%20Security%20Scan%20Plugin&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8" target="_blank">Click here to support this plugin.</a>
	</div>
						
						</div>
					<?php endif; ?>

					
	<?php
}


function mrt_sms_main_control() {
global $succfail;
add_meta_box("mrt_sms", "Send Quick Message", "mrt_sms_meta_box1", "sms");
add_meta_box("mrt_sms", "Donations", "mrt_sms_meta_box2", "sms2");
$mrt_sms_maxlen = get_option('mrt_sms_max');
        ?>

<div class="wrap">
                <h2><?php _e('SMS Text Message Control Panel') ?></h2>

				<div id="dashboard-widgets-wrap">
				<div class="metabox-holder">
					<div style="float:left; width:48%;" class="inner-sidebar1">
						<?php do_meta_boxes('sms','advanced','');  ?>	
					</div>

					<div style="float:right; width:48%; " class="inner-sidebar1">
						<?php do_meta_boxes('sms2','advanced',''); ?>	
					</div>

				</div>

<!--<div style="float: left;width: 285px;border: 1px solid #999;margin: 0 15px 15px 0;padding: 25px;">-->
	
	

<!--	
   <div width=600px style="text-align:center;font-weight:bold;"><h3>Donations</h3></div>
   <div style="text-align:center"><em>This plugin is updated as a free service to the WordPress community.  Donations of any size are appreciated.</em>
      <br /><br />
      <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mrtorbert%40gmail%2ecom&item_name=Support%20SMS%20Text%20Message%20Plugin&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8" target="_blank">Click here to support this plugin.</a>
      <br /><br /><h4>Highest Donations</h4></div>

-->
<?php
/*      $ch = curl_init();
      curl_setopt($ch, CURLOPT_URL, "http://semperfiwebdesign.com/donations/top_donations.php");
      curl_setopt($ch, CURLOPT_HEADER, 0);
      curl_exec($ch);
      curl_close($ch);

*/
?>
  <!--    <br /><br /><div style="text-align:center"><h4>Recent Donations</h4></div>

-->
<?php /*
      $ch = curl_init();
      curl_setopt($ch, CURLOPT_URL, "http://semperfiwebdesign.com/donations/recent_donations.php");
      curl_setopt($ch, CURLOPT_HEADER, 0);
      curl_exec($ch);
      curl_close($ch);
*/
?>
   </div>   </div>
   <div style="clear:both"></div>
   Plugin by <a href="http://semperfiwebdesign.com/" title="Semper Fi Web Design">Semper Fi Web Design</a>
<?php
   if ( $_POST['QS_user_email_post'] ) {
      $message = quick_subscribe_register($_POST['QS_user_email_post']);
      echo "sdfsfsdfsfsdf";
      }
?>
</div>
<?php } ?>
