<?php rewind_posts(); ?>
	<h3><b>FRESH</b> / LATEST POSTS</h3>
	<ul>		
 <?php query_posts('showposts=5'); ?>
  <?php while (have_posts()) : the_post(); ?>
  
  
		<li><span class="cat"><?php the_category('&nbsp;'); ?></span> <a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a>
		
		<?php if ( function_exists('the_excerpt_reloaded')) :?>
			
<?php the_excerpt_reloaded(15, '', 'excerpt', FALSE, '[more]', FALSE, 1, TRUE); ?>
			
<?php endif; ?>
		</li>		
		<?php endwhile; ?>
	</ul>
	
	
<?php if ( function_exists('akpc_most_popular')) :?>
	<h3><b>FEATURED</b> / BEST OF <span style="text-transform: uppercase;"><?php bloginfo('name'); ?></span></h3>
	<p><?php akpc_most_popular($limit = '10', $before = '', $after = '<br/>'); ?></p>
<?php endif; ?>


<?php if ( function_exists('bdp_comments')) :?>	
	<h3><b>FOLLOW</b> / YOUR COMMENTS</h3>
	<ul> 
<?php bdp_comments('5'); ?>
	</ul>
<?php endif; ?>

<?php if (function_exists('wp_tag_cloud') ) : ?>
	<h3 style="padding-bottom:10px;"><strong>TAG</strong> / <span class="normal">CLOUD</span></h3>
<?php wp_tag_cloud('smallest=8&largest=36&'); ?>
<?php endif; ?>
	

	
	<?php if ( !function_exists('dynamic_sidebar')
        || !dynamic_sidebar(1) ) : ?>
        
        <?php endif; ?>
        
</div><!-- end sidebar2 -->

<div id="sidebar">
	<a href="<?php bloginfo('rss2_url'); ?>"><img src="<?php bloginfo('template_url'); ?>/images/rss_black.png" alt="Feeds" /></a><br/><br/>
	<h1><a href="<?php echo get_option('home'); ?>/"><?php bloginfo('name'); ?></a></h1>
	<p><?php bloginfo('description'); ?></p>
		<ul>
			<?php 	/* Widgetized sidebar, if you have the plugin installed. */
					if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar(2) ) : ?>
			

				<?php wp_list_pages('title_li=<h3>Inside</h3>'); ?>
		
		<li><h3>Search</h3></li>
				<li><?php include (TEMPLATEPATH . '/searchform.php'); ?><br/><br/></li>

		
		
		<li><h3>Archives</h3>
				<ul>
				<?php wp_get_archives('type=monthly'); ?>
				</ul>
			</li>
			
			<?php /* If this is the frontpage */ if ( is_home() || is_page() ) { ?>
				<?php wp_list_bookmarks('categorize=0&title_before=<h3>&title_after=</h3>'); ?>
				<?php } ?>

			

		<li><h3>Meta</h3>
				<ul>
					<?php wp_register(); ?>
					<li><?php wp_loginout(); ?></li>
					<li><a href="http://validator.w3.org/check/referer" title="This page validates as XHTML 1.0 Transitional">Valid <abbr title="eXtensible HyperText Markup Language">XHTML</abbr></a></li>
					<li><a href="http://gmpg.org/xfn/"><abbr title="XHTML Friends Network">XFN</abbr></a></li>
					<li><a href="http://wordpress.org/" title="Powered by WordPress, state-of-the-art semantic personal publishing platform.">WordPress</a></li>
					<?php wp_meta(); ?>
				</ul>
				</li>
			
				<li>Copyright &copy; 2007 by <?php bloginfo('name'); ?>. All rights reserved.<br/></li>
				<!-- PLEASE don't remove the link to Upstart Blogger. Feel free to edit the theme as much as you like, but keep this link in your sidebar or footer. I do it for the egoboo, and keeping this link is good karma. Besides, it automatically links me to you. See http://www.upstartblogger.com/referrers -->
				<li>Modicus theme by <a href="http://www.upstartblogger.com/"><strong>Upstart Blogger</strong></a>.</li>
		
			
			<?php endif; ?>
		</ul>
</div><!-- end sidebar -->