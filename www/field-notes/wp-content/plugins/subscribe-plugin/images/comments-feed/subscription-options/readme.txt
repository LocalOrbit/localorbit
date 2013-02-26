=== Subscription Options ===
Contributors: freedimensional
Donate link: http://bit.ly/donate_to_me
Tags: subscription, subscribe, option, options, feedburner, rss, feed, mail, email, service, twitter, stream, follow, delivery, icon, icons, widget, sidebar, settings
Requires at least: 2.0.2
Tested up to: 2.8
Stable tag: 0.1.5.6

Add 3 subscription options for readers with related feed icons: a RSS feed URL; your FeedBurner Email URL and your Twitter feed. Totally user-defined.

== Description ==

The most common ways for people subscribe to a blog and its content are through RSS, Email and Twitter.
This plugin places three matching icons in a widget area and lets users enter their own feed URLs.
Simple really. The main functions are is that it looks cool and it is simple to use. I hope you agree.

== Features ==

Once the plugin is active you can edit five variables from the Appearance > Widgets panel:

+ Your RSS Feed URL (*FeedBurner recommended as always*) - it will be linked to the standard orange RSS icon.
+ The FeedBurner Email Service URL (find your Subscription Link Code [here on FeedBurner](http://feedburner.google.com/fb/a/emailsyndication?id=0ei84asp04fn7it63s8l28aafo&divToShow=subscriptionMgmt)) - linked to my custom green mail icon (remixed from [here](http://www.dyers.org/blog/archives/2007/09/25/free-as-in-beer-e-mail-subscription-icons/)).
+ Your Twitter Stream URL - it  will be linked to my totally new blue Twitter icon, matching the other two icons.
+ The title of the widget, if desired. Suggested text to use is "Subscription Options:".
+ The size of the icons. It can be in pixels, ems, percentages or simply "auto".

== Installation ==

1. Download the plugin by hitting that big red 'Download' button to the right.
2. Extract the files and place the entire 'subscription-options' folder in your wp_content/plugins directory.
3. Go to your 'Installed Plugins' panel and activate 'Subscription Options'.
4. You are now ready to use the widget.

== Usage ==

1.  Go to your 'Appearance > Widgets' panel and select the widget area you wish for the plugin to appear in.
2.  Enter the following details:
	+ Widget Title (entirely optional)
	+ RSS Feed URL
	+ Email Service URL
	+ Twitter Stream URL
	+ Size of Feed Icons (using px, em or % as a suffix, or simply "auto")
3.  Hit 'Done' then 'Save Changes'. Test the appearance and perhaps change the size of the icons as necessary

== Screenshots ==
	
1.  This is how the plugin could look on your blog.
2.  This is the widget options panel.

== Frequently Asked Questions ==
**Where do I put the widget?**
You can place the widget wherever you like as long as it is within a pre-defined widget area. I haven't worked out how to let people place the widget wherever they like. Let me know if you can help on my [contact page](http://digitalcortex.net/contact) though. 

**Can I style the widget in my own way?**
Yes of course, it's WordPress! You can use your stylesheet.css to override your theme's default widget settings by using the following CSS classes:

+ the widget container > *div.suboptions_widget*
+ the widget title > *h3.suboptions_widget*	
+ the RSS feed icon > *img.rss_icon*	
+ the email service icon > *img.mail_icon*		
+ the twitter icon > *img.twitter_icon*

Please note that the icons' sizes will still need to be set from within the widget admin panel. CSS doesn't let you override that.

**Where can I find more help and support?**
Just email me from the contact page on [my blog](http://digitalcortex.net/contact). I'll be happy to help where possible. If this plugin really takes off I'll create a bbPress forum.

**How do I deactivate or uninstall the widget?**
If you wish to deactivate the plugin, simply deactivate it from the Plugins panel. If you wish to reactivate it at a later date, your WordPress database will save the text that you had entered for future use. If you wish to uninstall the plugin entirely, it is best practice to deactivate the plugin and then delete the files.

**How can I support the development of this plugin?**
Thank you so much for asking. Here is a link to where you can contribute to the development fund: [Donate](http://bit.ly/donate_to_me)