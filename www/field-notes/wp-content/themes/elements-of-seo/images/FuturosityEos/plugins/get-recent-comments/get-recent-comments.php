<?php
/*
Plugin Name: Get Recent Comments
Version: 2.0.2
Plugin URI: http://blog.jodies.de/archiv/2004/11/13/recent-comments/
Author: Krischan Jodies
Author URI: http://blog.jodies.de
Description: Display the most recent comments or trackbacks with your own formatting in the sidebar. Visit <a href="options-general.php?page=get-recent-comments.php">Options/Recent Comments</a> after activation of the plugin.



*/

if ( function_exists("is_plugin_page") && is_plugin_page() ) {
	kjgrc_options_page(); 
	return;
}

function kjgrc_subpage_misc()
{
?>
<h2><?php _e('Miscellaneous Options') ?></h2>
<form method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=6&amp;updated=true">
<input type="hidden" name="function" value="misc">
<?php wp_nonce_field('update-options') ?>

<p class="submit"><input type="submit" name="Submit" value="<?php _e('Update Options &raquo;') ?>" /></p>

<fieldset class="options"> 
<legend><?php _e('Smileys') ?></legend> 
<?php
$converter = "WordPress";
if (function_exists("csm_convert") ) {
?>
The Custom Smileys plugin is active.
<?php $converter = "Custom Smileys";
} else { ?>
WordPress offers conversion of emoticons like :-) and :-P to graphics on display. At the moment WordPress is set to: <a href="options-writing.php"><?php if (get_settings('use_smilies')) echo 'convert to graphics'; else echo 'don\'t convert to graphics'; ?></a>.
<?php
}
?>

<table class="optiontable"> 

<th scope="row"><?php _e('The plugin should:') ?> </th>
<td>
<label><input type="radio" name="convert_smileys" value="1" <?php if (kjgrc_get_option("misc","convert_smileys") == 1) echo 'checked="checked"' ?>> do it like <?php echo $converter ?>.</label>
<br>
<label><input type="radio" name="convert_smileys" value="0" <?php if (kjgrc_get_option("misc","convert_smileys") == 0) echo 'checked="checked"' ?>> never convert emoticons to graphics (even if <?php echo $converter ?> does it elsewhere).</label>
</td>

</tr>
</table>
</fieldset> 

<fieldset class="options"> 
<legend><?php _e('Cache') ?></legend> 
If there are no new comments, the plugin fetches the output from the cache,
instead of querying the database. If you want the plugin to ask the database
every time, a web page is generated, you can disable this feature.

<table class="optiontable"> 

<th scope="row"><?php _e('The plugin should:') ?> </th>
<td>
<label><input type="checkbox" name="use_cache_checkbox" <?php if (kjgrc_use_cache()) echo 'checked="checked"'?>> cache the output (recommended).</label>
</td>

</tr>
</table>
</fieldset> 

<p class="submit"><input type="submit" name="Submit" value="<?php _e('Update Options &raquo;') ?>" />
<input type="hidden" name="action" value="update" /> 
<input type="hidden" name="page_options" value="blogname,blogdescription,siteurl,admin_email,users_can_register,gmt_offset,date_format,time_format,home,start_of_week,comment_registration,default_role" /> 
</p>
</form>

</div> 
<?php
}

