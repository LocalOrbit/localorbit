<?php

// current_post_keywords()
// This function was more or less completely written by Peter Bowyer
/**
 * Builds a word frequency list from the Wordpress post, and returns a string
 * to be used in matching against the MySQL full-text index.
 *
 * @param integer $num_to_ret The number of words to use when matching against
 * 							  the database.
 * @return string The words
 */
function current_post_keywords($num_to_ret = 20) {
	global $post;
	// An array of weightings, to make adjusting them easier.
	$w = array(
			   'title' => 2,
			   'name' => 2,
			   'content' => 1,
			   'cat_name' => 3
		      );
	
	/*
	Thanks to http://www.eatdrinksleepmovabletype.com/tutorials/building_a_weighted_keyword_list/
	for the basics for this code.  It saved me much typing (or thinking) :)
	*/
	
	// This needs experimenting with.  I've given post title and url a double
	// weighting, changing this may give you better results
	$string = str_repeat($post->post_title, $w['title'].' ').
			  str_repeat(str_replace('-', ' ', $post->post_name).' ', $w['name']).
			  str_repeat(strip_tags(apply_filters_without('the_content',$post->post_content,'yarpp_default')), $w['content'].' ');//mitcho: strip_tags
	
	// Cat names don't help with the current query: the category names of other
	// posts aren't retrieved by the query to be matched against (and can't be
	// indexed)
	// But I've left this in just in case...
	$post_categories = get_the_category();
	foreach ($post_categories as $cat) {
		$string .= str_repeat($cat->cat_name.' ', $w['cat_name']);
	}
	
	// Remove punctuation.
	$wordlist = preg_split('/\s*[\s+\.|\?|,|(|)|\-+|\'|\"|=|;|&#0215;|\$|\/|:|{|}]\s*/i', strtolower($string));
	
	// Build an array of the unique words and number of times they occur.
	$a = array_count_values($wordlist);
	
	//Remove words that don't matter--"stop words."
	$overusedwords = array( '', 'a', 'an', 'the', 'and', 'of', 'i', 'to', 'is', 'in', 'with', 'for', 'as', 'that', 'on', 'at', 'this', 'my', 'was', 'our', 'it', 'you', 'we', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '10', 'about', 'after', 'all', 'almost', 'along', 'also', 'amp', 'another', 'any', 'are', 'area', 'around', 'available', 'back', 'be', 'because', 'been', 'being', 'best', 'better', 'big', 'bit', 'both', 'but', 'by', 'c', 'came', 'can', 'capable', 'control', 'could', 'course', 'd', 'dan', 'day', 'decided', 'did', 'didn', 'different', 'div', 'do', 'doesn', 'don', 'down', 'drive', 'e', 'each', 'easily', 'easy', 'edition', 'end', 'enough', 'even', 'every', 'example', 'few', 'find', 'first', 'found', 'from', 'get', 'go', 'going', 'good', 'got', 'gt', 'had', 'hard', 'has', 'have', 'he', 'her', 'here', 'how', 'if', 'into', 'isn', 'just', 'know', 'last', 'left', 'li', 'like', 'little', 'll', 'long', 'look', 'lot', 'lt', 'm', 'made', 'make', 'many', 'mb', 'me', 'menu', 'might', 'mm', 'more', 'most', 'much', 'name', 'nbsp', 'need', 'new', 'no', 'not', 'now', 'number', 'off', 'old', 'one', 'only', 'or', 'original', 'other', 'out', 'over', 'part', 'place', 'point', 'pretty', 'probably', 'problem', 'put', 'quite', 'quot', 'r', 're', 'really', 'results', 'right', 's', 'same', 'saw', 'see', 'set', 'several', 'she', 'sherree', 'should', 'since', 'size', 'small', 'so', 'some', 'something', 'special', 'still', 'stuff', 'such', 'sure', 'system', 't', 'take', 'than', 'their', 'them', 'then', 'there', 'these', 'they', 'thing', 'things', 'think', 'those', 'though', 'through', 'time', 'today', 'together', 'too', 'took', 'two', 'up', 'us', 'use', 'used', 'using', 've', 'very', 'want', 'way', 'well', 'went', 'were', 'what', 'when', 'where', 'which', 'while', 'white', 'who', 'will', 'would', 'your');
	
	// Remove the stop words from the list.
	foreach ($overusedwords as $word) {
		 unset($a[$word]);
	}
	arsort($a, SORT_NUMERIC);
	
	$num_words = count($a);
	$num_to_ret = $num_words > $num_to_ret ? $num_to_ret : $num_words;
	
	$outwords = array_slice($a, 0, $num_to_ret);
	return implode(' ', array_keys($outwords));
	
}

