<div id="sidebar">


<!--sidebar.php-->

<?php if ( !function_exists('dynamic_sidebar')
        || !dynamic_sidebar() ) : ?>


		<!--searchfiled-->
		<?php include (TEMPLATEPATH . '/searchform.php'); ?>

	<br /><br />

	<h2>About <?php bloginfo('name'); ?></h2>
		<p>Put something about you here by editing the right sidebar.</p>

<br />  
<!--recent posts-->

	<h2>Recent Posts</h2>
	<ul>
	<?php get_archives('postbypost', 10); ?>
	</ul>

<!--list of categories, order by name, without children categories, no number of articles per category-->
		<h2>Topics</h2>			
		<ul><?php wp_list_cats('sort_column=name'); ?>
		</ul>

<!--archives ordered per month-->
		<h2>Archives</h2>
		<ul>
		<?php wp_get_archives('type=monthly'); ?>
		</ul>



<!--links or blogroll-->
		<h2>Blogroll</h2>
		<ul><?php get_links(-1, '<li>', '</li>', ' - '); ?></ul>

			
		<h2>Meta</h2>
			<ul>
				<?php wp_register(); ?>
				<li><?php wp_loginout(); ?></li>
			</ul>



<!--sidebar.php end-->

<?php endif; ?>

</div>