=== Plugin Name ===
Contributors: matt__79
Tags: admin, posts, visual editor
Requires at least: 2.0.2
Tested up to: 2.7.1
Stable tag: 0.1

A simple plugin-in that deactivates the visual editor for a specific page or post by a custom field set by the author.

== Description ==

The visual editor is nice when pages and posts are simple, but when you try to add special text such as php code to a page then the visual editor oftentimes has to be deactivated to edit the page.  This plug-in allows you to set which posts should not use the visual editor by setting a custom field 'deactivate\_visual\_editor' to true.  This allows the visual editor to be deactivated for the given post/page, but remain active for all others.

== Installation ==

1. Upload `deactivate_visual_editor.php` to the `/wp-content/plugins/` directory
2. Activate the plugin through the 'Plugins' menu in WordPress

== Frequently Asked Questions ==

= How do I tell the plug-in to deactivate the visual editor? =

On the edit page or post form create a custom field 'deactivate\_visual\_editor' and type 'true' as the value.

== Screenshots ==

1. <a href="http://svn.wp-plugins.org/deactive-visual-editor/trunk/dve.jpg">Screenshot 1: </a>Demonstrates how to input the custom field to deactivate the visual editor on a post or page.