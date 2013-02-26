=== Twitter Tools: bit.ly Links ===
Contributors: Viper007Bond
Donate link: http://www.viper007bond.com/donate/
Tags: twitter
Requires at least: 2.7
Tested up to: 2.8
Stable tag: trunk

Makes the links that Twitter Tools posts to Twitter be API-created bit.ly links so you can track the number of clicks and such via your bit.ly account.

== Description ==

[Twitter Tools](http://wordpress.org/extend/plugins/twitter-tools/) is an excellent plugin for posting notifications of new blog posts to [Twitter](http://twitter.com/). However Twitter Tools just sends the URL to the new post normally which is then shortened by Twitter itself to a [bit.ly](http://bit.ly/) short link. This is done anonymously.

This plugin will replace the normal URLs sent by Twitter Tools to Twitter with bit.ly URLs tied to your bit.ly account. You can then easily track the number of clicks from your bit.ly profile.

**Requirements**

* [Twitter Tools](http://wordpress.org/extend/plugins/twitter-tools/) be installed and activated
* PHP 5.2.0 or newer (PHP4 is dead anyway)
* WordPress 2.7 or newer

== Installation ==

###Manual Installation###

Extract all files from the ZIP file, **making sure to keep the file/folder structure intact**, and then upload it to `/wp-content/plugins/`.

###Automated Installation###

Visit Plugins -> Add New in your admin area and search for this plugin. Click "Install".

**See Also:** ["Installing Plugins" article on the WP Codex](http://codex.wordpress.org/Managing_Plugins#Installing_Plugins)

###Plugin Usage###

Visit Settings -> Twitter Tools: bit.ly and fill in your login and API key.

== Frequently Asked Questions ==

= It's not working! =

Did you make sure to fill in your bit.ly login and API key on the plugin's settings page?

== ChangeLog ==

**Version 1.1.2**

* Starting with version 2.0, Twitter Tools comes with it's own plugin to allow this. As such, my plugin will now give way to if the other plugin is activated.

**Version 1.1.1**

* Display an error message to the user if they don't meet the minimum PHP and WordPress version requirements.

**Version 1.1.0**

* Apparently you need `history=1` in the API call in order for it to show up in your history. That was my problem.
* Minor settings page improvements.

**Version 1.0.1**

* Fix a stupid mistake on my part that completely broke the plugin.

**Version 1.0.0**

* Initial release!