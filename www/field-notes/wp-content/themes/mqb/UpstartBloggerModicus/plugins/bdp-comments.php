<?php
/*
Plugin Name:bdp-comments
Plugin URI:http://www.ozpolitics.info/blog/?page_id=164#comments
Description:List recent comments and posts - hacked from the WordPress core
Version:1.0.6
Author:Bryan Palmer (bryan@ozpolitics.info)
Author URI:http://www.ozpolitics.info/

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function bdp_comments($listHowMany='10', $numSummaryWords=0, $allLink=FALSE, $before='<li>', $after='</li>') {

	global $wpdb;

	$sql = 	"SELECT comment_author, comment_author_url, comment_ID, " .
		"comment_post_ID, comment_content FROM $wpdb->comments " .
		"WHERE comment_approved = '1' " .
		"ORDER BY comment_date_gmt DESC LIMIT $listHowMany";

	if ( $comments = $wpdb->get_results($sql) )  {
		foreach ($comments as $comment) {
			
			$link = "<a href='" . get_permalink($comment->comment_post_ID) . 
				'#comment-' . $comment->comment_ID . "'>";
			
			echo "$before";
			if($allLink)
				echo $link."<strong>";
			else
			{
				if($comment->comment_author_url && $comment->comment_author_url != 'http://') 
					echo '<a href="' .$comment->comment_author_url. '"  rel="nofollow">';
			}
			
			echo "$comment->comment_author";
			
			if($allLink) echo "</strong>";
			
			if(!$allLink && $comment->comment_author_url != 'http://') 
				echo '</a>';
			
			if(is_int($numSummaryWords) && intval($numSummaryWords)>0)
			{
				$words = strip_tags($comment->comment_content);
				if($words)
				{
					echo ' ' . __('said') . ' &ldquo;';
					$wordArray = preg_split("'\s'", $words, -1, PREG_SPLIT_NO_EMPTY);
					$size = count($wordArray);
					for($i=0; $i<$numSummaryWords && $i<$size; $i++)
					{
						if($i>0) echo ' ';
						
						// trim long words
						$maxWordLength = 16;
						if(strlen($wordArray[$i])>$maxWordLength)	// trim long words
						{
							$wordArray[$i] = substr($wordArray[$i], 0, $maxWordLength);
							$wordArray[$i] = $wordArray[$i] . "~";
						}
						
						echo $wordArray[$i];
					}
					if($size > $numSummaryWords) echo ' ...';
					echo '&rdquo;';
				}
			}
			
			echo ' ' . __('on') . ' ';
				
			if(!$allLink) echo $link;
			
			/* if($allLink) echo "<strong>"; */
			
			echo get_the_title($comment->comment_post_ID);
			
			/* if($allLink) echo "</strong>"; */
			
			echo '</a>';
			
			echo $after . "\n";
		}
	}
}

function bdp_posts($listHowMany='10', $before='<li>', $after='</li>') {

	global $wpdb;

	$today = current_time('mysql', 1);

	$sql =	"SELECT ID, post_title FROM $wpdb->posts WHERE " .
		"post_status='publish' AND post_date_gmt<'$today' AND post_type='post' " .
		"ORDER BY post_date DESC LIMIT $listHowMany";

	if ( $recentposts = $wpdb->get_results($sql) )  
	{
		foreach ($recentposts as $post) 
		{
			$link = '<a href="' . get_permalink($post->ID) . '">';
			echo "$before$link". $post->post_title . "</a>$after\n";
		}
	}
}

?>