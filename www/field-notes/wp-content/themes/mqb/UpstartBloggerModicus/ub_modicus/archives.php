<?php
/*
Template Name: Archives
*/
?>


<?php get_header(); ?>
<div class="post">
<div class="entry">

<p>Looking for something?</p><p> It's probably in here somewhere. Have a look around. Explore the archives by time or by topic. Or give the search a spin.</p><br/>



<ul class="archive"><b>FIND</b> / SEARCH
<li><?php include (TEMPLATEPATH . '/searchform.php'); ?><br/></li>
	</ul><br/><br/>
	
<ul><b>TIME</b> / ARCHIVES BY MONTH
	
		<?php wp_get_archives('type=monthly'); ?>
	</ul><br/><br/>

<ul><b>TOPICS</b> / ARCHIVES BY CATEGORY
	<li>
		 <?php wp_list_categories('title_li='); ?></li>
	</ul>

</div><!-- end entry -->
</div><!-- end post -->
<div id="sidebar2">
<h1>Archives</h1>
	<p>
		<small>
			These are the archives. It's all good.
		</small>
	</p>

<?php get_sidebar(); ?>

<?php get_footer(); ?>