<?php
if ( function_exists('register_sidebar') ) {
    register_sidebar(array(
		'name' => 'Wide Sidebar',
		'before_widget' => '<div class="block %1$s %2$s">',
		'after_widget' => '</div>',
		'before_title' => '<h3 class="boxedin">',
		'after_title' => '</h3>',
    ));
    register_sidebar(array(
		'name' => 'Left Sidebar',
		'before_widget' => '<div class="block %1$s %2$s">',
		'after_widget' => '</div>',
		'before_title' => '<h3 class="boxedin">',
		'after_title' => '</h3>',
    ));
    register_sidebar(array(
		'name' => 'Right Sidebar',
		'before_widget' => '<div class="block %1$s %2$s">',
		'after_widget' => '</div>',
		'before_title' => '<h3 class="boxedin">',
		'after_title' => '</h3>',
    ));
    register_sidebar(array(
		'name' => 'Left Footbar',
		'before_widget' => '<div class="block %1$s %2$s">',
		'after_widget' => '</div>',
		'before_title' => '<h3 class="boxedin">',
		'after_title' => '</h3>',
    ));
    register_sidebar(array(
		'name' => 'Mid Footbar',
		'before_widget' => '<div class="block %1$s %2$s">',
		'after_widget' => '</div>',
		'before_title' => '<h3 class="boxedin">',
		'after_title' => '</h3>',
    ));
    register_sidebar(array(
		'name' => 'Right Footbar',
		'before_widget' => '<div class="block %1$s %2$s">',
		'after_widget' => '</div>',
		'before_title' => '<h3 class="boxedin">',
		'after_title' => '</h3>',
    ));
}
?>