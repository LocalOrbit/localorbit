<?php
/*
Plugin Name: Future Calendar
Plugin URI: http://anthologyoi.com/wordpress/plugins/future-posts-calendar-plugin.html
Description: A simple plugin that utalizes a modified get_calendar function that shows what dates have a future post scheduled in a calendar format, and makes it easy to change the current timestamp. Temperature Functionality and some tweaks by Flavio Jarabeck (www.InternetDrops.com.br)
Author: Aaron Harun
Version: 1.0
Author URI: http://anthologyoi.com/
*/

/*Uncomment the following line if you want to have the calendar appear on the dashboard.*/
//add_action('activity_box_end', 'get_future_calendar_html');


	if (strpos($_SERVER['PHP_SELF'], 'post')){	
		if($wp_version < 2.5){
			add_action('dbx_post_sidebar', 'get_future_calendar_html',2);
		}else{
			add_action('submitpost_box', 'get_future_calendar_html');
		}
		add_action('admin_head', 'fcal_javascript');
	}


// This gets called at the plugins_loaded action
function widget_fut_posts_init() {

	// Check for the required API functions
	if ( !function_exists('register_sidebar_widget') || !function_exists('register_widget_control') )
		return;

	// This saves options and prints the widget's config form.
	function widget_fut_posts_control() {
		$options = $newoptions = get_option('widget_fut_posts');
		if ( $_POST['fut_posts-submit'] ) {
			$newoptions['title'] = strip_tags(stripslashes($_POST['fut_posts-title']));
		}
		if ( $options != $newoptions ) {
			$options = $newoptions;
			update_option('widget_fut_posts', $options);
		}
	?>
				<div style="text-align:right">
				<label for="fut_posts-title" style="line-height:35px;display:block;"><?php _e('Widget title:', 'widgets'); ?> <input type="text" id="fut_posts-title" name="fut_posts-title" value="<?php echo wp_specialchars($options['title'], true); ?>" /></label>
				<input type="hidden" name="fut_posts-submit" id="fut_posts-submit" value="1" />
				</div>
	<?php
	}

	// This prints the widget
	function widget_fut_posts($args) {
		extract($args);
		$defaults = array('title' => 'Future Posts');
		$options = (array) get_option('widget_fut_posts');

		foreach ( $defaults as $key => $value )
			if ( !isset($options[$key]) )
				$options[$key] = $defaults[$key];

			echo $before_widget . $before_title . $title . $after_title;
			fcal_get_future_posts(0);
			echo $after_widget;
	}


	register_sidebar_widget('Future Posts', 'widget_fut_posts');
	register_widget_control('Future Posts', 'widget_fut_posts_control');
}

// Delay plugin execution to ensure Dynamic Sidebar has a chance to load first
add_action('widgets_init', 'widget_fut_posts_init');


function future_post_sidebar(){
	$title = __('Future Post','fcal');
	echo '<div>' . '<h3>' . $title . '</h3>';
	fcal_get_future_posts();
	echo '</div>';
}

function fcal_javascript(){
	echo '
	<script type="text/javascript">
		function fcal_set_date(day,month,year){

				if(day > 0 && month <= 12 && month >= 0 && year > 0){
				document.getElementById("jj").value = day;
				document.getElementById("aa").value = year;
				document.getElementsByName("mm")[0].selectedIndex = month;
				}

		}
	</script>
	';
}


function get_future_calendar_html(){
global $wp_version;
	
	if($wp_version < 2.5){
		echo '<fieldset id="future_cal" class="dbx-box side-info">';
		echo '<h3 class="dbx-handle">'.__('Future Post Dates','fcal').'</h3>';
		echo '<div class="dbx-content">';
			fcal_get_future_posts();
		echo '</div></fieldset>';
	}else{
		echo '<div class="inside">';
		echo '<p><strong>'.__('Future Post Dates','fcal').'</strong></p>';
			fcal_get_future_posts();
		echo '</div>';
		
	}
	
}

