<?php
if ( function_exists('register_sidebar') )
    register_sidebars((2),array(
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
    'after_widget' => '</div>',
            'before_title' => '<h3>',
        'after_title' => '</h3>',
    ));
?>