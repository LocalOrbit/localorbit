<?php 
/* 
Plugin Name: My Custom Widgets
Plugin URI: http://www.janek-niefeldt.de/blog/mycustomwidget/ 
Description: Define your own or copy existing widgets and include them into your sidebar or everywhere else.
Author: Janek Niefeldt 
Version: 2.0.5
Author URI: http://www.janek-niefeldt.de/ 
*/ 

/******************************************************************************/
/* Version History:	                                                      */
/******************************************************************************/
/*0.1 - widget definition needs to be hard-coded                              */
/*0.2 - adding option screen, widget definition via textbox                   */
/*0.3 - adding differentiation between HTML and PHP-code                      */
/*0.4 - adding filter                                                         */
/*0.5 - adding dropdown editing screen and singlesave option                  */  
/*0.6 - adding filter as parameters                                           */
/*0.7 - modularize several tasks                                              */
/*0.8 - adding configuration screen                                           */
/*0.9 - adding widget-preview in development screen                           */
/*1.0b - beta release                                                         */
/*1.1b - fixing "apostrophe"-bug                                              */
/*1.1 - adding option information                                             */
/*1.2 - adding backup functionality and more help-buttons                     */
/*1.2.1 - fixing "Jeffreys-use-case"-Bug                                      */
/*1.2.2 - fixing stripslashes-bug in additional HTML-code                     */
/*1.3 - redesign of code evaluation, adding debug-mode, filter bug            */
/*1.3.1 - fixing global variable issue to work with other plugins             */
/*1.4 - add AJAX components                                                   */
/*1.4.1 - fix small coding bug (function: submit_form)                        */ 
/*1.5 - add apply_filter-functionality, add optional css wrapper              */
/*1.6 - CustomWidgets can now be used outside of the sidebar                  */
/*1.6.1 - fix styling bug that has been introduced with wordpress 2.7         */
/*1.7 - enter widget titles that will be added automatically                  */
/*1.8 - duplicate existing widgets                                            */
/*1.8.1 - fix styling bug in duplicate feature                                */
/*1.9 - widget data moved from central storage to individual db-entries       */
/*1.9.1 - Minor bugfix                                                        */
/*2.0 - make compatible to wordpress 2.8                                      */
/*2.0.1 - remove some bugs found by David Brewster                            */
/*2.0.2 - and another one                                                     */
/*2.0.3 - removed the root of "all evil"                                      */
/*2.0.4 - add compatibility with multiple blogs (thx HaZa)                    */
/*2.0.5 - fix bug that disabled the maintenance area                          */
/******************************************************************************/

/*  
Copyright 2007-2010 Janek Niefeldt (email: mail@janek-niefeldt.de)
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

/*********************************/
/***    constant parameters    ***/
/*********************************/

include_once('my_custom_widget_meta.php');
include_once($mcw_path['function_source']);


/************************************/
/***    Start of Custom Widget    ***/
/************************************/
function MCW_plugin_init(){
  if ( !function_exists('register_widget') )
		return;

/******************************/    
/*** deinstallation routine ***/
/******************************/  
  function MCW_deinstall(){
    global $mcw_prefix;
    global $mcw_widgetsoption;
    global $mcw_configoption;
    global $mcw_metaoption;
    global $mcw_backup_postfix;
    delete_option($mcw_prefix.$mcw_metaoption);
    
    //delete all productive data
    $all_widget_IDs = get_option($mcw_prefix.$mcw_widgetsoption);       
    $max = count($all_widget_IDs);
    for ( $i = 0; $i < $max; ++$i ) {
      delete_option($mcw_prefix.'w_'.$all_widget_IDs[$i]['name']);
    }    
    delete_option($mcw_prefix.$mcw_widgetsoption);    
    delete_option($mcw_prefix.$mcw_configoption);
    
    //delete all backup data
    $all_backup_widget_IDs = get_option($mcw_prefix.$mcw_widgetsoption.$mcw_backup_postfix);       
    $max = count($all_backup_widget_IDs);
    for ( $i = 0; $i < $max; ++$i ) {
      delete_option($mcw_prefix.$mcw_backup_postfix.'w_'.$all_backup_widget_IDs[$i]['name']);
    }    
    delete_option($mcw_prefix.$mcw_widgetsoption.$mcw_backup_postfix);
    delete_option($mcw_prefix.$mcw_configoption.$mcw_backup_postfix);
  }
  
/************************************/
/***     initialize widgets       ***/
/************************************/
  $myWidget_IDs_all = MCW_get_all_widget_IDs();
  $maxindex = count($myWidget_IDs_all);
  // Register widgets 
  if (!empty($myWidget_IDs_all)){
    if (MCW_generaterequired() == true){
      echo MCW_generate_class();
    }
    //include_once( "my_custom_widget_classes.php" );
    global $mcw_path;
    include_once( $mcw_path["include_class"] );
    
    $tag=MCW_get_option('outfilter');
    
    add_filter($tag, MCW_make_available_outside);
    
  }
/*************************************************************************/
/***  single widget-implementation as it has to be according to WP 2.8 ***/
/*************************************************************************/  
  include_once( "my_custom_widget_addon.php" );  
}


/***********************************/
/***  create configuration page  ***/
/***********************************/

function MCW_add_pages() {
  add_theme_page("Administration of My Custom Widgets", "My Custom Widgets", 8, mcw_get_mainfile_name(), "MCW_include_theme_page");
  add_options_page("Configuration of My Custom Widgets", "My Custom Widgets", 8, mcw_get_mainfile_name(), "MCW_include_option_page"); 
}
function MCW_include_option_page() {
  global $mcw_prefix;
  global $mcw_configoption;
    $mcw_options = MCW_get_default_options();
    add_option($mcw_prefix.$mcw_configoption, $mcw_options, 'Options for My Custom Widgets - Plugin', true );
    include(MCW_get_url('style' ));
    //echo "<h2>My Custom Widget - Configuration</h2>";
    include( "my_custom_widget_configuration.php" ); 
}

function MCW_include_theme_page() {
  global $mcw_prefix;
  global $mcw_widgetsoption;
  add_option($mcw_prefix.$mcw_widgetsoption , array(), "IndexOption for MyCustomWidgets", true);
  include(MCW_get_url('style'));
  //echo "<h2>My Custom Widget - test1</h2>";
  include( "my_custom_widget_options.php" );
}

/******************************/
/***  deactivation dialog  ***/
/*****************************/
function MCW_deactivate_plugin(){
  //echo "JANEK-TEST-PLUGIN-DEACTIVATION";
}


/**********************/
/***   wake up !!!  ***/
/**********************/
add_action("plugins_loaded", "MCW_plugin_init");
add_action('widget_init', 'MCW_plugin_init');

add_action("admin_menu", "MCW_add_pages");
register_deactivation_hook(__FILE__, 'MCW_deactivate_plugin');


 
?>