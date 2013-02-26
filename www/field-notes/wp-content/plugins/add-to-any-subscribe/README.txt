=== AddToAny: Subscribe Button ===
Contributors: micropat
Donate link: http://www.addtoany.com/contact/
Tags: widget, sidebar, rss, plugin, links, feed, feeds, images, admin, button, Post, posts, subscribe, add to any, addtoany, add, any, email, e-mail, mobile, Google, My, Yahoo, iTunes, Feeds
Requires at least: 2.8
Tested up to: 3.0
Stable tag: 0.9.9.1

Help people subscribe to your blog using email or any feed reader, such as Google Reader, My Yahoo! and many more feed services.

== Description ==

The Subscribe button helps people **subscribe** to your blog using **any feed reader**, such as Google Reader, My Yahoo!, Netvibes, Windows Live, and all other RSS readers.  The button comes with AddToAny's customizable Smart Menu, which **places the services visitors use at the top of the menu**, based on each visitor's browsing and usage history.

<a href="http://www.addtoany.com/buttons/subscribe" title="Subscribe button and share button" target="_blank">Subscribe Button</a> (standard)

* AddToAny <a href="http://www.addtoany.com/blog/smart-menus-the-services-your-visitors-use-displayed-first/" target="_blank">Smart Menu</a>
* Includes all services
* Services updated automatically
* WordPress optimized, localized (i18n for English, Chinese, French, Danish)
* Support for WordPress MU (WPMU)
* Many more publisher and user features

See also:

* The <a href="/extend/plugins/add-to-any/" title="Sharing plugin">Share/Bookmark/Email button</a> plugin.
* The <a href="http://www.addtoany.com/buttons/for/wordpress_com" title="WordPress.com sharing button widget" target="_blank">Share button for WordPress.com</a> blogs

== Installation ==

1. Upload the `add-to-any-subscribe` directory (including all files within) to the `/wp-content/plugins/` directory
1. Activate the plugin through the `Plugins` menu in WordPress
1. Go to `Appearance` -> `Widgets` and click `Add` next to "AddToAny Subscribe"

== Frequently Asked Questions ==

= How often is the list of services updated? =

Constantly... and it's done automatically without having to upgrade.

= Where can I choose which button to display and other options? =

Go to `Settings` > `Subscribe Buttons`. 

= Why isn't the drop-down menu appearing for the button? =

It's likely because your theme wasn't <a href="http://codex.wordpress.org/Theme_Development#Plugin_API_Hooks" target="_blank">coded properly</a>.  Using the Theme Editor, make sure that the following piece of code is included in your theme's `footer.php` file just before the `</body>` line:

`<?php wp_footer(); ?>`

= How come the widget doesn't display once I activate it? =

You'll have to manually put it where you want it in your sidebar.  You can do so by going to `Presentation` > `Widgets` and clicking `Add` next to "AddToAny Subscribe".  You'll need to have a "widget ready" theme.

If you have already added the widget but the actual button is not displaying, you should reinstall the widget, making sure to copy the actual `add-to-any-subscribe` folder (and all of its contents) to your plugins folder.

Also, be sure to deactivate any previous versions of the widget in the `Plugins` tab.

= What if I don't have a "widget ready" theme, or I want to place the button somewhere else? =

Using the Theme Editor, you can place the following code in your template pages (within sidebar.php, index.php, single.php, and/or page.php):

`<?php if( class_exists('Add_to_Any_Subscribe_Widget') ) { Add_to_Any_Subscribe_Widget::display(); } ?>`

= How can I customize the feed of the widget? (Useful for comment feeds, category feeds, etc.) =

This can be done through the template tag (as described above).  Simply supply a feed name and feed URL through the template tag like so:

`<?php if( class_exists('Add_to_Any_Subscribe_Widget') ) {
	$A2A_SUBSCRIBE_options = array(
		"feedname" => "Name of the Feed",
		"feedurl" => "http://www.example.com/feed");
	Add_to_Any_Subscribe_Widget::display( $A2A_SUBSCRIBE_options );
} ?>`

= Why do embedded objects (like Flash) disappear when the menu is displayed? =

This is done to overcome browser limitations that prevent the drop-down menu from displaying on top of intersecting embedded objects.  If you would like to disable this, uncheck the `Hide embedded objects (Flash, video, etc.) that intersect with the menu when displayed` option on the plugin's settings page.

= For WordPress MU (WPMU), how can I set the plugin to automatically execute so that it's available as a widget for all blogs? =

Upload the plugin directory (including all files within) to the `/wp-content/mu-plugins/` folder, then move the `add-to-any-subscribe.php` file from the plugin directory to the `mu-plugins` folder so that it can auto-execute.

== Screenshots ==

1. This is the AddTo Subscribe button
2. This is the drop-down menu that appears instantly when visitors move the mouse over the Subscribe button
3. This is the drop-down menu showing the services available to the user within the Subscribe menu.  Services are constantly added/updated.

== Changelog ==

= .9.9.1 =
* Fix critical issue affecting hard-coded placements using the template code function
 * http://wordpress.org/support/topic/428113
* Replace deprecated function
* Fixes for debug mode notices
* Add Italian translation by <a href="http://gidibao.net/">Gianni</a>

= .9.9 =
* Major rewrite to support New Widgets API since WP 2.8
* Work around WP core issue to use HTTPS/SSL for static content files, like the buttons and files in admin
 * http://core.trac.wordpress.org/ticket/13941
