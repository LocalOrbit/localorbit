<?php
	if(isset($_POST['saveit'])){
		if (isset($_POST['newspage_numitems']))
			update_option('newspage_numitems', $_POST['newspage_numitems']);
		if (isset($_POST['newspage_cache_on'])){
			update_option('newspage_cache_on', $_POST['newspage_cache_on']);
		}
		if (isset($_POST['newspage_cache_duration']))
			update_option('newspage_cache_duration', $_POST['newspage_cache_duration']);
		if (isset($_POST['newspage_cache_duration_units']))
			update_option('newspage_cache_duration_units', $_POST['newspage_cache_duration_units']);
		if (isset($_POST['newspage_linklove']))
			update_option('newspage_linklove', $_POST['newspage_linklove']);
		if (isset($_POST['newspage_useFeedTitle']))
			update_option('newspage_useFeedTitle', $_POST['newspage_useFeedTitle']);
		if (isset($_POST['newspage_showtopics']))
			update_option('newspage_showtopics', $_POST['newspage_showtopics']);
		if (isset($_POST['newspage_use_externalstyle']))
			update_option('newspage_use_externalstyle', $_POST['newspage_use_externalstyle']);
		if (isset($_POST['newspage_newwindow']))
			update_option('newspage_newwindow', $_POST['newspage_newwindow']);
	}
	$newspage_numitems = get_option('newspage_numitems');
	$newspage_cache_on = get_option('newspage_cache_on');
	$newspage_cache_duration = get_option('newspage_cache_duration');
	$newspage_cache_duration_units = get_option('newspage_cache_duration_units');
	$newspage_linklove = get_option("newspage_linklove");
	$newspage_useFeedTitle = get_option("newspage_useFeedTitle");
	$newspage_showtopics = get_option("newspage_showtopics");
	$newspage_use_externalstyle = get_option("newspage_use_externalstyle");
	$newspage_newwindow = get_option("newspage_newwindow");
