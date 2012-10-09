<?php

/*
Plugin Name: Gravatar
Plugin URI: http://www.gravatar.com/implement.php#section_2_2
Description: This plugin allows you to generate a gravatar URL complete with rating, size, default, and border options. See the <a href="http://www.gravatar.com/implement.php#section_2_2">documentation</a> for syntax and usage.
Version: 1.1
Author: Tom Werner
Author URI: http://www.mojombo.com/

CHANGES
2004-11-14 Fixed URL ampersand XHTML encoding issue by updating to use proper entity
*/

function gravatar($rating = false, $size = false, $default = false, $border = false) {
	global $comment;
	$out = "http://www.gravatar.com/avatar.php?gravatar_id=".md5($comment->comment_author_email);
	if($rating && $rating != '')
		$out .= "&amp;rating=".$rating;
	if($size && $size != '')
		$out .="&amp;size=".$size;
	if($default && $default != '')
		$out .= "&amp;default=".urlencode($default);
	if($border && $border != '')
		$out .= "&amp;border=".$border;
	echo $out;
}

?>