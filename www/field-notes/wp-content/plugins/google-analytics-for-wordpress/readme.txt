=== Google Analytics for WordPress ===
Contributors: joostdevalk
Donate link: http://yoast.com/donate/
Tags: analytics, google analytics, statistics
Requires at least: 2.7
Tested up to: 2.9
Stable tag: 3.2.5

The Google Analytics for WordPress plugin automatically tracks and segments all outbound links from within posts, comment author links, links within comments, blogroll links and downloads. It also allows you to track AdSense clicks, add extra search engines, track image search queries and it will even work together with Urchin.

== Description ==

The Google Analytics for WordPress plugin automatically tracks and segments all outbound links from within posts, comment author links, links within comments, blogroll links and downloads. It also allows you to track AdSense clicks, add extra search engines, track image search queries and it will even work together with Urchin.

In the options panel for the plugin, you can determine the prefixes to use for the different kinds of outbound links and downloads it tracks.

* [Google Analytics for WordPress](http://yoast.com/wordpress/google-analytics/).
* Other [Wordpress plugins](http://yoast.com/wordpress/) by the same author.
* Check out the authors [WordPress Hosting](http://yoast.com/wordpress-hosting/) experience. Good hosting is hard to come by, but it doesn't have to be expensive, Joost tells you why!

== Installation ==

This section describes how to install the plugin and get it working.

1. Delete any existing `gapp` or `google-analytics-for-wordpress` folder from the `/wp-content/plugins/` directory
1. Upload `google-analytics-for-wordpress` folder to the `/wp-content/plugins/` directory
1. Activate the plugin through the 'Plugins' menu in WordPress
1. Go to the options panel under the 'Settings' menu and add your Analytics account number and set the settings you want.

== Changelog ==

= 3.2.5 =
* Fix for XSS vulnerability as mentioned [here](http://www.securityfocus.com/archive/1/508211).

= 3.2.4 =
* Fixed a bug in search tracking introduced with previous version.

= 3.2.3 =
* Added 0 result search tracking inspired by [Justin Cutroni's post](http://www.epikone.com/blog/2009/09/08/tracking-ero-result-searches-in-google-analytics/).

= 3.2.2 =
* Fix to the hashtag redirect so it actually works in all cases.

= 3.2.1 =
* Slight change to RSS URL tagging, now setting campaign to post name, and behaving better when not using rewritten URL's.
* Two patches by [Lee Willis](http://www.leewillis.co.uk):
	* Made some changes so the entire plugin works fine with .co.uk, .co.za etc domains.
	* Made sure internal blogroll links aren't tagged as external clicks.

= 3.2 =
* Added option to add tracking to add tracking to login / register pages, so you can track new signups (under Advanced settings).
* Added beta option to track Google image search as a search engine, needs more testing to make sure it works.
* Fixed a bug in the extra search engine tracking implementation.
* Removed redundant "More Info" section from readme.txt.

= 3.1.1 =
* Stupid typo that caused warnings.

= 3.1 =
* Added 404 tracking as described [here](http://www.google.com/support/googleanalytics/bin/answer.py?hl=en&answer=86927).
* Optimized the tracking script, if extra search engine tracking is disabled it'll be a lot smaller now.
* Various code optimizations to prevent PHP notices and removal of redundant code.

= 3.0.1 =
* Removed no longer needed code to add config page that caused PHP warnings.

= 3.0 =
* Major backend overhaul, using new Yoast backend class.
* Added ability to automatically redirect non hashtagged campaign URLs to hashtagged campaign URL's when setAllowAnchor is set to true (if you don't get it, forget about it, you might need it but don't need to worry)

= 2.9.5 =
* Fixed a bug with the included RSS, which came up when multiple Yoast plugins were installed.

= 2.9.4 =
* Changed to the new Changelog design.
* Removed pre 2.6 compatibility code, plugin now requires WP 2.6 or higher.
* Small changes to the admin screen.

= 2.9.3 =
* Added a new option for RSS link tagging, which allows you to tag your RSS feed links with RSS campaign variables. When you've set campaign variables to use # instead of ?, this will adhere to that setting too. Thanks to [Timan Rebel](http://rebelic.nl/) for the idea and code.

= 2.9.2: =
* Added a check to see whether the wp_footer() call is in footer.php.
* Added a message to the source when tracking code is left out because user is logged in as admin.
* Added option to segment logged in users.
* Added try - catch to script lines like in new Google Analytics scripts.
* Fixed bug in warning when no UA code is entered.
* Prevent link tracking when admin is logged in and admin tracking is disabled.
* Now prevents parsing of non http and https link.

= 2.9 = 
* Re arranged admin panel to have "standard" and "advanced" settings.
* Added domain tracking.
* Added fix for double onclick parameter, as suggested [here](http://wordpress.org/support/topic/241757).

= 2.8 = 
* Added the option to add setAllowAnchor to the tracking code, allowing you to track campaigns with # instead of ?.

= 2.7 = 
* Added option to select either header of footer position.
* Added new AdSense integration options.
* Removed now unneeded adsense tracking script.

= 2.6.6=
* Fixed settings link.

= 2.6.5 = 
* added Ozh admin menu icon and settings link.

= 2.6.4 = 
* Fixes for 2.7.

= 2.6.3 = 
* Fixed bug that didn't allow saving of outbound clicks from comments string.

= 2.6 =
* Fixed incompatibility with WP 2.6.

= 2.5.4 =
* Fixed an issue with pluginpath being used globally.
* Changed links to [new domain](http://yoast.com/).

= 2.2 = 
* Switched to the new tracking code.

= 2.1 = 
* Made sure tracking was disabled on preview pages.

= 2.0 = 
* Added AdSense tracking.

= 1.5 =
* Added option to enable admin tracking, off by default.

== Frequently Asked Questions ==

= This inflates my clicks, can I filter those out? =

Yes you can, create a new profile based on your original profile and name it something like 'domain - clean'. For each different outbound clicks or download prefix you have, create an exclude filter. You do this by:

1. choosing a name for the filter, something like 'Exclude Downloads';
1. selecting 'Custom filter' from the dropdown;
1. selecting 'Exclude';
1. selecting 'Request URI' in the Filter Field dropdown;
1. setting the Filter Pattern to '/downloads/(.*)$' for a prefix '/downloads/';
1. setting case sensitive to 'No'.

For some more info, see the screenshot under Screenshots.

= Can I run this plugin together with another Google Analytics plugin? =

No. You can not. It will break tracking.

= How do I check the image search stats and keywords after installing this plugin? =

Check out this <a href="http://yoast.com/wordpress/google-analytics/how-to-check-your-image-search-stats-and-keywords/">tutorial on checking your image search stats and keywords</a>.

= How do I check my outbound link and download stats? =

Check out this <a href="http://yoast.com/wordpress/google-analytics/checking-your-outbound-click-stats/">tutorial on checking your outbound click stats</a>.

= I want the image search keywords in one big overview... =

Create a <a href="http://yoast.com/wordpress/google-analytics/creating-a-google-analytics-filter-for-image-search/">Google Analytics filter for image search</a>.

== Screenshots ==

1. Screenshot of the configuration panel for this plugin.
2. Example of the exclude filter in Google Analytics.
