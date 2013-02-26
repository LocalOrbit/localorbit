<!-- begin l_sidebar -->

	<div id="l_sidebar">

	<?php if ( function_exists('dynamic_sidebar') && dynamic_sidebar(1) ) : else : ?>
	

	<h2>Recently Written</h2>
		<ul>
		<?php get_archives('postbypost', 10); ?>
		</ul>



	<h2>Categories</h2>
		<ul>
		<?php wp_list_cats('sort_column=name'); ?>
		</ul>

		

	<h2>Archives</h2>
		<ul>
		<?php wp_get_archives('type=monthly'); ?>
		</ul>



	<h2>Blogroll</h2>
		<ul>
		<?php get_links(-1, '<li>', '</li>', ' - '); ?>
		</ul>



		<?php endif; ?>

	
</div>

<!-- end l_sidebar -->