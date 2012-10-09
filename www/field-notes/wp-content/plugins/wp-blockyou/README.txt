=== WP-BlockYou ===
Contributors: JulesR
Tags: comments, block, ban, spam, admin
Donate link: http://www.thiswebhost.com/blog/wp-blockyou/
Requires at least: 2.0.0
Tested up to: 2.5.1
Stable tag: trunk

A plugin that can be used to block or "ban" users via their IP address from viewing your blog, and then redirecting them to a URL of your choice.

== Description ==

Comment blacklisting works well, but what if you actually want to stop someone from even *reading* your blog? This plugin will take care of that for you.

It uses .htaccess file modifications to deny access to your blog from particular IP addresses (Deny from) and then follows up with an ErrorDocument 403 redirect to a URL of your choice. It doesn't hook into Wordpress, which makes it a lot faster due to no database or PHP calls.

== Installation ==

1. Upload `wp-blockyou` folder to the `/wp-content/plugins/` directory.
2. Activate the plugin through the 'Plugins' menu in WordPress.
3. Configure plugin under 'Settings' menu.

== Frequently Asked Questions ==

= Will this overwrite my existing .htaccess additions? =

No, this plugin will only append its own rules to the file, and will not remove existing content.

= I've messed something up and now I've blocked myself out of my blog, help! =

Simply edit the .htaccess file manually via FTP or directly on the server, and remove everything between the "# start wp-block" and "# end wp-block" code blocks.

== Screenshots ==

1. Screenshot Admin Area
