=== Simply RSS Fetcher ===
Tags: RSS, fetcher
Requires at least: 2.1
Tested up to: 2.7
Stable tag: trunk
Donate link: http://rick.jinlabs.com/donate/

Simple plugin to fetch a desired RSS and put it wherever you want in your blog.

== Description ==

Simple plugin to fetch a desired RSS and put it wherever you want in your blog.

**Features**

Simply
Customizable
Widget support
No options page (yes, its a feature)
Uses Wordpress resources (no extra files needed)

**Usage**

If you use WordPress widgets, just drag the widget into your sidebar and configure. If widgets are not your thing, use the following code to display your public Twitter messages:

`<?php srssfetcher("username"); ?>`

For more info (options, customization, etc.) visit [the plugin homepage](http://rick.jinlabs.com/code/simply-rss-fetcher/ "Simply RSS Fetcher").

**Customization**

The plug in provides the following CSS classes:

    * ul.srssfetcher: the main ul (if list is activated)
    * li.srssfetcher-item: the ul items (if list is activated)
    * p.srssfetcher-message: each one of the paragraphs (if items  > 1)
    * .srssfetcher-timestamp: the timestamp span class

== Installation ==

Drop srssfetcher folder (or even srssfetcher.php) into /wp-content/plugins/ and activate the plug in the Wordpress admin area.

== Credits ==

[Ronald Heft](http://cavemonkey50.com/) - The plugin is highly based in his Pownce for Wordpress, so the major part of the credits goes to him.

[Michael Feichtinger](http://bohuco.net/blog) - For the multi-widget feature.

== Contact ==

Suggestion, fixes, rants, congratulations, gifts et al to rick[at]jinlabs.com