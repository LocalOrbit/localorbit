<?php
/*-----------------------------------------------------------------------------------*/
/* Initializing Widgetized Areas (Sidebars)											                     */
/*-----------------------------------------------------------------------------------*/

register_sidebar( array(
	'name' => 'Sidebar',
	'before_widget' => '<div id="%1$s" class="widget %2$s">',
	'after_widget' => '</div>',
	'before_title' => '<h3 class="title">',
	'after_title' => '</h3>'
) );

register_sidebar( array(
	'name' => 'Sidebar (half left)',
	'before_widget' => '<div id="%1$s" class="widget %2$s">',
	'after_widget' => '</div>',
    'before_title' => '<h3 class="title">',
	'after_title' => '</h3>'
) );

register_sidebar( array(
	'name' => 'Sidebar (half right)',
	'before_widget' => '<div id="%1$s" class="widget %2$s">',
	'after_widget' => '</div>',
    'before_title' => '<h3 class="title">',
	'after_title' => '</h3>'
) );



/*----------------------------------*/
/* Footer widgetized areas			*/
/*----------------------------------*/
 
register_sidebar(array(
    'name'=>'Footer (column 1)',
    'id' => 'footer_1',
    'before_widget' => '<div class="widget %2$s" id="%1$s">',
    'after_widget' => '<div class="clear"></div></div>',
    'before_title' => '<h3 class="title">',
    'after_title' => '</h3>',
));

register_sidebar(array(
    'name'=>'Footer (column 2)',
    'id' => 'footer_2',
    'before_widget' => '<div class="widget %2$s" id="%1$s">',
    'after_widget' => '<div class="clear"></div></div>',
    'before_title' => '<h3 class="title">',
    'after_title' => '</h3>',
));

register_sidebar(array(
    'name'=>'Footer (column 3)',
    'id' => 'footer_3',
    'before_widget' => '<div class="widget %2$s" id="%1$s">',
    'after_widget' => '<div class="clear"></div></div>',
    'before_title' => '<h3 class="title">',
    'after_title' => '</h3>',
));
 

 
?>