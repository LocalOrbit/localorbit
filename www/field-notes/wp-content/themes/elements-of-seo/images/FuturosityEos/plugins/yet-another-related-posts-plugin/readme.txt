=== Yet Another Related Posts Plugin ===
Contributors: mitchoyoshitaka
Author: mitcho (Michael Yoshitaka Erlewine)
Author URI: http://mitcho.com/
Plugin URI: http://mitcho.com/code/yarpp/
Donate link: https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=mitcho%40mitcho%2ecom&item_name=mitcho%2ecom%2fcode%3a%20donate%20to%20Michael%20Yoshitaka%20Erlewine&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8
Tags: related, posts, post, pages, page
Requires at least: 2.1
Tested up to: 2.3.2
Stable tag: 1.5.1

Returns a list of the related entries based on keyword matches, limited by a certain relatedness threshold. Like the tried and true Related Posts plugins‹just better!

## Description

Yet Another Related Posts Plugin (YARPP) gives you a list of posts and/or pages related to the current entry, introducing the reader to other relevant content on your site. YARPP is based on the work of [Peter Bowyer](http://peter.mapledesign.co.uk/weblog/archives/wordpress-related-posts-plugin), [Alexander Malov, and Mike Lu](http://wasabi.pbwiki.com/Related%20Entries). Key features include:

1. *Limiting by a threshold*: Peter Bowyer did the great work of making the algorithm use MySQL's [fulltext search](dev.mysql.com/doc/en/Fulltext_Search.html) score to identify related posts. But it just displayed, for example, the top 5 most "relevant" entries, even if some of them weren't at all relevant. Now you can set a threshold limit for relevance, and you get more related posts if there are more related posts and less if there are less. Ha!
2. *Related posts and pages*: **New in 1.1!** Puts you in control of pulling up related posts, pages, or both.
3. *Simple installation*: **New in 1.5!** Automatically displays related posts after content on single entry pages without any theme tinkering.
4. *Miscellany*: a nicer options screen, displaying the fulltext match score on output for admins, an option to allow related posts from the future, a couple bug fixes, etc.

## Installation

### Auto display

With YARPP 1.5, you can just put the `yarpp` directory in your `/wp-content/plugins/` directory, activate the plugin, and you're set! You'll see related posts in single entry (permalink) pages. If all your pages say "no related posts," see the FAQ.

### Manual installation

If you would like to put the related posts display in another part of your theme, or display them in pages other than single entry pages, turn off "auto display" in the YARPP Options, then drop `related_posts()`, `related_pages()`, or `related_entries()` (see below) in your [WP loop](http://codex.wordpress.org/The_Loop). Change any options in the Related Posts (YARPP) Options pane in Admin > Plugins. See Examples in Other Notes for sample code you can drop into your theme.

There're also `related_posts_exist()`, `related_pages_exist()`, and `related_entries_exist()` functions, which return a boolean as expected.

### The "related" functions

By default, `related_posts()` gives you back posts only, `related_pages()` gives you pages, and there's `related_entries()` gives you posts and pages. When the "cross-relate posts and pages" option is checked in the YARPP options panel, `related_posts()`, `related_pages()`, and `related_entries()` will give you exactly the same output.

## FAQ

### Every page just says "no related posts"! What's up with that?

Most likely you have "no related posts" right now as the default "match threshold" is too high. Here's what I recommend to find an appropriate match threshold: first, lower your match threshold in the YARPP prefs to something ridiculously low, like 1 or 0.5. Make sure the last option "show admins the match scores" is on. Most likely the really low threshold will pull up many posts that aren't actually related (false positives), so look at some of your posts' related posts and their match scores. This will help you find an appropriate threshold. You want it lower than what you have now, but high enough so it doesn't have many false positives.

### Why doesn't YARPP use tags to find related posts?

YARPP currently doesn't use tags to compare posts‹it uses the actual content of the posts. Tag comparison as part of the "relatedness algorithm" will come soon but, in the mean time, I've found the current algorithm to work very well for many situations.

### Things are weird after I upgraded. Ack!

I highly recommend you disactivate YARPP, replace it with the new one, and then reactivate it.

## Coming soon

1. Incorporation of tags and categories in the algorithm. I've gotten the code working, but I still need to think about what the most natural algorithm would be for weighing these factors against the mysql fulltext score currently used (and works pretty well, I must say).
2. Um, something else! Let me know if you have any suggestions for improvement. ^^

## Version log

* 1.0
	* Initial upload
* 1.0.1
	* Bugfix: 1.0 assumed you had Markdown installed
* 1.1
	* Related pages support!
	* Also, uses `apply_filters` to apply whatever content text transformation you use (Wikipedia link, Markdown, etc.) before computing similarity.
* 1.5
	* Simple installation: automatic display of a basic related posts install
	* code and variable cleanup
	* FAQ in the documentation
* 1.5.1
	* Bugfix: standardized directory references to `yet-another-related-posts-plugin`