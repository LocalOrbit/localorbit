<?php get_header(); ?>
<div class="entry">
	<p>Things change. What you're looking for has probably never existed, or has been moved, deleted or *gasp* lost.
	</p><br/>
	<p> While you're here, though, why not have a look around?</p>
	<ul class="archive">
		<li>Try a search...</li>
		<li>
			<ul><?php include (TEMPLATEPATH . '/searchform.php'); ?></ul><br/>
		</li>
	</ul>
	
	
<?php if ( function_exists('random_posts')) :?>
	<ul class="archive">
		<li>Or maybe have a look at one of these random posts...</li><?php random_posts('10','25','<li>','<br />','',' [...]</li>','false','true'); ?>
	</ul>
<?php endif; ?>
	
	
</div>
<div id="sidebar2">
	<h1>404. Fiddle-de-dee, file not found.</h1>
	<p>
		<small>
			Fiddlesticks. Try somthing fresh, or have a look at one of my favorites. See below. Lower...
		</small>
	</p>

<?php get_sidebar(); ?>

<?php get_footer(); ?>