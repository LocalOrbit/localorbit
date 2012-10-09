<?php
global $ts_options;

if (empty($ts_options)) {
	$ts_options = get_option('ts_options');
}

if (!empty($_POST['ts_rt_save'])) {			
	$ts_options['rt_title'] 		   = strip_tags(stripslashes($_POST['ts_rt_title']));
	$ts_options['rt_result_count'] 	   = (int) $_POST['ts_rt_result_count'];
	$ts_options['rt_show_tweet_count'] = (int) $_POST['ts_rt_show_tweet_count'];
	$ts_options['rt_cache_expiry']	   = (int) $_POST['ts_rt_cache_expiry'];
	$ts_options['rt_trim_title']	   = (int) $_POST['ts_rt_trim_title'];
	
	unset($ts_options['rt_cache']);
	unset($ts_options['rt_cache_date']);
	
	update_option('ts_options', $ts_options);
}
?>
<style type="text/css">
#ts_rt_widget_options td { padding-bottom: 5px; }
</style>
<p>
<label for="ts_rt_title">
	<?php _e('Title:'); ?>
	<input class="widefat" id="ts_rt_title" name="ts_rt_title" type="text" value="<?php echo attribute_escape($ts_options['rt_title']); ?>" />
</label>
</p>
<table id="ts_rt_widget_options">
<tr>
<td>
	<label for="ts_rt_result_count"><?php _e('Nr. of posts to show:', 'tweet_stats'); ?> </label>
</td>
<td>	
	<input style="width: 30px; text-align: center;" id="ts_rt_result_count" name="ts_rt_result_count" type="text" value="<?php echo $ts_options['rt_result_count']; ?>" />
</td>
</tr>
<tr>
<td>
	<label for="ts_rt_show_tweet_count"><?php _e('Display nr. of tweets:', 'tweet_stats'); ?></label>
</td>
<td>
	<select name="ts_rt_show_tweet_count" id="ts_rt_show_tweet_count">
	<option value="1" <?php if ($ts_options['rt_show_tweet_count'] == 1): ?>selected="selected"<?php endif; ?>>Yes</option>
	<option value="0" <?php if ($ts_options['rt_show_tweet_count'] == 0): ?>selected="selected"<?php endif; ?>>No</option>
	</select>
</td>
</tr>
<tr>
<td>
	<label for="ts_rt_cache_expiry"><?php _e('Cache for:', 'tweet_stats'); ?></td>
<td>		
	<select name="ts_rt_cache_expiry" id="ts_rt_cache_expiry">
	<option value="900" <?php if ($ts_options['rt_cache_expiry'] == 900): ?>selected="selected"<?php endif; ?>>15 min</option>
	<option value="1800" <?php if ($ts_options['rt_cache_expiry'] == 1800): ?>selected="selected"<?php endif; ?>>30 min</option>
	<option value="3600" <?php if ($ts_options['rt_cache_expiry'] == 3600): ?>selected="selected"<?php endif; ?>>1 hour</option>
	<option value="25200" <?php if ($ts_options['rt_cache_expiry'] == 25200): ?>selected="selected"<?php endif; ?>>1 day</option>
	<option value="176400" <?php if ($ts_options['rt_cache_expiry'] == 176400): ?>selected="selected"<?php endif; ?>>1 week</option>
	</select>
</td>
</tr>
<tr>
<td>	
	<label for="ts_rt_trim_title"><?php _e('Trim titles at:', 'tweet_stats'); ?></label>
</td>
<td>
	<input style="width: 35px; text-align: center;" type="text" name="ts_rt_trim_title" id="ts_rt_trim_title" value="<?php echo $ts_options['rt_trim_title']; ?>" size="3" /> <?php _e('chars', 'tweet_stats'); ?>
</td>
</tr>
</table>
</p>
<input type="hidden" id="ts_rt_save" name="ts_rt_save" value="1" />