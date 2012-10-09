<div id="sidebarl">
<!--sidebar.php-->
<?php if ( !function_exists('dynamic_sidebar')
        || !dynamic_sidebar(1) ) : ?>
<h2>About Me</h2>
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
<!--searchfiled-->
<?php include (TEMPLATEPATH . '/searchform.php'); ?>
<br /><br />
<!--sidebar.php end-->
<?php endif; ?>
</div>