function kjgrc_subpage_gravatar() 
{
	$gravatar_checked[0] = '';
	$gravatar_checked[1] = '';
	$gravatar_checked[2] = '';
	$gravatar_checked[3] = '';
	$gravatar_checked[kjgrc_get_option('gravatar','rating')] = "checked=\"checked\" ";
	
?>
<form method="POST" action="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=5&amp;updated=true">
<input type="hidden" name="function" value="gravatar">

<h2>Settings for %gravatar</h2>
<fieldset class="options">
<table width="100%" cellspacing="2" cellpadding="5" class="editform">
<tr valign="top">
<th width="33%" scope="row"><?php _e('Size of Gravatars:') ?></th>
<td nowrap><input name="gravatar_size" type="text" value="<?php echo kjgrc_get_option("gravatar","size"); ?>" size="3" /> <?php _e('Pixel') ?><br />
Valid values are between 1 and 80 pixels.
</td>
</tr>
<tr valign="top"> 
        <th scope="row">Alternative URL:</th> 
        <td><input name="gravatar_alt_url" type="text" style="width: 95%" value="<?php echo kjgrc_get_option("gravatar","alt_url"); ?>" size="45" />
        <br />
This is an <strong>optional</strong> image that will be displayed if no gravatar is found. Enter the full URL (with http://). If left empty, gravatar.com returns a transparent pixel.</td> 
</tr> 
<tr>
        <th scope="row">Display gravatars up to this rating:</th> 
        <td> <label for="gravatar_rating0"><input name="gravatar_rating" id="gravatar_rating0" type="radio" value="0" <?php echo $gravatar_checked[0]; ?>/> G (All audiences)</label><br />
<label for="gravatar_rating1"><input name="gravatar_rating" id="gravatar_rating1" type="radio" value="1" <?php echo $gravatar_checked[1]; ?>/> PG</label><br />
<label for="gravatar_rating2"><input name="gravatar_rating" id="gravatar_rating2" type="radio" value="2" <?php echo $gravatar_checked[2]; ?>/> R</label><br />
<label for="gravatar_rating3"><input name="gravatar_rating" id="gravatar_rating3" type="radio" value="3" <?php echo $gravatar_checked[3]; ?>/> X</label></td> 
</tr> 

</table>

<p class="submit">
<input type="submit" name="Submit" value="<?php _e('Update Options') ?> &raquo;" />
</p>
</form> 
<?php
} // kjgrc_subpage_gravatar

function kjgrc_subpage_exclude_cat() 
{
	global $wpdb;
	if (function_exists("get_categories")) {
		$categories = get_categories('&hide_empty=0');
	} else {
		// be still compatible to 2.0.11
		$categories = $wpdb->get_results("SELECT * FROM $wpdb->categories ORDER BY cat_name");
	}
	$exclude_cat = kjgrc_get_exclude_cat();
?>
<form method="POST" action="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=4&amp;updated=true">

<input type="hidden" name="function" value="exclude_cat">
<h2>Categories</h2>
<label><input type="radio" name="exclude_categories_reverse" value="1" <?php if (kjgrc_get_option("misc","exclude_cat_reverse") == 1) echo 'checked="checked"' ?>>Show only comments to articles of the following categories:</label>
<br>
<label><input type="radio" name="exclude_categories_reverse" value="0" <?php if (kjgrc_get_option("misc","exclude_cat_reverse") == 0) echo 'checked="checked"' ?>>Show no comments to articles of the following categories:</label>
<p>

<?php

	if ($categories) {
		foreach ($categories as $category) {
			$checked = '';
			if ($exclude_cat && in_array($category->cat_ID,$exclude_cat)) {
				$checked = 'checked="checked" ';
			}
			echo "<label for=\"\">\n";
			echo "<input name=\"exclude_category[]\" type=\"checkbox\" value=\"$category->cat_ID\" $checked/>";
			echo " $category->cat_name</label><br />\n";
		}
	}
?>
<p class="submit">
<input type="submit" name="Submit" value="<?php _e('Update Options') ?> &raquo;" />
</p>
</form> 
<?php
} // kjgrc_subpage_exclude_cat

function kjgrc_subpage_grc() 
{
?>
<script type="text/javascript">
<!--
function toggle_grouped_titles()
{
        if (document.get_recent_comments_form.grouped_by_post_checkbox.checked == false) {
		document.getElementById('grouped_by_post_cell_a').style.display = "none";
		document.getElementById('grouped_by_post_cell_b').style.display = "none";
        } else {
		document.getElementById('grouped_by_post_cell_a').style.display = "";
		document.getElementById('grouped_by_post_cell_b').style.display = "";
        }
}
function toggle_exclude_blog_owner2()
{
	if (document.get_recent_comments_form.grc_exclude_blog_owner_checkbox.checked == false) {
		document.getElementById('grc_exclude_blog_owner_checkbox2').style.display = "none";
	} else {
		document.getElementById('grc_exclude_blog_owner_checkbox2').style.display = "";
	}
}
-->
</script>

<form name="get_recent_comments_form" method=post action="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;updated=true">
<input type="hidden" name="function" value="grc">
<h2><?php _e('Recent Comments') ?></h2>
<fieldset class="options"> 
<table width="100%" cellspacing="2" cellpadding="5" class="editform">
<tr valign="top">
<th width="33%" scope="row"><?php _e('Show the most recent:') ?></th>
<td><input name="max_comments" type="text" id="max_comments" value="<?php echo kjgrc_get_option("grc","max_comments"); ?>" size="3" /> <?php _e('comments') ?></td>
<td rowspan="6"><pre><div style='font-size: 10px; border-left: 1px solid; margin: 0px;'> %comment_excerpt - Shortened comment.
 %comment_link    - Link to the comment. 
 %comment_author  - Name left by the commenter
 %comment_date    - Date of comment
 %comment_time    - Time of comment
 %comment_type    - Comment, Trackback or Pingback
 %time_since      - Time since comment was posted
 %userid          - UserID of the commenter
 %gravatar        - Gravatar of the commenter, full img tag
 %gravatar_url    - Gravatar of the commenter, only url
 %profile_picture - URL of profile picture
 %author_url      - URL of author or trackback
 %author_url_href - href="%author_url" or empty
 %post_title      - Title of the posting
 %post_link       - Link to the posting 
 %post_date       - Date of the posting
 %post_counter    - Number of comments to this post</pre></div></td>
</tr>
<tr valign="top">
<th width="33%" scope="row"><?php _e('Long comments are chopped off at:') ?></th>
<td nowrap><input name="chars_per_comment" type="text" id="chars_per_comment" value="<?php echo kjgrc_get_option("grc","chars_per_comment"); ?>" size="3" /> <?php _e('characters') ?></td>
</tr>
<tr valign="top">
<th width="33%" scope="row"><?php _e('Wrap long words at:') ?></th>
<td nowrap><input name="chars_per_word" type="text" id="chars_per_word" value="<?php echo kjgrc_get_option("grc","chars_per_word"); ?>" size="3" /> <?php _e('characters') ?></td>
</tr>
<tr valign="top">
<th width="33%" scope="row">Template:
<td>&nbsp;</td>
</tr>

<tr>
<td colspan=2>
<label for="grc_exclude_blog_owner_checkbox">
<input type="checkbox" name="grc_exclude_blog_owner_checkbox" id="grc_exclude_blog_owner_checkbox" onclick="toggle_exclude_blog_owner2();" <?php if (kjgrc_get_option("grc","exclude_blog_owner") == 1) echo "checked=\"checked\""; ?>> Exclude comments by blog authors (your own comments)</label>
</td>
</tr>

<tr id="grc_exclude_blog_owner_checkbox2" style="display: <?php echo ((kjgrc_get_option("grc","exclude_blog_owner") == 0) ? "none" : "table-row") ?>;">
<td colspan=2>
<label for="grc_exclude_blog_owner2_checkbox">&nbsp;&nbsp;&nbsp;
<input type="checkbox" name="grc_exclude_blog_owner2_checkbox" id="grc_exclude_blog_owner2_checkbox" <?php if (kjgrc_get_option("grc","exclude_blog_owner2") == 1) echo "checked=\"checked\""; ?>> Also consider usernames and e-mail addresses, to recognize blog authors</label>
</td>
</tr>


<tr>
<td colspan=2>
<label for="grc_show_trackbacks_checkbox">
<input type="checkbox" name="grc_show_trackbacks_checkbox" id="grc_show_trackbacks_checkbox" <?php if (kjgrc_get_option("grc","show_trackbacks") == 1) echo "checked=\"checked\""; ?>> Show Comments and Trackbacks/Pingbacks together</label>
</td>
</tr>
</tr>
<tr>
<td colspan=2>
<label for="grouped_by_post_checkbox">
<input type="checkbox" name="grouped_by_post_checkbox" id="grouped_by_post_checkbox" onclick="toggle_grouped_titles();" <?php if (kjgrc_get_option("grc","grouped_by_post") == 1) echo "checked=\"checked\""; ?>> Group comments by Posting</label>
</td>
</tr>
<tr id="grouped_by_post_cell_a" style="display: <?php echo ((kjgrc_get_option("grc","grouped_by_post") == 0) ? "none" : "table-row") ?>;">
<td colspan=3>
<label for="grc_limit_comments_per_post_checkbox">
<input type="checkbox" name="grc_limit_comments_per_post_checkbox" id="grc_limit_comments_per_post_checkbox" onclick="toggle_grouped_titles();" <?php if (kjgrc_get_option("grc","limit_comments_per_post") == 1) echo "checked=\"checked\""; ?>> Limit number of comments per post: <!-- aka de klein limit --></label> <input type="text" name="grc_comments_per_post" size=3 value="<?php echo kjgrc_get_option("grc","comments_per_post");?>"><br /><br />

<textarea name="grouped_by_post_a" cols="60" rows="2" id="grouped_by_post_a" style="width: 98%; font-size: 12px;" class="code"><?php echo stripslashes(htmlspecialchars(kjgrc_get_option("grc","grouped_by_post_a"))); ?></textarea><br /><span style="font-size: 10px;"><strong>Template for the post</strong>. It should start with &lt;li&gt; and end with &lt;ul&gt;<span>
</td>
</tr>

<tr>
<td colspan=3 style="padding-left: 30px;"><textarea name="format" cols="60" rows="2" id="format" style="width: 98%; font-size: 12px;" class="code"><?php echo stripslashes(htmlspecialchars(kjgrc_get_option("grc","format"))); ?></textarea><br /><span style="font-size: 10px;"><strong>Template for the comments</strong>. If you want them as a list, It should start with &lt;li&gt; and end with &lt;/li&gt;<span></td>
</tr>
<tr>

<tr id="grouped_by_post_cell_b" style="display: <?php echo ((kjgrc_get_option("grc","grouped_by_post") == 0) ? "none" : "table-row") ?>;">
<td colspan=3>

<textarea name="grouped_by_post_b" cols="60" rows="2" id="grouped_by_post_b" style="width: 98%; font-size: 12px;" class="code"><?php echo stripslashes(htmlspecialchars(kjgrc_get_option("grc","grouped_by_post_b"))); ?></textarea><br /><span style="font-size: 10px;"><strong>Template for the closing tags of the post template</strong>. Usally &lt;/ul&gt;&lt;/li&gt;</span></td>

</tr>

<tr>
<td colspan=3>
<strong>Result</strong>
<?php $result=kjgrc_create_recent_comments('grc_sample');  substr_count($result, "\n");?>
<textarea cols="60" rows="<?php $result=kjgrc_create_recent_comments('grc_sample');  substr_count($result, "\n"); echo substr_count($result, "\n")+1;?>" style="width: 98%; font-size: 12px; left-margin: 30;" class="code" wrap="off" readonly><?php echo trim($result); ?></textarea>
</td>         
</tr>

</table>
<p class="submit">
<input type="submit" id="deletepost" name="reset_template" value="<?php _e('Reset template to default') ?> &raquo;" onclick="return confirm('You are about to reset your template for \'Recent Comments\'.\n  \'Cancel\' to stop, \'OK\' to delete.')" />
<input type="submit" name="Submit" value="<?php _e('Update Recent Comments Options') ?> &raquo;" />
</p>
</fieldset>
</form>

<?php
} // kjgrc_subpage_grc 

function kjgrc_subpage_grt () 
{
?>

<form name="trackback_form" method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;updated=true&amp;subpage=2">
<input type="hidden" name="function" value="grt">
<h2><?php _e('Recent Trackbacks') ?></h2>
<fieldset class="options"> 
<table width="100%" cellspacing="2" cellpadding="5" class="editform">
<tr valign="top">
<th width="33%" scope="row"><?php _e('Show the most recent:') ?></th>
<td nowrap><input name="max_comments" type="text" id="max_comments" value="<?php echo kjgrc_get_option("grt","max_comments"); ?>" size="3" /> <?php _e('Trackbacks') ?></td>
<td rowspan="3"><pre><div style='font-size: 10px; border-left: 1px solid; margin: 0px;'> %comment_excerpt - Shortened comment.
 %comment_link    - Link to the comment.
 %comment_author  - Name left by the commenter
 %comment_date    - Date of comment
 %comment_time    - Time of comment
 %comment_type    - Pingback or Trackback
 %time_since      - Time since trackback was posted
 %author_url      - URL of author or trackback
 %author_url_href - href="%author_url" or empty
 %trackback_title - Title of trackback
 %post_title      - Title of the posting
 %post_link       - Link to the posting
 %post_date       - Date of the posting</pre></div></td>
</tr>
<tr valign="top">
<th width="33%" scope="row"><?php _e('Long trackbacks are chopped off at:') ?></th>
<td nowrap><input name="chars_per_comment" type="text" id="chars_per_comment" value="<?php echo kjgrc_get_option("grt","chars_per_comment"); ?>" size="3" /> <?php _e('characters') ?></td>
</tr>
<tr valign="top">
<th width="33%" scope="row"><?php _e('Wrap long words at:') ?></th>
<td><input name="chars_per_word" type="text" id="chars_per_word" value="<?php echo kjgrc_get_option("grt","chars_per_word"); ?>" size="3" /> <?php _e('characters') ?></td>
</tr>
<tr valign="top">
<th width="33%" scope="row"><?php _e('Ignore trackbacks originating from this ip address:') ?></th>
<td><input name="ignore_ip" type="text" id="ignore_ip" value="<?php echo kjgrc_get_option("grt","ignore_ip"); ?>" size="16" /><br><span style='font-size: 10px;'>Insert the <a href="javascript:;" onmousedown="document.trackback_form.ignore_ip.value='<?php global $_SERVER; echo $_SERVER['SERVER_ADDR']; ?>';">address of your webserver</a> to filter pingbacks from your own posts</span></td>
</tr>
<tr valign="top">
<th width="33%" scope="row">Template:
<td>&nbsp;</td>
</tr>
<tr valign="top">
<td colspan="3">
       <textarea name="format" cols="60" rows="2" id="format" style="width: 98%; font-size: 12px;" class="code"><?php echo stripslashes(htmlspecialchars(kjgrc_get_option("grt","format"))); ?></textarea><br /><span style="font-size: 10px;"><strong>Template for the trackbacks and pingbacks.</strong> Usually starts with &lt;li&gt; and ends with &lt;/li&gt;.</span>
</td>
</tr>

<tr>
<td colspan=3>
<strong>Result</strong>
<?php $result=kjgrc_create_recent_comments('grc_sample');  substr_count($result, "\n");?>
<textarea cols="60" rows="<?php $result=kjgrc_create_recent_trackbacks('grt_sample');  substr_count($result, "\n"); echo substr_count($result, "\n")+1;?>" style="width: 98%; font-size: 12px; left-margin: 30;" class="code" wrap="off" readonly><?php echo trim($result); ?></textarea>
</td>         
</tr>

</table>


<p class="submit">
<input type="submit" id="deletepost" name="reset_template" value="<?php _e('Reset template to default') ?> &raquo;" onclick="return confirm('You are about to reset your template for \'Recent Trackbacks\'.\n  \'Cancel\' to stop, \'OK\' to delete.')" />
<input type="submit" name="Submit" value="<?php _e('Update Recent Trackbacks Options') ?> &raquo;" />
</p>
</form>   
</fieldset>

<?php 
} //kjgrc_subpage_grt

function kjgrc_subpage_instructions () 
{
?>   
<h2><?php _e('Instructions') ?></h2>
<p><strong>1. What this plugin does</strong></p>
It shows excerpts of the latest comments and/or trackbacks in your sidebar. You
have comprehensive control about their appearance. This ranges from the number
of comments, the length of the excerpts up to the html layout. You can let the
plugin order the comments by the corresponding post, or simply order them by
date. The plugin can (optionally) separate the trackbacks/pingbacks from the
comments. It can ignore comments to certain categories, and it offers support
for gravatars. It only gives extra work to the database, when actually a new
comment arrived. And you can filter out unwanted pingbacks, which originate
from your own blog. And it is a widget.

<p><strong>2. Installation</strong></p>
Since you are reading this text, you already uploaded and activated the plugin.
Now you want to add the plugin to your theme. There are two options to do this:

<p><strong>2.1 Modern Theme with widget support</strong></p>
The plugin is a <a href="http://automattic.com/code/widgets/">widget</a>. If
your theme supports widgets, and you have installed the widget plugin, adding
the plugin to the sidebar is easy: Go to the <a href="themes.php">presentation menu</a> and drag
and drop the widget into the sidebar. Don't forget the Get Recent Trackbacks
box. And you might want to change the title. All done.

<p><strong>2.2 Old school theme without widget support</strong></p>

<p>
You need to insert the following code snippet into the <a href="theme-editor.php">sidebar template</a>. 
</p>

<span class="code">wp-content/themes/default/sidebar.php</span>
<div style="border: 1px solid; border-color: #ccc; margin: 15px; background: #eee;">

<pre class="code" style='color:#000000;'><span style='color:#7f0055; background:#ffffe8; '>&lt;?php</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; font-weight:bold; '>if</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#000000; background:#ffffe8; '>(</span><span style='color:#7f0055; background:#ffffe8; font-weight:bold; '>function_exists</span><span style='color:#000000; background:#ffffe8; '>(</span><span style='color:#2a00ff; background:#ffffe8; '>'get_recent_comments'</span><span style='color:#000000; background:#ffffe8; '>)</span><span style='color:#000000; background:#ffffe8; '>)</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#000000; background:#ffffe8; '>{</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; '>?></span><span style='color:#000000;  '></span>
<span style='color:#000000;  '>   </span><span style='color:#7f0055;  '>&lt;</span><span style='color:#7f0055;  font-weight:bold; '>li</span><span style='color:#7f0055;  '>></span><span style='color:#7f0055;  '>&lt;</span><span style='color:#7f0055;  font-weight:bold; '>h2</span><span style='color:#7f0055;  '>></span><span style='color:#7f0055; background:#ffffe8; '>&lt;?php</span><span style='color:#000000; background:#ffffe8; '> _e</span><span style='color:#000000; background:#ffffe8; '>(</span><span style='color:#2a00ff; background:#ffffe8; '>'Recent Comments:'</span><span style='color:#000000; background:#ffffe8; '>)</span><span style='color:#000000; background:#ffffe8; '>;</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; '>?></span><span style='color:#7f0055;'>&lt;/</span><span style='color:#7f0055;  font-weight:bold; '>h2</span><span style='color:#7f0055;  '>></span><span style='color:#000000;  '></span>
<span style='color:#000000;  '>   </span><span style='color:#7f0055;  '>&lt;</span><span style='color:#7f0055;  font-weight:bold; '>ul</span><span style='color:#7f0055;  '>></span><span style='color:#7f0055; background:#ffffe8; '>&lt;?php</span><span style='color:#000000; background:#ffffe8; '> get_recent_comments</span><span style='color:#000000; background:#ffffe8; '>(</span><span style='color:#000000; background:#ffffe8; '>)</span><span style='color:#000000; background:#ffffe8; '>;</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; '>?></span><span style='color:#7f0055;  '>&lt;/</span><span style='color:#7f0055;  font-weight:bold; '>ul</span><span style='color:#7f0055;  '>></span><span style='color:#000000;  '></span>
<span style='color:#000000;  '>   </span><span style='color:#7f0055;  '>&lt;/</span><span style='color:#7f0055;  font-weight:bold; '>li</span><span style='color:#7f0055;  '>></span><span style='color:#000000;  '></span>
<span style='color:#7f0055; background:#ffffe8; '>&lt;?php</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#000000; background:#ffffe8; '>}</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; '>?></span>   

<span style='color:#7f0055; background:#ffffe8; '>&lt;?php</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; font-weight:bold; '>if</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#000000; background:#ffffe8; '>(</span><span style='color:#7f0055; background:#ffffe8; font-weight:bold; '>function_exists</span><span style='color:#000000; background:#ffffe8; '>(</span><span style='color:#2a00ff; background:#ffffe8; '>'get_recent_trackbacks'</span><span style='color:#000000; background:#ffffe8; '>)</span><span style='color:#000000; background:#ffffe8; '>)</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#000000; background:#ffffe8; '>{</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; '>?></span><span style='color:#000000;  '></span>
<span style='color:#000000;  '>   </span><span style='color:#7f0055;  '>&lt;</span><span style='color:#7f0055;  font-weight:bold; '>li</span><span style='color:#7f0055;  '>></span><span style='color:#7f0055;  '>&lt;</span><span style='color:#7f0055;  font-weight:bold; '>h2</span><span style='color:#7f0055;  '>></span><span style='color:#7f0055; background:#ffffe8; '>&lt;?php</span><span style='color:#000000; background:#ffffe8; '> _e</span><span style='color:#000000; background:#ffffe8; '>(</span><span style='color:#2a00ff; background:#ffffe8; '>'Recent Trackbacks:'</span><span style='color:#000000; background:#ffffe8; '>)</span><span style='color:#000000; background:#ffffe8; '>;</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; '>?></span><span style='color:#7f0055;  '>&lt;/</span><span style='color:#7f0055;  font-weight:bold; '>h2</span><span style='color:#7f0055;  '>></span><span style='color:#000000;  '></span>
<span style='color:#000000;  '>   </span><span style='color:#7f0055;  '>&lt;</span><span style='color:#7f0055;  font-weight:bold; '>ul</span><span style='color:#7f0055;  '>></span><span style='color:#7f0055; background:#ffffe8; '>&lt;?php</span><span style='color:#000000; background:#ffffe8; '> get_recent_trackbacks</span><span style='color:#000000; background:#ffffe8; '>(</span><span style='color:#000000; background:#ffffe8; '>)</span><span style='color:#000000; background:#ffffe8; '>;</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; '>?></span><span style='color:#7f0055;  '>&lt;/</span><span style='color:#7f0055;  font-weight:bold; '>ul</span><span style='color:#7f0055;  '>></span><span style='color:#000000;  '></span>
<span style='color:#000000;  '>   </span><span style='color:#7f0055;  '>&lt;/</span><span style='color:#7f0055;  font-weight:bold; '>li</span><span style='color:#7f0055;  '>></span><span style='color:#000000;  '></span>
<span style='color:#7f0055; background:#ffffe8; '>&lt;?php</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#000000; background:#ffffe8; '>}</span><span style='color:#000000; background:#ffffe8; '> </span><span style='color:#7f0055; background:#ffffe8; '>?></span>
</pre>

</div>

<p><strong>3. Customizing</strong></p>
The strongest feature of the plugin is that you can change the html layout in the admin interface, by filling in templates. In the templates you make use of macros, that are later replaced by the actual data.

<p><strong>3.1 Using the Macros</strong></p>
<table>
<tr><td valign="top" nowrap>%comment_excerpt</td><td>The text of the comment. It might get shorted to the number of characters you entered in <em>"Long comments are chopped off at..."</em></td></tr>
<tr><td valign="top" nowrap>%comment_link</td><td>The URL to the cited comment.</td></tr> 
<tr><td valign="top" nowrap>%comment_author</td><td>The name, the commenter entered in the comment form. If she left the field empty, the name is "Anonymous".</td></tr>
<tr><td valign="top" nowrap>%comment_date</td><td>The date, when the comment was posted in the style you configured as <a href="options-general.php">default date format</a>.</td></tr>
<tr><td valign="top" nowrap>%comment_time</td><td>The time, when the comment was posted</td></tr>
<tr><td valign="top" nowrap>%time_since</td><td>Time since the comment was posted. For example: &quot;9 hours 16 minutes&quot;.</td></tr>
<tr><td valign="top" nowrap>%comment_type</td><td>&quot;Comment&quot;, &quot;Trackback&quot; or &quot;Pingback&quot;.</td></tr>
<tr><td valign="top" nowrap>%gravatar</td><td>This macro becomes a complete image tag. If the comment author registered a gravatar with <a href="http://www.gravatar.com">gravatar.com</a>. Example:<br />&lt;img src=&quot;http://www.gravatar.com/avatar.php?gravatar_id=1ebbd34d4e45cac&amp;size=25&amp;rating=X&quot;/&gt;  </td></tr>
<tr><td valign="top" nowrap>%gravatar_url</td><td>This macro becomes only the URL to the gravatar. Example:<br />http://www.gravatar.com/avatar.php?gravatar_id=1ebbd34d4e45cac&amp;size=25&amp;rating=X</td></tr>
<tr><td valign="top" nowrap>%profile_picture</td><td>Becomes to URL of a profile picture. Use it like this: &lt;img src="%profile_picture" width=16 height=16&gt;. This only works after activation of <a href="http://geekgrl.net">Hannah Gray's</a> <a href="http://geekgrl.net/2007/01/02/profile-pics-plugin-release/">Profile Pics Plugin</a>.</td></tr>
<tr><td valign="top" nowrap>%userid</td><td>If the comment author is registered with your wordpress, and was logged in, when she wrote the comment this is replaced with the user id, she has in WordPress. The user id's are listed here: <a href="users.php">users.php</a>. You can do fancyful things with this macro. For example you may construct an image url, that points to pictures of all the authors of your blog: &lt;img src=&quot;/images/user%userid.jpg&quot;&gt;</td></tr>
<tr><td valign="top" nowrap>%author_url</td><td>The URL, the comment author left in the comment form, or if the comment is a trackback, the URL of the site that issued the trackback.</td></tr>
<tr><td valign="top" nowrap>%author_url_href</td><td>The same like %author_url but inside a href statement. If there is no URL, the whole macro is empty. Without a href="" statement the link looks like a link, but is inactive. Use it like this: &lt;a %author_url_href title="%comment_date"&gt;comment_author&lt;/a&gt;</td></tr>
<tr><td valign="top" nowrap>%post_title</td><td>The title of the posting that was commented.</td></tr>
<tr><td valign="top" nowrap>%post_link</td><td>The URL of the posting that was commented.</td></tr> 
<tr><td valign="top" nowrap>%post_date</td><td>The date when the commented posting was published.</td></tr>
<tr><td valign="top" nowrap>%post_counter</td><td>The number of comments this post has..</td></tr>
<tr><td valign="top" nowrap>%trackback_title</td><td>Only applicable in trackbacks: The title of the trackback. It  might get shorted to the number of characters you entered in <em>"Long trackbacks are chopped off at..."</em></td></tr>
</table>

<p><strong>3.2 Group by comments</strong></p>

If you want to order the comments by their posting, you will have not one but
three templates. The middle one is just the same as in the normal order. The
first and the last template are used to generate headers for the grouped
comments. Usually you will show the %post_title in this header. This is the
html markup that is generated by the templates:

<style type="text/css">
<!--
.top-example { vertical-align:top; }
.top-ital { vertical-align:top; font-style:italic; padding-left: 10px; }
#example { font-family:monospace; 
           font-weight:bold; 
           border: 1px solid;
           border-color: #ccc;
           margin: 15px;
           background: #eee;
}	
#example pre {
	margin: 0;
}
#example td {
	
}
-->
</style>
<div id="example">
<table style="border-spacing:0px; ">
<tr>
<td class="top-example"><pre><span style="color:green">&lt;li&gt;&lt;h2&gt;Recent Comments:&lt;/h2&gt;
   &lt;ul&gt;</pre></span></td>
