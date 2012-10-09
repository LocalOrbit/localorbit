*** SETUP INSTRUCTIONS ***

1. Upload the plugin file (related-posts.php) to your /wp-content/plugins/ directory and activate it.

2.	a) You will notice a "Related Posts Options" tab under your "Plugins" tab. If this is your first time installing this plugin please click the link for index table setup script at the bottom of the options page. You only need to do this once when you install the plugin for the first time. If automatic setup fails (can happen and may not even be my fault) read on ...

	b) If automatic creation of a full text index fails. You will have to set it up manually. Don't worry it's not hard. Just open your database in phpMySQLadmin and run the following command (cut & paste):

ALTER TABLE `wp_posts` ADD FULLTEXT `post_related` (
    `post_name` ,
    `post_content`
)

Note: You may have to change wp_posts to something else if you are using a different prefix, which is common when you have multiple WP installs running of the same database.

3. Put <?php related_posts(); ?> somewhere in your WP loop, et voila!

*** PARAMETERS ***

Starting with version 2.0 you can yust use the options page to customize the look and output. However you can use the following guide to edit the paremeters manually if you wish.

<?php related_posts($limit, $len, '$before_title', '$after_title', '$before_post', '$after_post', $show_pass_post, $show_excerpt); ?>

$limit - No. of related entries to display. (Defaut: 5)
$len - Desired excerpt length (no. of words). (Default: 10)
$before/after_title - Text to insert before/after the title section.
$before/after_post - Text to insert before/after the post exceprt section, if displayed.
$show_pass_post - Toggle show/hide password protected posts. (Default: False)
$show_excerpt - Toggle show/hide excerpts. (Default: False)

Example:	<?php related_posts(5, 10, '<li>', '</li>', '', '', false, false); ?>

Result:	Will display an unordered list (output is ordered based on keyword matches) of a maximum of 5 "related" posts.

*** CUSTOM KEYWORDS ***

This functionality was adden by Mike (http://mike.blogdns.org/mikelu/archives/2004/07/27/related-post-plugin-v13-en/) and it allows you to manually relate entries using keywords in situations where post title may have little to do with post's content.

Keywords are specified by placing <!--kw=keyword1 keyword2--> into your article. The plugin will store these keywords into a custom field and use them instead of the post title to find possible related entries. Otherwise, post title will be used for matching.

*** PROBLEMS / QUESTIONS / SUGGESTIONS ***

Problems, questions and suggestions should be directed either to me (http://www.w-a-s-a-b-i.com) or Mike (http://mike.blogdns.org/mikelu/).