?>
<style>
a.info{position:relative;z-index:24;}
a.info:hover {z-index:25;text-decoration:none;}
a.info span {display: none;}
a.info:hover span {display:block;position:absolute;top:1em;left:0;width:350px;border:1px solid #000;background-color:#ccc;color:#000;padding:4px;}
</style>
<div class="wrap">
	<h2>NewsPage Settings</h2>
	<form method="post" action="" id="ap_conf">
	<input type="hidden" name="saveit" value="1" />
	<table class="form-table">
	<tr valign="top">
		<th scope="row"><label for="newspage_numitems">Number of Items to Show Per Feed?</label></th>
		<td><input type="text" name="newspage_numitems" value="<?php echo $newspage_numitems?>" /></td>
	</tr>
	<tr valign="top">
		<th scope="row"><label for="newspage_cache_on">Turn caching on?</label></th>
		<td>
			<select name="newspage_cache_on">
				<option value="1" <?php if($newspage_cache_on == 1) echo " selected "; ?>>Yes (Recommended)</option>
				<option value="0" <?php if($newspage_cache_on == 0) echo " selected "; ?>>No</option>
			</select>
			<p class="footnote">Disabling cache will negatively impact performance (and anger feed creators), but will ensure that the very freshest version of the feed is displayed at all times.</p>
		</td>
	</tr>
	<tr valign="top">
		<th scope="row"><label for="newspage_cache_duration">How long to cache for?</label></th>
		<td>
			<input type="text" class="text" name="newspage_cache_duration" value="<?php echo $newspage_cache_duration ?>" size="10" />
			<select name="newspage_cache_duration_units">
				<option value="1" <?php if($newspage_cache_duration_units == 1) echo " selected "; ?>>Seconds</option>
				<option value="60" <?php if($newspage_cache_duration_units == 60) echo " selected "; ?>>Minutes</option>
				<option value="3600" <?php if($newspage_cache_duration_units == 3600) echo " selected "; ?>>Hours</option>
				<option value="87840" <?php if($newspage_cache_duration_units == 87840) echo " selected "; ?>>Days</option>
			</select>
			<p class="footnote">How long before we ask the feed if it's been updated? Recommend 1 hour (3600 seconds).</p>
		</td>
	</tr>
	<tr valign="top">
		<th scope="row">
			<label for="newspage_useFeedTitle">Use the titles from the RSS feeds for each feed?</label>
		</th>
		<td>
			<select name="newspage_useFeedTitle">
				<option value="1" <?php if($newspage_useFeedTitle == 1) echo " selected "; ?>>Yes (Recommended)</option>
				<option value="0" <?php if($newspage_useFeedTitle == 0) echo " selected "; ?>>No</option>
			</select>
			<p class="footnote">
				If set to no, newsPage will use the title you enter in RSS Feeds page
			</p>
		</td>
	</tr>
	<tr valign="top">
		<th scope="row">
			<label for="newspage_showtopics">Show List of Topics at bottom of newspage?</label>
		</th>
		<td>
			<select name="newspage_showtopics">
				<option value="1" <?php if($newspage_showtopics == 1) echo " selected "; ?>>Yes (Recommended)</option>
				<option value="0" <?php if($newspage_showtopics == 0) echo " selected "; ?>>No</option>
			</select>
		</td>
	</tr>
	<tr valign="top">
		<th scope="row">
			<label for="newspage_newwindow">Open links in a new window?</label>
		</th>
		<td>
			<select name="newspage_newwindow">
				<option value="1" <?php if($newspage_newwindow == 1) echo " selected "; ?>>Yes (Recommended)</option>
				<option value="0" <?php if($newspage_newwindow == 0) echo " selected "; ?>>No</option>
			</select>
		</td>
	</tr>
	<tr valign="top">
		<th scope="row">
			<label for="newspage_use_externalstyle">Use your own stylesheet instead of the newsPage stylesheet?</label>
		</th>
		<td>
			<select name="newspage_use_externalstyle">
				<option value="0" <?php if($newspage_use_externalstyle == 0) echo " selected "; ?>>No (Recommended)</option>
				<option value="1" <?php if($newspage_use_externalstyle == 1) echo " selected "; ?>>Yes</option>
			</select>
			<p class="footnote">
				If you set this option to 0, then please make sure you copy the following to your CSS, and change it as you go:<br/>
				<div style="width:70%;overflow:auto;"><pre><code>
div.feed {width: 300px;float: left;padding: 0 20px 20px 0;margin: 0;}
.feed div.feedtitle {font-family: 'Trebuchet MS', arial;font-size: 14pt;font-weight: bold;margin: 0;padding: 0;text-transform: uppercase;}
.feed div.feedtitle a:link, .feed div.feedtitle a:visited {color: #666;text-decoration: none;}
.feed ul {margin: 0;padding: 0;list-style: none;}
.feed li {font-family: Arial;font-size: 8pt;line-height: 2em;border-top: 1px solid #ccc;}
.feeditem a:link, .feeditem a:visited {position: relative;z-index: 24;text-decoration: none;color: #000;}
.feeditem a:hover {z-index: 25;background: #eee;color: #666;}
.feeditem a span { display: none }
.feeditem a:hover span {display: block;position: absolute;top: 2em;left: 2em;width: 300px;border: 1px solid #ccc;padding: 5px;background-color: #eee;color: #000;font-family: Arial;font-size: 10pt;}
				</code></pre></div>
			</p>
		</td>		
	</tr>
	<tr valign="top">
		<th scope="row">
			<label for="newspage_linklove">
			Help promote newsPage plugin?
			</label>
		</th>
		<td>
			<select name="newspage_linklove">
				<option value="1" <?php if($newspage_linklove == 1) echo " selected "; ?>>Yes</option>
				<option value="0" <?php if($newspage_linklove == 0) echo " selected "; ?>>No</option>
			</select>
			<p class="footnote">
				This option will add the code <code>newsPage brought to you by &lt;a href='http://www.rogerstringer.com/projects/newspage/'&gt;newsPage Plugin&lt;/a&gt;.</code>. Try turning it on, updating your options, and see the code in the code example to the right. These links and donations are greatly appreciated.</span>
			</p>
		</td>
	</tr>
	</table>
	<br />
	<input type="submit" value="Save Settings" class="button" />
	</form>
	<h2>Displaying your NewsPage on a page</h2>
	<p>
		To display your NewsPage on a page of your blog, create a page and
		add the following line to it anywhere:<br/>
		<div style="padding-left:20px;">
			&lt;!--newspage--&gt; or [newspage]
		</div>
	</p>
	<p>
		Or, alernatively, you can also add the following php code to a template on your blog:<br/>
		<div style="padding-left:20px;">
			&lt;?php if (function_exists('newsPage')) newsPage(); ?&gt;
		</div>
	</p>
	<p>
		If you want to limit how many feeds are displayed, like if you were displaying a couple on a frontpage, and the rest on another page, you could call it like this:
		<div style="padding-left:20px;">
			&lt;?php if (function_exists('newsPage')) newsPage(2); ?&gt;
		</div>
	</p>
	<p>
		To show a list of topics on a page, use the following code:
		<div style="padding-left:20px;">
			&lt;!--newstopics--&gt; or [newstopics]
		</div>
	</p>
	<p>
		To show a specific topic on your page, you can use the following:
		<div style="padding-left:20px;">
				[newspage limit=5 topic="<b>web design</b>"]
		</div>
	</p>
	<p>
		Or, alernatively, you can also add the following php code to a template on your blog:<br/>
		<div style="padding-left:20px;">
			&lt;?php if (function_exists('newsTopics')) newsTopics(); ?&gt;
		</div>
	</p>
	<p>
		You can also directly specify a topic using your php function, by entering the follow:
		<div style="padding-left:20px;">
			&lt;?php if (function_exists('newsPage')) newsPage(5,"<b>web design</b>"); ?&gt;
		</div>
	</p>
	<p>
		This will tell the plugin to display your activity feed at that location.
	</p>
<h2>Like this plugin?</h2>
<p><?php _e('Why not do any of the following:','newspage'); ?></p>
<ul class="newspagemenu">
	<li><?php _e('Link to it so other folks can find out about it.','newspage'); ?></li>
	<li><?php _e('<a href="http://wordpress.org/extend/plugins/newspage/">Give it a good rating</a> on WordPress.org.','newspage'); ?></li>
	<li><?php _e('<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=roger.stringer%40me%2ecom&item_name=newsPage&item_number=Support%20Open%20Source&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8">Donate a token of your appreciation</a>.','newspage'); ?></li>
</ul>
<h2>Need support?</h2>
<p><?php _e(' If you have any problems or good ideas, please talk about them in the <a href="http://wordpress.org/tags/newspage">Support forums</a>.', 'newspage'); ?></p>
</div>