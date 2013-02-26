=== RSSImport ===
Contributors: Bueltge, novaclic
Plugin URI: http://bueltge.de/wp-wartungsmodus-plugin/101/
Author: Frank B&uuml;ltge
Author URI: http://bueltge.de/
Donate link: http://bueltge.de/wunschliste/
Tags: rss, post, content, post, feed
Requires at least: 1.5
Tested up to: 3.4
Stable tag: 4.4.12

Import and display Feeds in your blog, use PHP or the Shortcode.

== Description ==
Import and display Feeds in your blog, use PHP, a Widget or the Shortcode. The plugin use the standards of WordPress, non extra library; use [MagpieRSS](http://magpierss.sourceforge.net/) or [SimplePie](http://simplepie.org/) for parse feeds.

Use following code with a PHP-Plugin or in a template, example `sidebar.php` or `single.php`, for WordPress:

_Example:_
`&lt;?php RSSImport(10, 'http://bueltge.de/feed/'); ?&gt;`

This is smallest code for use the plugin with your own feed-url. The plugin have many parameters for custom import of content form a feed. See the list of parameters. You can also use all parameters with shorcode in posts and pages.

_Example for Shortcode:_
[RSSImport display="5" feedurl="http://bueltge.de/feed/"]

For all boolean parameter it is possible to use the string `true` or `false` or the integer value `0` or `1`.

1. `display` - How many items, Default is `5`
1. `feedurl` - Feed-Adress, Default is `http://bueltge.de/feed/`
1. `before_desc` - string before description, Default is `empty`
1. `displaydescriptions` - (bool) true or false for display description of the item, Default is `false`
1. `after_desc` - string after description, Default is `empty`; you can use the follow strings for custom html `%title%` for title of entry and `%href%` for link of entry
1. `html` - (bool) display description include HTML-tags, Default is `false`
1. `truncatedescchar` - truncate description, number of chars, Default is `200`, set the value to empty `''` for non truncate
1. `truncatedescstring` - string after truncate description, Default is ` ... `
1. `truncatetitlechar` - (int) truncate title, number of chars, Default is `empty`, set a integer `50` to the value for truncate
1. `truncatetitlestring` - string after truncate title, Default is `' ... '`
1. `before_date` - string before date, Default is ` <small>`
1. `date` - (bool) return the date of the item, Default is `false`
1. `after_date` - string after the date, Default is `</small>`
1. `date_format`- your format for the date, leave empty for use format of your WordPress installation, alternativ give the php date string, Example: `F j, Y`; see also [doku in Codex](http://codex.wordpress.org/Formatting_Date_and_Time)
1. `before_creator` - string before creator of the item, Default is ` <small>`
1. `creator` - (bool) return the creator of th item, Default is `false`
1. `after_creator` - string after creator of the item, Default is `</small>`
1. `start_items` - string before all items, Default is `<ul>`
1. `end_items` - string after all items, Default is `</ul>`
1. `start_item` - string before the item, Default is `<li>`
1. `end_item` - string after the items, Default is `</li>`
1. `target` - string with the target-attribut, Default is `empty`; use `blank`, `self`, `parent`, `top`
1. `rel` - string with the rel-attribut, Default is `empty`, use string, `nofollow`, `follow`
1. `desc4title` - Use description for the title-attribut on the title-link, Default is `false`
1. `charsetscan` - Scan for charset-type, load slowly; use this for problems with strings on the return content, Default is `false`
1. `debug` - activate debug-mode, echo the array of Magpie-Object; Default is `false`, Use only for debug purpose
1. `before_noitems` - HTML or string before message, when the feed is empty, Default is `<p>`
1. `noitems`- Message, when the feed is empty, Default is `No items, feed is empty.`
1. `after_noitems` - HTML or string before message, when the feed is empty, Default is `</p>`
1. `before_error` - HTML or string before message, when the feed have an error, Default is `<p>`
1. `error` - Errormessage, Default is `Error: Feed has a error or is not valid`
1. `after_error` - HTML or string before message, when the feed have an error, Default is `</p>`
1. `paging` - Pagination on, set `TRUE`, Default is `FALSE`
1. `prev_paging_link` - Linkname for previous page, Default is `&laquo; Previous`
1. `next_paging_link` - Linkname for next page, Default is `Next &raquo;`
1. `prev_paging_title` - Title for the link of previous page, Default is `more items`
1. `next_paging_title` - Title for the link of next page, Default is `more items`
1. `use_simplepie`- Use the class SimplePie for parse the feed; SimplePie is include with WordPress 2.8 and can parse RSS and ATOM-Feeds, Default is `false`
1. `view` - echo or return the content of the function `RSSImport`, Default is `true`; Shortcode Default is `false`

The pagination function add a div with the class `rsspaging` for design with CSS. Also youcan style the previous and next link with the classes: `rsspaging_prev` and `rsspaging_next`.

All parameters it is possible to use in the function, only in templates with PHP, and also with the Shortcode in posts and pges.

= Examples: =
_The function with many parameters:_

	RSSImport(
		$display = 5, $feedurl = 'http://bueltge.de/feed/', 
		$before_desc = '', $displaydescriptions = false, $after_desc = '', $html = false, $truncatedescchar = 200, $truncatedescstring = ' ... ', 
		$truncatetitlechar = '', $truncatetitlestring = ' ... ', 
		$before_date = ' <small>', $date = false, $after_date = '</small>', 
		$before_creator = ' <small>', $creator = false, $after_creator = '</small>', 
		$start_items = '<ul>', $end_items = '</ul>', 
		$start_item = '<li>', $end_item = '</li>' 
	)

_The shortcode with a lot of parameters:_

	[RSSImport display="10" feedurl="http://your_feed_url/" 
	displaydescriptions="true" html="true" 
	start_items="<ol>" end_items="</ol>" paging="true" ]

= Interested in WordPress tips and tricks =
You may also be interested in WordPress tips and tricks at [WP Engineer](http://wpengineer.com/) or for german people [bueltge.de](http://bueltge.de/) 


== Installation ==
1. Unpack the download-package
1. Upload all files to the `/wp-content/plugins/` directory
1. Activate the plugin through the 'Plugins' menu in WordPress
1. Create a new site in WordPress or edit your template
1. Copy the code in site-content or edit templates


== Screenshots ==
1. Widget support

== Changelog ==
= v4.4.12 (04/02/2012) =
* Bugfix: restored RSSImport QuickTag for Wordpress 3.3 and later
* Improvement: avoid PHP-notice when description is missing for an item
* TODO: add parameter to allow prefix of url (see http://wordpress.org/support/topic/plugin-rssimport-fix-for-headline-links-without-full-paths)
* TODO: check documentation of call to function (PHP), see http://wordpress.org/support/topic/plugin-rssimport-change-feed-display
* Documentation: corrected 'after_desc' (thanks to elricky for reporting)

= v4.4.11 (13/12/2011) =
* Bugfix: noitems string display is back
* Improvement: html_entity_decode feedurl when using shortcodes
* Maintenance: Add romanian language files

= v4.4.10 (01/12/2011) =
* Bugfix: add param desc4title on shortcodes
* Bugfix: Filter Feed-Url vor masked `&`; now works Yahoo Pipes feeds
* Maintenance: Translate strings from options

= v4.4.9 (09/16/2010) =
* Feature: add new param `desc4title` to add the description to title-attribut on title-links
* Bugfix: target parameter in widget
* Maintenance: rescan/rewrite de_DE language file
* Maintenance: rescan .pot

= v4.4.8 (06/04/2010) =
* small changes for better debugging
* change metadata for WordPress
* multilanguage plugin-description
* change error-handling on feeds; use WP-Error

= v4.4.7 (05/20/2010) =
* bugfix widget parameter for description
* small changes on source

= v4.4.6 (07/10/2009) =
* add function for WordPress lower version 2.8
* add option for format the date

= v4.4.5 (30/09/2009) =
* bugfix Widget-title
* include class SimpliePie for alternative parse
* new parameter `$use_simplepie` for active parse with class SimplePie
* change for boolean type, possible to use `true` or `false` and `1` or `0`

= v4.4.4 (15/09/2009) =
* change updatenotice to standard WP

= v4.4.3 (14/09/2009) =
* add strings %title% and %href% to replace in after-desc-option

= v4.4.2 (07/09/2009) =
* Bugfix for utl-value on shortcode
* change clean the title-attribut an links for multilanguage-support

= v4.4.1 (14/07/2009) =

* add rel attribut for links
* add widget support, WP 2.8 and higher

See on [the official website](http://bueltge.de/wp-rss-import-plugin/55/#historie "RSSImport Changelog") for older entries on changelog.


== Other Notes ==
= Acknowledgements =
Thanks to [Dave Wolf](http://www.davewolf.net, "Dave Wolf") for the idea, to [Thomas Fischer](http://www.securityfocus.de "Thomas Fischer") and [Gunnar Tillmann](http://www.gunnart.de "Gunnar Tillmann") for better code and Ilya Shindyapin, http://skookum.com for the idea and solution of pagination.

= Localizations =
* German language files by me [Frank B&uuml;ltge](http://bueltge.de/) ;-) 
* Russian translation by Fat Cow
* Ukrainian translation by [WordPress Ukraine](http://wpp.pp.ua/)
* French translation by [Martin Korolczuk](http://petitnuage.fr)
* Hungarian translation by [Feriman](http://feriman.com)
* Hindi translation by [Ashish Jha](http://outshinesolutions.com)
* Italian translation by [Gianni Diurno](http://gidibao.net/)
* Romanian language files, thanks to [Alexander Ovsov](http://webhostinggeeks.com/)
* Lithuanian translation files by [Vincent G](http://www.host1plus.com)
* Portuguese translation files by [Miguel Patricio Angelo](http://www.miguelpatricio.com/)

= Licence =
Good news, this plugin is free for everyone! Since it's released under the GPL, you can use it free of charge on your personal or commercial blog. But if you enjoy this plugin, you can thank me and leave a [small donation](http://bueltge.de/wunschliste/ "Wishliste and Donate") for the time I've spent writing and supporting this plugin. And I really don't want to know how many hours of my life this plugin has already eaten ;)

= Translations =
The plugin comes with various translations, please refer to the [WordPress Codex](http://codex.wordpress.org/Installing_WordPress_in_Your_Language "Installing WordPress in Your Language") for more information about activating the translation. If you want to help to translate the plugin to your language, please have a look at the sitemap.pot file which contains all defintions and may be used with a [gettext](http://www.gnu.org/software/gettext/) editor like [Poedit](http://www.poedit.net/) (Windows).
