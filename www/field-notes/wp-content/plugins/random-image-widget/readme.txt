=== Random Image widget ===
Tags: WordPress, WordPress Plugin, widget, images, photos, sidebar
Contributors: mproulx
Requires at least: 2.5
Tested up to: 2.7
Stable tag: 1.5

== Description ==

The Random Image widget displays a user-selectable number of random photos from a directory on the web server in the sidebar, post, or any other location in a WordPress blog.


== Installation ==

1. Download and unzip `random-image.zip`.
2. Place `random-image.php` in your blog's plugin subdirectory (e.g., `/wp-content/plugins/`).
3. Create a new subdirectory to hold your images (`random-image` is the recommended name for this directory).
4. Activate the plugin from the Plugins tab of your blog's administrative panel.
5. Go to the Widgets page from the Presentation tab.
6. Click the 'Add' link on the widget to add the widget to the appropriate sidebar.
7. Click the 'Edit' link on the widget's placeholder to open the settings form.
8. Use the form to adjust any of the visual settings to fit your theme and preferences and save the sidebar settings.  Be sure the directory points to the folder you are using to store your images.  If you don't want the plugin to display in the sidebar, uncheck the "Show widget in sidebar" option (you can still use the widget to display images in posts or elsewhere in your page.)
9. Click the 'Save' button on the settings form.
10. Click the 'Save Changes' at the bottom of the Current Widgets section. You should be able to see the sidebar on your front page.
11. If you would like to have multiple copies of the widget on your blog, simply click the 'Add' button again.  At this time, you can only use one copy of the widget active if you use it outside of the sidebar.
12. To display in a post or page, add a line in your post that says `(randomimage)`.
13. To display elsewhere in a page, you can call the display function in the appropriate php file of your theme using the function echo_random_image().

== Frequently Asked Questions ==

= I installed the plugin but can't see it.  What's wrong? =

If the widget doesn't show up on the Widgets page:
* Check to make sure the plugin was uploaded to the widgets subdirectory.
* Check to make sure both the widgets plugin and the photos plugin are activated.
* Version 1.3 of the widget won't work with versions of WordPress older than 2.5.  You can download version 1.2 or earlier, which will work with 2.0-2.3.

If the widget doesn't appear on the sidebar once the plugin has been added:
* Make sure the plugin has been added to the correct sidebar.
* Be sure to save changes on the settings form and in the Current Widgets section.
* Make sure the directory name is entered correctly on the settings page

If the widget title appears but no photos appear below it:
* Make sure the directory name is entered correctly on the settings page

= The widget doesn't work with my theme.  How can I fix this? =

This widget has been tested on a number of themes and is compatible with all truly widget-ready themes.  However, certain formatting settings are "locked" in the code.  

The code isn't locked in stone, however.  You may be able to edit the PHP file to adjust things to your particular code.  You may also contact the plugin author for suggestions; these may result in a better plugin in the future.

== Homepage ==

[http://www.district30.net/random-image-widget](http://www.district30.net/random-image-widget)