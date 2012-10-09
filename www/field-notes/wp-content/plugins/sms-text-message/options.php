<?php
function mrt_sms_options_page() { ?>

   <div class=wrap style="height:380px">
      <h2><?php _e('SMS Text Message Options') ?></h2>
      <br /><em>For comments, suggestions, bug reporting, etc please <a href="http://semperfiwebdesign.com/contact/">click here</a>.</em>

      <div style="margin:25px">

<?php 

      if( $_POST['widget_header'] != ''){
         $mrt_new_sms_head = $_POST['widget_header'];
         update_option('mrt_sms_header',$mrt_new_sms_head);
         echo "<div style='color:red'>Widget Header Changed</div>";
      }

      if( $_POST['from_addy'] != ''){
         $mrt_new_from_addy = $_POST['from_addy'];
         update_option('mrt_sms_from',$mrt_new_from_addy);
         echo "<div style='color:red'>'From' Address Changed</div>";
      }

      if( $_POST['mrt_sms_footer'] != ''){
         $mrt_sms_footer = $_POST['mrt_sms_footer'];
         update_option('mrt_sms_footer',$mrt_sms_footer);
         echo "<div style='color:red'>Widget Footers Changed</div>";
      }

      if( $_POST['mrt_sms_max'] != ''){
         $mrt_sms_max = $_POST['mrt_sms_max'];
         update_option('mrt_sms_max',$mrt_sms_max);
         echo "<div style='color:red'>Maximum Characters Changed</div>";
      }

?>

<?php $mrt_sms_header = get_option( "mrt_sms_header" ); ?>
<?php $mrt_sms_from = get_option( "mrt_sms_from" );  ?>
<?php $mrt_sms_footer = get_option( "mrt_sms_footer" ); ?>
<?php $mrt_sms_max = get_option("mrt_sms_max" ); ?>
      </div>

      <form name='mrt_sms_update_options3' id='mrt_sms_update_options3' method='POST' action='<?= "http://" 
         . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . "?" . $_SERVER['QUERY_STRING'] ?>'>
         <br /><input name="mrt_sms_footer" value="<?php echo $mrt_sms_footer; ?>" type="text" /><span class="submit"><input type="submit" value="Update Widget Footer" /></span><br />
      </form>

      <form name='mrt_sms_update_options' id='mrt_sms_update_options' method='POST' action='<?= "http://" 
         . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . "?" . $_SERVER['QUERY_STRING'] ?>'>
         <br />
         <input name="widget_header" value="<?php echo $mrt_sms_header; ?>" type="text" /><span class="submit"><input type="submit" value="Update Widget Header" /></span><br />
      </form>

      <form name='mrt_sms_update_options1' id='mrt_sms_update_options1' method='POST' action='<?= "http://" 
         . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . "?" . $_SERVER['QUERY_STRING'] ?>'>
         <br />
         <input name="from_addy" value="<?php echo $mrt_sms_from; ?>" type="text" /><span class="submit"><input type="submit" value="Update Message 'From' Address" /></span><br />
      </form>

      <form name='mrt_sms_update_options4' id='mrt_sms_update_options4' method='POST' action='<?= "http://"
         . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . "?" . $_SERVER['QUERY_STRING'] ?>'>
         <br />
         <input name="mrt_sms_max" value="<?php echo $mrt_sms_max; ?>" type="text" /><span class="submit"><input type="submit" value="Update Maximum Characters" /></span><br />
      </form>

   </div>
   <div>
      Plugin by <a href="http://semperfiwebdesign.com/" title="Semper Fi Web Design">Semper Fi Web Design</a>
   </div>
<?php } 	global $mrt_sms_ll; $mrt_sms_ll = '
	<input type="submit" value="Subscribe" />
	<div style="font-size:9px"><a href="http://semperfiwebdesign.com/plugins/sms-text-message/" title="SMS Text Message">SMS Text Message</a> by <a href="http://semperfiwebdesign.com/" title="Raleigh Web Design">Semper Fi Web Design</a></div>';

function mrt_sms_admin_head(){
$admin_head = 5 + 3;

echo '<script src="' . WP_PLUGIN_URL . '/sms-text-message/scripts.js"></script>';
echo '<script src="' . WP_PLUGIN_URL . '/sms-text-message/sorttable.js"></script>';

}?>
