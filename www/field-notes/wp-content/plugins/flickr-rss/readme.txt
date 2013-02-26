=== flickrRSS ===
Contributors: eightface, stefano.verna
Tags: flickr, photos, images, sidebar, widget, rss
Requires at least: 3.0
Tested up to: 3.2.1
Stable tag: 5.2

Allows you to integrate Flickr photos into your site. It supports user, set, favorite, group and community photostreams.


== Description ==

This plugin allows you to easily display Flickr photos on your site. It supports user, set, favorite, group and community photostreams. The plugin is relatively easy to setup and configure via an options panel. It also has support for an image cache located on your server.


== Installation ==

1. Put the flickrRSS files into your plugins directory
2. If you want to cache images, create a directory and make it writable
3. Activate the plugin
4. Configure your settings via the panel in Options
5. Add `<?php get_flickrRSS(); ?>` somewhere in your templates


== Frequently Asked Questions ==

= Can I get random images from my stream? =
No, it's a limitation of using the RSS feed (it only contains the most recent photos). Other people have produced API based version of the plugin, try searching for them.	

= How do I refresh the photos manually? =
No. The plugin uses built-in WordPress functions to update the feed.

= When I use multiple tags, why does nothing shows up? =
The feed will only pull in photos that have both tags, not one or the other.

= When I enable cache, why do just a bunch of random characters show up? =
You've probably specified the full path wrong. Double check with your host to make sure you've got it right. If you're still having troubles, check the forum.

= Why aren't any photos showing up? =
Sometimes it can take a little while to kick in, have patience. Flickr may possibly have been down. Also, make sure it works without the cache first.

= Will it work with video? =
Yes and no, videos will be displayed as a thumbnail image. You'll need to click through to flickr to play it though.


== Feedback and Support ==

I don't use the plugin anymore and don't really support it. If you're having issues, you could try visiting the [WordPress forums](http://wordpress.org/tags/flickr-rss?forum_id=10) or the old [Google group](http://groups.google.com/group/flickrrss/).

== Advanced ==

The plugin also supports a number of parameters, allowing you to have multiple instances across your site.

1. `'type' => 'user'` - The type of Flickr images that you want to show. Possible values: 'user', 'favorite', 'set', 'group', 'public'</li>
2. `'tags' => ''` - Optional: Can be used with type = 'user' or 'public', comma separated</li>
3. `'set' => ''` - Optional: To be used with type = 'set'</li>
4. `'id' => ''` - Optional: Your Group or User ID. To be used with type = 'user' or 'group'</li>
5. `'do_cache' => false` - Enable the image cache</li>
6. `'cache_sizes' => array('square')` - What are the image sizes we want to cache locally? Possible values: 'square', 'thumbnail', 'small', 'medium' or 'large'</li>
7. `'cache_path' => ''` - Where the images are saved (server path)</li>
8. `'cache_uri' => ''` - The URI associated to the cache path (web address)</li>
9. `'num_items' => 4` - The number of images that you want to display</li>
10. `'before_list' => ''` - The HTML to print before the list of images</li>
11. `'html' => '<a href="%flickr_page%" title="%title%"><img src="%image_square%" alt="%title%"></a&>'` - the code to print out for each image.
	Meta tags available: %flickr_page%, %title%, %image_small%, %image_square%, %image_thumbnail%, %image_medium%, %image_large%
12. `'default_title' => "Untitled Flickr photo"` - the default title</li>
13. `'after_list' => ''` - the HTML to print after the list of images</li>

**Example 1**

`<?php get_flickrRSS(array('num_items' => 10, 'type' => 'public', 'tags' => 'london,people')); ?>`
This would show the 10 most recent community photos tagged with london and people. It won't
show photos with only one of the tags.

**Example 2**

`<?php get_flickrRSS(array('set' => '72157601681097311', 'num_items' => 20, 'type' => 'set', 'id' => '44124462494@N01')); ?>`

This would show the 20 most recent thumbnail sized photos from the specified user's set.

== Plugin History ==

**Latest Release:** December 8, 2011

* 5.2 - Fixed image cache server name change, also had a nested function for some reason which was messing up multiple instances for people
* 5.1 - Minor interface tweaks to avoid confusion
* 5.0 - Added more customization of presentation logic, separated core code from display, improved paramter system, many other changes, thanks to Stefano Verna for major code updates.
* 4.0 - New interface for WP 2.5, support for sets and favorites, a few widget tweaks, some cleanup in the source
* 3.5 - Co-released with 4.0, bringing support for sets and favorites to WP 2.3
* 3.2.1 - Minor interface tweaks to avoid confusion
* 3.2 - Updated for WordPress 2.1
* 3.1.2 - Flickr altered the address of static photo urls, affected people using cache
* 3.1.1 - Minor update to add support for Flickr servers with three digits
* 3.1 - Flickr changed the RSS url, support for 20 images in admin panel, a few minor tweaks to display text
* 3.0.3 - added basic support for the WordPress Widgets plugin
* 3.0.2 - fixed before/after image bug, config panel back to options instead of presentation, put group option back in panel
* 3.0.1 - attempt to fix cache bug (wasn't working), fix for command parameter $type error
* 3.0 - Rewrote large parts of the plugin, proper flickr image size, parameters make more sense
* 2.3 - Flickr changed rss feed structure (permanent location of picture)
* 2.2 - should no longer display an error message if flickr times out.
* 2.1 - cURL (uses fopen if not found), empty cache no longer hardcoded, should work for multiple ids/tags, can now use quotes in the before/after tags, bugfixes
* 2.0.2 - bug fixes
* 2.0.1 - fixed new cache bug, flickr added a 10th photo server, breaking the script
* 2.0a - cURL instead of fopen, uses built in rss-functions instead of MagpieRSS, cleaned up options panel
* 1.2 - added thumbnail size
* 1.1 - bug fixes
* 1.0 - Options panel implemented
* 0.7 - Initial release

