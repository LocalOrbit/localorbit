<?php

// This file is part of the Carrington Mobile Theme for WordPress
// http://carringtontheme.com
//
// Copyright (c) 2008-2009 Crowd Favorite, Ltd. All rights reserved.
// http://crowdfavorite.com
//
// Released under the GPL license
// http://www.opensource.org/licenses/gpl-license.php
//
// **********************************************************************
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
// **********************************************************************

if (__FILE__ == $_SERVER['SCRIPT_FILENAME']) { die(); }
if (CFCT_DEBUG) { cfct_banner(__FILE__); }

global $post, $wp_query, $comments, $comment;

if ($comments || 'open' == $post->comment_status) {
	if (empty($post->post_password) || $_COOKIE['wp-postpass_' . COOKIEHASH] == $post->post_password) {
		$comments = $wp_query->comments;
		$comment_count = count($comments);
		$comment_count == 1 ? $comment_title = __('One Response', 'carrington-mobile') : $comment_title = sprintf(__('%d Responses', 'carrington-mobile'), $comment_count);
	}

?>

<h2 id="comments" class="title-divider"><span><?php echo $comment_title; ?></span></h2>

<?php 

	if ($comments) {
?>
	<ol class="commentlist">
<?php
		foreach ($comments as $comment) {
?>
		<li id="comment-<?php comment_ID() ?>">
<?php
			cfct_comment();
?>
		</li>
<?php
		}
?>
	</ol>
<?php
	}
	cfct_form('comment'); 
}
?>