* Nonce validation for admin form
* Switch more options to <a href="http://www.addtoany.com/blog/new-menu-api-examples-documentation/">new API spec</a>
* Deprecate embedded object hiding option in favor of Menu API due to a new automatic workaround and a change in default value
 * If you need to have AddToAny hide objects (like Flash) to display the AddToAny menu, set a2a_config.hide_embeds = 1; in the Additional Options box
* Fixes for debug mode notices
* Planned support for multi-widget (different options per widget instance)
 * Not yet implemented
* Spaces in "Add to Any" removed, now camel-case: "AddToAny"

= .9.8.1 =
* SSL - HTTPS support
* Fixed a potential semantic HTML validation issue when used as a WordPress widget

= .9.8 =
* Important note: If you are using the AddToAny Share plugin, be sure to update that plugin to version 9.9.5+
* Faster menu initialization
* Switched to AddToAny's <a href="http://www.addtoany.com/blog/new-menu-api-examples-documentation/">new API spec</a>
* Fixed localization
* Also no longer outputs language strings if WordPress locale is set to "en" (or the default "en_US")
* Updated AddToAny icon
* French translation

= .9.7.2 =
* Automatic support for over 50 languages
 * The drop-down menu automatically detects the visitor's set language and localizes accordingly
* Less JavaScript output; removed redundant code
 * No longer outputs language strings if WordPress locale is set to the default "en_US"
* Forward support for WordPress 2.9

= .9.7.1 =
* French translation (by <a href="http://wittwer.fr">Whiler</a>

= .9.7 =
* Accept optional text with the small Subscribe button
 * Note: "Subscribe" text will appear by default for the small icon
* Added admin action links
* Updated readme
 * Installation
 * Changelog formatting

= .9.6.5 =
* i18n folder renamed to languages due to a problem with the CodeStyling Localization plugin
* Fixed textdomain
* Basename cleanup
* Support for WPMU auto-execution (thanks <a href="http://www.frozenpc.net/">Aaron</a>)

= .9.6.4.1 =
* Fix for blogs without titles

= .9.6.4 =
* Automatic localization/i18n

= .9.6.3 =
* wp_footer() detection
* Replaced short form of PHP's open tags with long form to work around configurations with shortopentag disabled

= .9.6.2.2 =
* Settings panel submits to current page instead of unreliable REQUEST_URI which can omit querystring on IIS
 * See http://www.microsoft.com/downloads/results.aspx?freetext=954946

= .9.6.2.1 =
* Highlight admin notices
* Danish translation (by <a href="http://wordpress.blogos.dk/" target="_blank">Georg</a>)
* FAQ

= .9.6.2 =
* Important syntax fix

= .9.6.1 =
* Additional options / JavaScript API clarification
* i18n update 

= .9.6 =
* Widget title option
* Text-only button stripslashes

= .9.5.5.6 =
* Chinese translation updated

= .9.5.5.5 =
* i18n
* Chinese translation
* Installation clarified

= .9.5.5.4 =
* WordPress 2.7 admin styling
* Settings link on Plugins page
* Basename var

= .9.5.5.3 =
* Less JavaScript redundancy from Additional Options (saves bandwidth)
* Compressed PNGs added, select a button from settings to begin using PNG (saves bandwidth)

= .9.5.5.2 =
* Additional Options in Admin panel provides link to JavaScript API
* Option to have full addtoany.com legacy page open in a new window

= .9.5.5.1 =
* Replaced short form of PHP's open tags with long form to work around configurations with short_open_tag disabled

= .9.5.5 =
* Accomodates renamed plugin directory

= .9.5.4 =
* Fixed a small syntax error (critcal if you're on .9.5.3)

= .9.5.3 =
* Language & localization update

= .9.5.2 =
* Event attributes removed (JS now takes care of button events)
 * This eliminates the chance of errors prior to JS fully loading

= .9.5.1 =
* Fixed repo problem

= .9.5 =
* Supports custom feeds using through template tag
* Updated template tag to prevent PHP errors when deactivating plugin
* For XHTML validation, special characters are converted to HTML entities within JavaScript variables
* Reprioritized plugin to load later
* Text-only button option

= .9.4 =
* Internationalization
* Buttons updated

= .9.3 =
* Moved external JavaScript to bottom so that content is prioritized over HTTP requests to static.addtoany.com
 * Please note that some improperly-coded themes may prevent this from working. See the FAQ entry for "Why isn't the drop-down menu appearing?" if this is the case.
* Added support to better conform to widget-ready themes
* Fixed markup generation to support list containers and ensure W3C validation

= .9.2.2 =
* Fixed bug in Internet Explorer 6 that caused custom buttons to have a height and width of 0
* Removed the XHTML deprecated `name` attribute from the button's anchor

= .9.2.1 =
* Fixed 1 line to support those without short_open_tag

= .9.2 =
* New: Custom buttons (specify a URL)
* Fix to permit XHTML Strict validation

= .9.1 =
* New Menu Styler lets you customize the color of the menus
* New Menu Option: "Only show the menu when the user clicks the Subscribe button"
* New additional customization: Set custom JavaScript variables
* Simplified config panel in `Design` > `Widgets` with link to `More Settings...`
* New full settings panel in: `Settings` > `Subscribe Buttons`
* Better support for CSS styling: .addtoany_share_save
* PHP support for short_open_tag
* PHP4 legacy and compatibility fixes