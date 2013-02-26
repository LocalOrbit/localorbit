=== Authors Widget ===
Contributors: flocsy
Donate link: http://blog.fleischer.hu/wordpress/authors/
Tags: authors, author, multi-author, multi-user, list, sidemenu, sidebar, links, widgets, widget, plugin, avatar, gravatar
Requires at least: 2.0.2
Tested up to: 3.5
Stable tag: trunk

Authors Widget shows the list or cloud of the authors in the sidemenu.

== Description ==

Authors Widget shows the list or cloud of the authors, with the number of posts, link to RSS feed next to their name, avatar. It is useful in a multi-author blog, where you want to have the list in the sidemenu.
The widget can also display an "Author Cloud" if [SEO Tag Cloud plugin](http://wordpress.org/extend/plugins/seo-tag-cloud/) is installed.

== Installation ==

To install Authors Widget follow the following steps:

1. Unpack `authors.zip` to `/wp-content/plugins/authors/` directory
2. Activate the plugin through the 'Plugins' menu in WordPress
3. Go to 'Presentation' or 'Design' or 'Appearance' menu
4. Go to 'Widgets' menu
5. Drag & Drop the Authors Widget to the place on your sidebar where you would like to display the authors' list

Optionally you can change the following settings:

1. Title
2. Format: list | cloud | dropdown
3. Order by: name | post count
4. Number of authors to show
5. Show Avatar
6. Avatar size
7. Show RSS links
8. Show post counts
9. Exclude admin
10. Hide credit
11. Save the changes

And you're welcome to [donate](http://blog.fleischer.hu/wordpress/authors/) to keep the plugin developed

== Frequently Asked Questions ==

= What languages Authors Widget is translated to? =

* English
* Hungarian / Magyar
* Russian / Русский by [Fat Cow](http://www.fatcow.com "Fat Cow")
* Spanish / Español by [Jos Velasco](http://cuanticawebs.com/ "Cuántica Webs")
* Turkish / Türkçe by [losing911]
* Bulgarian / български by [Dimitar Kolevski](http://webhostinggeeks.com/ "Web Geek")
* German / Deutsch by [Roland Heide](http://www.designcontest.com/ "Design Contest"), [Ralph Stenzel](http://www.fuerther-freiheit.info/)
* Lithuanian by [Nata Strazda](http://www.webhostinghub.com/ "Web Hub")
* Hebrew / עברית by [Sagive](http://sagive.co.il "Sagive SEO")
* Belarusian / беларуская by [Alexander Ovsov](http://webhostinggeeks.com/science/ "Web Geek Sciense")
* Polish / Polski [Krzysztof](http://pl2wp.prywatny.eu/)

= How can I exclude certain authors from being displayed? =

Add them to the Exclude list either by ID or user_login:

1,3,7

"admin","bob","joe"

= How can I include only certain authors? =

Add them to the Include list. The format is the same as for the Exclude.
Fill only one of the fields: either Include or Exclude, but not both of them.

== Screenshots ==

1. List style
2. Cloud style
3. List style with avatars
4. Dropdown style
5. Open the Appearance box in wp-admin and chose the Widgets menu
6. Drag Authors
7. Drop it to your Sidebar and set up the widget options
8. This is how it looks in older WP versions

== Upgrade Notice ==

== Changelog ==

= 2.2.2 =
* Changed donation button to comply with WP guidelines

= 2.2.1 =
* Changed hide_credit to show_credit to comply with WP guidelines

= 2.2 =
* Added feature: hide_empty - hide authors with 0 posts

= 2.1.1 =
* Added Polish translation

= 2.1 =
* Added option to Include certain authors

= 2.0.3 =
* Improved German translation
* Fixed ul bug

= 2.0.2 =
* Added Belarusian translation

= 2.0.1 =
* Added Turkish translation
* Added Hebrew translation

= 2.0 =
* Added feature: Exclude authors by ID or "user_login"
* Fixed warning: load_plugin_textdomain

= 1.9.1 =
* Fixed bug: Number of authors to show in list, dropdown format

= 1.9 =
* Added feature: show full name
* Added: order by first_name, last_name

= 1.8 =
* Fixed bug: order by posts didn't work when doesn't show post count

= 1.7 =
* Added feature: show avatar
* Fixed bug: exclude_admin now should work also for admins that have ID > 1, with user_name <> 'admin'

= 1.6.1 =
* Fixed bug: format radio buttons didn't show when seo-tag-cloud widget wasn't installed

= 1.6 =
* Added format option to show authors in dropdown menu
* Fixed bug: args don't work when used without widget

= 1.5 =
* Added option to show only top N authors (only in cloud format)

= 1.4 =
* Added credit link

= 1.3 =
* Added Cloud format
* Added option to choose format: list | cloud
* Added option to order by: name | post count

= 1.2 =
* Added Russian translation

= 1.1 =

= 1.0 =