function yarpp_related($type,$args,$echo = true) {
	global $wpdb, $post, $user_level;
	get_currentuserinfo();

	// if cross_relate is set, override the type argument and make sure both matches are accepted in the sql query
	if (get_option('yarpp_cross_relate')) $type = array('post','page');

	// Get option values from the options page--this can be overwritten: see readme
	$options = array('limit','threshold','before_title','after_title','show_excerpt','excerpt_length','before_post','after_post','show_pass_post','past_only','show_score');
	$optvals = array();
	foreach (array_keys($options) as $index) {
		if (isset($args[$index+1])) {
			$optvals[$options[$index]] = stripslashes($args[$index+1]);
		} else {
			$optvals[$options[$index]] = stripslashes(get_option('yarpp_'.$options[$index]));
		}
	}
	extract($optvals);
			
	// Fetch keywords
    $terms = current_post_keywords();

	// Make sure the post is not from the future
	$time_difference = get_settings('gmt_offset');
	$now = gmdate("Y-m-d H:i:s",(time()+($time_difference*3600)));
	
	// Primary SQL query
	
    $sql = "SELECT ID, post_title, post_content,"
         . "MATCH (post_name, post_content) "
         . "AGAINST ('$terms') AS score "
         . "FROM $wpdb->posts WHERE "
		 . "post_type IN ('".implode("', '",$type)."') "
         . "AND MATCH (post_name, post_content) AGAINST ('$terms') >= $threshold "
		 . "AND (post_status IN ( 'publish',  'static' ) && ID != '$post->ID') ";
	if (past_only) { $sql .= "AND post_date <= '$now' "; }
    if ($show_pass_post=='false') { $sql .= "AND post_password ='' "; }
    $sql .= "ORDER BY score DESC LIMIT $limit";
    $results = $wpdb->get_results($sql);
    $output = '';
    if ($results) {
		foreach ($results as $result) {
			$title = stripslashes(apply_filters('the_title', $result->post_title));
			$permalink = get_permalink($result->ID);
			$post_content = strip_tags($result->post_content);
			$post_content = stripslashes($post_content);
			$output .= $before_title .'<a href="'. $permalink .'" rel="bookmark" title="Permanent Link: ' . $title . '">' . $title . (($show_score and $user_level >= 8)? ' ('.round($result->score,3).')':'') . '</a>' . $after_title;
			if ($show_excerpt) {
				$ze = substr($post_content, 0, $excerpt_length);
				$ze = substr($ze, 0, strrpos($ze,' '));
				$ze .= '...';
				$output .= $before_post . $ze . $after_post;
			}
		}
		$output = get_option('yarpp_before_related').$output.get_option('yarpp_after_related');
	} else {
		$output = get_option('yarpp_no_results');
    }
	if ($echo) echo $output; else return $output;
}

function yarpp_related_exist($type,$args) {
	global $wpdb, $post;

	if (get_option('yarpp_cross_relate')) $type = array('post','page');

	$options = array('threshold','show_pass_post','past_only');
	$optvals = array();
	foreach (array_keys($options) as $index) {
		if (isset($args[$index+1])) {
			$optvals[$options[$index]] = stripslashes($args[$index+1]);
		} else {
			$optvals[$options[$index]] = stripslashes(get_option('yarpp_'.$options[$index]));
		}
	}
	extract($optvals);

    $terms = current_post_keywords();

	$time_difference = get_settings('gmt_offset');
	$now = gmdate("Y-m-d H:i:s",(time()+($time_difference*3600)));
	
    $sql = "SELECT COUNT(*) as count "
         . "FROM $wpdb->posts WHERE "
		 . "post_type IN ('".implode("', '",$type)."') "
		 . "AND MATCH (post_name, post_content) AGAINST ('$terms') >= $threshold "
		 . "AND (post_status IN ( 'publish',  'static' ) && ID != '$post->ID') ";
	if (past_only) { $sql .= "AND post_date <= '$now' "; }
    if ($show_pass_post=='false') { $sql .= "AND post_password ='' "; }

    $result = $wpdb->get_var($sql);
	return $result > 0 ? true: false;
}

?>