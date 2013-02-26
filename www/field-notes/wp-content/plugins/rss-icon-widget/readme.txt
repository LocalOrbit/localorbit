=== RSS Icon Widget ===
Contributors: brandondove, jeffreyzinn
Donate link: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3497105
Tags: RSS Feed, Feed Icon, Widget, Sidebar
Requires at least: 2.8
Tested up to: 3.3
Stable tag: 3.0

== Description ==

We had a client who want to be able to put a link to his rss feed in his sidebar. Visit studiolightroom.com to check it out. Oddly enough we didn’t find anything readily available to do that without adding code to his theme files. We decided to create a little widget to handle this functionality. It has the following features and is freely available right here:

1. Customizable link text
2. Customizable link color
3. Selection of Standard Feed Icon (feedicons.com) in six different sizes
4. Enter any feed URL

http://www.youtube.com/watch?v=piDZibMb8NU

If you have any problems with this widget, please don't hesitate to let us know. If you use the widget and like it, please rate it.

== Installation ==

1. Upload `rss-icon-widget` folder and it's contents to your `/wp-content/plugins/` directory.
2. Activate the plugin through the 'Plugins' menu in WordPress.
3. Go to the "Appearance" section of the WordPress Admin.
4. Click on the "Widgets" sub-navigation.
5. Add the widget from the left on to the sidebar of your choice and rearrange its position to your liking.
6. Configure the widget to your liking.

== Frequently Asked Questions ==

= The color picker doesn't work! =

It actually does work, just not as designed. Because of the enhanced drag/drop widget interface in WordPress 2.8, there is a JavaScript issue that I'm working on fixing. The color picker will work if you save the widget. Take the following steps to side step the problem:

1. Drag/drop the widget to the sidebar.
2. Save the widget.
3. Configure the widget.
4. Save the widget.

= Widgets? What's a Widget? =

Ok. If you don't see mention of widgets in the WordPress admin, you're not crazy. Most themes utilize the widgets feature of WordPress, but some don't. You'll need to either switch your theme, or find someone who can widgetize your theme for you. If you don't know any widgeteers, let us know and we'll do our best to help you out.

== Changelog ==

= 3.0 =
- Cleaned up code
- Removed legacy (pre-2.8) support
- Added escaping for security purposes
- Added translation support