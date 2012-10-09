=== Get Recent Comments ===
Tags: comments, widget
Requires at least: 1.5
Tested up to: 2.3
Stable tag: trunk

Display the most recent comments or trackbacks with your own formatting in the sidebar. 

== Description ==

This plugin shows excerpts of the latest comments and/or trackbacks in your
sidebar. You have comprehensive control about their appearance. This ranges
from the number of comments, the length of the excerpts up to the html layout.
You can let the plugin order the comments by the corresponding post, or simply
order them by date. The plugin can (optionally) separate the
trackbacks/pingbacks from the comments. It can ignore comments to certain
categories, and it offers support for gravatars. It only gives extra work to
the database, when actually a new comment arrived. You can filter out
unwanted pingbacks, which originate from your own blog. And it is a widget.

You might want to have a look in the [changelog](http://blog.jodies.de/archiv/2004/11/13/recent-comments/2/#changelog).

*Feature List*

* Highly configurable via WordPress admin interface.
* Support for WordPress 1.5, 2.0, 2.1, 2.2 and 2.3
* Adjustable layout by macros.
* Handles trackbacks and comments in separate lists, or in one combined list.
* Widget support
* Caches the output
* Order comments by date, or by posting
* Support for [gravatars](http://www.gravatar.com/).
* Option to exclude comments to posts in certain categorys
* Doesn’Äôt show pingbacks originating from own blog
* There is a special version for lyceum multiblog installations: http://blog.jodies.de/blog/get-recent-comments/lyceum/
* Supports [Hannah Gray’Äôs](http://geekgrl.net/) [Profile Pics Plugin](http://geekgrl.net/2007/01/02/profile-pics-plugin-release/)

== Installation ==
1. Upload `get-recent-comments.php` to the `/wp-content/plugins/` directory.
2. Activate `Get Recent Comments` through the 'Plugins' menu in WordPress.
3. What to do now depends on how up to date your theme is:

    **Modern theme with widget support**

    The plugin is a [widget](http://automattic.com/code/widgets/). If your
theme supports widgets, and you have installed the [widget
plugin](http://wordpress.org/extend/plugins/widgets/), adding the plugin to the
sidebar is easy: Go to the presentation menu and drag and drop the widget into
the sidebar ([Screenshot](http://wordpress.org/extend/plugins/get-recent-comments/screenshots/)). Don't forget the Get Recent Trackbacks box. And you might want to
change the title. All done.

    **Old school theme without widget support**

    You need to insert the following code snippet into the sidebar template.   
*wp-content/themes/&lt;name of theme&gt;/sidebar.php*

        <?php if (function_exists('get_recent_comments')) { ?>
        <li><h2><?php _e('Recent Comments:'); ?></h2>
              <ul>
              <?php get_recent_comments(); ?>
              </ul>
        </li>
        <?php } ?>   
         
        <?php if (function_exists('get_recent_trackbacks')) { ?>
        <li><h2><?php _e('Recent Trackbacks:'); ?></h2>
              <ul>
              <?php get_recent_trackbacks(); ?>
              </ul>
        </li>
        <?php } ?>

== Contributors/Changelog ==

Many users of the plugin gave feedback and contributed their ideas. They are
referenced in the [changelog](http://blog.jodies.de/archiv/2004/11/13/recent-comments/2/#changelog):


    Version Date       Changes
    2.0.2   2007/09/25 Fix: Plugin was not compatible to WordPress
                       2.0.11 any more. Thank you to Stephan for
                       reporting the bug.

    2.0.1   2007/09/24 Added switch on the categories page, which
                       reverses the selection. It is now possible to
                       include or exclude categories.

    2.0     2007/09/24 New code for fetching the data: 1. Instead of
                       one expensive database query we now use two
                       or more cheap queries. Thanks to mirra, who
                       reported the problem. And again thank you to
                       the people mentioned in changlog 1.4, where
                       the cache was introduced for the same
                       (performance-) problems on big blogs. 2. This
                       also fixed a bug, which lead to too less than
                       requested comments in lists, ordered by post.
                       Thanks to Johanna and Frˆ©dˆ©ric for reporting
                       and documenting this. Changed the css in the
                       admin gui, to work around a display issue
                       with Tiger Admin. Thank you, Andi, for
                       finding this. Added %time_since macro, which
                       displays the time since the comment was
                       posted. Thanks to Imran and Keith for
                       sugesting (something like) this (very long
                       ago). Admin interface: Added switch fpr
                       turning on and off smileys. Thank you, panos,
                       for requesting this feature. Support for
                       Custom Smileys Plugin. Thanks to Henry for
                       suggesting this. Fix: Username was not
                       displayed as "Anonymous", if commentor left
                       no name. Thanks to Pixelation for reporting
                       this. Added support for WordPress 2.3. It
                       will drop the post2cat table. Changed plugin
                       to new taxonomy scheme. A *great* thank you
                       goes to Lakatos Zsolt, who provided a
                       complete patch for get-recent-comments-1.5.6,
                       which made it very easy for me to understand
                       how 2.0-beta10 had to be changed. Thank you
                       also to xelios, Ville and Kretzschmar who
                       warned me, that WordPress 2.3 will break the
                       old plugin code.

    1.5.5   2007/03/26 Added support for malyfred's Polyglot Plugin.
                       Requested by Torben.
    1.5.4   2007/02/01 Use full pingback_author as %comment_author
                       (instead of 'Unknown', if the pingback parser
                       fails to recognize the pingback_author.
                       Thanks again to Gant who found this in his
                       blog. Added %author_url_href macros, which
                       allows to generate inactive links, if the
                       commentator did not leave an url. This was
                       wished (in part long ago) by beej, carl,
                       FilSchiesty and SwB.
                       Added %profile_picture macro, which supports
                       Hannah Gray's Profile Pics Plugin. Thank you
                       for the idea and your help, Markus
    1.5.3   2007/01/15 Refresh cache, when a comment is approved by
                       moderator. Problem found by Gant. Thank you!
    1.5.2   2007/01/05 Added option for excluding comments from blog
                       authors. Suggested by This is Zimbabwe, Slim,
                       marilyn's shampoo and Igor M.
    1.5.1   2006/12/29 Store the cache base64 encoded. There seems
                       to be a problem with the unserialization of
                       multibyte characters. Thanks to priv, who
                       reported the problem and suggested the
                       encoding.
                       After upgrading to this version you should
                       trigger a regeneration of the cache by adding
                       a comment somewhere.
    1.5     2006/12/27 New pingback parser
                       Stop losing html entities and tags in the
                       post titles and comments by using
                       wptexturize. Thanks to ejm (again!) and
                       mobius for reporting the problem and making
                       suggestions.
                       Bugfix in widget code: Error, when trackbacks
                       came before comments
    1.4     2006/12/24 The plugin is a widget now. Thanks to
                       herrmueller and Thomas de Klein for
                       suggesting this feature.
                       Cache the output in order to reduce the
                       database impact of the plugin. Thanks to the
                       following people for reporting the poor
                       performance and making suggestions to solve
                       the problem: Brandon Stone, King of Fools,
                       Robert Basic and especially CountZero.
                       Option to combine comments and trackbacks in
                       one list (requested by Maniac and die
                       produzentin)
                       Allow to Group comments by their posting
                       (requested by eyolf)
                       Allow limit of comments per post (suggested
                       by Thomas)
                       Use Wordpress 2.1 compatible database
                       variables. Thanks to spencerp, for reporting
                       and fixing.
                       Bugfix: Wrong key used in gravatar hash
                       (Thank you, Hamzeh N., for finding and fixing
                       this).
                       Updated the stylesheets to the look of
                       wordpress 2.x.
                       Added two macros: %comment_type and
                       %post_counter.
                       Use less option variables in db.
                       Updated instructions page.
                       Dropped support for Wordpress 1.2
    1.3.1   2006/12/11 Fixes for problems with wordpress running
                       under windows.
    1.3     2006/11/26 Fixes for problems with php5.
    1.2     2005/09/15 Prevent pingbacks from own blog. Thanks to
                       Matt for the idea and support!
                       To use the feature, go to the trackbacks
                       configuration and enter the address of your
                       webserver.
    1.0     2005/03/21 Also show comments to static pages. (They are
                       new in WP 1.5). Thanks to maza for the hint.
    0.9     2005/03/20 Introduced admin gui. Handle trackbacks
                       different than comments. Replaced most
                       regular expressions with basic string
                       operations. Dedicated macro for posting time.
                       Requested by Zonekiller
    0.8     2005/02/04 Readjusted sequence of arguments to the one
                       described in the documentation. Thanks to
                       Thomas
    0.7     2005/02/03 Renamed plugin to get-recent-comments, to
                       make it possible to use the subversion system
                       at www.wp-plugins.org
                       Allow to specify your own formatting in the
                       function call
    0.5     2005/01/02 Removed superfluous </p>
    0.4     2004/12/19 Use function arguments for displaying HTML
                       before and after the comment
                       Make number of comments and number of
                       characters also function arguments
    0.3     2004/12/08 Link to permalink of comment
                       Wrap very long strings
    0.2                Don’Äôt show comments that are not approved
    0.1     2004/11/03 Initial release

Thanks to all who sent bug reports and ideas for improvements.
Please send me a mail if I forgot you to mention here.


== Screenshots ==
1. Activation of widget
2. Administration Interface

