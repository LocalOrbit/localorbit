=== Plugin Name ===
Contributors: Janek Niefeldt
Donate link: http://www.janek-niefeldt.de/blog/mycustomwidget
Tags: widget, customize, admin, sidebar, custom, plugin, code, own widget, tags, tag, filter, duplicate, copy
Requires at least: 2.8
Tested up to: 3.0
Stable tag: 2.0.5

Plugin to create your own custom widgets.

== Description ==

Use this plugin to create your own widgets, duplicate existing widgets and arrange them in a sidebar or anywhere else. 
Thanks to filter definitions you can decide whether the widget should be displayed or not for specific pages or page-types.

This plugin does not work with Wordpress 2.7.1 and below. 
If you are using Wordpress 2.2 - 2.7.x please use Release 1.9.1 of this plugin.

The following features have been implemented:

*   define own widgets with php and/or html code 
*   decide where your widget should be displayed (e.g. archive-page only)
*   define your own filters through plugin configuration
*   widget-titles that fit into your theme can be defined and changed comfortable as well
*   Debug-mode for code review
*   apply_filter-functionality can be activated within CustomWidgets 
*   widgets are also available through custom tags such as &lt;!--MyWidget--&gt; 
and can be used outside of the sidebar as well
*   duplicate/copy existing widgets (beta feature)
*   deinstallation routine to remove all option entries created by the plugin 
*   Backup routine for widget- and plugin-configuration


== Installation ==

1. Upload the folder complete mycustomwidget-folder into the `/wp-content/plugins/` directory
2. Make file `my_custom_widget_classes.php` writeable (i.e. chmod 0666)
3. Activate the plugin through the 'Plugins' menu in WordPress
4. Configure the plugin through option menu (e.g. define own filters) (optional)
5. Define your Widgets through theme menu in Wordpress.
6. Organize your widgets through the 'Widgets' menu in Wordpress
7. Have fun

== Frequently Asked Questions ==

= I have found a bug. What should I do? =
Just visit me on my website and describe the failure. I will see what I can do.

= Does this plugin works with other plugins? =
Usually there should not be a problem. Nevertheless I added a backup routine. 

= Cool stuff! But I miss something. Can I add it? =
Sure you can. It's GPL! But you can also contact me. Maybe we can develop this plugin together.


== Screenshots ==

1. configuration screen / creating new widgets (appearance-menu)
2. Sidebar configuration screen with open CustomWidget
3. Debugging/Preview on configuration screen 
4. option screen (1/2) (Settings-menu)
5. option screen (2/2) (Settings-menu)