<td class="top-ital"><span style="color:green">Start sequence.</span> Automatically provided when the plugin is used as widget. Otherwise you have to enter this by manually into the <a href="theme-editor.php">sidebar.php template</a>.</td>
</tr>
<tr>
<td class="top-example"><pre>
      <span style="color:blue">&lt;li&gt;Post 1&lt;/li&gt;
         &lt;ul&gt;
</pre></span></td>
<td class="top-ital"><span style="color:blue">Template for the post. This is the header for a list of comments, that all belong to the same posting.</span></td>
</tr>
<tr>
<td class="top-example"><pre>
            <span style="color:olive">&lt;li&gt;Comment1 to Post1&lt;/li&gt;
            &lt;li&gt;Comment2 to Post1&lt;/li&gt;
</pre></span></td>
<td class="top-ital"><span style="color:olive">Template for the comments<br />It is repeated for every single comment</span></td>
</tr>
<tr class="top-example">
<td class="top-example"><pre>
         <span style="color:red">&lt;/ul&gt;
      &lt;/li&gt;
</pre></span></td>
<td class="top-ital"><span style="color:red">Template for the closing tags of the post template</span></td>
</tr>
<tr class="top-example">
<td class="top-example"><pre>
      <span style="color:blue">&lt;li&gt;Post 2&lt;/li&gt;
         &lt;ul&gt;
