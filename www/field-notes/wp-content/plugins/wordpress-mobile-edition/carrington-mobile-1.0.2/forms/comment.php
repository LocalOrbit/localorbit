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

global $post, $user_ID, $user_identity, $comment_author, $comment_author_email, $comment_author_url;

$req = get_option('require_name_email');

// if post is open to new comments
if ('open' == $post->comment_status) {
	// if you need to be regestered to post comments..
	if ( get_option('comment_registration') && !$user_ID ) { ?>

<p id="you-must-be-logged-in-to-comment"><?php printf(__('You must be <a href="%s">logged in</a> to post a comment.', 'carrington-mobile'), get_bloginfo('wpurl').'/wp-login.php?redirect_to='.get_permalink()); ?></p>

<?php
	}
	else { 
?>

<form id="respond" action="<?php bloginfo('wpurl'); ?>/wp-comments-post.php" method="post">
	<h3 class="title-divider"><span><?php _e('Leave a Reply', 'carrington-mobile'); ?></span></h3>
	<?php // if you're logged in...
			if ($user_ID) {
	?>
		<p><?php printf(__('Logged in as <a href="%s">%s</a>. ', 'carrington-mobile'), get_bloginfo('wpurl').'/wp-admin/profile.php', $user_identity); wp_loginout() ?></p>
	<?php
			} else { 
	?>
		<p>
			<input type="text" name="author" id="author" value="<?php echo $comment_author; ?>" size="22" />
			<label for="author"><small><?php _e('Name', 'carrington-mobile'); if ($req) { _e(' (required)', 'carrington-mobile'); } ?></small></label>
		</p>
		<p>
			<input type="text" name="email" id="email" value="<?php echo $comment_author_email; ?>" size="22" />
			<label for="email"><small><?php _e('Email', 'carrington-mobile');
			if ($req) {
				_e(' (required, but never shared)', 'carrington-mobile');
			}
			else {
				_e(' (never shared)', 'carrington-mobile');
			} ?></small></label>
		</p>
		<p>
			<input type="text" name="url" id="url" value="<?php echo $comment_author_url; ?>" size="22" />
			<label title="<?php _e('Your website address', 'carrington-mobile'); ?>" for="url"><small><?php _e('Web', 'carrington-mobile'); ?></small></label>	
		</p>
	<?php 
			} 
	?>
	<p><textarea name="comment" id="comment" rows="8" cols="40"></textarea></p>
	<p>
		<input name="submit" type="submit" id="submit" value="<?php _e('Submit comment', 'carrington-mobile'); ?>" tabindex="5" />
		<input type="hidden" name="comment_post_ID" value="<?php echo $post->ID; ?>" />
	</p>
<?php
do_action('comment_form', $post->ID);
?>
</form>
<?php 
	} // If registration required and not logged in 
} // If you delete this the sky will fall on your head
?>