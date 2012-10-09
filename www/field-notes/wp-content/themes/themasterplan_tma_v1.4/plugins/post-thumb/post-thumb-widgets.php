<?php
/*
Plugin Name: Post thumb widget
Description: Adds sidebar widgets to display post-thumb revisited features
Version: 2.2
Author: Alakhnor
Author URI: http://www.alakhnor.com/post-thumb
*/

/**********************************************************************************
Widget functions:
	- pt-wordtube
	- pt-random
	- pt-recent
	- pt-recent-video
	- pt-recent-youtube
	- pt-categories
	- pt-slideshow
	- pt-news
	- pt-last-youtube
**********************************************************************************/

function post_thumb_widget()
{
	if ( !function_exists('register_sidebars')) return;
/*********************************************************************************/
/* wordTube widget
/*********************************************************************************/
if (function_exists('pt_replacevideo')) {
	function web_wordtube($args)
	{
		extract($args);

		// Each widget can store its own options. We keep strings here.
		$options = get_option('web_wordtube');
		$title = $options['title'];
		$mediaid = $options['mediaid'];
		$content = '[MEDIA='.$mediaid.']';

		// These lines generate our output.
		echo $before_widget . $before_title . $title . $after_title;
		$url_parts = parse_url(get_bloginfo('home'));
		echo pt_replacevideo($mediaid, $content);
		echo $after_widget;

	}
	/*********************************************************************************/
	/* wordTube widget control
	/*********************************************************************************/
	function web_wordtube_control()
	{
		global $wpdb;
		$options = get_option('web_wordtube');
		if ( !is_array($options) )
			$options = array('title'=>'', 'mediaid'=>'0');

		if ( $_POST['wordtube-submit'] )
	        {
	        	$options['title'] = strip_tags(stripslashes($_POST['wordtube-title']));
			$options['mediaid'] = $_POST['wordtube-mediaid'];
			update_option('web_wordtube', $options);
		}

		$title = htmlspecialchars($options['title'], ENT_QUOTES);

		// The Box content
		echo '<p style="text-align:right;"><label for="wordtube-title">' . __('Title:') . ' <input style="width: 200px;" id="wordtube-title" name="wordtube-title" type="text" value="'.$title.'" /></label></p>';
		echo '<p style="text-align:right;"><label for="wordtube-mediaid">' . __('Select Media:', 'wpTube'). ' </label>';
		echo '<select size="1" name="wordtube-mediaid" id="wordtube-mediaid">';

		$tables = $wpdb->get_results("SELECT * FROM $wpdb->wordtube ORDER BY 'vid' ASC ");
		if($tables)
	        {
			foreach($tables as $table) {
				echo '<option value="'.$table->vid.'" ';
				if ($table->vid == $options['mediaid']) echo "selected='selected' ";
				echo '>'.$table->name.'</option>'."\n\t";
				}
			}
		echo '</select></p>';
		echo '<input type="hidden" id="wordtube-submit" name="wordtube-submit" value="1" />';
	}

	register_sidebar_widget ( 'pt-wordTube', 'web_wordTube', 'wid-wordtube');
	register_widget_control ( 'pt-wordTube', 'web_wordtube_control', 300, 100);

}
/*********************************************************************************/
/* Simple forum widget
/*********************************************************************************/
if (function_exists('sf_recent_posts_tag')) {
	function web_forum($args)
	{
		extract($args);
		$options = get_option('web_forum');
		$title = empty($options['title']) ? __('Forum', 'post-thumb') : $options['title'];

		?>
		<?php echo $before_widget; ?>
			<?php echo $before_title . $title . $after_title; ?>
			<ul>
				<?php sf_recent_posts_tag (); ?>
			</ul>
		<?php echo $after_widget;

	}
}
/*********************************************************************************/
/* Random post widget
/*********************************************************************************/
function web_random($args) {

	extract($args);
	$options = get_option('web_random');
	$arg = GetWidgetArg($options);

	$bn = $options['basename'] ? '1' : '0';
	if ($options['html'] =='') $html='li'; else $html = $options['html'];
	if ($options['class'] =='') $class=''; else $class = ' class="'.$options['class'].'"';
	$title = empty($options['title']) ? __('Random', 'post-thumb') : $options['title'];

	?>
	<?php echo $before_widget; ?>
		<?php echo $before_title . $title . $after_title; ?>
		<ul>
			<?php the_random_thumb ('subfolder=random&altappend=random-&basename='.$bn.'&'.$arg, '<li>', '</li>', '', ''); ?>
		</ul>
	<?php echo $after_widget; ?>
	<?php echo '<'.$html.$class.'></'.$html.'>'; ?>
        <?php
}
/*********************************************************************************/
/* Random post widget control
/*********************************************************************************/
function web_random_control() {

	$options = $newoptions = get_option('web_random');
	if ( $_POST['web-random-submit'] ) {
		$newoptions['keepratio'] 	= isset($_POST['web-random-keepratio']);
		$newoptions['width'] 		= strip_tags(stripslashes($_POST['web-random-width']));
		$newoptions['height'] 		= strip_tags(stripslashes($_POST['web-random-height']));
		$newoptions['limit'] 		= strip_tags(stripslashes($_POST['web-random-limit']));
		$newoptions['showtitle'] 	= strip_tags(stripslashes($_POST['web-random-showtitle']));
		$newoptions['category'] 	= strip_tags(stripslashes($_POST['web-random-category']));
		$newoptions['showpost'] 	= isset($_POST['web-random-showpost']);
		$newoptions['showlink'] 	= isset($_POST['web-random-showlink']);
		$newoptions['LBeffect'] 	= isset($_POST['web-random-LBeffect']);
		$newoptions['class'] 		= strip_tags(stripslashes($_POST['web-random-class']));
		$newoptions['html'] 		= strip_tags(stripslashes($_POST['web-random-html']));
		$newoptions['title'] 		= strip_tags(stripslashes($_POST['web-random-title']));
		$newoptions['basename']		= isset($_POST['web-random-basename']);
	}
	if ( $options != $newoptions ) {
		$options = $newoptions;
		update_option('web_random', $options);
	}
	$title = wp_specialchars($options['title']);
	if (wp_specialchars($options['html']) =='') $html='li'; else $html = $options['html'];
	$class = wp_specialchars($options['class']);
	$category = wp_specialchars($options['category']);
	$keepratio = $options['keepratio'] ? 'checked="checked"' : '';
	$basename = $options['basename'] ? 'checked="checked"' : '';
	if (wp_specialchars($options['width']=='')) $width = '240'; else $width = wp_specialchars($options['width']);
	if (wp_specialchars($options['height']=='')) $height = '200'; else $height = wp_specialchars($options['height']);
	if (wp_specialchars($options['limit']=='')) $limit = '5'; else $limit = wp_specialchars($options['limit']);
	$showtitle = wp_specialchars($options['showtitle']);
	$LBeffect = $options['LBeffect'] ? 'checked="checked"' : '';
	$showpost = $options['showpost'] ? 'checked="checked"' : '';
	$showlink = $options['showlink'] ? 'checked="checked"' : '';
?>
	<p><label for="web-random-title"><?php _e('Title:'); ?> <input style="width: 240px;" id="web-random-title" name="web-random-title" type="text" value="<?php echo $title; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-keepratio"><?php _e('Keep ratio', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $keepratio; ?> id="web-random-keepratio" name="web-random-keepratio" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-width" style="text-align:right;"><?php _e('Width', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-random-width" name="web-random-width" value="<?php echo $width; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-height" style="text-align:right;"><?php _e('Height', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-random-height" name="web-random-height" value="<?php echo $height; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-limit" style="text-align:right;"><?php _e('Show count', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-random-limit" name="web-random-limit" value="<?php echo $limit; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-showtitle" style="text-align:right;"><?php _e('Show title', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-random-showtitle" name="web-random-showtitle" value="<?php echo $showtitle; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-showpost" style="text-align:right;"><?php _e('Link to post', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $showpost; ?> id="web-random-showpost" name="web-random-showpost" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-showlink" style="text-align:right;"><?php _e('Link to url', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $showlink; ?> id="web-random-showlink" name="web-random-showlink" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-category" style="text-align:right;"><?php _e('Category filter', 'post-thumb'); ?> <input style="width: 40px;" type="text" value="<?php echo $category; ?>" id="web-random-category" name="web-random-category" /></label></p>
	<p style="text-align:right;margin-right:20px;margin-bottom:20px;"><label for="web-random-LBeffect"><?php _e('HS effect', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $LBeffect; ?> id="web-random-LBeffect" name="web-random-LBeffect" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-html"><?php _e('Closing html:'); ?> <input style="width: 100px;" id="web-random-html" name="web-random-html" type="text" value="<?php echo $html; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-class"><?php _e('Closing class:'); ?> <input style="width: 100px;" id="web-random-class" name="web-random-class" type="text" value="<?php echo $class; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="web-random-basename"><?php _e('Force name to unique', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $basename; ?> id="web-random-basename" name="web-random-basename" /></label></p>
	<input type="hidden" id="web-random-submit" name="web-random-submit" value="1" />
<?php
}

register_sidebar_widget ( 'pt-random', 'web_random', 'wid_random' );
register_widget_control ( 'pt-random', 'web_random_control', 300, 440);

/*********************************************************************************/
/* Slideshow widget
/*********************************************************************************/
if (function_exists('pt_slideshow')) {
	function web_slideshow($args) {
	
		extract($args);
		$options = get_option('web_slideshow');
		$arg = GetWidgetArg($options);
		
		$bn = $options['basename'] ? '1' : '0';
		$r = $options['random'];
		$title = empty($options['title']) ? __('Slideshow', 'post-thumb') : $options['title'];
		?>
		<?php echo $before_widget; ?>
			<?php echo $before_title . $title . $after_title; ?>
				<?php pt_slideshow('altappend=slide-&subfolder=slideshow&media=0&basename='.$bn.'&'.$arg, $r); ?>
		<?php echo $after_widget; ?>
	        <?php
	}
	/*********************************************************************************/
	/* Slideshow widget control
	/*********************************************************************************/
	function web_slideshow_control() {
	
		$options = $newoptions = get_option('web_slideshow');
		if ( $_POST['web-slideshow-submit'] ) {
		
			$newoptions['width'] 	= strip_tags(stripslashes($_POST['web-slideshow-width']));
			$newoptions['height'] 	= strip_tags(stripslashes($_POST['web-slideshow-height']));
			$newoptions['random']	= isset($_POST['web-slideshow-random']);
			$newoptions['keepratio']= isset($_POST['web-slideshow-keepratio']);
			$newoptions['category'] = strip_tags(stripslashes($_POST['web-slideshow-category']));
			$newoptions['title'] 	= strip_tags(stripslashes($_POST['web-slideshow-title']));
			$newoptions['showpost'] = isset($_POST['web-slideshow-showpost']);
			$newoptions['showlink'] = isset($_POST['web-slideshow-showlink']);
			$newoptions['LBeffect'] = isset($_POST['web-slideshow-LBeffect']);
			$newoptions['limit']	= strip_tags(stripslashes($_POST['web-slideshow-limit']));
			$newoptions['basename']= isset($_POST['web-slideshow-basename']);
		}
		if ( $options != $newoptions ) {
			$options = $newoptions;
			update_option('web_slideshow', $options);
		}
		$title = wp_specialchars($options['title']);
		$category = wp_specialchars($options['category']);
		$random = $options['random'] ? 'checked="checked"' : '';
		$keepratio = $options['keepratio'] ? 'checked="checked"' : '';
		$basename = $options['basename'] ? 'checked="checked"' : '';
		if (wp_specialchars($options['limit']=='')) $limit = '10'; else $limit = wp_specialchars($options['limit']);
		if (wp_specialchars($options['width']=='')) $width = '240'; else $width = wp_specialchars($options['width']);
		if (wp_specialchars($options['height']=='')) $height = '200'; else $height = wp_specialchars($options['height']);
		$showpost = $options['showpost'] ? 'checked="checked"' : '';
		$showlink = $options['showlink'] ? 'checked="checked"' : '';
		$LBeffect = $options['LBeffect'] ? 'checked="checked"' : '';
		
		?>
		<p><label for="web-slideshow-title"><?php _e('Title:'); ?> <input style="width: 240px;" id="web-slideshow-title" name="web-slideshow-title" type="text" value="<?php echo $title; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-slideshow-keepratio"><?php _e('Keep ratio', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $keepratio; ?> id="web-slideshow-keepratio" name="web-slideshow-keepratio" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-slideshow-category" style="text-align:right;"><?php _e('Category filter', 'post-thumb'); ?> <input style="width: 40px;" type="text" value="<?php echo $category; ?>" id="web-slideshow-category" name="web-slideshow-category" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-slideshow-width" style="text-align:right;"><?php _e('Width', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-slideshow-width" name="web-slideshow-width" value="<?php echo $width; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-slideshow-height" style="text-align:right;"><?php _e('Height', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-slideshow-height" name="web-slideshow-height" value="<?php echo $height; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-slideshow-limit" style="text-align:right;"><?php _e('Number of posts', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-slideshow-limit" name="web-slideshow-limit" value="<?php echo $limit; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;margin-bottom:20px;"><label for="web-slideshow-showpost"><?php _e('Link to post', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $showpost; ?> id="web-slideshow-showpost" name="web-slideshow-showpost" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-slideshow-showlink" style="text-align:right;"><?php _e('Link to url', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $showlink; ?> id="web-slideshow-showlink" name="web-slideshow-showlink" /></label></p>
		<p style="text-align:right;margin-right:20px;margin-bottom:20px;"><label for="web-slideshow-LBeffect"><?php _e('HS effect', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $LBeffect; ?> id="web-slideshow-LBeffect" name="web-slideshow-LBeffect" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-slideshow-random"><?php _e('Randomize images?', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $random; ?> id="web-slideshow-random" name="web-slideshow-random" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-slideshow-basename"><?php _e('Force name to unique', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $basename; ?> id="web-slideshow-basename" name="web-slideshow-basename" /></label></p>
		<input type="hidden" id="web-slideshow-submit" name="web-slideshow-submit" value="1" />
		<?php
		
	}

	register_widget_control ( 'pt-slideshow', 'web_slideshow_control', 300, 400);
	register_sidebar_widget ( 'pt-slideshow', 'web_slideshow', 'wid-slideshow' );

}
/*********************************************************************************/
/* Get recent posts widget
/*********************************************************************************/
function web_recent($args) {

	extract($args);
	$options = get_option('web_recent');
	$arg = GetWidgetArg($options);

	if ($options['html'] =='') $html='li'; else $html = $options['html'];
	if ($options['class'] =='') $class=''; else $class = ' class="'.$options['class'].'"';
	$title 	= empty($options['title']) ? __('Recent Posts', 'post-thumb') : $options['title'];

	?>
	<?php echo $before_widget; ?>
		<?php echo $before_title . $title . $after_title; ?>
		<ul>
			<?php the_recent_thumbs('subfolder=recent&altappend=recent-&'.$arg, '<li>', '</li>', '', '');	?>
		</ul>
	<?php echo $after_widget; ?>
	<?php echo '<'.$html.$class.'></'.$html.'>'; ?>
        <?php
}
/*********************************************************************************/
/* Get recent posts widget control
/*********************************************************************************/
function web_recent_control() {

	get_recent_control('web-recent', 'web_recent');
}

register_sidebar_widget ( 'pt-recent', 'web_recent', 'wid_recent' );
register_widget_control ( 'pt-recent', 'web_recent_control', 300, 470);


/*********************************************************************************/
/* Get recent posts widget
/*********************************************************************************/
function web_recent_image($args) {

	extract($args);
	$options = get_option('web_recent_image');
	$arg = GetWidgetArg($options);

	if ($options['html'] =='') $html='li'; else $html = $options['html'];
	if ($options['class'] =='') $class=''; else $class = ' class="'.$options['class'].'"';
	$title 	= empty($options['title']) ? __('Recent Images', 'post-thumb') : $options['title'];
	?>
	<?php echo $before_widget; ?>
		<?php echo $before_title . $title . $after_title; ?>
		<ul>
			<?php the_recent_thumbs('subfolder=recent&altappend=image-&media=0&'.$arg, '<li>', '</li>', '', '');	?>
		</ul>
	<?php echo $after_widget; ?>
	<?php echo '<'.$html.$class.'></'.$html.'>'; ?>
        <?php
}
/*********************************************************************************/
/* Get recent posts widget control
/*********************************************************************************/
function web_recent_image_control() {

	get_recent_control('web-recent-image', 'web_recent_image');

}
	register_sidebar_widget ( 'pt-recent-image', 'web_recent_image', 'wid_recent_image' );
	register_widget_control ( 'pt-recent-image', 'web_recent_image_control', 300, 470);
	
/*********************************************************************************/
/* Get recent posts widget
/*********************************************************************************/
function web_recent_video($args) {

	extract($args);
	$options = get_option('web_recent_video');
	$arg = GetWidgetArg($options);

	if ($options['html'] =='') $html='li'; else $html = $options['html'];
	if ($options['class'] =='') $class=''; else $class = ' class="'.$options['class'].'"';
	$title 	= empty($options['title']) ? __('Recent videos', 'post-thumb') : $options['title'];
	?>
	<?php echo $before_widget; ?>
		<?php echo $before_title . $title . $after_title; ?>
		<ul>
			<?php the_recent_thumbs('subfolder=recent&altappend=video-&media=1&'.$arg, '<li>', '</li>', '', '');	?>
		</ul>
	<?php echo $after_widget; ?>
	<?php echo '<'.$html.$class.'></'.$html.'>'; ?>
        <?php
}
/*********************************************************************************/
/* Get recent posts widget control
/*********************************************************************************/
function web_recent_video_control() {

	get_recent_control('web-recent-video', 'web_recent_video');

}

register_sidebar_widget ( 'pt-recent-video', 'web_recent_video', 'wid_recent_video' );
register_widget_control ( 'pt-recent-video', 	'web_recent_video_control', 	300, 470);

/*********************************************************************************/
/* Get recent posts widget
/*********************************************************************************/
function web_recent_youtube($args) {
	
	extract($args);
	$options = get_option('web_recent_youtube');
	$arg = GetWidgetArg($options);

	if ($options['html'] =='') $html='li'; else $html = $options['html'];
	if ($options['class'] =='') $class=''; else $class = ' class="'.$options['class'].'"';
	$title 	= empty($options['title']) ? __('Recent youtube', 'post-thumb') : $options['title'];
	?>
	<?php echo $before_widget; ?>
		<?php echo $before_title . $title . $after_title; ?>
		<ul>
			<?php the_recent_thumbs('subfolder=recent&altappend=youtube-&media=2&'.$arg, '<li>', '</li>', '', '');	?>
		</ul>
	<?php echo $after_widget; ?>
	<?php echo '<'.$html.$class.'></'.$html.'>'; ?>
	<?php
}
/*********************************************************************************/
/* Get recent posts widget control
/*********************************************************************************/
function web_recent_youtube_control() {

	get_recent_control('web-recent-youtube', 'web_recent_youtube');

}

register_sidebar_widget ( 'pt-recent-youtube', 'web_recent_youtube', 'wid_recent_youtube' );
register_widget_control ( 'pt-recent-youtube', 	'web_recent_youtube_control', 	300, 470);

/*********************************************************************************/
/* pt-categories widget
/*********************************************************************************/
if (function_exists('pt_list_categories')) {
	function web_categories($args)
	{
		extract($args);
		$options = get_option('web_categories');
		$c = $options['count'] ? '1' : '0';
		$h = $options['hierarchical'] ? '1' : '0';
		$title = empty($options['title']) ? __('Categories') : $options['title'];

		echo $before_widget;
			echo $before_title . $title . $after_title; ?>
			<ul>
				<?php pt_list_categories("sort_column=name&title_li=&show_count=$c&hierarchical=$h"); ?>
			</ul>
		<?php echo $after_widget;

	}
	/*********************************************************************************/
	/* pt-categories widget control
	/*********************************************************************************/
	function web_categories_control()
	{
		$options = $newoptions = get_option('web_categories');
		if ( $_POST['categories-submit'] )
	        {
			$newoptions['count'] = isset($_POST['categories-count']);
			$newoptions['hierarchical'] = isset($_POST['categories-hierarchical']);
			$newoptions['title'] = strip_tags(stripslashes($_POST['categories-title']));
		}
		if ( $options != $newoptions )
	        {
			$options = $newoptions;
			update_option('web_categories', $options);
		}
		$count = $options['count'] ? 'checked="checked"' : '';
		$hierarchical = $options['hierarchical'] ? 'checked="checked"' : '';
		$title = wp_specialchars($options['title']);
	?>
		<p><label for="categories-title"><?php _e('Title:'); ?> <input style="width: 250px;" id="categories-title" name="categories-title" type="text" value="<?php echo $title; ?>" /></label></p>
		<p style="text-align:right;margin-right:40px;"><label for="categories-count"><?php _e('Show post counts', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $count; ?> id="categories-count" name="categories-count" /></label></p>
		<p style="text-align:right;margin-right:40px;"><label for="categories-hierarchical" style="text-align:right;"><?php _e('Show hierarchy', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $hierarchical; ?> id="categories-hierarchical" name="categories-hierarchical" /></label></p>
		<input type="hidden" id="categories-submit" name="categories-submit" value="1" />
	<?php
	}

	register_sidebar_widget ( 'pt-categories', 'web_categories', 'wid-categories' );
	register_widget_control ( 'pt-categories', 'web_categories_control', 300, 130);

}
/*********************************************************************************/
/* pt-bookmarks widget
/*********************************************************************************/
if (function_exists('pt_list_bookmarks')) {
	function web_bookmarks($args)
	{
		extract($args);
		$options = get_option('web_bookmarks');
		$b = empty($options['html_title_before']) ? __('<h4>') : $options['html_title_before'];
		$a = empty($options['html_title_after']) ? __('</h4>') : $options['html_title_after'];
		$title = empty($options['title']) ? __('Blogroll') : $options['title'];

		if (is_home()) {
			echo $before_widget;
				echo $before_title . $title . $after_title;
				echo '<ul>';
					pt_list_bookmarks('title_before='.$b.'&title_after='.$a);
				echo '</ul>';
			echo $after_widget;
		}
	}
	/*********************************************************************************/
	/* pt-bookmarks widget control
	/*********************************************************************************/
	function web_bookmarks_control()
	{
		$options = $newoptions = get_option('web_bookmarks');
		if ( $_POST['bookmarks-submit'] )
	        {
			$newoptions['title'] = strip_tags(stripslashes($_POST['bookmarks-title']));
			$newoptions['html_title_before'] = stripslashes($_POST['bookmarks-before']);
			$newoptions['html_title_after'] = stripslashes($_POST['bookmarks-after']);
		}
		if ( $options != $newoptions )
	        {
			$options = $newoptions;
			update_option('web_bookmarks', $options);
		}
		$title = wp_specialchars($options['title']);
		$html_title_before = wp_specialchars($options['html_title_before']);
		$html_title_after = $options['html_title_after'];
	?>
		<p><label for="bookmarks-title"><?php _e('Title:'); ?> <input style="width: 250px;" id="bookmarks-title" name="bookmarks-title" type="text" value="<?php echo $title; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="bookmarks-before" style="text-align:right;"><?php _e('html before title', 'post-thumb'); ?> <input style="width: 200px;" id="bookmarks-before" name="bookmarks-before" type="text" value="<?php echo $html_title_before; ?>"  /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="bookmarks-after" style="text-align:right;"><?php _e('html after title', 'post-thumb'); ?> <input style="width: 200px;" id="bookmarks-after" name="bookmarks-after" type="text" value="<?php echo $html_title_after; ?>" /></label></p>
		<input type="hidden" id="bookmarks-submit" name="bookmarks-submit" value="1" />
	<?php
	}

	register_sidebar_widget ( 'pt-bookmarks', 'web_bookmarks', 'wid-latest' );
	register_widget_control ( 'pt-bookmarks', 'web_bookmarks_control', 300, 150);

}
/*********************************************************************************/
/* News from rss feed widget
/*********************************************************************************/
if (function_exists('pt_RSS_Import')) {
	function web_news($args)
	{
		extract($args);
		$options = get_option('web_news');
		$l = $options['limit'];
		$f1 = $options['feed1'];
		$f2 = $options['feed2'];
		$w = $options['words'];
		$title = empty($options['title']) ? __('News', 'post-thumb') : $options['title'];
		?>
		<?php echo $before_widget; ?>
			<?php echo $before_title . $title . $after_title; ?>
			<?php if ($f1 != '') { ?>
				<div class="startseite">
					<div class="jd_news_scroll" id="elm1">
						<ul>
							<?php pt_RSS_Import ($l,$f1,$w);  ?>
						</ul>
					</div>
				</div>
			<?php } ?>
			<?php if ($f2 != '') { ?>
			<?php } ?>
		<?php echo $after_widget; ?>
	<?php
	}
	/*********************************************************************************/
	/* News from rss feed widget control
	/*********************************************************************************/
	function web_news_control()
	{
		$options = $newoptions = get_option('web_news');
		if ( $_POST['web-news-submit'] )
	        {
			$newoptions['limit'] = 		strip_tags(stripslashes($_POST['web-news-limit']));
			$newoptions['feed1'] = 		strip_tags(stripslashes($_POST['web-news-feed1']));
			$newoptions['feed2'] = 		strip_tags(stripslashes($_POST['web-news-feed2']));
			$newoptions['words'] = 		strip_tags(stripslashes($_POST['web-news-words']));
			$newoptions['title'] = 		strip_tags(stripslashes($_POST['web-news-title']));
		}
		if ( $options != $newoptions )
	        {
			$options = $newoptions;
			update_option('web_news', $options);
		}
		$title = wp_specialchars($options['title']);
		if (wp_specialchars($options['limit']=='')) $limit = '5'; else $limit = wp_specialchars($options['limit']);
		$feed1 = wp_specialchars($options['feed1']);
		$feed2 = wp_specialchars($options['feed2']);
		if (wp_specialchars($options['words']=='')) $words = '40'; else $words = wp_specialchars($options['words']);
	?>
		<p><label for="web-news-title"><?php _e('Title:'); ?> <input style="width: 240px;" id="web-news-title" name="web-news-title" type="text" value="<?php echo $title; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-news-limit" style="text-align:right;"><?php _e('Number of posts', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-news-limit" name="web-news-limit" value="<?php echo $limit; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-news-feed1" style="text-align:right;"><?php _e('Feed 1', 'post-thumb'); ?> <input style="width: 280px;" type="text" value="<?php echo $feed1; ?>" id="web-news-feed1" name="web-news-feed1" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-news-feed2" style="text-align:right;"><?php _e('Feed 2', 'post-thumb'); ?> <input style="width: 280px;" type="text" value="<?php echo $feed2; ?>" id="web-news-feed2" name="web-news-feed2" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-news-words" style="text-align:right;"><?php _e('Number of words', 'post-thumb'); ?> <input style="width: 40px;" type="text" value="<?php echo $words; ?>" id="web-news-words" name="web-news-words" /></label></p>
		<input type="hidden" id="web-news-submit" name="web-news-submit" value="1" />
	<?php
	}

	register_sidebar_widget ( 'pt-news', 'web_news', 'wid-news' );
	register_widget_control ( 'pt-news', 'web_news_control', 400, 210);

}
if (class_exists('PostThumbLibrary')) {
	/*********************************************************************************/
	/* Get recent posts widget
	/*********************************************************************************/
	function web_last_youtube($args) {
	
		extract($args);
		$options = get_option('web_last_youtube');
		$author_id = trim($options['id']);
		$k 	= $options['keepratio'] ? '1' : '0';
		$w 	= $options['width'];
		$h 	= $options['height'];
		$title 	= empty($options['title']) ? __('Last youtube', 'post-thumb') : $options['title'];
		$XML = GetUserYoutubeVideo($author_id, 1);

		$id = $XML['id'];
		$ytitle = $XML['title'];
		$ythumb = $XML['thumbnail_url'];
		$arg = 'width='.$w.'&height='.$h.'&subfolder=last&keepratio=1&dirname=1';

		$t = new pt_thumbnail(get_pt_options_all(), $ythumb, $arg);
		$thumb_url = $t->thumb_url;
		unset($t);

		?>
		<?php echo $before_widget; ?>
			<?php echo $before_title . $title . $after_title; ?>
			<ul>
				<li>
				<?php echo get_Youtube($id, $ytitle, $thumb_url);	?>
				</li>
			</ul>
		<?php echo $after_widget; ?>
		<li class="clear"></li>
	        <?php
	}
	/*********************************************************************************/
	/* Get recent posts widget control
	/*********************************************************************************/
	function web_last_youtube_control() {
	
		$options = $newoptions = get_option('web_last_youtube');
		if ( $_POST['web-last-youtube-submit'] ) {
		
			$newoptions['id'] 	= strip_tags(stripslashes($_POST['web-last-youtube-id']));
			$newoptions['title'] 	= strip_tags(stripslashes($_POST['web-last-youtube-title']));
			$newoptions['width'] 	= strip_tags(stripslashes($_POST['web-last-youtube-width']));
			$newoptions['height'] 	= strip_tags(stripslashes($_POST['web-last-youtube-height']));
		}
		if ( $options != $newoptions ) {
		
			$options = $newoptions;
			update_option('web_last_youtube', $options);
		}

		$title = wp_specialchars($options['title']);
		$id = wp_specialchars($options['id']);
		if (wp_specialchars($options['width']=='')) $width = '240'; else $width = wp_specialchars($options['width']);
		if (wp_specialchars($options['height']=='')) $height = '180'; else $height = wp_specialchars($options['height']);

	?>
		<p><label for="web-last-youtube-title"><?php _e('Title:'); ?> <input style="width: 240px;" id="web-last-youtube-title" name="web-last-youtube-title" type="text" value="<?php echo $title; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-last-youtube-id" style="text-align:right;"><?php _e('User id', 'post-thumb'); ?> <input style="width: 250px;" type="text" id="web-last-youtube-id" name="web-last-youtube-id" value="<?php echo $id; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-last-youtube-width" style="text-align:right;"><?php _e('Width', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-last-youtube-width" name="web-last-youtube-width" value="<?php echo $width; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-last-youtube-height" style="text-align:right;"><?php _e('Height', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-last-youtube-height" name="web-last-youtube-height" value="<?php echo $height; ?>" /></label></p>
		<input type="hidden" id="web-last-youtube-submit" name="web-last-youtube-submit" value="1" />
	<?php

	}
	register_sidebar_widget ( 'pt-last-youtube', 'web_last_youtube', 'wid_last_youtube' );
	register_widget_control ( 'pt-last-youtube', 'web_last_youtube_control', 300, 200);
	
	/*********************************************************************************/
	/* Recent images post widget
	/*********************************************************************************/
	function web_recent_images($args) {
	
		extract($args);
		$options = get_option('web_recent_images');
		$arg = GetWidgetArg($options);
		$slice = 5;

		$cache = $options['cache'];
		if ($options['html'] =='') $html='li'; else $html = $options['html'];
		if ($options['class'] =='') $class=''; else $class = ' class="'.$options['class'].'"';
		$title = empty($options['title']) ? __('Recent images', 'post-thumb') : $options['title'];

		?>
		<?php echo $before_widget; ?>
			<?php echo $before_title . $title . $after_title; ?>
			<?php echo RecentImages('subfolder=recentimages&'.$arg, $slice, $cache); ?>
		<?php echo $after_widget; ?>
		<?php echo '<'.$html.$class.'></'.$html.'>'; ?>
	        <?php
	}
	/*********************************************************************************/
	/* Recent images post widget control
	/*********************************************************************************/
	function web_recent_images_control() {

		$options = $newoptions = get_option('web_recent_images');
		if ( $_POST['web-recent-images-submit'] ) {
			$newoptions['keepratio'] 	= isset($_POST['web-recent-images-keepratio']);
			$newoptions['width'] 		= strip_tags(stripslashes($_POST['web-recent-images-width']));
			$newoptions['height'] 		= strip_tags(stripslashes($_POST['web-recent-images-height']));
			$newoptions['limit'] 		= strip_tags(stripslashes($_POST['web-recent-images-limit']));
			$newoptions['cache'] 		= strip_tags(stripslashes($_POST['web-recent-images-cache']));
			$newoptions['LBeffect'] 	= isset($_POST['web-recent-images-LBeffect']);
			$newoptions['class'] 		= strip_tags(stripslashes($_POST['web-recent-images-class']));
			$newoptions['html'] 		= strip_tags(stripslashes($_POST['web-recent-images-html']));
			$newoptions['title'] 		= strip_tags(stripslashes($_POST['web-recent-images-title']));
		}
		if ( $options != $newoptions ) {
			$options = $newoptions;
			update_option('web_recent_images', $options);
		}
		$title = wp_specialchars($options['title']);
		if (wp_specialchars($options['html']) =='') $html='li'; else $html = $options['html'];
		$class = wp_specialchars($options['class']);
		$keepratio = $options['keepratio'] ? 'checked="checked"' : '';
		if (wp_specialchars($options['width']=='')) $width = '50'; else $width = wp_specialchars($options['width']);
		if (wp_specialchars($options['height']=='')) $height = '75'; else $height = wp_specialchars($options['height']);
		if (wp_specialchars($options['limit']=='')) $limit = '5'; else $limit = wp_specialchars($options['limit']);
		if (wp_specialchars($options['cache']=='')) $cache = '60'; else $cache = wp_specialchars($options['cache']);
		$showtitle = wp_specialchars($options['showtitle']);
		$LBeffect = $options['LBeffect'] ? 'checked="checked"' : '';
	?>
		<p><label for="web-recent-images-title"><?php _e('Title:'); ?> <input style="width: 240px;" id="web-recent-images-title" name="web-recent-images-title" type="text" value="<?php echo $title; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-recent-images-keepratio"><?php _e('Keep ratio', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $keepratio; ?> id="web-recent-images-keepratio" name="web-recent-images-keepratio" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-recent-images-width" style="text-align:right;"><?php _e('Width', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-recent-images-width" name="web-recent-images-width" value="<?php echo $width; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-recent-images-height" style="text-align:right;"><?php _e('Height', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-recent-images-height" name="web-recent-images-height" value="<?php echo $height; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-recent-images-limit" style="text-align:right;"><?php _e('Show count', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-recent-images-limit" name="web-recent-images-limit" value="<?php echo $limit; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-recent-images-showtitle" style="text-align:right;"><?php _e('Show title', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-recent-images-showtitle" name="web-recent-images-showtitle" value="<?php echo $showtitle; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;margin-bottom:20px;"><label for="web-recent-images-LBeffect"><?php _e('HS effect', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $LBeffect; ?> id="web-recent-images-LBeffect" name="web-recent-images-LBeffect" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-recent-images-html"><?php _e('Closing html:'); ?> <input style="width: 100px;" id="web-recent-images-html" name="web-recent-images-html" type="text" value="<?php echo $html; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-recent-images-class"><?php _e('Closing class:'); ?> <input style="width: 100px;" id="web-recent-images-class" name="web-recent-images-class" type="text" value="<?php echo $class; ?>" /></label></p>
		<p style="text-align:right;margin-right:20px;"><label for="web-recent-images-cache" style="text-align:right;"><?php _e('Cache delay (minutes)', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="web-recent-images-cache" name="web-recent-images-cache" value="<?php echo $cache; ?>" /></label></p>
		<input type="hidden" id="web-recent-images-submit" name="web-recent-images-submit" value="1" />
	<?php
	}
	register_sidebar_widget ( 'Recent Images', 'web_recent_images', 'wid_recent_images' );
	register_widget_control ( 'Recent Images', 'web_recent_images_control', 300, 360);
}
/*********************************************************************************/
/* Register widgets and widget controls
/*********************************************************************************/
	register_sidebar_widget ( 'pt-forum', 'web_forum', 'wid_forum' );

}

// Run our code later in case this loads prior to any required plugins.
add_action('widgets_init', 'post_thumb_widget');

/*********************************************************************************/
/* Get arg for recent widgets
/*********************************************************************************/
function GetWidgetArg($options) {

	$k 	= $options['keepratio'] ? '1' : '0';
	$w 	= $options['width'];
	$h 	= $options['height'];
	$lb 	= $options['LBeffect'] ? '1' : '0';
	$l 	= $options['limit'];
	$o 	= $options['offset'];
	$link = 'i';
	if ($options['showpost']) $link ='p';
	if ($options['showlink']) $link ='u';
	if ($options['showtitle'] =='') $st=''; else $st = '&showtitle='.$options['showtitle'];
	if ($options['thetitle'] != '') $tt = '&title='.$options['thetitle']; else $tt='';
	if ($options['category'] != '') $c = '&category='.$options['category']; else $c='';

	return '&width='.$w.'&height='.$h.'&keepratio='.$k.'&limit='.$l.'&LB_effect='.$lb.'&link='.$link.$c.$st.'&offset='.$o.$tt;

}
/*********************************************************************************/
/* Get recent posts widget control
/*********************************************************************************/
function get_recent_control($prefix, $option_name) {

	$options = $newoptions = get_option($option_name);
	if ( $_POST[$prefix.'-submit'] ) 
        {
		$newoptions['width'] 	= strip_tags(stripslashes($_POST[$prefix.'-width']));
		$newoptions['height'] 	= strip_tags(stripslashes($_POST[$prefix.'-height']));
		$newoptions['keepratio']= isset($_POST[$prefix.'-keepratio']);
		$newoptions['limit']	= strip_tags(stripslashes($_POST[$prefix.'-limit']));
		$newoptions['offset'] 	= strip_tags(stripslashes($_POST[$prefix.'-offset']));
		$newoptions['category'] = strip_tags(stripslashes($_POST[$prefix.'-category']));
		$newoptions['showpost'] = isset($_POST[$prefix.'-showpost']);
		$newoptions['showlink'] = isset($_POST[$prefix.'-showlink']);
		$newoptions['showtitle']= strip_tags(stripslashes($_POST[$prefix.'-showtitle']));
		$newoptions['thetitle'] = strip_tags(stripslashes($_POST[$prefix.'-thetitle']));
		$newoptions['LBeffect'] = isset($_POST[$prefix.'-LBeffect']);
		$newoptions['class'] 	= strip_tags(stripslashes($_POST[$prefix.'-class']));
		$newoptions['html'] 	= strip_tags(stripslashes($_POST[$prefix.'-html']));
		$newoptions['title'] 	= strip_tags(stripslashes($_POST[$prefix.'-title']));
	}
	if ( $options != $newoptions ) 
        {
		$options = $newoptions;
		update_option($option_name, $options);
	}

	if (wp_specialchars($options['width']=='')) $width = '80'; else $width = wp_specialchars($options['width']);
	if (wp_specialchars($options['height']=='')) $height = '60'; else $height = wp_specialchars($options['height']);
	if (wp_specialchars($options['html']) =='') $html='li'; else $html = $options['html'];
	$class = wp_specialchars($options['class']);
	$title = wp_specialchars($options['title']);
	$keepratio = $options['keepratio'] ? 'checked="checked"' : '';
	if (wp_specialchars($options['limit']=='')) $limit = '10'; else $limit = wp_specialchars($options['limit']);
	if (wp_specialchars($options['offset']=='')) $offset = '0'; else $offset = wp_specialchars($options['offset']);
	$category = wp_specialchars($options['category']);
	$showtitle = wp_specialchars($options['showtitle']);
	$thetitle = wp_specialchars($options['thetitle']);
	$media = $options['media'] ? 'checked="checked"' : '';
	$showpost = $options['showpost'] ? 'checked="checked"' : '';
	$showlink = $options['showlink'] ? 'checked="checked"' : '';
	$LBeffect = $options['LBeffect'] ? 'checked="checked"' : '';

?>
	<p><label for="<?php echo $prefix; ?>-title"><?php _e('Title:'); ?> <input style="width: 240px;" id="<?php echo $prefix; ?>-title" name="<?php echo $prefix; ?>-title" type="text" value="<?php echo $title; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-keepratio"><?php _e('Keep ratio', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $keepratio; ?> id="<?php echo $prefix; ?>-keepratio" name="<?php echo $prefix; ?>-keepratio" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-width" style="text-align:right;"><?php _e('Width', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="<?php echo $prefix; ?>-width" name="<?php echo $prefix; ?>-width" value="<?php echo $width; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-height" style="text-align:right;"><?php _e('Height', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="<?php echo $prefix; ?>-height" name="<?php echo $prefix; ?>-height" value="<?php echo $height; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-limit" style="text-align:right;"><?php _e('Number of posts', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="<?php echo $prefix; ?>-limit" name="<?php echo $prefix; ?>-limit" value="<?php echo $limit; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-offset" style="text-align:right;"><?php _e('Offset of posts', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="<?php echo $prefix; ?>-offset" name="<?php echo $prefix; ?>-offset" value="<?php echo $offset; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-category" style="text-align:right;"><?php _e('Category filter', 'post-thumb'); ?> <input style="width: 40px;" type="text" value="<?php echo $category; ?>" id="<?php echo $prefix; ?>-category" name="<?php echo $prefix; ?>-category" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-showtitle" style="text-align:right;"><?php _e('Show title', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="w<?php echo $prefix; ?>-showtitle" name="<?php echo $prefix; ?>-showtitle" value="<?php echo $showtitle; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-thetitle" style="text-align:right;"><?php _e('Choose title (T/C/E)', 'post-thumb'); ?> <input style="width: 40px;" type="text" id="<?php echo $prefix; ?>-thetitle" name="<?php echo $prefix; ?>-thetitle" value="<?php echo $thetitle; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-showpost"><?php _e('Link to post', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $showpost; ?> id="<?php echo $prefix; ?>-showpost" name="<?php echo $prefix; ?>-showpost" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-showlink" style="text-align:right;"><?php _e('Link to url', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $showlink; ?> id="<?php echo $prefix; ?>-showlink" name="<?php echo $prefix; ?>-showlink" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-LBeffect"><?php _e('HS effect', 'post-thumb'); ?> <input class="checkbox" type="checkbox" <?php echo $LBeffect; ?> id="<?php echo $prefix; ?>-LBeffect" name="<?php echo $prefix; ?>-LBeffect" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-html"><?php _e('Closing html:'); ?> <input style="width: 100px;" id="<?php echo $prefix; ?>-html" name="<?php echo $prefix; ?>-html" type="text" value="<?php echo $html; ?>" /></label></p>
	<p style="text-align:right;margin-right:20px;"><label for="<?php echo $prefix; ?>-class"><?php _e('Closing class:'); ?> <input style="width: 100px;" id="<?php echo $prefix; ?>-class" name="<?php echo $prefix; ?>-class" type="text" value="<?php echo $class; ?>" /></label></p>
	<input type="hidden" id="<?php echo $prefix; ?>-submit" name="<?php echo $prefix; ?>-submit" value="1" />
<?php

}
?>