</pre></span></td>
<td class="top-ital"><span style="color:blue">The next posting.</span></td>
</tr>
<tr class="top-example">
<td class="top-example"><pre>
            <span style="color:olive">&lt;li&gt;Comment1 to Post2&lt;/li&gt;
            &lt;li&gt;Comment2 to Post2&lt;/li&gt;
</pre></span></td>
<td class="top-ital"><span style="color:olive">The comments to the next posting</span></td>
</tr>
<tr class="top-example">
<td class="top-example"><pre>
         <span style="color:red">&lt;/ul&gt;
      &lt;/li&gt;
</pre></span></td>
<td class="top-ital"><span style="color:red">Again close the tags</span></td>
</tr>
<tr class="top-example">
<td class="top-example"><pre>
   <span style="color:green">&lt;/ul&gt;
&lt;/li&gt;
</pre></span></td>
<td class="top-ital"><span style="color:green">End sequence.</span> Automatically provided when the plugin is used as widget. Otherwise you have to enter this by manually into the <a href="theme-editor.php">sidebar.php template</a>.</td>
</tr>
</table>
</div>


<p><strong>4. Miscellaneous</strong></p>
<ul>
<li>Don't worry if you screwed up the template, reset the template to default and try again.</li>
<li><em>"Wrap long words at..."</em> means: words, that exceed this length are split into fragments to prevent damage to the layout of your blog.</li>
<li>"<em>Ignore trackbacks originating from this ip address</em>" on the
configuration page for recent trackbacks is useful for filtering out pingbacks
that occur when you have a link to your own site in a post.</li>
<li>If you select to exclude comments made by blog authors (your own comments) from  the list, then the comments which you made, when you were logged in, are ignored. If you also want to exclude comments you made, when you were not logged in, you can select to also consider the username and e-mail address.</li>
</ul>
<p><strong>5. Interoperation with other plugins</strong></p>
<ul>
<li>If <a href="http://geekgrl.net">Hannah Gray's</a> <a href="http://geekgrl.net/2007/01/02/profile-pics-plugin-release/
">Profile Pics Plugin</a> is present, you may use to macro <em>%profile_picture</em> to obtain an URL to the profile picture of the commentator (read in the macro section for a working example).</li>
<li>If <a href="http://fredfred.net/skriker/index.php/polyglot">malyfred's</a> <a href="http://fredfred.net/skriker/index.php/polyglot">Polyglot</a> Plugin is present, additional filters are applied to comments, titles, dates and times, which select the right language for the user.</li>
</ul>
</div>  

<?php  
}

function kjgrc_subpage_header ($kjgrc_selected_tab) {
	$current_tab[$kjgrc_selected_tab] = "class=\"current\"";
?>
<style>
<!--
#adminmenu3 li {
        display: inline;
        line-height: 200%;
        list-style: none;
        text-align: center;
}

#adminmenu3 {
        background: #0d324f;
        border-bottom: none;
        margin: 0;
	height: 25px;
        padding: 3px 2em 0 1em;
	paddi/ng: 0 0 0 0;
}
                                                                                     
#adminmenu3 .current {
        background: #f9fcfe;
        border-top: 1px solid #045290;
        border-right: 2px solid #045290;
        color: #000;
}
                                                                                     
#adminmenu3 a {
        border: none;
        color: #fff;
        font-size: 12px;
        padding: .3em .4em .33em;
}
                                                                                     
#adminmenu3 a:hover {
        background: #ddeaf4;
        color: #393939;
}
                                                                                     
-->
</style>
<ul id="submenu">
   <li><a href="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=1" <?php echo $current_tab[1] ?>>Comments</a></li>
   <li><a href="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=2" <?php echo $current_tab[2] ?>>Trackbacks</a></li>
   <li><a href="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=4" <?php echo $current_tab[4] ?>>Categories</a></li>
   <li><a href="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=5" <?php echo $current_tab[5] ?>>Gravatars</a></li>
   <li><a href="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=6" <?php echo $current_tab[6] ?>>Misc</a></li>
   <li><a href="<?php echo $_SERVER['PHP_SELF']; ?>?page=get-recent-comments.php&amp;subpage=3" <?php echo $current_tab[3] ?>>Instructions</a></li>
</ul>
<div class="wrap">
<?php
}

// function kjgrc_log ($msg="")
// {
// 	$handle = @fopen ("/home/krischan/debug.log", "a");
// 	if (is_writable("/home/krischan/debug.log")) {
// 	  	fwrite($handle,date("r").": $msg\n");
// 		fclose($handle);
// 	}
// }	

function kjgrc_set_option($key,$value) 
{
	global $kjgrc_options_loaded;
	// Fetch dummy value just to enforce migration if needed
	kjgrc_get_option("grc","max_comments");
	$options = get_option("kjgrc_options");
	$options[$key] = $value;
	update_option("kjgrc_options",$options);
	kjgrc_invalidate_cache();
}

function kjgrc_get_option($section,$option_name)
{
	global $wpdb,$kjgrc_options_loaded;
	$version = 11; // If version differs from saved value -> insert new defaults
	$kjgrc_options = get_option("kjgrc_options");
	if ($kjgrc_options == NULL || $kjgrc_options['version'] != $version) 
	{
		$default_options = array (
			"grc_max_comments" => 5,
			"grc_chars_per_comment" => 120,
			"grc_chars_per_word" => 30,
			"grc_format" => "<li><a href=\"%comment_link\" title=\"%post_title, %post_date\">%comment_author</a>: %comment_excerpt</li>",
			"grc_grouped_by_post" => 0,
			"grc_grouped_by_post_a" => '<li><strong><a href="%post_link" title="%post_title was posted on %post_date">%post_title</a>&nbsp;(<a href="#" title="There are %post_counter comments to this posting">%post_counter</a>)</strong><ul>',
			"grc_grouped_by_post_b" => '</ul></li>',
			"grc_show_trackbacks" => 0,
			"grc_comments_per_post" => 5,
			"grc_limit_comments_per_post" => 0,
			"grc_exclude_blog_owner" => 0,
			"grc_exclude_blog_owner2" => 0,
			"grt_max_comments" => 5,
			"grt_chars_per_comment" => 120,
			"grt_chars_per_word" => 30,
			"grt_format" => "<li><a href=\"%comment_link\" title=\"Trackback to &quot;%post_title&quot;: %comment_excerpt\">%comment_author</a>: %trackback_title</li>",
			"misc_exclude_cat" => "",
			"misc_exclude_cat_reverse" => 0,
			"misc_convert_smileys" => 1,
			"gravatar_size" => 20,
			"gravatar_alt_url" => "",
			"grt_ignore_ip" => "",
			"gravatar_rating" => 0,
			"grc_sidebar_title" => "Recent Comments",
			"grt_sidebar_title" => "Recent Trackbacks"
		);
		$old_keys = array("grc_max_comments","grc_chars_per_comment","grc_chars_per_word","grc_format","grt_max_comments","grt_chars_per_comment","grt_chars_per_word","grt_format","misc_exclude_cat","gravatar_size","gravatar_alt_url","gravatar_rating","grt_ignore_ip"); 
		// This might be an upgrade from < 1.4 to 1.4 or newer version. If there are old keys, migrate them to the new array:
		add_option('gravatar_alt_url','');
		if ($kjgrc_options == NULL) {
			foreach ($old_keys as $key) {
				$sql = "SELECT option_value,option_id FROM $wpdb->options WHERE option_name = 'kjgrc_$key'";
				$old_value = $wpdb->get_row($sql,ARRAY_N); // $old_value[0] = old value, $old_value[1] = option id
				if ($old_value[1] != NULL) { 
					$kjgrc_options[$key] = $old_value[0];
					delete_option("kjgrc_$key");
				} 
			}
		}
		// Whether it's a new installation or an introduction of new options: Fill in default values
		foreach (array_keys($default_options) as $key) {
			if (($kjgrc_options == NULL) || ! array_key_exists($key,$kjgrc_options) ) {
				$kjgrc_options[$key] = $default_options[$key];
			}
		}
		// Delete keys that are not in use any more
		foreach (array_keys($default_options) as $key) {
			$tmp[$key] = $kjgrc_options[$key];
		}
		$kjgrc_options = $tmp;
		$kjgrc_options["version"] = $version;
		add_option("kjgrc_options",$options,$description = '', $autoload = 'no');
		update_option('kjgrc_options',$kjgrc_options);
	}
	return $kjgrc_options[$section . "_" . "$option_name"];
}

