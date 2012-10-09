=== Search Meter ===
Contributors: bennettmcelwee
Donate link: http://www.thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/
Tags: search, meter, search-meter, statistics, widget, admin
Requires at least: 1.5
Tested up to: 2.7
Stable tag: 2.5

Search Meter tracks what your readers are searching for on your blog. View full details of recent searches or stats for the last day, week or month.

== Description ==

If you have a Search box on your blog, Search Meter automatically records what people are searching for -- and whether they are finding what they are looking for. Search Meter's admin interface shows you what people have been searching for in the last couple of days, and in the last week or month. It also shows you which searches have been unsuccessful. If people search your blog and get no results, they'll probably go elsewhere. With Search Meter, you'll be able to find out what people are searching for, and give them what they want by creating new posts on those topics.

You can also show your readers what the most popular searches are. The Popular Searches widget displays a configurable list of recent popular successful search terms on your blog, with each term hyperlinked to the actual search results. There's also a Recent Searches widget, which simply displays the most recent searches. If you are happy to edit your theme, both of these functions are also available as template tags.

Search Meter installs easily and requires no configuration. Just install it, activate it, and it starts tracking your visitors' searches.

= View Statistics =

To see your search statistics, Log in to WordPress Admin, go to the Dashboard section and click Search Meter. You'll see the most popular searches in the last day, week and month. Click "Last 100 Searches" or "Last 500 Searches" to see lists of all recent searches.

= Manage Statistics =

There are a couple of management option available if you go to the Settings section and click Search Meter. Use the Reset Statistics button to clear all past search statistics; Search Meter will immediately start gathering fresh statistics. If you're technically-minded, you might want to check the "Keep detailed information" checkbox to make Search Meter save technical information about every search (the information is taken from the HTTP headers).

= Popular and Recent Searches =

The Popular Searches widget displays a list of the most popular successful search terms on your blog during the last 30 days. The Recent Searches widget displays a simple list of the most recent successful search terms. In both cases, the search terms in the lists are hyperlinked to the actual search results; readers can click the search term to show the results for that search. Also, you can configure the maximum number of searches that each widget will display.

To add these widgets to your sidebar, log in to WordPress Admin, go to the Appearance section and click Widgets. You can drag the appropriate widget to the sidebar of your choice, and click the Edit button to set the number of searches to display.

Widget support depends on the version of WordPress and the theme you're using. In some cases you will not be able to use the widgets. In any case, you can always use the Search Meter template tags to display the same information. You'll need to edit your theme to use them.

The `sm_list_popular_searches()` template tag displays a list of the 5 most popular successful search terms on your blog during the last 30 days. Each term is a hyperlink; readers can click the search term to show the results for that search. Here are some examples of using this template tag.

`sm_list_popular_searches()`
Show a simple list of the 5 most popular recent successful search terms, hyperlinked to the actual search results.

`sm_list_popular_searches('<h2>Popular Searches</h2>')`
Show the list as above, with the heading "Popular Searches". If there have been no successful searches, then this tag displays no heading and no list.

`sm_list_popular_searches('<li><h2>Popular Searches</h2>', '</li>')`
Show the headed list as above; this form of the tag should be used in the default WordPress theme. Put it in the `sidebar.php` file.

`sm_list_popular_searches('<li><h2>Popular Searches</h2>', '</li>', 10)`
This is the same as the above, but it shows the 10 most popular searches.

`sm_list_recent_searches()`
Show a simple list of the 5 most recent successful search terms, hyperlinked to the actual search results. You can also use the same options as for the `sm_list_popular_searches` tag.

== Installation ==

1. Just install the plugin as usual - in WordPress 2.7 and higher you can simply upload the search-meter.zip file. For older version, unzip & upload to the /wp-content/plugins/search-meter directory
1. Activate the plugin through the 'Plugins' section in WordPress

== Frequently Asked Questions ==

= Where can I find out more information? =

The [Search Meter home page](http://www.thunderguy.com/semicolon/wordpress/search-meter-wordpress-plugin/) has more information and a form to submit comments and questions.

== Screenshots ==

1. The Search Meter administration interface, showing some of the reports available.
