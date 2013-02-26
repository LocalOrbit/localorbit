<?php

$mrt_sms_db_version = "2.4";

function mrt_sms_install () {
   global $wpdb;
   global  $mrt_sms_db_version;
$mrt_sms_db_version = "2.4";
   $table_name = $wpdb->prefix . "mrt_sms_list";
   if($wpdb->get_var("show tables like '$table_name'") != $table_name) {
     update_option('mrt_sms_header',"SMS Text Message"); 
     update_option('mrt_sms_footer',"*Standard text messaging rates may apply from your carrier*");
     update_option('mrt_sms_from',"info@semperfiwebdesign.com");
      $sql = "CREATE TABLE " . $table_name . " (
	  id mediumint(9) NOT NULL AUTO_INCREMENT,
	  number text NOT NULL,
          carrier text NOT NULL,
	  mrt_frm VARCHAR(100) NOT NULL,
          date VARCHAR(100) NOT NULL,
          UNIQUE KEY id (id)
	);";

      require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
      dbDelta($sql);
 
      add_option("mrt_sms_db_version", $mrt_sms_db_version);

   }

add_option('mrt_sms_max','150');

$installed_ver = get_option( "mrt_sms_db_version" );
   if( $installed_ver != $mrt_sms_db_version ) {
      $sql = "CREATE TABLE " . $table_name . " (
          id mediumint(9) NOT NULL AUTO_INCREMENT,
          number text NOT NULL,
          carrier text NOT NULL,
          mrt_frm VARCHAR(100) NOT NULL,
          date VARCHAR(100) NOT NULL,
          UNIQUE KEY id (id)

      );";

      require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
      dbDelta($sql);

      update_option( "mrt_sms_db_version", $mrt_sms_db_version );
      update_option('mrt_sms_header',"SMS Text Message");
      update_option('mrt_sms_footer',"*Standard text messaging rates may apply from your carrier*");
      update_option('mrt_sms_from',"info@semperfiwebdesign.com");
  }
}
?>