function fcal_get_future_posts($onclick = 1){
global $wpdb, $wp_locale;

	$thisyear = gmdate('Y', current_time('timestamp'));
	$thismonth = gmdate('m', current_time('timestamp'));

	// Quick check. If we have no posts at all, abort!
	if ( !$posts ) {
		$gotsome = $wpdb->get_var("SELECT ID from $wpdb->posts WHERE post_type = 'post' AND post_status = 'future' ORDER BY post_date DESC LIMIT 1");
		if ( !$gotsome ){
			get_future_calendar($thismonth,$thisyear,$onclick);
			return;
		}
	}

	get_future_calendar($thismonth,$thisyear,$onclick);

	//Technically thismonth is really nextmonth, but no reason to be technical about it
	//But if thismonth is 12 then we need to reset it, and add a year otherwise we will be checking
	// out the 13th month of this year.
	if($thismonth == 12){
		$thismonth = 0;
		$thisyear +=1;
	}
	// Get months this year and next with at least one post
	$future = $wpdb->get_results("SELECT
		DISTINCT MONTH(post_date) AS month, YEAR(post_date) AS year
		FROM $wpdb->posts
		WHERE post_date >'$thisyear-".($thismonth+1)."-01'
		AND post_type = 'post' AND post_status = 'future'
		ORDER	BY post_date ASC");

	foreach($future as $now){
		get_future_calendar($now->month,$now->year);
	}
}


// Calendar Output...
function get_future_calendar( $thismonth ='', $thisyear='', $onclick=1, $initial=true ) {
	global $wpdb, $timedifference, $wp_locale;
	$unixmonth = mktime(0, 0 , 0, $thismonth, 1, $thisyear);

	// week_begins = 0 stands for Sunday
	$week_begins = intval(get_option('start_of_week'));
	$add_hours = intval(get_option('gmt_offset'));
	$add_minutes = intval(60 * (get_option('gmt_offset') - $add_hours));

	echo '<table class="wp-calendar">
	<caption><em>' . $wp_locale->get_month($thismonth) . ' ' . $thisyear . '</em></caption>
	<thead>
	<tr>';

	$myweek = array();

	for ( $wdcount=0; $wdcount<=6; $wdcount++ ) {
		$myweek[] = $wp_locale->get_weekday(($wdcount+$week_begins)%7);
	}

	foreach ( $myweek as $wd ) {
		$day_name = (true == $initial) ? $wp_locale->get_weekday_initial($wd) : $wp_locale->get_weekday_abbrev($wd);
		echo "\n\t\t<th abbr=\"$wd\" scope=\"col\" title=\"$wd\">$day_name</th>";
	}

	echo '
	</tr>
	</thead>
	<tbody>
	<tr>';

	// Get days with posts
	$dayswithposts = $wpdb->get_results("SELECT DISTINCT DAYOFMONTH(post_date)
		FROM $wpdb->posts WHERE MONTH(post_date) = '$thismonth'
		AND YEAR(post_date) = '$thisyear'
		AND post_type = 'post' AND post_status = 'future'
		AND post_date > '" . current_time('mysql') . '\'', ARRAY_N);
	if ( $dayswithposts ) {
		foreach ( $dayswithposts as $daywith ) {
			$daywithpost[] = $daywith[0];
		}
	} else {
		$daywithpost = array();
	}



	if ( strstr($_SERVER['HTTP_USER_AGENT'], 'MSIE') || strstr(strtolower($_SERVER['HTTP_USER_AGENT']), 'camino') || strstr(strtolower($_SERVER['HTTP_USER_AGENT']), 'safari') )
		$ak_title_separator = "\n";
	else
		$ak_title_separator = ', ';

	$ak_titles_for_day = array();
    //sets the Density Thermometer
	$ak_posts_for_day = array();

	$ak_post_titles = $wpdb->get_results("SELECT post_title, DAYOFMONTH(post_date) as dom "
		."FROM $wpdb->posts "
		."WHERE YEAR(post_date) = '$thisyear' "
		."AND MONTH(post_date) = '$thismonth' "
		."AND post_date > '".current_time('mysql')."' "
		."AND post_type = 'post' AND post_status = 'future'"
	);
	if ( $ak_post_titles ) {
		foreach ( $ak_post_titles as $ak_post_title ) {
				if ( empty($ak_titles_for_day['day_'.$ak_post_title->dom]) )
					$ak_titles_for_day['day_'.$ak_post_title->dom] = '';
				if ( empty($ak_titles_for_day["$ak_post_title->dom"]) ) // first one
					$ak_titles_for_day["$ak_post_title->dom"] = str_replace('"', '&quot;', wptexturize($ak_post_title->post_title));
				else
					$ak_titles_for_day["$ak_post_title->dom"] .= $ak_title_separator . str_replace('"', '&quot;', wptexturize($ak_post_title->post_title));

                $ak_posts_for_day["$ak_post_title->dom"] +=1;

		}
	}


	// See how much we should pad in the beginning
	$pad = calendar_week_mod(date('w', $unixmonth)-$week_begins);
	if ( 0 != $pad ) { echo "\n\t\t".'<td colspan="'.$pad.'" class="pad">&nbsp;</td>'; }

	    //Determines the Density Thermometer colors
	    $thermo = Array( "#BDFFBE", "#7AFFDE", "#2FEEFF", "#108BFF", "#0E72FF" );


	$daysinmonth = intval(date('t', $unixmonth));
	for ( $day = 1; $day <= $daysinmonth; ++$day ) {
		if ( isset($newrow) && $newrow )
			echo "\n\t</tr>\n\t<tr>\n\t\t";
		$newrow = false;

		if ( $day == gmdate('j', (time() + (get_option('gmt_offset') * 3600))) && $thismonth == gmdate('m', time()+(get_option('gmt_offset') * 3600)) && $thisyear == gmdate('Y', time()+(get_option('gmt_offset') * 3600)) )
			echo '<td style="font-weight:bold;">';
		else
			echo '<td>';

		if($onclick == 1){
			$onclick1 = 'onclick="fcal_set_date('.$day.','.($thismonth-1).','.$thisyear.')"';
		}

        // any posts on that day?
		if ( in_array($day, $daywithpost) ) {
            //Outputs the Density Thermometer along with the day...
			echo '<span style="background-color:'.($ak_posts_for_day[$day]<=Count($thermo) ? $thermo[$ak_posts_for_day[$day]-1] : $thermo[Count($thermo)-1]).';" title="'.$ak_titles_for_day[$day].' '.$onclick1.' >'.$day.'</span>';

		} else {
			echo '<span '.$onclick1.' >'.$day.'</span>';
        }
		echo '</td>';

		if ( 6 == calendar_week_mod(date('w', mktime(0, 0 , 0, $thismonth, $day, $thisyear))-$week_begins) )
			$newrow = true;
	}

	$pad = 7 - calendar_week_mod(date('w', mktime(0, 0 , 0, $thismonth, $day, $thisyear))-$week_begins);
	if ( $pad != 0 && $pad != 7 )
		echo "\n\t\t".'<td class="pad" colspan="'.$pad.'">&nbsp;</td>';

	echo "\n\t</tr>\n\t</tbody>\n\t</table>";
}
?>
