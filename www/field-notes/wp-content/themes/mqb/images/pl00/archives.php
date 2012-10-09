<?php
/*
Template Name: Archives
*/
?>

<?php get_header(); ?>

		<div id="PageBody">
	
		<div id="Content">

<?php include (TEMPLATEPATH . '/searchform.php'); ?>

<h2>Archives by Month:</h2>
	<ul>
		<?php wp_get_archives('type=monthly'); ?>
	</ul>

<h2>Archives by Subject:</h2>
	<ul>
		 <?php wp_list_categories(); ?>
	</ul>

</div>

		</div><!-- end "PageBody" div -->
	
	</div><!-- end "PageContainer" div -->

<?php get_footer(); ?>