function kjgrc_use_cache()
{
	add_option('kjgrc_use_cache',1);
	return get_option("kjgrc_use_cache");
}

function kjgrc_options_page ()
{
?>
<?php
	$function = $_POST['function'];
	if (isset($_GET['updated']) && ($_GET['updated'] == 'true') && 
		(!empty($_POST['max_comments'])) && 
		(!empty($_POST['chars_per_comment'])) &&         
		(!empty($_POST['chars_per_word'])) && 
		(!empty($_POST['function'])) )
		// todo: check new params
	{
		if (($function == 'grc') ||
		    ($function == 'grt'))
		{
			if (!empty($_POST['reset_template'])) {
				if ($function == 'grc') {
					kjgrc_set_option('grc_format','<li><a href="%comment_link" title="%post_title, %post_date">%comment_author</a>: %comment_excerpt</li>');
					kjgrc_set_option('grc_grouped_by_post_a','<li><strong><a href="%post_link" title="%post_title was posted on %post_date">%post_title</a> (<a href="#" title="There are %post_counter comments to this posting">%post_counter</a>)</strong><ul>');
					kjgrc_set_option('grc_grouped_by_post_b','</ul></li>');
				}
				if ($function == 'grt') {
					kjgrc_set_option('grt_format','<li><a href="%comment_link" title="Trackback to &quot;%post_title&quot;: %comment_excerpt">%comment_author</a>: %trackback_title</li>');
				}
				//delete_option('kjgrc_'.$function.'_format');
			} else {
				kjgrc_set_option($function.'_max_comments', (int)$_POST['max_comments']);
				kjgrc_set_option($function.'_chars_per_comment', (int)$_POST['chars_per_comment']);
				kjgrc_set_option($function.'_chars_per_word', (int)$_POST['chars_per_word']);
				kjgrc_set_option($function.'_format', $_POST['format']);
				kjgrc_set_option($function.'_grouped_by_post_a', $_POST['grouped_by_post_a']);
				kjgrc_set_option($function.'_grouped_by_post_b', $_POST['grouped_by_post_b']);
			}
		}
		if ($function == 'grc') {

			if ($_POST['grc_exclude_blog_owner_checkbox'] == 'on') 
				kjgrc_set_option('grc_exclude_blog_owner',1);
			else 
				kjgrc_set_option('grc_exclude_blog_owner',0);
			if ($_POST['grc_exclude_blog_owner2_checkbox'] == 'on') 
				kjgrc_set_option('grc_exclude_blog_owner2',1);
			else
				kjgrc_set_option('grc_exclude_blog_owner2',0);
			if ($_POST['grouped_by_post_checkbox'] == 'on') {
				kjgrc_set_option('grc_grouped_by_post',1);
			} else {
				kjgrc_set_option('grc_grouped_by_post',0);
			}
			if ($_POST['grc_show_trackbacks_checkbox'] == 'on') {
				kjgrc_set_option('grc_show_trackbacks',1);
			} else {
				kjgrc_set_option('grc_show_trackbacks',0);
			}
			if (! empty($_POST['grc_comments_per_post'])) {
				kjgrc_set_option('grc_comments_per_post',(int)$_POST['grc_comments_per_post']);
				if (kjgrc_get_option("grc","comments_per_post") == 0)
					kjgrc_set_option("grc_comments_per_post",1);
			}
			if ($_POST['grc_limit_comments_per_post_checkbox'] == 'on') {
				kjgrc_set_option('grc_limit_comments_per_post',1);
			} else {
				kjgrc_set_option('grc_limit_comments_per_post',0);
			}
		}
	}
	if (isset($_GET['updated']) && ($_GET['updated'] == 'true'))
	{
	   	if ($function == 'exclude_cat') 
        	{
			if (count($_POST['exclude_category']) == 0) {
				kjgrc_set_option('misc_exclude_cat','');
			} else {
				kjgrc_set_option('misc_exclude_cat',implode(" ",$_POST['exclude_category']));
			}
			if (isset($_POST['exclude_categories_reverse'])) {
				if ($_POST['exclude_categories_reverse'] == 0 || $_POST['exclude_categories_reverse'] == 1) {
					kjgrc_set_option("misc_exclude_cat_reverse",$_POST['exclude_categories_reverse']);
				}
			}
        	}
		if ($function == 'gravatar') {
			if ($_POST['gravatar_size'] > 0 && $_POST['gravatar_size'] < 81) {
				kjgrc_set_option('gravatar_size',$_POST['gravatar_size']);
			}
			kjgrc_set_option('gravatar_alt_url',$_POST['gravatar_alt_url']);
			kjgrc_set_option('gravatar_rating',$_POST['gravatar_rating']);
		}
		if ($function == 'grt' && isset($_POST['ignore_ip']))
		{
			kjgrc_set_option('grt_ignore_ip',trim($_POST['ignore_ip']));
		}
		if ($function == 'misc' && isset($_POST['convert_smileys'])) {
			if ($_POST['convert_smileys'] == 0 || $_POST['convert_smileys'] == 1) {
				kjgrc_set_option("misc_convert_smileys",$_POST['convert_smileys']);
			}
		}
		if ($function == 'misc') {
			if ($_POST['use_cache_checkbox'] == 'on') {
				update_option("kjgrc_use_cache",1);
			} else {
				update_option("kjgrc_use_cache",0);
			}
		}
	}
	$kjgrc_subpage = 1;
	if (isset($_GET['subpage'])) {
		$kjgrc_subpage = $_GET['subpage'];
	}
	kjgrc_subpage_header($kjgrc_subpage);
	if ($kjgrc_subpage == 1) {
		kjgrc_subpage_grc(); 
	} elseif ($kjgrc_subpage == 2) {
		kjgrc_subpage_grt();
	} elseif ($kjgrc_subpage == 3) {
		kjgrc_subpage_instructions();
	} elseif ($kjgrc_subpage == 4) {
		kjgrc_subpage_exclude_cat();
	} elseif ($kjgrc_subpage == 5) {
		kjgrc_subpage_gravatar();
	} elseif ($kjgrc_subpage == 6) {
		kjgrc_subpage_misc();
	}
}

function kjgrc_add_options_page() 
{
	add_options_page('Get Recent Comments Plugin', 'Recent Comments', 8, 'get-recent-comments.php','kjgrc_options_page');
}

function kjgrc_get_exclude_cat ()
{
	$exclude_cat = kjgrc_get_option('misc','exclude_cat');
	if ($exclude_cat == '') {
		return FALSE;
	}
	#echo "cats: '". kjgrc_get_option('misc','exclude_cat') ."' ";
	return explode(" ",kjgrc_get_option('misc','exclude_cat'));
}

#function kjgrc_suicide ()
#{
#	$plugins = get_settings('active_plugins');
#	if (in_array('get-recent-comments.php',$plugins)) {
#		unset($plugins['get-recent-comments.php']);
#		update_option('active_plugins',$plugins);
#	}
#	delete_option('kjgrc_options');
#	kjgrc_get_option('grc','max_comments');
#	delete_option('kjgrc_options');
#	delete_option('kjgrc_cache');
#	echo 'you are now dead';
#}

function get_recent_comments()
{
	echo kjgrc_cache("comments");
}

function get_recent_trackbacks()
{
	echo kjgrc_cache("trackbacks");
}

function kjgrc_invalidate_cache() {
	delete_option('kjgrc_cache');
}
function kjgrc_handle_new_comment($args) {
	if (wp_get_comment_status($args) == 'approved') {
		kjgrc_invalidate_cache();
	}
}

function kjgrc_prepare_cache($cache)
{
	// return $cache;
	$last = 0;
	$start = strpos($cache,'<%time_since:');
	if ($start === false) {
		return $cache;
	}
	while ($start !== false)
	{
		//kjgrc_log("start: $start");
		$end = strpos($cache,'>',$start);
		//kjgrc_log("end $end");
		//kjgrc_log("cut $last - $start");
		$newcache = $newcache . substr($cache,$last,$start-$last);
		$tmp = substr($cache,$start+13,$end-$start-13);
		$ago = gmdate('U')-$tmp;
		//kjgrc_log("--> $tmp <--");
		$newcache = $newcache . kjgrc_format_seconds($ago);
		#kjgrc_log("$newcache");
		$last = $end + 1;
		$start = strpos($cache,'<%time_since:',$last);
	}
	$newcache = $newcache . substr($cache,$last);
	return $newcache;	
}

