=== Subscription Options ===
Contributors: Tom Saunter
Donate link: http://bit.ly/donate_to_me
Tags: subscription, subscribe, option, options, color, colour, colors, colours, feedburner, rss, feed, mail, email, service, twitter, stream, follow, facebook, page, delivery, linkedin, flickr, google, google plus, google+, podcast, podcasting, itunes, youtube, channel, pinterest, pin, spotify, tumblr, icon, icons, widget, sidebar, settings
Requires at least: 2.8
Tested up to: 3.4.2
Stable tag: 0.9.1
Adds subscription option icons for your RSS Feed; your FeedBurner Email Service; your Twitter Stream and your Facebook page. Totally user-defined.
== Description ==
The most common ways for people to subscribe to a blog and its content are through RSS, Email and Twitter. Some people syndicate to Facebook too. This plugin places related subscription icons in a widget area and lets users enter their own feed or page URLs and select the colour of their icons. Its really simple but theres lots of power under the hood.
= Features: =
* Offers an attractive range of subscription options for your readers using familiar-looking icons.
* Intuitive interface for editing options, including your feed or page URLs, widget title and icon sizes.
* Independent handling across multiple widget instances, using WordPress 2.8's widget_class coolness.
* Ability to select any colour, via HEX code or [HTML Color Name](http://www.w3schools.com/html/html_colornames.asp).
* Integration with the [Subscription Options Add-on Pack](http://digitalcortex.net/plugins/subscription-options/addon-pack).
== Installation ==
1. Download the plugin by hitting the big red 'download' button.
2. Extract the files and place the entire 'subscription-options' folder into your wp_content/plugins directory.
3. Go to your 'Installed Plugins' panel and activate 'Subscription Options'.
4. You are now ready to use the widget.
= Setup: =
* Go to your 'Appearance > Widgets' panel and select the widget area you wish for the plugin to appear in.
* Enter the following details:
1. Widget Title
2. RSS Feed URL & Colour
3. Email Service URL & Colour
4. Twitter Stream URL & Colour
5. Facebook Page URL & Colour
6. Size of Feed Icons

* Please note that you don't need to use all the icons - just don't enter a URL if you don't want an icon to show up.
* Please also note that you can use any HTML colour code, be it HEX code or [HTML Color Name](http://www.w3schools.com/html/html_colornames.asp).
* Hit 'Done' then 'Save Changes'. Test the appearance and perhaps change the size of the icons as necessary.
* If you would like additional icons for LinkedIn, Flickr, Google+, Podcasting, YouTube, Pinterest, Spotify or Tumblr please consider installing the [Subscription Options Add-on Pack](http://digitalcortex.net/plugins/subscription-options/addon-pack) and a new set of subscription options will automatically appear in the widget options panel.
== Screenshots ==
1.  This is how the plugin could look on your blog.
2.  This is the widget options panel.
3.  These are some example configurations.
== Changelog ==
* 0.1.0 was the first iteration of what I promise will be a participatory experience
* 0.1.5 - added css classes for users to hook into and edit through their css sheets
* 0.2 - added user-defined header size and target of users' clicks
* 0.3 - updated icons to scale up to higher sizes without dithering
* 0.4 - switched to WP 2.8's widget_class functionality to really crank it up
* 0.5 - inclusion of a new subscription icon for Facebook, by popular demand
* 0.6 - implemented an icon colour changer with twelve options
* 0.7 - upgraded to pass XHTML 1.0 Transitional validation
* 0.8 - full colour options & additional subscription icons based on user feedback
* 0.9 - modified icon designs plus four new icons in the [Add-on Pack](http://digitalcortex.net/plugins/subscription-options/addon-pack)
= Future Versions: =
* 1.0 - farbtastic or other java-based colour picker integration
== Upgrade Notice ==
= 0.9 =
If you're upgrading from version 0.7 or earlier, then you will need to re-enter your colour codes and check that all your URLs are present. Version 0.8 brought in thousands of new colour options, using transparent icons and CSS3 rounded corners. As such, the widget looks best in modern CSS3-compatible web browsers, so please upgrade only if you are entirely comfortable with this.
== Frequently Asked Questions ==
= Where do I put the widget? =
You can place the widget wherever you like as long as it is within a pre-defined widget area. I haven't worked out how to let people place the widget wherever they like. Let me know if you can help on my [contact page](http://digitalcortex.net/contact) though.
= Can I style the widget in my own way? =
Yes of course, it's WordPress! You can use your stylesheet.css or this widget's internal stylesheet to override your theme's default widget settings by using the following CSS classes:

* img.suboptions-icon - all icons (useful for setting alignment or spacing)
* img.rss-icon - the RSS feed icon
* img.email-icon - the email service icon
* img.twitter-icon - the Twitter icon
* img.facebook-icon - the Facebook icon
Please note that the icons' sizes will still need to be set from within the widget admin panel. CSS doesn't let you override that.
= Why have my icons turned grey and colourless? =
You'll need to re-enter your colours, as the widget now uses a different way to pick them. You can pick any HTML colour, be it via HEX code or [HTML Color Name](http://www.w3schools.com/html/html_colornames.asp). Just enter your preference and hit 'Save' in the widget settings.
= Why don't my icons have nice rounded corners any more? =
The latest version of this plugin gives you thousands of new colour options, using transparent icons and CSS3 rounded corners. As such, the widget looks best in modern CSS3-compatible web browsers such as Firefox, Google Chrome or IE9. If you are not entirely comfortable with this, you can always roll back to an [older version](http://wordpress.org/extend/plugins/subscription-options/download).
= How do I find my Feedburner Email Service URL? =
The clickstream from within Feedburner looks like this: Publicize > Email Subscriptions > Activate. Then right click and copy the text that says 'Preview Subscription Link...' That's your Feedburner Email Service URL.
= Where can I find more help and support? =
Just email me from the contact page on [my blog](http://digitalcortex.net/contact) or leave a comment [right here](http://digitalcortex.net/plugins/subscription-options). I'll be happy to help where possible.
= I'm a fan of this plugin. What are my options? = [Digital Cortex](http://digitalcortex.net) ([rss](http://feeds.feedburner.com/digitalcortex)) is actively seeking new fans & followers on [Facebook](http://facebook.com/digitalcortex) and [Twitter](http://twitter.com/freedimensional) if you fancy it?
= How can I support the development of this plugin? =
Thank you so much for asking. There are a couple of options. You can purchase the [Subscription Options Add-on Pack](http://digitalcortex.net/plugins/subscription-options/addon-pack) for $1.50, or you can [donate here](http://bit.ly/donate_to_me) without upgrading.