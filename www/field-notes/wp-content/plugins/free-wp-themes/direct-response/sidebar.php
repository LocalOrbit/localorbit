<div id="sidebar">
<ul>

<!--sidebar.php-->

<?php if ( !function_exists('dynamic_sidebar')
        || !dynamic_sidebar() ) : ?>

<li>

<div id="emailbox">


<div class="emailboxtext">About This Blog</div>
		<p>Put something about you here by editing the right sidebar.</p>
</div>

<br />

<div align="left"><a href="<?php echo get_settings('home'); ?>/feed/"><img src="<?php bloginfo('template_url'); ?>/images/feed.jpg" alt="Feed" border="0" /></a></div>






<!--recent posts-->

	<h2>Recent Posts</h2>
	<ul>
	<?php get_archives('postbypost', 10); ?>
	</ul>

<!--list of categories, order by name, without children categories, no number of articles per category-->
		<h2>Topics</h2>			
		<ul><?php wp_list_cats('sort_column=name'); ?>
		</ul>


<!--links or blogroll-->
		<h2>Links</h2>
		<ul><?php get_links(-1, '<li>', '</li>', ' - '); ?></ul>


		<!--searchfiled-->
		<?php include (TEMPLATEPATH . '/searchform.php'); ?>

	<br /><br />



<!--sidebar.php end-->

<?php endif; ?>
</li>
</ul>
</div>