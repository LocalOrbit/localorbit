<?php
// Begin Related Posts Options

global $yarpp_value_options, $yarpp_binary_options;
if (!yarpp_enabled()) {
	echo '<div class="updated">';
	if (yarpp_activate()) echo 'The YARPP database had an error but has been fixed.';
	echo '</div>';
}

if (isset($_POST['update_yarpp'])) {
	foreach (array_keys($yarpp_value_options) as $option) {
		update_option('yarpp_'.$option,$_POST[$option]);
	}
	foreach (array_keys($yarpp_binary_options) as $option) {
		(isset($_POST[$option])) ? update_option('yarpp_'.$option,true) : update_option('yarpp_'.$option,false);
	}		
	echo '<div id="message" class="updated fade" style="background-color: rgb(207, 235, 247);"><p>Options saved!</p></div>';
}

function checkbox($option,$desc,$tr="<tr>
			<td width='33%' scope='row' colspan='2'>",$inputplus = '') {
	echo "			$tr<label for='$option'>$desc</label></td>
			<td>
			<input $inputplus type='checkbox' name='$option' value='true'". ((get_option('yarpp_'.$option)) ? ' checked="checked"': '' )."  />
			</td>
		</tr>";
}
function textbox($option,$desc,$size=2,$tr="<tr>
			<td width='33%' scope='row' colspan='2'>") {
	echo "			$tr<label for='$option'>$desc</label></td>
			<td><input name='$option' type='text' id='$option' value='".htmlspecialchars(stripslashes(get_option('yarpp_'.$option)))."' size='$size' /></td>
		</tr>";
}

?>

<script type="text/javascript">
var css=document.createElement("link");
css.setAttribute("rel", "stylesheet");
css.setAttribute("type", "text/css");
css.setAttribute("href", "../wp-content/plugins/yet-another-related-posts-plugin/options.css");
document.getElementsByTagName("head")[0].appendChild(css);
</script>

<div class="wrap">
	<h2>Yet Another Related Posts Plugin Options <small><?php echo get_option('yarpp_version'); ?></small></h2>
	<p><small>by <a href="http://mitcho.com/code/">mitcho (Michael Ëä„Ë¾¥ Erlewine)</a> and based on the fabulous work of <a href="http://peter.mapledesign.co.uk/weblog/archives/wordpress-related-posts-plugin">Peter Bower</a>, <a href="http://wasabi.pbwiki.com/Related%20Entries">Alexander Malov & Mike Lu</a>. If you appreciate this plugin, please consider <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=mitcho%40mitcho%2ecom&item_name=mitcho%2ecom%2fcode%3a%20donate%20to%20Michael%20Yoshitaka%20Erlewine&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8">donating to the author, mitcho</a>.</small></p>
	<form method="post">
	<fieldset class="options">
	<h3>"Relatedness" options</h3>
	<p>YARPP is different than the <a href="http://wasabi.pbwiki.com/Related%20Entries">previous plugins it is based on</a> as it limits the related posts list by (1) a maximum number and (2) a <em>match threshold</em>. <a href="#" class='info'>more&gt;<span>The higher the match threshold, the more restrictive, and you get less related posts overall. The default match threshold is 5. If you want to find an appropriate match threshhold, I recommend you turn on the "show admins the match scores" setting below. That way, you can see what kinds of related posts are being picked up and with what kind of match scores, and determine an appropriate threshold for your site.</span></a></p>
	
	<table class="optiontable editform" width="100%" scope="row">
<?php textbox('limit','Maximum number of related posts:')?>
<?php textbox('threshold','Match threshold:')?>
<?php checkbox('cross_relate',"Cross-relate posts and pages? <a href='#' class='info'>more&gt;<span>When the \"Cross-relate posts and pages\" option is selected, the <code>related_posts()</code>, <code>related_pagaes()</code>, and <code>related_entries()</code> all will give the same output, returning both related pages and posts.</span></a>"); ?>

	</table>
	<h3>Display options</h3>
	<table class="optiontable editform" width="100%" scope="row">
<?php checkbox('auto_display',"Automatically display related posts? <span class='red'>NEW!</span> <a href='#' class='info'>more&gt;<span>This option automatically displays related posts right after the content on single entry pages. If this option is off, you will need to manually insert <code>related_posts()</code> or variants into your theme files.</span></a>"); ?>
		<tr>
			<td colspan='2'><label for="before_related">Before</label> / <label for="after_related">after related entries </label>:</td>
			<td><input name="before_related" type="text" id="before_related" value="<?php echo htmlspecialchars(stripslashes(get_option('yarpp_before_related'))); ?>" size="10" /> / <input name="after_related" type="text" id="after_related" value="<?php echo htmlspecialchars(stripslashes(get_option('yarpp_after_related'))); ?>" size="10" /><em><small> For example: &lt;ol&gt;&lt;/ol&gt; or &lt;div&gt;&lt;/div&gt;</small></em>
			</td>
		</tr>
		<tr>
			<td colspan='2'><label for="before_title">Before</label> / <label for="after_title">after each post </label>:</td>
			<td><input name="before_title" type="text" id="before_title" value="<?php echo htmlspecialchars(stripslashes(get_option('yarpp_before_title'))); ?>" size="10" /> / <input name="after_title" type="text" id="after_title" value="<?php echo htmlspecialchars(stripslashes(get_option('yarpp_after_title'))); ?>" size="10" /><em><small> For example: &lt;li&gt;&lt;/li&gt; or &lt;dl&gt;&lt;/dl&gt;</small></em>
			</td>
		</tr>
<?php checkbox('show_excerpt',"Show excerpt?","<tr>
			<td colspan='2'>",' onclick="javascript:excerpt()"'); ?>
<?php textbox('excerpt_length','Excerpt length (No. of words):',null,"<tr name='excerpted'>
			<td style='background-color: gray; width: .3px;'>&nbsp;</td><td>")?>

		<tr name="excerpted">
			<td style='background-color: gray; width: 3px;'>&nbsp;</td><td><label for="before_post">Before</label> / <label for="after_post">After</label> (Excerpt):</td>
			<td><input name="before_post" type="text" id="before_post" value="<?php echo htmlspecialchars(stripslashes(get_option('yarpp_before_post'))); ?>" size="10" /> / <input name="after_post" type="text" id="after_post" value="<?php echo htmlspecialchars(stripslashes(get_option('yarpp_after_post'))); ?>" size="10" /><em><small> For example: &lt;li&gt;&lt;/li&gt; or &lt;dl&gt;&lt;/dl&gt;</small></em>
			</td>
		</tr>

<?php textbox('no_results','Default display if no results:','40')?>
<?php checkbox('show_past_post',"Show password protected posts?"); ?>
<?php checkbox('past_only',"Show only previous posts?"); ?>
<?php checkbox('show_score',"Show admins (user level > 8) the match scores?"); ?>
	</table>
	</fieldset>

	<div class="submit"><input type="submit" name="update_yarpp" value="<?php _e('Save!', 'update_yarpp') ?>"  style="font-weight:bold;" /></div>
	
	</form>       
	
</div>
<script language="javascript">
	function excerpt() {
		if (!document.getElementsByName('show_excerpt')[0].checked) {
			document.getElementsByName('excerpted')[0].style.display = 'none';
			document.getElementsByName('excerpted')[1].style.display = 'none';
		} else {
			document.getElementsByName('excerpted')[0].style.display = 'table-row';
			document.getElementsByName('excerpted')[1].style.display = 'table-row';
		}
	}
	excerpt();
</script>

<?php

// End Related Posts Options

?>