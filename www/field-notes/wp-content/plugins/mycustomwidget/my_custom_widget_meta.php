<?php
/*********************************/
/***    constant parameters    ***/
/*********************************/
$mcw_write_log = false;

$mcw_plugin_folder = "mycustomwidget";
$mcw_widgetsoption = "mywidgets";
$mcw_prefix = "mcw_";
$mcw_configoption = "options";
$mcw_metaoption = "meta";
$mcw_backup_postfix = "_backup";
$mcw_version = "2.0";

$mcw_all_widgets = array();
$mcw_all_widget_IDs = array();



  function MCW_get_blogid(){
    global $blog_id;
    if  ($blog_id=1) {
      return '';
    } else {
      return '_'.$blog_id;
    } 
  }

$mcw_path = array('add'             => get_option('siteurl').'/wp-content/plugins/'.$mcw_plugin_folder.'/add.png',
                  'tool'            => get_option('siteurl').'/wp-content/plugins/'.$mcw_plugin_folder.'/tool.png', 
                  'edit'            => get_option('siteurl').'/wp-content/plugins/'.$mcw_plugin_folder.'/edit.png', 
                  'save'            => get_option('siteurl').'/wp-content/plugins/'.$mcw_plugin_folder.'/save.png', 
                  'remove'          => get_option('siteurl').'/wp-content/plugins/'.$mcw_plugin_folder.'/remove.png',
                  'preview'         => get_option('siteurl').'/wp-content/plugins/'.$mcw_plugin_folder.'/preview.png',
                  'info'            => get_option('siteurl').'/wp-content/plugins/'.$mcw_plugin_folder.'/info.png',
                  'js_tooltip'      => get_option('siteurl').'/wp-content/plugins/'.$mcw_plugin_folder.'/js/wz_tooltip.js',
                  'include_class'   => dirname(__FILE__).'/my_custom_widget_classes'.MCW_get_blogid().'.php',
                  'log'             => dirname(__FILE__).'/log.html',
                  'style'           => '../wp-content/plugins/'.$mcw_plugin_folder.'/my_custom_widget_style.css',
                  'function_source' => 'my_custom_widget_functions.php',
                  'config_source'   => 'my_custom_widget_configuration.php',
                  'option_source'   => 'my_custom_widget_options.php',
                  'meta_source'     => 'my_custom_widget_meta.php',
                  'js_1'            => get_option('siteurl').'/wp-content/plugins/mycustomwidget/js/prototype.js',
                  'js_2'            => get_option('siteurl').'/wp-content/plugins/mycustomwidget/js/scriptaculous.js?load=effects');

$mcw_title_tooltip = "Leave blank to ignore the theme-specific widget style. <br>Enter &quot; &quot; (space) to make theme specific widget style appear without title.<br>Enter title to make the widgets title appear in the theme specific layout.";
$mcw_filters_tooltip = "Filters can be used to make the widget appear respectively disappear on specific screens. (Default: all)";
$mcw_officialform_tooltip = "It is not possible to maintain the widget on this screen. <br>Use the maintenance screen by following the link mentioned above or use the MCW 2.0 Addon.";
$mcw_custag_tooltip = "Use this tag to make your widget available everywhere.";
$mcw_uniquename_tooltip = "Choose a unique ID for your CustomWidget.<br>Only regular characters and underscores (&quot;_&quot;) are allowed.<br>Spaces (&quot; &quot;) will be replaced by underscores.";
?>