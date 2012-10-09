<?php

function widget_mrt_sms($args) {
  extract($args);
  echo "\n <!--SMS Text Message WordPress plugin widget by Michael Torbert of http://semperfiwebdesign.com/ \n plugin url: http://wordpress.org/extend/plugins/sms-text-message/-->\n";
  echo $before_widget;
  echo $before_title . get_option( "mrt_sms_header" ) . $after_title;
  mrt_sms_guts_widget();
  echo "<h6><em>" . get_option( "mrt_sms_footer" ) . "</em></h6>";
  echo $after_widget;
  echo "\n <!--End of SMS Text Message plugin widget-->";
}

function mrt_sms_widget_init(){
   register_sidebar_widget(__('SMS Text Message'), 'widget_mrt_sms');
}?>