function kjgrc_cache($type)
{
	global $wpdb,$kjgrc_cache;
	$use_cache = FALSE;
	if (kjgrc_use_cache()) {
		$use_cache = TRUE;
	}
	if ($use_cache == FALSE) {
		// kjgrc_log("return cache without caching");
		$kjgrc_cache[comments] = kjgrc_prepare_cache(kjgrc_create_recent_comments());
		$kjgrc_cache[trackbacks] = kjgrc_prepare_cache(kjgrc_create_recent_trackbacks());
		return $kjgrc_cache[$type];
	}
	if ($kjgrc_cache == NULL) {
		// kjgrc_log("return cache WITH caching");
		$kjgrc_cache = get_option('kjgrc_cache');
		if ($kjgrc_cache == NULL) {
			// kjgrc_log("write new cache");
			$kjgrc_cache[comments] =  base64_encode(kjgrc_create_recent_comments());
			$kjgrc_cache[trackbacks] = base64_encode(kjgrc_create_recent_trackbacks());
			update_option('kjgrc_cache',$kjgrc_cache);
		}
		$kjgrc_cache[comments] = kjgrc_prepare_cache(base64_decode($kjgrc_cache[comments]));
		$kjgrc_cache[trackbacks] = kjgrc_prepare_cache(base64_decode($kjgrc_cache[trackbacks]));
	}
	// search and replace up to date information
	return $kjgrc_cache[$type];
}


function kjgrc_create_recent_trackbacks( $caller = '')
{
	global $kjgrc_we_are_a_widget,$kjgrc_widget_args;;

	// $entries = kjgrc_get_entries($max_comments,$chars_per_comment,$chars_per_word,$format,$query,0,$caller);
	$entries = kjgrc_get_comments2('grt',$caller);
	// If we are a widget: Also care for the title
	if ($kjgrc_we_are_a_widget == TRUE) {
        	extract($kjgrc_widget_args);
        	return $before_widget . $before_title . kjgrc_get_option("grt","sidebar_title") . $after_title .
        	'<div id="get_recent_comments_wrap"><ul>' .
		$entries .
		'</ul></div>' .
		$after_widget;
        }
	return $entries;
}

function kjgrc_create_recent_comments ($caller='')
{
	global $kjgrc_we_are_a_widget,$kjgrc_widget_args;

	// $entries = kjgrc_get_entries($max_comments,$chars_per_comment,$chars_per_word,$format,$query,kjgrc_get_option("grc","grouped_by_post"),$caller);
	// If we are a widget: Also care for the title
	// $entries = kjgrc_get_comments2($max_comments,$chars_per_comment,$chars_per_word,$format,kjgrc_get_option("grc","grouped_by_post"),$caller);
	$entries = kjgrc_get_comments2('grc',$caller);
	if ($kjgrc_we_are_a_widget == TRUE) {
        	extract($kjgrc_widget_args);
        	return $before_widget . $before_title . kjgrc_get_option("grc","sidebar_title") . $after_title .
        	'<div id="get_recent_comments_wrap"><ul>' .
		$entries .
		'</ul></div>' .
		$after_widget;
        } 
	return $entries;
}

function kjgrc_parse_pingback($pingback_author)
{
	$workstring = trim($pingback_author);
	/* most common syntax
	1. author &raquo; title
	2. author &raquo; category &raquo; title
	3. title at author
	4. title - author (too insignificant)
	5. [&raquo;] title &laquo; author
	*/
	$first_delimiter = strpos($workstring,'&raquo;');
	while ($first_delimiter !== false && $first_delimiter == 0) {
		$workstring = trim(substr($workstring,7));
		$first_delimiter = strpos($workstring,'&raquo;');
	}
	if ($first_delimiter !== false) {
		$comment_author = substr($workstring,0,$first_delimiter-1);
		$workstring = trim(substr($workstring,$first_delimiter+7));
		$first_delimiter = strpos($workstring,'&raquo;');
		if ($first_delimiter !== false) {
			$workstring = trim(substr($workstring,$first_delimiter+7));
		}
		return array($comment_author,$workstring);
	}
	foreach (array(' at ','&laquo;',' - ',' auf ',' by ',' // ',' | ',' : ',' @ ',' / ') as $delimiter)
	{
		$first_delimiter = strpos($workstring,$delimiter);
		if ($first_delimiter !== false) {
			$trackback_title = trim(substr($workstring,0,$first_delimiter));
			$comment_author = trim(substr($workstring,$first_delimiter+strlen($delimiter)));
			// kjgrc_log("delimiter match [$delimiter]: $workstring -> a: '$comment_author' t: '$trackback_title' ");
			return array($comment_author,$trackback_title);
		}
	}
	// $comment_author = 'Unknown';
	$comment_author = $pingback_author;
	$trackback_title = '';
	return array($comment_author,$trackback_title);
}

// original function from wordpress 2.3 for backwards compatibility to wordpress 2.0.11
function kjgrc_get_users_of_blog( $id = '' ) {
        global $wpdb, $blog_id;
        if ( empty($id) )
                $id = (int) $blog_id;
        $users = $wpdb->get_results( "SELECT user_id, user_login, display_name, user_email, meta_value FROM $wpdb->users, $wpdb->usermeta WHERE " . $wpdb->users . 
".ID = " . $wpdb->usermeta . ".user_id AND meta_key = '" . $wpdb->prefix . "capabilities' ORDER BY {$wpdb->usermeta}.user_id" );
        return $users;
}


/* This function is dedicated to Mike */
function kjgrc_is_wordpress_user($comment)
{
	global $kjgrc_wordpress_users;
	if ($kjgrc_wordpress_users == NULL) {
		// be still compatible to wordpress 2.0.11
		if (function_exists("get_users_of_blog")) {
			$kjgrc_wordpress_users = get_users_of_blog();
		} else {
			$kjgrc_wordpress_users = kjgrc_get_users_of_blog();
		}
	}
	foreach ($kjgrc_wordpress_users as $user) {
		if (strcasecmp($comment->comment_author_email,$user->user_email) == 0 ) {
			if ( (strcasecmp($comment->comment_author,$user->user_login) == 0) ||
			     (strcasecmp($comment->comment_author,$user->display_name) == 0) ) 
			{
				return TRUE;
			}
		}
	}
	return FALSE;
}

