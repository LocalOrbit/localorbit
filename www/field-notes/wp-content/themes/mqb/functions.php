<?php
if ( function_exists('register_sidebar') ) {
    register_sidebar( array('name' => 'sidebar_one', 'before_widget' => '<div class="side_content sidebar_links">', 'after_widget' => '</div>', 'before_title' => '<h3>', 'after_title' => '</h3>') );
    register_sidebar( array('name' => 'sidebar_two', 'before_widget' => '<div class="side_content sidebar_links">', 'after_widget' => '</div>', 'before_title' => '<h3>', 'after_title' => '</h3>') );
}
function recent_comments($src_count=7, $src_length=40, $before='', $after='') {
	global $wpdb;
	$sql = "SELECT DISTINCT ID, post_title, post_password, comment_ID, comment_post_ID, comment_author, comment_date_gmt, comment_approved, comment_type, SUBSTRING(comment_content,1,$src_length) AS com_excerpt FROM $wpdb->comments LEFT OUTER JOIN $wpdb->posts ON ($wpdb->comments.comment_post_ID = $wpdb->posts.ID) WHERE comment_approved = '1' AND comment_type = '' AND post_password = '' ORDER BY comment_date_gmt DESC LIMIT $src_count";
	$comments = $wpdb->get_results($sql);
	$output = $before;
	$output .= "\n<ul>";
	foreach ($comments as $comment) {
		$output .= "\n\t<li><strong><a href=\"".get_permalink($comment->ID)."#comment-".$comment->comment_ID."\"title=\"on ".$comment->post_title."\">".$comment->comment_author."</a></strong>:".strip_tags($comment->com_excerpt)."...</li>";
	}
	$output .= "\n</ul>";
	$output .= $after;
	echo $output;
}
?>