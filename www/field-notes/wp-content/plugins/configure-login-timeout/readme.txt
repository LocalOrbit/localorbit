=== configure-login-timeout ===
Plugin Name: Configure Login Timeout
Contributors: n8v
Donate link: http://worldvision.org
Tags: timeout, cookie, user, users, admin, remember, remember me, authentication, author, automatic, comments, password, login, log in, logout, log out, session, expiration, expiry, expires, weeks, days
Requires at least: 2.8
Tested up to: 3.1beta
Stable tag: trunk
Version: 1.0

== Description ==

By default, WordPress makes your login session cookie expire in 48 hours (or on browser close), or 14 days if you check the "Remember Me" box.  This plugin makes those timeout values user-configurable through the Users admin control panel.

== Installation ==

= Prerequisites =

I don't think this will work with versions of WordPress earlier than 2.8, when the current option pages were implemented.  You may want to [directly hack the timeout values in the source code](http://www.planetmike.com/2008/06/30/how-to-make-the-wordpress-login-cookie-last-longer-than-two-weeks/) if you're running an earlier version of WordPress.

The control panel uses Javascript.  It may not work on really archaic browsers.

= Installification = 
1. Either
  1. Unpack the zip file and upload the files to `wp-content/plugins/configure-login-timeout`, 

     or my favorite,
  2. Check it out fresh with Subversion:
<pre>
     cd wp-content/plugins
     svn co http://plugins.svn.wordpress.org/configure-login-timeout/trunk configure-login-timeout
</pre>

2. Activate the plugin through the 'Plugins' menu in WordPress.
3. Go to Users->Login Timeout to configure your site's login timeouts.
4. You'll have to log out and log in again for the new timeout to take effect on your session.


== Frequently Asked Questions ==

= Q. How many questions have been asked about this plugin? =
A.  None at all.  Not one.  Zero.

== Screenshots ==

1. This plugin lets you easily adjust the login timeout settings.

== Changelog == 

= 1.0 = 

Initial release


