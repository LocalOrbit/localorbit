=== Plugin Name ===
Contributors: pixelstats
Tags: plugin, statistics, stats, tracking
Donate link: http://www.arrogant.de/pixelstats/
Requires at least: 2.7
Tested up to: 2.7.1
Stable tag: 1.0

Tracks views of all individual articles, even if viewed on front page, category pages and RSS feeds.

== Description ==

Count every viewer and every article view for each blog entry, no matter how and where it is read: pixelstats tracks views of each blog post or page, not only on a single article page but also on each other page where the complete article is shown, i.e. the blog front page, category pages, search result page, archive pages and even RSS feeds.

Normal statistic tools count visitors and page impressions per actual page or URL, i.e. an article view is only counted, when your visitor clicks on the article's permalink. This doesn't make sense for blogs, because many of your visitors read articles on your blog's front page or in full content RSS feeds.
This plugin does not supply endless features to analyze your visitor's behavior, it just gives you an accurate impression, which of your articles is viewed how many times.

Count every view just once: pixelstats can distinguish between recurring and non-recurring views per (anonymous) user to compute a unique or total view count per post/page.

Show off your stats: You can display you view count for each article on your blog.

Analyze your statistics: pixelstats offers comfortable analyzation tools, including graphs, dashboard widget etc.

Feature details:

* Count viewers and article views for each post and article using tracking pixel
* Tracking pixel is displayed automatically, no theme customization needed.
* Define where views are tracked (front page, single page, archive pages, RSS feeds)
* Define if logged in users should be tracked.
* Aggregate statistic data to optimize performance (automatically per cron or manually in Wordpress backend). (Not implemented yet)
* Identify recurring users per pseudonym, stored in browser cookie.
* View stats in Wordpress backend. Top 10 (or Top n) articles, based on unique or total views, Bar chart for Top n articles (including unique and total views), line chart with daily totals of unique article views, total article views and unique viewers.
* Dashboard widget with quick overview chart

See more at http://www.arrogant.de/pixelstats


== Installation ==

1. Download pixelstats
1. Upload `pixelstats/` to the `/wp-content/plugins/` directory
1. Activate the plugin through the 'Plugins' menu in WordPress

To show off your Stats add the following code to your Wordpress Template code:

* Unique views: `<?php print(get_pixelstats()); ?>`
* Total views: `<?php print(get_pixelstats(false)); ?>`

After update, please deactivate and activate plugin to make sure all database settings are up to date.

== Screenshots ==

1. Quick overview
2. Top articles overview
3. Dashboard Widget
4. Top articles details page
5. Select your time period
6. Access detailed stats for each post or page via link in post overview
7. Stats details for individual page
8. Total numbers details