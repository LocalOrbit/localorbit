<?php
if ( function_exists('register_sidebar') )
    register_sidebar(array(
		'name'=>'MiddleColumn',
        'before_widget' => '<div id="%1$s" class="widget %2$s">',
        'after_widget' => '</div>',
        'before_title' => '<h3 class="mast">',
        'after_title' => '</h3>',
    ));

	register_sidebar(array(
		'name'=>'RightColumn',
    	'before_widget' => '<div id="%1$s" class="widget %2$s">',
    	'after_widget' => '</div>',
    	'before_title' => '<h3 class="mast">',
    	'after_title' => '</h3>',
));

function tma_previous_image_link( $text ) {
    $i = tma_adjacent_image_link( true );
	if ( $i )
		print $text . $i;
}

function tma_next_image_link( $text ) {
    $i = tma_adjacent_image_link( false );
	if ( $i )
		print $text . $i;
}

function tma_adjacent_image_link($prev = true) {
    global $post;
    $post = get_post($post);
    $attachments = array_values(get_children(
Array('post_parent' => $post->post_parent,
      'post_type' => 'attachment',
      'post_mime_type' => 'image',
      'orderby' => 'menu_order ASC, ID ASC')));

    foreach ( $attachments as $k => $attachment )
        if ( $attachment->ID == $post->ID )
            break;

    $k = $prev ? $k - 1 : $k + 1;

    if ( isset($attachments[$k]) )
        return wp_get_attachment_link($attachments[$k]->ID, 'thumbnail', true);
	else
		return false;
}

add_filter('comments_template', 'legacy_comments');
	function legacy_comments($file) {
	if(!function_exists('wp_list_comments')) : // WP 2.7-only check
	$file = TEMPLATEPATH . '/legacy.comments.php';
	endif;
	return $file;
}

function tma_comment($comment, $args, $depth) {
   $GLOBALS['comment'] = $comment; ?>

	<li id="comment-<?php comment_ID() ?>">
		
		<div class="commentcont">

		<div class="fright"><?php echo get_avatar( $comment, $size = '40' ); ?></div>
							
			<?php comment_text() ?>
				
				<p>
					<?php if ($comment->comment_approved == '0') : ?>
				
					<em>Your comment is awaiting moderation.</em>
					
					<?php endif; ?>
				</p>
		
		</div>
		
		<cite>
		
		Posted by <span class="commentauthor"><?php comment_author_link() ?></span> | <a href="#comment-<?php comment_ID() ?>" title=""><?php comment_date('F j, Y') ?>, <?php comment_time() ?></a> <?php edit_comment_link('edit','| ',''); ?>						
		
		</cite>
		
		<div class="reply">
         <?php comment_reply_link(array_merge( $args, array('reply_text' => 'Reply to this comment', 'depth' => $depth, 'max_depth' => $args['max_depth']))) ?>
      </div>

		
            
<?php }


?>