// function kjgrc_get_comments2 ($max_comments,$chars_per_comment,$chars_per_word,$format,$grouped_by_post,$caller)
function kjgrc_get_comments2 ($requested_comment_type,$caller)
{
	// kjgrc_log("kjgrc_get_comments2 $caller");
	// echo "kjgrc_get_comments2 $requested_comment_type $caller<br>";
	global $wpdb;
	$batch_number = 0;
	$number_of_comments = 0;

	$requested_number_of_comments = kjgrc_get_option($requested_comment_type,"max_comments");
	$chars_per_comment = kjgrc_get_option($requested_comment_type,"chars_per_comment");
	$chars_per_word = kjgrc_get_option($requested_comment_type,"chars_per_word");
	$format = stripslashes(kjgrc_get_option($requested_comment_type,"format"));
	$batch_size = $requested_number_of_comments * 3;
	// grc
	//x// $max_comments = kjgrc_get_option("grc","max_comments");
	//x// $chars_per_comment = kjgrc_get_option("grc","chars_per_comment");
	//x// $chars_per_word = kjgrc_get_option("grc","chars_per_word");
	//x// $format = stripslashes(kjgrc_get_option("grc","format"));
	//x// $sql_comment_type = "AND comment_type = '' ";
	//x// if (kjgrc_get_option("grc","show_trackbacks") == 1) {
	//x// 	$sql_comment_type = '';
	//x// }
	
	// grt
	//// $max_comments = kjgrc_get_option("grt","max_comments");
	//// $chars_per_comment = kjgrc_get_option("grt","chars_per_comment");
	//// $chars_per_word = kjgrc_get_option("grt","chars_per_word");
	//// $format = stripslashes(kjgrc_get_option("grt","format"));

	//// $query = "SELECT DISTINCT $wpdb->comments.* FROM $wpdb->comments ".
	//// 	"LEFT JOIN $wpdb->posts ON $wpdb->posts.ID=$wpdb->comments.comment_post_ID ".
	//// 	$sql_join_post2cat .
	//// 	"WHERE (post_status = 'publish' OR post_status = 'static') AND comment_approved= '1' AND  post_password = '' ".
	//// 	$sql_exlude_cat .
	//// 	"AND ( comment_type = 'trackback' OR comment_type = 'pingback' ) ".
        ////         $sql_ignore_ip .
	//// 	"ORDER BY comment_date DESC LIMIT $max_comments";
	
	$sql_ignore_ip = '';
	$sql_exclude_owner = '';
	$grouped_by_post = 0;
	if ($requested_comment_type == 'grt')
	{	
		if (kjgrc_get_option("grt","ignore_ip") != '') {
			$sql_ignore_ip = "AND comment_author_IP != '". kjgrc_get_option("grt","ignore_ip") ."' ";
		}
		$sql_comment_type = "( comment_type = 'trackback' OR comment_type = 'pingback' ) ";
	}
	if ($requested_comment_type == 'grc')
	{
		$sql_comment_type = "comment_type = '' ";
		if (kjgrc_get_option("grc","show_trackbacks") == 1) {
			$sql_comment_type = '1 ';
		}
		if (kjgrc_get_option("grc","exclude_blog_owner") == 1) {
		 	$sql_exclude_owner = "AND user_id = '0' ";
		}
		if (kjgrc_get_option("grc","grouped_by_post")) {
			$grouped_by_post = 1;
		}
	}

	while ($comments_number < $requested_number_of_comments) 
	{
		$query = "SELECT * from $wpdb->comments WHERE comment_approved= '1' AND " . 
			 $sql_comment_type .
			 $sql_exclude_owner .
			 $sql_ignore_ip .
			 "ORDER BY comment_date DESC LIMIT " . ($batch_number*$batch_size) . ",$batch_size"; 
		// echo "$query<br><br>";
		$comments = $wpdb->get_results($query);
		if (!$comments) {
			$result .= "none";
			break;
		}
		unset($missing_post);
		foreach ($comments as $comment) {
			if ($post_cache == NULL || ! array_key_exists($comment->comment_post_ID,$post_cache)) {
				$missing_post[$comment->comment_post_ID] = 1;
			}
		}
		if ($missing_post != NULL)
		{
			unset($comma_separated);
			$comma_separated = implode(",", array_keys($missing_post));
			if (empty($wpdb->term_relationships)) {
				$query = "SELECT * from $wpdb->posts JOIN $wpdb->post2cat ON ID = post_id WHERE ID IN ($comma_separated);";
			} else { 
				$query = "SELECT * from $wpdb->posts JOIN $wpdb->term_relationships ON ($wpdb->term_relationships.object_id=ID)  WHERE ID IN ($comma_separated);"; 
			}
			// echo "$query<br>";
			$posts = $wpdb->get_results($query);
			foreach ($posts as $post) {
				// echo "p: $post->ID ";
				$post_cache[$post->ID] = $post;
				if (empty($wpdb->term_relationships)) {
					$cat_cache[$post->ID][$post->category_id] = 1;
				} else {
					$cat_cache[$post->ID][$post->term_taxonomy_id] = 1;
				}	
			}
		}
		// echo "-------<br>";
		// drop comments:
		// 1. comment_approved = 1 -> in select
        	// 2. post_status = 'publish' OR post_status = 'static'
		// 3. post_password = ''
		// 4. AND user_id = '0' -> in select
		// 5. AND comment_author_IP != '1.2.3.4' -> in select	
		// 6. "AND category_id  != '$cat'
    		// 7. limit_comments_per_post

		foreach ($comments as $comment) 
		{
			if ($post_cache[$comment->comment_post_ID]->post_status != 'publish' &&
                            $post_cache[$comment->comment_post_ID]->post_status != 'static' ) 
			{	
				// echo "drop $comment->comment_ID (". $post_cache[$comment->comment_post_ID]->post_status .")<br>";
				continue;
			}	
			if ($post_cache[$comment->comment_post_ID]->post_password != '') {
				// echo "drop $comment->comment_ID (protected)<br>";
				continue;
			}
			/* Optional additional check for wordpress users who are not logged in */
			if ((kjgrc_get_option("grc","exclude_blog_owner") == 1) && 
			    (kjgrc_get_option("grc","exclude_blog_owner2") == 1)	
			   ) 
			{
				if (kjgrc_is_wordpress_user($comment)) {
					// echo "drop $comment->comment_ID (is_wordpress_user)<br>";
					continue;
				}
			}
			$exclude_cat = kjgrc_get_exclude_cat();
			$is_in_excluded_cat = 0;
			if (kjgrc_get_option("misc","exclude_cat_reverse") == 1) {
				$is_in_excluded_cat = 1;
			}
			if ($exclude_cat) {
				foreach ($exclude_cat as $cat) {
					if ($cat_cache[$comment->comment_post_ID][$cat] == 1) {
						$is_in_excluded_cat = 1;
						if (kjgrc_get_option("misc","exclude_cat_reverse") == 1) {
							$is_in_excluded_cat = 0;
						}
						// echo "drop $comment->comment_ID (is in excluded cat $cat)<br>";
						
					}
				}
				if ($is_in_excluded_cat) {
					continue;
				}
			}
			// nur !trackbacks?
			if ($grouped_by_post && kjgrc_get_option("grc","limit_comments_per_post") == 1) {
				if ($comments_per_post_counter[$comment->comment_post_ID] >= kjgrc_get_option("grc","comments_per_post")) {
					// echo "drop $comment->comment_ID (max nr cmt/post reached)<br>";
					continue;
				}
			}
			$comments_per_post_counter[$comment->comment_post_ID]++;
			$comments_number++;
			// $result .= "$comments_number [$batch_number] $comment->comment_ID ($comment->comment_content)<br>";
			$fetched_comments[] = $comment;
			if ($comments_number >= $requested_number_of_comments) {
				break;
			}
		}
		$batch_number++;
		
	} 
        // comments are selected. now format them

	if (!(strpos($format,"%gravatar") !== false))
		$has_gravatar = 0;
	else {
		$has_gravatar = 1;
		$gravatar_alt_url = kjgrc_get_option('gravatar','alt_url');
		$gravatar_size    = kjgrc_get_option('gravatar','size');
		$gravatar_rating  = kjgrc_get_option('gravatar','rating');
		$gravatar_mpaa[0] = 'G';
		$gravatar_mpaa[1] = 'PG';
		$gravatar_mpaa[2] = 'R';
		$gravatar_mpaa[3] = 'X';
		$gravatar_options .= "&amp;size=$gravatar_size";
		$gravatar_options .= "&amp;rating=" . $gravatar_mpaa[$gravatar_rating];
		if (kjgrc_get_option('gravatar','alt_url') != '') {
			$gravatar_options .= "&amp;default=" . urlencode($gravatar_alt_url);
		}
	}

        if (! $fetched_comments) {
		return "<li><!-- no comments yet --></li>";
	}
	foreach ($fetched_comments as $comment)
	{
		$trackback_title = '';
		if (function_exists("polyglot_init")) {
			// This looks like the wrong filter, but the_content deletes smileys when called from here
			$comment_excerpt = apply_filters('single_post_title',$comment->comment_content);
		} else {
			$comment_excerpt = $comment->comment_content;
		}
		// comment_author, 
		$comment_type = "Comment";
		if ($comment->comment_type == 'pingback') 
		{
			
			$comment_type = "Pingback";
			list($comment_author,$trackback_title) = kjgrc_parse_pingback($comment->comment_author);
			if(strpos($comment_excerpt,'[...]') == 0) 
				$comment_excerpt = trim(substr($comment_excerpt,5));
			if(strpos($comment_excerpt,'[...]') == strlen($comment_excerpt)-5)
				$comment_excerpt = trim(substr($comment_excerpt,0,strlen($comment_excerpt)-5));
		}
		elseif ($comment->comment_type == 'trackback') 
		{
			$comment_type = "Trackback";
			$trackback_title = preg_replace("/^<strong>(.+?)<\/strong>.*/s","$1",$comment->comment_content);
			$trackback_title = strip_tags($trackback_title);
			$trackback_title = preg_replace("/[\n\t\r]/"," ",$trackback_title);
               		$trackback_title = preg_replace("/\s{2,}/"," ",$trackback_title);
               		$trackback_title = wordwrap($trackback_title,$chars_per_word,' ',1);
										
			$comment_excerpt = preg_replace("/^<strong>.+?<\/strong>/","",$comment->comment_content,1);
			$comment_author = $comment->comment_author;
		}
		else 
		{
			$comment_author = $comment->comment_author;
			if (!$comment_author)
				$comment_author = "Anonymous";
		}	
		$comment_excerpt = strip_tags(wptexturize($comment_excerpt));

		$comment_excerpt = preg_replace("/[\n\t\r]/"," ",$comment_excerpt); // whitespace into 1 blank
		$comment_excerpt = preg_replace("/\s{2,}/"," ",$comment_excerpt); // whitespace into 1 blank
                $comment_excerpt = wordwrap($comment_excerpt,$chars_per_word,' ',1);

		if ($trackback_title == '')
			$trackback_title = $comment_excerpt;

		$post_link    = get_permalink($comment->comment_post_ID);
		$comment_link = $post_link .
				"#comment-$comment->comment_ID";
		/* Does not work - polyglot uses global variables to access the comment/post data
		if (function_exists("polyglot_init")) {
			$comment_date = apply_filters('the_date',$comment->comment_date);
		} else {
			$comment_date = mysql2date(get_settings('date_format'),$comment->comment_date);
		}
		if (function_exists("polyglot_init")) {
			$comment_time = apply_filters('the_time',$comment->comment_date);
		} else {
			//$comment_time = substr($comment->comment_date,11,5); // 2005-03-09 22:23:53
			$comment_time = mysql2date(get_settings('time_format'),$comment->comment_date); // Thanks to Keith
		}
		*/
		$comment_date = mysql2date(get_settings('date_format'),$comment->comment_date);
		$comment_time = mysql2date(get_settings('time_format'),$comment->comment_date); // Thanks to Keith

		if ($has_gravatar && $comment_author != '') 
		{
			if ($md5_cache && array_key_exists($comment->comment_author,$md5_cache)) {
				$gravatar_md5 = $md5_cache[$comment->comment_author];
			} else {
				$gravatar_md5 = md5($comment->comment_author_email);
				$md5_cache[$comment->comment_author_email] = $gravatar_md5; 
			}
			$comment_gravatar_url = "http://www.gravatar.com/avatar.php?" .
				"gravatar_id=$gravatar_md5" .
				$gravatar_options;
				
			$comment_gravatar = "<img src=\"" . $comment_gravatar_url .
				"\" alt=\"\" width=\"$gravatar_size\" height=\"$gravatar_size\" class=\"kjgrcGravatar\" />";
		}
		#$post = get_postdata($comment->comment_post_ID);
		#$post_date = mysql2date(get_settings('date_format'),$post['Date']);
		#$post_title = trim(htmlspecialchars(stripslashes($post['Title'])));
		#$post = get_postdata($comment->comment_post_ID);
		// *** insert cache for post data here
		// $post = $wpdb->get_row("SELECT * from $wpdb->posts WHERE ID = $comment->comment_post_ID");
		$post = $post_cache[$comment->comment_post_ID];
		if (function_exists("polyglot_init")) {
			$post_date = apply_filters('the_date',$post->post_date);
		} else {
			$post_date = mysql2date(get_settings('date_format'),$post->post_date);
		}
		// $post_title = trim(htmlspecialchars(stripslashes($post->post_title)));
		$post_title = strip_tags(wptexturize($post->post_title));
		if (function_exists("polyglot_init")) {
			$post_title = apply_filters('single_post_title',$post_title);
		}
		$post_counter = $post->comment_count;

		$author_url = $comment->comment_author_url;
		if ($author_url == "http://")
			$author_url = "";
		if (empty($author_url) || $author_url == "http://")
			$author_url_href = "";

		$output = $format;
		// Replace tags by values
		$output = str_replace("%comment_link",    $comment_link,     $output);
		$output = str_replace("%author_url_href", $author_url_href,  $output);
		$output = str_replace("%author_url",      $author_url,       $output);
		$output = str_replace("%userid",  	  $comment->user_id, $output);
		
		$output = str_replace("%gravatar_url",    $comment_gravatar_url, $output);
		$output = str_replace("%gravatar",        $comment_gravatar, $output);

		// function author_image_path($authorID, $display = true, $type = 'url') 
		if (function_exists("author_image_path")) {
			$profile_pict = author_image_path($comment->user_id,false,'url');
			$output = str_replace("%profile_picture",  $profile_pict,   $output);
		} else {
			$output = str_replace("%profile_picture",  '',   $output);
		}

		$output = str_replace("%comment_author",  $comment_author,   $output);
		$output = str_replace("%comment_date",    $comment_date,     $output);
		$output = str_replace("%comment_time",    $comment_time,     $output);

		
		//$output = str_replace("%time_since",    'time_since_' . $comment->unixdate . ' - ' . gmdate('U') .' = '. ($comment->unixdate-gmdate('U')),    $output);
		$utc_time = kjgrc_utc2unixtime($comment->comment_date_gmt); //2006-12-30 17:05:59
		$output = str_replace("%time_since",    "<%time_since:$utc_time>",    $output);
		
		$output = str_replace("%comment_type",    $comment_type,     $output);
		$output = str_replace("%post_title",      $post_title,       $output);
		$output = str_replace("%post_link",       $post_link,        $output);
		$output = str_replace("%post_date",       $post_date,        $output);
		$output = str_replace("%post_counter",    $post_counter,     $output);

		/*
		// Nice idea, but confuses users
		//strip title or content?
		$visible = strip_tags($output);
		if (strpos($visible,'%comment_excerpt') !== false) {
			$comment_excerpt = kjgrc_excerpt($comment_excerpt,$chars_per_comment,$chars_per_word,'%comment_excerpt',$output);
		} 
		elseif (strpos($visible,'%trackback_title') !== false) {
			$trackback_title = kjgrc_excerpt($trackback_title,$chars_per_comment,$chars_per_word,'%trackback_title',$output);
		}
		*/
		$comment_excerpt = kjgrc_excerpt($comment_excerpt,$chars_per_comment,$chars_per_word,'%comment_excerpt',$output);
		if (kjgrc_get_option("misc","convert_smileys")) {
			if (function_exists("csm_convert") ) {
				$comment_excerpt = csm_convert($comment_excerpt);
			} 
			else {
				if (get_settings('use_smilies')) {
					$comment_excerpt = convert_smilies($comment_excerpt);
				}
			}
		}

		$trackback_title = kjgrc_excerpt($trackback_title,$chars_per_comment,$chars_per_word,'%trackback_title',$output);
		
		$output = str_replace("%comment_excerpt", $comment_excerpt, $output);
		$output = str_replace("%trackback_title", $trackback_title, $output);
		// Replacement done

		//$len = strlen(strip_tags($output));
		//$output .= " [$comment_time]";
		// . " (" . time_since(strtotime($comment->comment_date_gmt." GMT")) ." ago)";
		// *** Das aber nur bei recent comments, nicht bei trackbacks!
		// if (kjgrc_get_option("grc","limit_comments_per_post") == 1) {
		// 	if (count($comment_list[$comment->comment_post_ID]) < kjgrc_get_option("grc","comments_per_post")) { 
		// 		$comment_list[$comment->comment_post_ID][] = $output;
		// 	}
		// } else {
		// 		$comment_list[$comment->comment_post_ID][] = $output;
		// }
		$comment_list[$comment->comment_post_ID][] = $output;

		if (($post_list == NULL) || ! array_key_exists($comment->comment_post_ID,$post_list)) {
			$post_output = stripslashes(kjgrc_get_option("grc","grouped_by_post_a"));
			$post_output = str_replace("%post_title",         $post_title,         $post_output);
			$post_output = str_replace("%post_link",          $post_link,          $post_output);
			$post_output = str_replace("%post_date",          $post_date,          $post_output);
			$post_output = str_replace("%post_counter",       $post_counter, $post_output);
			$post_list[$comment->comment_post_ID] = $post_output;
		}

		$all_entries .= "\t$output\n";
		if ($caller == 'grc_sample' || $caller ==  'grt_sample') 
			break;
	} // foreach comments

	if ($grouped_by_post == 1)
	{	
		$all_entries = '';
		foreach (array_keys($post_list) as $post_id) {
			$all_entries .= $post_list[$post_id] . "\n";
			foreach ($comment_list[$post_id] as $tmp) {
				$all_entries .= $tmp ."\n";
			} 
			$all_entries .= kjgrc_get_option("grc","grouped_by_post_b") ."\n";
		}
	}
		
	return $all_entries;
}

