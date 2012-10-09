=== Tweetbacks ===
Contributors: joostdevalk
Donate link: http://yoast.com/donate/
Tags: comments, twitter, tweets, tweetback
Requires at least: 2.5
Tested up to: 2.7
stable tag: 1.5.3

Show tweets that mention your post as "tweetbacks" in your comments section.

== Description ==

People are talking about your posts, and not only in the comments to your post. A lot of that conversation is happening on Twitter, and now, you can take that conversation right back to your blog! This plugin imports those tweets about your posts as comments. You can display them in between the other comments on your blog, or display them separately.

More info:

* [TweetBacks](http://yoast.com/wordpress/tweetbacks/).
* Check out the other [Wordpress plugins](http://yoast.com/wordpress/) by the same author.

== Installation ==

Installation is easy:

* Download the plugin.
* Copy the folder to the plugins directory of your blog.
* Enable the plugin in your admin panel.

== Changelog ==

= Known issues =

* If a person changes their Twitter avatar, tweetbacks displays a link to a broken image. 

= 1.5.3 =

* Rewrote Avatar functionality, saving 2 kb of code and solving some bugs.

= 1.5.2 =

* Fix for the bitly empty URL issue.

= 1.5.1 =

* Removed error logging

= 1.5 =

* Several great fixes by Donncha, including moving from doing the tweetbacks get on the shutdown to WP-cron.

= 1.4.4 =

* Removed tr.im by request of tr.im, as they'll start blocking tweetbacks requests due to API issues.

= 1.4.3 = 

* Fixed empty post ID issue which caused problems with mainly bit.ly
* Fixed cleanup function to work on blogs where table_prefix is not wp_
* Fixed pattern recognition so twitter names with _'s in them are completely clickable too

= 1.4.2 =

* Made auto approving tweetbacks optional, and turned it off by default. Thanks to [blog.automated.it](http://blog.automated.it/2009/01/12/wordpress-tweetbacking/comment-page-1/) and [Phill Price](http://www.phillprice.com/) for the addition!
 
= 1.4.1 =

* Smarter way of checking results that come back from the url shortener API's.

= 1.4 =

* Removed zi.ma URL shortener due to API issues causing "spam-like" comments.

= 1.3 =

* Option to filter out retweets (which are still counted though, to give proper stats)
* Smarter shorturl filtering to prevent rate limiting issues

= 1.2 =

* Added option to filter out certain Twitter usernames 
* Added option to change the time between updates to the Twitter API
* Added more filtering of shorturls to prevent rate limiting errors
* Added option to clean up shorturls too
* (Temporarily) removed adjix.com URL shortener due to API issues
* Made sure the permalink itself is searched for as well, next to all the shorturls

= 1.1 =

* Added timeout to snoopy
* Added checks for empty shorturl's
* Added icon for Ozh Admin menu plugin
