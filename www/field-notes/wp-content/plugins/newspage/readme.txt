=== NewsPage ===
Contributors: Roger Stringer
Author URL: http://www.rogerstringer.com/
Plugin URI: http://www.rogerstringer.com/projects/newspage
Donate link: https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=roger.stringer%40me%2ecom&item_name=newsPage&item_number=Support%20Open%20Source&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8
Tags: newspage, rss feeds
Requires at least: 2.5
Tested up to: 3.4.1
Stable tag: 3.0

newsPage is an easy to use plugin that allows you to have a headline aggregation page on your blog.

== Description ==

NewsPage is a plugin that lets you create your own RSS feed aggregation page on your blog like PopUrls or AllTop.

You could easily use this plugin to make a website similiar to PopUrls, or you could use it to make a page that has all your 
industry news.

Use NewsPage to create a custom start page, topical headline site, or to add a page of related feeds to your blog.

== Installation ==

1.	In an FTP program, open the `wp-content/plugins` folder
2.	Put the entire `newspage` folder into that folder
3.	Browse to your WordPress administration panel (http://www.example.com/wp-admin).
4.	Click the "Plugins" link in the top right menu.
5.	In the list of inactive plugins, check the box next to "newsPage", and click the "Activate" button.
6.	Click the "newsPage" link on your menu.
7.  You'll have 2 options, the first option lets you manage your RSS Feeds so you can add as many as you want, the second 
	option lets you control your cache settings, etc.

To display your NewsPage on a page of your blog, create a page and add the following line to it anywhere: `<!--newspage-->` or `[newspage]`

Or, alernatively, you can also add the following php code to a template on your blog: `<?php if (function_exists('newsPage')) newsPage(); ?>`

If you want to limit how many feeds are displayed, like if you were displaying a couple on a frontpage, and the rest on another page, you could call it like this: `<?php if (function_exists('newsPage')) newsPage(2); ?>`

You can also specify topics for each feed, you can then call a list of those topics using the follow: `<!--newstopics-->` or `[newstopics limit=5 topic="web design"]` or by placing the following directly in a template: `<?php if (function_exists('newsTopics')) newsTopics(); ?>`

With this functionality, you can choose to list only feeds in a certain topic by the following: `[newspage limit=5 topic="web design"]` or `<?php if (function_exists('newsPage')) newsPage(20,"web design"); ?>`

This will tell the plugin to display your activity feed at that location. 