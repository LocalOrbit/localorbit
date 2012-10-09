<?php 
/*
Plugin Name: Random Posts
Plugin URI: http://www.w-a-s-a-b-i.com/archives/2004/05/27/wordpress-random-posts-plugin/
Description: Displays a configurable list of random posts. Usage: random_posts();
Version: 1.1
Author: Alexander Malov
Author URI: http://www.w-a-s-a-b-i.com/
*/

function random_posts ($limit, $len, $before_title = '<li>', $after_title = '</li>', $before_post = '', $after_post = '', $show_pass_post = false, $show_excerpt = false) {
    global $wpdb, $tableposts;
    $sql = "SELECT ID, post_title, post_content FROM $tableposts WHERE post_status = 'publish' ";
	if(!$show_pass_post) $sql .= "AND post_password ='' ";
	$sql .= "ORDER BY RAND() LIMIT $limit";
    $posts = $wpdb->get_results($sql);
	$output = '';
    foreach ($posts as $post) {
        $post_title = stripslashes($post->post_title);
		$post_title = str_replace('"', '', $post_title);
        $permalink = get_permalink($post->ID);
		$post_content = strip_tags($post->post_content);
		$post_content = stripslashes($post_content);
        $output .= $before_title . '<a href="' . $permalink . '" rel="bookmark" title="Permanent Link: ' . $post_title . '">' . $post_title . '</a>' . $after_title;
		if($show_excerpt) {
			$words=split(" ",$post_content); 
			$post_strip = join(" ",array_slice($words,0,$len));
			$output .= $before_post . $post_strip . $after_post;
	    }
		
	}
	echo $output;
}
?>