<div id="sidebar_one">
<?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('sidebar_one') ) : ?>	
	<div id="search">
		<form method="get" id="searchform" action="<?php bloginfo('url'); ?>">
		<input type="text" value="<?php echo wp_specialchars($s, 1); ?>" name="s" id="s" />
		<input id="searchsubmit" src="<?php bloginfo('template_url'); ?>/images/btn_search.gif"  alt="Submit" type="image" />
		</form>
	</div>
	<div class="sidebar_links side_content">
		<h3>Browse Posts By Category</h3>
		<p>Choose a category below to browse and subscribe to specific content.</p>

 <ul><?php wp_list_cats('feed_image='.get_bloginfo('template_directory').'/images/category-rss.jpg&feed=XML Feed&optioncount=0&children=1&hierarchical=0'); ?></ul>
 </div>
 	<div class="rss_links">
		<h3>Subscribe</h3>
		<p>Stay updated with <?php bloginfo('name');?> via RSS (Syndicate).</p>

		<ul>
			<li><a href="<?php bloginfo('rss_url'); ?>" title="Full content RSS feed">Content RSS</a> - Straight to your reader</li>
			<li><a href="<?php bloginfo('comments_rss2_url'); ?>" title="Full comments RSS feed">Comments RSS</a> - Add to the discussion</li>
		</ul>
	</div>
	
    <div class="user_links side_content">
		<h3>Comment &amp; Socialize</h3>    
        <p>Here are some recent comments from our users.</p>

 <?php if (function_exists('recent_comments')) { recent_comments(); } ?>	
</div>
<?php endif; ?>
</div>

<div id="sidebar_two">
<?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('sidebar_two') ) : ?>	
    <div id="side_content" class="user_links">
		<h3>Welcome to <?php bloginfo('name');?></h3>    
Some welcome text here. Some welcome text here. Some welcome text here. Some welcome text here. 
Some welcome text here. Some welcome text here. Some welcome text here. Some welcome text here. 
Some welcome text here. Some welcome text here. Some welcome text here. Some welcome text here. 
</div>
	<div class="side_content">
<div class="ez100"><a href="#"><img src="<?php bloginfo('template_url'); ?>/images/pixel.jpg" /></a></div>
<div class="ez100"><a href="#"><img src="<?php bloginfo('template_url'); ?>/images/pixel.jpg" /></a></div>
<div class="ez100"><a href="#"><img src="<?php bloginfo('template_url'); ?>/images/pixel.jpg" /></a></div>
<div style="clear: left;"></div>
	</div>
	<div class="sidebar_links side_content">
	<h3>Archives</h3>
	<ul>
		<?php wp_get_archives('type=monthly'); ?>
	</ul>
</div>
	<div class="sidebar_links side_content">
	<h3>Blogroll</h3>
	<ul>
<?php get_linksbyname('Blogroll', '<li>', '</li>', '', 0, 'name', 0, 0); ?>
	</ul>
</div>
<?php endif; ?>
</div>