function kjgrc_utc2unixtime($utc_time)
{
	$y = substr($utc_time,0,4);
	$m = substr($utc_time,5,2);
	$d = substr($utc_time,8,2);
	$h = substr($utc_time,11,2);
	$min = substr($utc_time,14,2);
	$s   = substr($utc_time,17,2);
	//mktime ( [int hour [, int minute [, int second [, int month [, int day [, int year [, int is_dst]]]]]]])
	//$ago = gmdate('U')-$utc_time;
	return gmmktime($h,$min,$s,$m,$d,$y);
}

function kjgrc_format_seconds($seconds)
{
	$d_str = "days";
	$h_str = "hours";
	$m_str = "minutes";
	$s_str = "seconds";

	$d = floor($seconds / (24 * 3600));
	if ($d == 1) $d_str = "day";
	$seconds = $seconds - ($d * 24 * 3600);
	
	$h = floor($seconds / 3600);
	if ($h == 1) $h_str = "hour";
	$seconds = $seconds - ($h * 3600);

	$m = floor($seconds / 60);
	if ($m == 1) $m_str = "minute";
	$seconds = $seconds - ($m * 60);
	
	$s = $seconds;
	if ($s == 1) $s_str = "second";
	
	if ($d > 0) return "$d $d_str $h $h_str";
	if ($h > 0) return "$h $h_str $m $m_str";
	if ($m > 0) return "$m $m_str $s $s_str";
	return "$s $s_str";
}

function kjgrc_excerpt ($text,$chars_per_comment,$chars_per_word,$tag,$output)
{
	$length = strlen(str_replace($tag,"",strip_tags($output)));
	$length = $chars_per_comment - $length;
	$length = $length -2; // we will add three dots at the end
	if ($length < 0) $length = 0;
	if (strlen($text) > $length) {
		$text = substr($text,0,$length);
		$text = substr($text,0,strrpos($text,' '));
		// last word exceeds max word length:
		if ((strlen($text) - strrpos($text,' ')) > $chars_per_word) {
			$text = substr($text,0,strlen($text)-3);
		} 
		$text = $text . "...";
	}
	#$text = "[EXCERPT]: '$text'";
	return "$text";
}

function widget_kj_get_recent_comments_init() {
	if (! function_exists("register_sidebar_widget")) {
		return;
	}
	function widget_get_recent_comments($args) {
		global $kjgrc_we_are_a_widget,$kjgrc_widget_args;
		$kjgrc_we_are_a_widget = TRUE;
		$kjgrc_widget_args = $args;
		get_recent_comments();
	}
	function widget_get_recent_comments_control() {
		global $kjgrc_we_are_a_widget;
		$kjgrc_we_are_a_widget = TRUE;
		if ( $_POST['get_recent_comments-submit'] ) {
			kjgrc_set_option("grc_sidebar_title",stripslashes($_POST['get_recent_comments-title']));
			kjgrc_invalidate_cache();
		}
		echo '<p style="text-align:right;"><label for="get_recent_comments-title">Title: <input style="width: 200px;" id="get_recent_comments-title" name="get_recent_comments-title" type="text" value="'.kjgrc_get_option("grc","sidebar_title").'" /></label></p>';
		echo '<input type="hidden" id="get_recent_comments-submit" name="get_recent_comments-submit" value="1" />';
		echo 'More options are on the <a href="options-general.php?page=get-recent-comments.php&amp;subpage=1">plugin page</a>.';
	}
	register_sidebar_widget('Get Recent Comments', 'widget_get_recent_comments');
	register_widget_control('Get Recent Comments', 'widget_get_recent_comments_control', 300, 100);
}

function widget_kj_get_recent_trackbacks_init() {
	if (! function_exists("register_sidebar_widget")) {
		return;
	}
	function widget_get_recent_trackbacks($args) {
		global $kjgrc_we_are_a_widget,$kjgrc_widget_args;;
		$kjgrc_we_are_a_widget = TRUE;
		$kjgrc_widget_args = $args;
		get_recent_trackbacks();
	}
	function widget_get_recent_trackbacks_control() {
		global $kjgrc_we_are_a_widget;
		$kjgrc_we_are_a_widget = TRUE;
		if ( $_POST['get_recent_trackbacks-submit'] ) {
			kjgrc_set_option("grt_sidebar_title",stripslashes($_POST['get_recent_trackbacks-title']));
			kjgrc_invalidate_cache();
		}
		echo '<p style="text-align:right;"><label for="get_recent_trackbacks-title">Title: <input style="width: 200px;" id="get_recent_trackbacks-title" name="get_recent_trackbacks-title" type="text" value="'.kjgrc_get_option("grt","sidebar_title").'" /></label></p>';
		echo '<input type="hidden" id="get_recent_trackbacks-submit" name="get_recent_trackbacks-submit" value="1" />';
		echo 'More options are on the <a href="options-general.php?page=get-recent-comments.php&amp;subpage=2">plugin page</a>.';
	}
	
	register_sidebar_widget('Get Recent Trackbacks', 'widget_get_recent_trackbacks');
	register_widget_control('Get Recent Trackbacks', 'widget_get_recent_trackbacks_control', 300, 100);
}

add_action('admin_menu', 'kjgrc_add_options_page');
add_action('edit_comment','kjgrc_invalidate_cache');
add_action('delete_comment','kjgrc_invalidate_cache');
add_action('edit_post','kjgrc_invalidate_cache');
add_action('delete_post','kjgrc_invalidate_cache');
add_action('publish_post','kjgrc_invalidate_cache');
add_action('switch_theme', 'kjgrc_invalidate_cache');
add_action('wp_set_comment_status','kjgrc_invalidate_cache');
add_action('comment_post','kjgrc_handle_new_comment');
add_action('trackback_post','kjgrc_handle_new_comment');
add_action('pingback_post','kjgrc_handle_new_comment');
add_action('plugins_loaded', 'widget_kj_get_recent_comments_init');
add_action('plugins_loaded', 'widget_kj_get_recent_trackbacks_init');

?>
