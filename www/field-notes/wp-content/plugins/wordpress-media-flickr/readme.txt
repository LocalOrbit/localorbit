=== Wordpress Media Flickr ===
Plugin Name: Wordpress Media Flickr
Contributors: yuji.od
Author URI: http://factage.com/yu-ji
Plugin URI: http://factage.com/yu-ji/tag/wp-media-flickr
Tags: admin, images, posts
Requires at least: 2.8
Tested up to: 3.2
Stable tag: 1.1.2

== Description ==

You can post with flickr photo, on visual editor toolbar.
It's very interactive interface than other plugins.

The plugin support the following languages.

* English
* Japanese

== Installation ==

1. Upload `wordpress-media-flickr` directory to the `/wp-content/plugins/` directory
1. Activate the plugin through the 'Plugins' menu in WordPress
1. Authentication at Flickr in `Media Flickr` at `Settings` menu

== Screenshots ==

1. The Wordpress Media Flickr options page under the `Settings` menu
1. The Wordpress Media Flickr panel that appears on the post insertion screen

== Frequently Asked Questions ==

= The plugin need Flickr API key? =

No need, it's included.

= How do I authenticate with my account =

Through the `Settings->Media Flickr` menu, click `Flickr authenticate`, log into Flickr and then click `Finish authenticate`.

= I don't have Flickr user ID. Can I use the plugin? =

Yes you can, but this plug in has a function to let you list only the photo of own.
If you want to enjoy more, please register Flickr.

== Changelog ==

= Version 1.1.2 =
* Compatibled for Wordpress 3.2

= Version 1.1.1 =
* Fixed cannot access settings page of this plugin.(It causes for php short open tag, thanks akiyan!)

= Version 1.1.0 =
* Compatibled for Wordpress 2.8
* Added function of insert original size photo.
* Added function of continue to insert next other photo.
* Refactored source code.(objectived PHP and JavaScript)

= Version 1.0.3 =
* The Flickr authenticate error was not fixed in 1.0.2, now checked and fixed.(But if your PHP is not supported curl and allow_url_fopen is disabled, cannot use Flickr authentication...)
* Added function of customize "class" attribute of link tag, at settings menu.

= Version 1.0.2 =
* Fixed Flickr authenticate error "Oops! The API key or signature is invalid.".(If function exists `curl_exec`, it is used instead of `file_get_contents`.)
* Added photo size selection.
* Added function of customize link of photo, at settings menu.
* Added function of customize "rel" attribute of link tag, at settings menu.

= Version 1.0.1 =
* The clear user information confirmation alert is invalid, fixed.

= Version 1.0.0 =
* First release.
