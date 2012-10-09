=== UMapper ===
Contributors: umapper
Donate link: http://www.umapper.com/
Tags: google, google maps, openstreet, virtual earth, maps, kml, kmz, routes, flash, Post, admin, widgets, media, geo, shortcodes
Requires at least: 2.5.1
Tested up to: 2.6.3
Stable tag: trunk

UMapper makes it a snap to create engaging maps and add them to your blog posts. Features integrated map editor - no KML knowledge required! 

== Description ==

The __UMapper__ plugin is a universal mapping platform that makes it a snap to create engaging maps and add them to your blog posts. Microsoft Virtual Earth, Google Maps, Yahoo and OpenStreet are all supported by this truly universal plugin.

__Support:__

If you encounter any problem whatsoever, please, feel free to contact me via victor ~at~ afcomponents ~dot~ com.

__New version includes:__

* New provider added - Yahoo!
* You can now import your feeds directly into map editor - acceptable formats are KML, GPX, GeoRSS
* Link Data Feed
* I18n support - currently work in progress (support for Russian language was added for beta)
* WordPressMU is truly supported - just enter [UMapper Integrator's Key](http://www.umapper.com/developers/api/integrator/) as site admin and all your hosted blogs would be able to interact with UMapper.com - no other keys are required!
* By popular request: custom map sizes are now available!
* Ability to delete maps from within plugin w/o visiting UMapper site.
* Rewritten UI, should make map creation much more simple.

__Supported map providers:__

* Microsoft Virtual Earth
* Google Maps
* OpenStreet
* Yahoo!

__Features:__

* Integrated map editor - manipulating geo contents has never been easier!
* Switching between map providers when creating a map, and later on when editing.
* Popular shortcode architecture introduced in WordPress 2.5
* Editor has HTML capabilities and allows Wikipedia and GeoNames search!!
* Allows non-technical users to create and manipulate objects, markers and geometrical shapes on the map
* Provides "save" and "edit" functionality
* Provides collaboration tools, map wiki, and social networking features (comments, ratings, etc.)
* Allows map distribution via embeds and widgets
* Allows syndication of map data using KML 

__More Info:__

* Make sure you check out [FAQ](http://wordpress.org/extend/plugins/umapper/faq/) and [Screenshots](http://wordpress.org/extend/plugins/umapper/screenshots/)
* [UMapper official site](http://www.umapper.com/) and [UMapper Developer Central](http://www.umapper.com/developers/) in case you want to write your own plugins/extensions
* [UMapper Google Group](http://groups.google.com/group/umapper?hl=en) - questions, support requests, feature suggestions
* [UMapper flash component](http://www.afcomponents.com/components/umap_as3/) on [AFC](http://www.afcomponents.com/components/)

== Requirements ==

General requirements:

* PHP 5.2.5 (5.1+ would probably also be ok, although no tests have been done)
* WordPress 2.5.1+ (we test each stable version when it becomes availble)
* JS is enabled in browser

Umapper plugin was tested to run in following browsers:

* Firefox 2 - fully supported
* IE 7 - this browser is not advised as WordPress has several limitations/bugs when run in it.
* Apple Safari 3 - fully supported
* Opera 9 - fully supported
* Generally any browser supported by WordPress should be ok

== Installation ==

Please review [requirements](http://wordpress.org/extend/plugins/umapper/other_notes/) for using this plugin.

This section describes how to install the plugin and get it working.

__Stand-alone WordPress installation:__

1. Download the plugin and unzip archive into `/wp-content/plugins/` directory. 
1. Login into your blog as admin and activate the plugin through the 'Plugins' menu in WordPress
1. Once activated, you should see the warning requiring you to obtain API-key for UMapper.
1. UMapper configuration page can be accessed directly at `Plugins/UMapper Configuration` menu in WordPress or by clicking the link present in above-mentioned warning.
1. In order to operate the plugin you need to obtain API-key from [Umapper](http://www.umapper.com/). Just [sign-up](http://www.umapper.com/account/signup/) for a free account, and then, on account page, request the key.
1. Once you enter the UMapper API-key, your plugin is ready to rock!
1. Make sure you go through [FAQ](http://wordpress.org/extend/plugins/umapper/faq/) and [Notes](http://wordpress.org/extend/plugins/umapper/other_notes/) for any additional information.

__WordPressMU installation:__

1. Download the plugin and unzip archive into `/wp-content/plugins/` directory. 
1. Copy `umapper-mu-inc.php` into `/wp-content/mu-plugins/directory`
1. Obtain Integrator's API-Key, if you do not want your users bother with manual key activation per blog. If you do not get Integrator's API-Key, then installation for hosted blogs is exactly the same as for stand-alone WordPress (described above)
1. Go to `Admin Panel/Site Admin/UMapper` and activate obtained Integrator's Key
1. That's all - your users would auto-get sub-accounts and API keys automatically once they try to use the plugin.

__NOTES:__
Generally, all your users on WordPressMU would have to activate their local copy of UMapper plugin. If you want UMapper plugin (or any other for that matter) to be auto-activated - I suggest you use [Plugin Commander](http://mu.wordpress.org/forums/topic.php?id=9570).

== Screenshots ==
1. Admin / Integrated Map Editor
2. Lines and markers example.
3. Polygon usage example.
4. Maps in your language!
5. UMapper editor fully supports HTML - check out this MU stadium image.
6. Wikipedia search example.

== Use Instructions ==

1. Would be uploaded soon.

== Frequently Asked Questions ==

= I have several blogs, can I re-use single API-key for all of them, or should I obtain separate key for each of this blogs? =

For simplisity and ease of use you are required to obtain API-key only once, then you can re-use it on any number of WordPress installations. Moreover, if in future UMapper would add support for other platforms, such as Joomla, you would be able to reuse the very same key for them too.

= What PHP and WordPress versions are required to successfully run the plugin? =

Plugin was tested to run with following versions:

* PHP 5.2.5
* WordPress 2.5.1
* JS is enabled in browser

Plugin will NOT work with PHP4, if you are still using it, consider upgrading - it's really the time PHP4 gives way to PHP5.

= Which browsers have been tested and fully support the plugin? =
Here is the list:

* Firefox 2 - fully supported
* IE 7 - this browser is not advised as WordPress has several limitations/bugs when run in it. Plugin support for this browser is scheduled.
* Apple Safari 3 - fully supported
* Opera 9 - fully supported

= I am getting "parse error, unexpected T_STRING, expecting T_OLD_FUNCTION or T_FUNCTION or T_VAR or '}' in Umapper.php.." error. What causes it? =

You are using PHP4 and PHP5 is required to run the plugin.

= What is the exact code I need to use to add UMapper maps in my posts? =

You do not need to type the code manually, UMapper was designed to be as simple as possible. 
Just navigate to post edit page and click the U button (it is located in Add Media block) to open user-friendly map addition window.

= Am I required to get an account on UMapper and why would I need one? =
Yes, you are required to obtain account on [UMapper](http://www.umapper.com/). The reason is simple - 
by registering an account you obtain API-key which serves as a bridge between your WP installations and UMapper API.
As UMapper strives to become really universal, single account registration would be enough to power any number of WP blogs,
as well as any other platforms we would support in future.

= What about WordPress MU? = 
Plugin should work w/o problems.

= Where maps are stored? = 
Map data is stored on [UMapper's servers](http://www.umapper.com). You can restrict access to your maps on UMapper site, by logging into your account and editing map preferences.


= Can I use my maps on pages as well as blog posts? =
Yes.

= Can I request/suggest a feature and how long does it normally take to be implemented? =
Feature requests and bug submissions should go through [UMapper's Google Group](http://groups.google.com/group/umapper?hl=en). 
UMapper is under heavy development and it normally takes 2-3 days for a new features, and about 12 (generally less) hours for bug requests. So, please, take your time and help us building better UMapper!

= Can I edit map once it is created? =
Absolutely. Starting from version 1.3 you can just select previously added `[umap]` tag and hit UMapper media button - new window would contain your previously added map.

