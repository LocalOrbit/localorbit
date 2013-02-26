<?php
/*
+----------------------------------------------------------------+
|																							|
|	WordPress 2.7 Plugin: WP-EMail 2.40										|
|	Copyright (c) 2008 Lester "GaMerZ" Chan									|
|																							|
|	File Written By:																	|
|	- Lester "GaMerZ" Chan															|
|	- http://lesterchan.net															|
|																							|
|	File Information:																	|
|	- Configure E-Mail Options														|
|	- wp-content/plugins/wp-email/email-options.php						|
|																							|
+----------------------------------------------------------------+
*/


### Check Whether User Can Manage EMail
if(!current_user_can('manage_email')) {
	die('Access Denied');
}


### E-Mail Variables
$base_name = plugin_basename('wp-email/email-options.php');
$base_page = 'admin.php?page='.$base_name;


### If Form Is Submitted
if($_POST['Submit']) {
	$email_smtp_name = strip_tags(trim($_POST['email_smtp_name']));
	$email_smtp_password = strip_tags(trim($_POST['email_smtp_password']));
	$email_smtp_server = strip_tags(trim($_POST['email_smtp_server']));
	$email_smtp = array('username' => $email_smtp_name, 'password' => $email_smtp_password, 'server' => $email_smtp_server);
	$email_options = array();
	$email_options['post_text'] = addslashes(trim($_POST['email_post_text']));
	$email_options['page_text'] = addslashes(trim($_POST['email_page_text']));
	$email_options['email_icon'] = trim($_POST['email_icon']);
	$email_options['email_type'] = intval($_POST['email_type']);
	$email_options['email_style'] = intval($_POST['email_style']);
	$email_options['email_html'] = trim($_POST['email_html']);
	$email_fields = array();
	$email_fields['yourname'] = intval($_POST['email_field_yourname']);
	$email_fields['youremail'] = intval($_POST['email_field_youremail']);
	$email_fields['yourremarks'] = intval($_POST['email_field_yourremarks']);
	$email_fields['friendname'] = intval($_POST['email_field_friendname']);
	$email_fields['friendemail'] = intval($_POST['email_field_friendemail']);
	$email_contenttype = strip_tags(trim($_POST['email_contenttype']));
	$email_mailer = strip_tags(trim($_POST['email_mailer']));
	$email_snippet = intval(trim($_POST['email_snippet']));
	$email_interval = intval(trim($_POST['email_interval']));
	$email_multiple = intval(trim($_POST['email_multiple']));
	$email_imageverify = intval(trim($_POST['email_imageverify']));
	$email_template_title = trim($_POST['email_template_title']);
	$email_template_subtitle = trim($_POST['email_template_subtitle']);
	$email_template_subject = strip_tags(trim($_POST['email_template_subject']));
	$email_template_body = trim($_POST['email_template_body']);
	$email_template_bodyalt = trim($_POST['email_template_bodyalt']);
	$email_template_sentsuccess = trim($_POST['email_template_sentsuccess']);
	$email_template_sentfailed = trim($_POST['email_template_sentfailed']);
	$email_template_error = trim($_POST['email_template_error']);
	$update_email_queries = array();
	$update_email_text = array();
	$update_email_queries[] = update_option('email_smtp', $email_smtp);
	$update_email_queries[] = update_option('email_options', $email_options);
	$update_email_queries[] = update_option('email_fields', $email_fields);
	$update_email_queries[] = update_option('email_contenttype', $email_contenttype);
	$update_email_queries[] = update_option('email_mailer', $email_mailer);
	$update_email_queries[] = update_option('email_snippet', $email_snippet);
	$update_email_queries[] = update_option('email_interval', $email_interval);
	$update_email_queries[] = update_option('email_multiple', $email_multiple);
	$update_email_queries[] = update_option('email_imageverify', $email_imageverify);
	$update_email_queries[] = update_option('email_template_title', $email_template_title);
	$update_email_queries[] = update_option('email_template_subtitle', $email_template_subtitle);
	$update_email_queries[] = update_option('email_template_subject', $email_template_subject);
	$update_email_queries[] = update_option('email_template_body', $email_template_body);
	$update_email_queries[] = update_option('email_template_bodyalt', $email_template_bodyalt);
	$update_email_queries[] = update_option('email_template_sentsuccess', $email_template_sentsuccess);
	$update_email_queries[] = update_option('email_template_sentfailed', $email_template_sentfailed);
	$update_email_queries[] = update_option('email_template_error', $email_template_error);
	$update_email_text[] = __('SMTP Information', 'wp-email');
	$update_email_text[] = __('E-Mail Style', 'wp-email');
	$update_email_text[] = __('E-Mail Fields', 'wp-email');
	$update_email_text[] = __('E-Mail Content Type', 'wp-email');
	$update_email_text[] = __('Send E-Mail Method', 'wp-email');
	$update_email_text[] = __('Snippet Option', 'wp-email');
	$update_email_text[] = __('Interval Option', 'wp-email');
	$update_email_text[] = __('Multiple E-Mails Option', 'wp-email');
	$update_email_text[] = __('Image Verification Option', 'wp-email');
	$update_email_text[] = __('Page Title Template', 'wp-email');
	$update_email_text[] = __('Page Subtitle Template', 'wp-email');
	$update_email_text[] = __('Subject Template', 'wp-email');
	$update_email_text[] = __('Body Template', 'wp-email');
	$update_email_text[] = __('Alternate Body Template', 'wp-email');
	$update_email_text[] = __('Sent Success Template', 'wp-email');
	$update_email_text[] = __('Sent Failed Template', 'wp-email');
	$update_email_text[] = __('Error Template', 'wp-email');
	$i=0;
	$text = '';
	foreach($update_email_queries as $update_email_query) {
		if($update_email_query) {
			$text .= '<font color="green">'.$update_email_text[$i].' '.__('Updated', 'wp-email').'</font><br />';
		}
		$i++;
	}
	if(empty($text)) {
		$text = '<font color="red">'.__('No E-Mail Option Updated', 'wp-email').'</font>';
	}
}
$email_options = get_option('email_options');
$email_fields = get_option('email_fields');
$emai_smtp = get_option('email_smtp');
?>
<script type="text/javascript">
/* <![CDATA[*/
	function email_default_templates(template) {
		var default_template;
		switch(template) {
			case "title":
				default_template = "<?php _e('E-Mail \'%EMAIL_POST_TITLE%\' To A Friend', 'wp-email'); ?>";
				break;
			case "subtitle":
				default_template = "<p style=\"text-align: center;\"><?php _e('Email a copy of <strong>\'%EMAIL_POST_TITLE%\'</strong> to a friend', 'wp-email'); ?></p>";
				break;
			case "subject":
				default_template = "<?php _e('Recommended Article By %EMAIL_YOUR_NAME%: %EMAIL_POST_TITLE%', 'wp-email'); ?>";
				break;
			case "body":
				default_template = "<?php _e('<p>Hi <strong>%EMAIL_FRIEND_NAME%</strong>,<br />Your friend, <strong>%EMAIL_YOUR_NAME%</strong>, has recommended this article entitled \'<strong>%EMAIL_POST_TITLE%</strong>\' to you.</p><p><strong>Here is his/her remarks:</strong><br />%EMAIL_YOUR_REMARKS%</p><p><strong>%EMAIL_POST_TITLE%</strong><br />Posted By %EMAIL_POST_AUTHOR% On %EMAIL_POST_DATE% In %EMAIL_POST_CATEGORY%</p>%EMAIL_POST_CONTENT%<p>Article taken from %EMAIL_BLOG_NAME% - <a href=\"%EMAIL_BLOG_URL%\">%EMAIL_BLOG_URL%</a><br />URL to article: <a href=\"%EMAIL_PERMALINK%\">%EMAIL_PERMALINK%</a></p>', 'wp-email'); ?>";
				break;
			case "bodyalt":
				default_template = "<?php _e('Hi %EMAIL_FRIEND_NAME%,\nYour friend, %EMAIL_YOUR_NAME%, has recommended this article entitled \'%EMAIL_POST_TITLE%\' to you.\n\nHere is his/her remark:\n%EMAIL_YOUR_REMARKS%\n\n%EMAIL_POST_TITLE%\nPosted By %EMAIL_POST_AUTHOR% On %EMAIL_POST_DATE% In %EMAIL_POST_CATEGORY%\n%EMAIL_POST_CONTENT%\nArticle taken from %EMAIL_BLOG_NAME% - %EMAIL_BLOG_URL%\nURL to article: %EMAIL_PERMALINK%', 'wp-email'); ?>";
				break;
			case "sentsuccess":
				default_template = "<p><?php _e('Article: <strong>%EMAIL_POST_TITLE%</strong> has been sent to <strong>%EMAIL_FRIEND_NAME% (%EMAIL_FRIEND_EMAIL%)</strong>', 'wp-email'); ?></p><p>&laquo; <a href=\"%EMAIL_PERMALINK%\"><?php _e('Back to %EMAIL_POST_TITLE%', 'wp-email'); ?></a></p>";
				break;
			case "sentfailed":
				default_template = "<p><?php _e('An error has occurred when trying to send this email: ', 'wp-email'); ?><br /><strong>&raquo;</strong> %EMAIL_ERROR_MSG%</p>";
				break;
			case "error":
				default_template = "<p><?php _e('An error has occurred: ', 'wp-email'); ?><br /><strong>&raquo;</strong> %EMAIL_ERROR_MSG%</p>";
				break;
			case "html":
				default_template = '<a href="%EMAIL_URL%" rel="nofollow" title="%EMAIL_TEXT%">%EMAIL_TEXT%</a>';
				break;
		}
		document.getElementById("email_template_" + template).value = default_template;
	}
	function check_email_style() {
		email_style_options = document.getElementById("email_style").value;
		if (email_style_options == 4) {
				document.getElementById("email_style_custom").style.display = 'block';
		} else {
			if(document.getElementById("email_style_custom").style.display == 'block') {
				document.getElementById("email_style_custom").style.display = 'none';
			}
		}
	}
/* ]]> */
</script>
<?php if(!empty($text)) { echo '<!-- Last Action --><div id="message" class="updated fade"><p>'.$text.'</p></div>'; } ?>
<form method="post" action="<?php echo $_SERVER['REQUEST_URI']; ?>"> 
<div class="wrap">
	<div id="icon-wp-email" class="icon32"><br /></div>
	<h2><?php _e('E-Mail Options', 'wp-email'); ?></h2>	
	<h3><?php _e('SMTP Settings', 'wp-email'); ?></h3>
	<table class="form-table">
		 <tr>
			<th width="20%"><?php _e('SMTP Username:', 'wp-email'); ?></th>
			<td><input type="text" name="email_smtp_name" value="<?php echo $emai_smtp['username']; ?>" size="30" dir="ltr" /></td>
		</tr>
		<tr>
			<th width="20%"><?php _e('SMTP Password:', 'wp-email'); ?></th>
			<td><input type="password" name="email_smtp_password" value="<?php echo $emai_smtp['password']; ?>" size="30" dir="ltr" /></td>
		</tr>
		<tr>
			<th width="20%"><?php _e('SMTP Server:', 'wp-email'); ?></th>
			<td><input type="text" name="email_smtp_server" value="<?php echo $emai_smtp['server']; ?>" size="30" dir="ltr" /><br /><?php _e('You may leave the above fields blank if you do not use a SMTP server.', 'wp-email'); ?></td>
		</tr>
	</table>
	<h3><?php _e('E-Mail Styles', 'wp-email'); ?></h3>
	<table class="form-table">
		<tr>
			<th scope="row" valign="top"><?php _e('E-Mail Text Link For Post', 'wp-email'); ?></th>
			<td>
				<input type="text" name="email_post_text" value="<?php echo stripslashes($email_options['post_text']); ?>" size="30" />
			</td>
		</tr>
		<tr>
			<th scope="row" valign="top"><?php _e('E-Mail Text Link For Page', 'wp-email'); ?></th>
			<td>
				<input type="text" name="email_page_text" value="<?php echo stripslashes($email_options['page_text']); ?>" size="30" />
			</td>
		</tr>
		<tr>
			<th scope="row" valign="top"><?php _e('E-Mail Icon', 'wp-email'); ?></th>
			<td>
				<?php
					$email_icon = $email_options['email_icon'];
					$email_icon_url = plugins_url('wp-email/images');
					$email_icon_path = WP_PLUGIN_DIR.'/wp-email/images';
					if($handle = @opendir($email_icon_path)) {     
						while (false !== ($filename = readdir($handle))) {  
							if ($filename != '.' && $filename != '..' && $filename != 'loading.gif') {
								if(is_file($email_icon_path.'/'.$filename)) {
									echo '<p>';
									if($email_icon == $filename) {
										echo '<input type="radio" name="email_icon" value="'.$filename.'" checked="checked" />'."\n";										
									} else {
										echo '<input type="radio" name="email_icon" value="'.$filename.'" />'."\n";
									}
									echo '&nbsp;&nbsp;&nbsp;';
									echo '<img src="'.$email_icon_url.'/'.$filename.'" alt="'.$filename.'" />'."\n";
									echo '&nbsp;&nbsp;&nbsp;('.$filename.')';
									echo '</p>'."\n";
								}
							} 
						} 
						closedir($handle);
					}
				?>
			</td>
		</tr>
		<tr>
			<th scope="row" valign="top"><?php _e('E-Mail Link Type', 'wp-email'); ?></th>
			<td>
				<select name="email_type" size="1">
					<option value="1"<?php selected('1', $email_options['email_type']); ?>><?php _e('E-Mail Standalone Page', 'wp-email'); ?></option>
					<option value="2"<?php selected('2', $email_options['email_type']); ?>><?php _e('E-Mail Popup', 'wp-email'); ?></option>
				</select>
			</td>
		</tr>
		<tr>
			<th scope="row" valign="top"><?php _e('E-Mail Text Link Style', 'wp-email'); ?></th>
			<td>
				<select name="email_style" id="email_style" size="1" onchange="check_email_style();">
					<option value="1"<?php selected('1', $email_options['email_style']); ?>><?php _e('E-Mail Icon With Text Link', 'wp-email'); ?></option>
					<option value="2"<?php selected('2', $email_options['email_style']); ?>><?php _e('E-Mail Icon Only', 'wp-email'); ?></option>
					<option value="3"<?php selected('3', $email_options['email_style']); ?>><?php _e('E-Mail Text Link Only', 'wp-email'); ?></option>
					<option value="4"<?php selected('4', $email_options['email_style']); ?>><?php _e('Custom', 'wp-email'); ?></option>
				</select>
				<div id="email_style_custom" style="display: <?php if(intval($email_options['email_style']) == 4) { echo 'block'; } else { echo 'none'; } ?>; margin-top: 20px;">
					<textarea rows="2" cols="80" name="email_html" id="email_template_html"><?php echo htmlspecialchars(stripslashes($email_options['email_html'])); ?></textarea><br />
					<?php _e('HTML is allowed.', 'wp-email'); ?><br />
					%EMAIL_URL% - <?php _e('URL to the email post/page.', 'wp-email'); ?><br />
					%EMAIL_POPUP% - <?php _e('It will produce the onclick html code which is nescassary for popup.', 'wp-email'); ?><br />
					<?php _e('Example Popup Template:', 'wp-email'); ?><br />
					<span dir="ltr"><?php echo htmlspecialchars('<a href="%EMAIL_URL%" %EMAIL_POPUP% rel="nofollow" title="%EMAIL_TEXT%">%EMAIL_TEXT%</a>'); ?></span><br />
					%EMAIL_TEXT% - <?php _e('E-Mail text link of the post/page that you have typed in above.', 'wp-email'); ?><br />
					%EMAIL_ICON_URL% - <?php _e('URL to the email icon you have chosen above.', 'wp-email'); ?><br />
					<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('html');" class="button" />
				</div>
			</td>
		</tr>
	</table>
	<h3><?php _e('E-Mail Settings', 'wp-email'); ?></h3>
	<table class="form-table">
		<tr>
			<th scope="row" valign="top"><?php _e('E-Mail Fields:', 'wp-email'); ?></th>
			 <td>
				<input type="checkbox" name="email_field_yourname" value="1"<?php checked('1', $email_fields['yourname']); ?> />&nbsp;<?php _e('Your Name', 'wp-email'); ?><br />
				<input type="checkbox" name="email_field_youremail" value="1"<?php checked('1', $email_fields['youremail']); ?> />&nbsp;<?php _e('Your E-Mail', 'wp-email'); ?><br />
				<input type="checkbox" name="email_field_yourremarks" value="1"<?php checked('1', $email_fields['yourremarks']); ?> />&nbsp;<?php _e('Your Remarks', 'wp-email'); ?><br />
				<input type="checkbox" name="email_field_friendname" value="1"<?php checked('1', $email_fields['friendname']); ?> />&nbsp;<?php _e('Friend\'s Name', 'wp-email'); ?><br />
				<input type="checkbox" name="email_field_friendemail" value="1" checked="checked" disabled="disabled" />&nbsp;<?php _e('Friend\'s E-Mail', 'wp-email'); ?>
			</td>
		</tr>
		 <tr>
			<th scope="row" valign="top"><?php _e('E-Mail Content Type:', 'wp-email'); ?></th>
			 <td>
				<select name="email_contenttype" size="1">
					<option value="text/plain"<?php selected('text/plain', get_option('email_contenttype')); ?>><?php _e('Plain Text', 'wp-email'); ?></option>
					<option value="text/html"<?php selected('text/html', get_option('email_contenttype')); ?>><?php _e('HTML', 'wp-email'); ?></option>
				</select>
			</td>
		</tr>
		<tr> 
			<th scope="row" valign="top"><?php _e('Method Used To Send E-Mail:', 'wp-email'); ?></th>
			<td>
				<select name="email_mailer" size="1">
					<option value="mail"<?php selected('mail', get_option('email_mailer')); ?>><?php _e('PHP', 'wp-email'); ?></option>
					<option value="sendmail"<?php selected('sendmail', get_option('email_mailer')); ?>><?php _e('SendMail', 'wp-email'); ?></option>
					<option value="smtp"<?php selected('smtp', get_option('email_mailer')); ?>><?php _e('SMTP', 'wp-email'); ?></option>
				</select>
				<br /><?php _e('If you ARE NOT using a smtp server of if there is a problem sending out email using your smtp server. Please Choose PHP or Send Mail.', 'wp-email'); ?>
			</td> 
		</tr>
		<tr> 
			<th scope="row" valign="top"><?php _e('No. Of Words Before Cutting Off:', 'wp-email'); ?></th>
			<td><input type="text" id="email_snippet" name="email_snippet" value="<?php echo  get_option('email_snippet'); ?>" size="5" maxlength="5" /><br /><?php _e('Setting this value more than 0 will enable the snippet feature. This feature will allow you to send a portion (defined by the text field above) of the article to your friend instead of the whole article.', 'wp-email'); ?></td> 
		</tr>
		<tr> 
			<th scope="row" valign="top"><?php _e('Interval Between E-Mails:', 'wp-email'); ?></th>
			<td><input type="text" id="email_interval" name="email_interval" value="<?php echo  get_option('email_interval'); ?>" size="5" maxlength="5" /> <?php _e('Mins', 'wp-email'); ?><br /><?php _e('It allows you to specify the interval in minutes between each email sent per user based on IP to prevent spam and flood.', 'wp-email'); ?></td> 
		</tr>
		<tr> 
				<th scope="row" valign="top"><?php _e('Max Number Of Multiple E-Mails:', 'wp-email'); ?></th>
				<td><input type="text" id="email_multiple" name="email_multiple" value="<?php echo  get_option('email_multiple'); ?>" size="5" maxlength="3" /><br /><?php _e('Setting this value more than 1 will enable this feature. It allows the maximum number of multiple e-mails that can be send at one go.', 'wp-email'); ?></td> 
		</tr> 
		<tr> 
			<th scope="row" valign="top"><?php _e('Enable Image Verification:', 'wp-email'); ?></th>
			<td>
				<select name="email_imageverify" size="1">
					<option value="1"<?php selected('1', get_option('email_imageverify')); ?>><?php _e('Yes', 'wp-email'); ?></option>
					<option value="0"<?php selected('0', get_option('email_imageverify')); ?>><?php _e('No', 'wp-email'); ?></option>
				</select><br /><?php _e('It is recommanded to choose <strong>Yes</strong> unless your server does not support PHP GD Library.', 'wp-email'); ?>
			</td> 
		</tr>
	</table>

	<h3><?php _e('Template Variables', 'wp-email'); ?></h3>
	<table class="widefat">
		<tr>
			<td><strong>%EMAIL_YOUR_NAME%</strong> - <?php _e('Display the sender\'s name', 'wp-email'); ?></td>
			<td><strong>%EMAIL_POST_TITLE%</strong> - <?php _e('Display the post\'s title', 'wp-email'); ?></td>
		</tr>
		<tr class="alternate">
			<td><strong>%EMAIL_YOUR_EMAIL%</strong> - <?php _e('Display the sender\'s email', 'wp-email'); ?></td>
			<td><strong>%EMAIL_POST_AUTHOR%</strong> - <?php _e('Display the post\'s author', 'wp-email'); ?></td>
		</tr>
		<tr>
			<td><strong>%EMAIL_YOUR_REMARKS%</strong> - <?php _e('Display the sender\'s remarks', 'wp-email'); ?></td>
			<td><strong>%EMAIL_POST_DATE%</strong> - <?php _e('Display the post\'s date', 'wp-email'); ?></td>
		</tr>
		<tr class="alternate">
			<td><strong>%EMAIL_FRIEND_NAME%</strong> - <?php _e('Display the friend\'s name', 'wp-email'); ?></td>
			<td><strong>%EMAIL_POST_CATEGORY%</strong> - <?php _e('Display the post\'s category', 'wp-email'); ?></td>
		</tr>
		<tr>
			<td><strong>%EMAIL_FRIEND_EMAIL%</strong> - <?php _e('Display the friend\'s email', 'wp-email'); ?></td>
			<td><strong>%EMAIL_POST_EXCERPT%</strong> - <?php _e('Display the post\'s excerpt', 'wp-email'); ?></td>
		</tr>
		<tr class="alternate">
			<td><strong>%EMAIL_ERROR_MSG%</strong> - <?php _e('Display the error message', 'wp-email'); ?></td>
			<td><strong>%EMAIL_POST_CONTENT%</strong> - <?php _e('Display the post\'s content', 'wp-email'); ?></td>
		</tr>
		<tr>
			<td><strong>%EMAIL_BLOG_NAME%</strong> - <?php _e('Display the blog\'s name', 'wp-email'); ?></td>
			<td><strong>%EMAIL_PERMALINK%</strong> - <?php _e('Display the permalink of the post', 'wp-email'); ?></td>
		</tr>
		<tr class="alternate">
			<td><strong>%EMAIL_BLOG_URL%</strong> - <?php _e('Display the blog\'s url', 'wp-email'); ?></td>
			<td>&nbsp;</td>
		</tr>
	</table>

	<h3><?php _e('E-Mail Page Templates', 'wp-email'); ?></h3>
	<table class="form-table">
		 <tr>
			<td width="30%">
				<strong><?php _e('E-Mail Page Title:', 'wp-email'); ?></strong><br /><br />
				<?php _e('Allowed Variables:', 'wp-email'); ?><br />
				<p style="margin: 2px 0;">- %EMAIL_POST_TITLE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_AUTHOR%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_DATE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_CATEGORY%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_URL%</p>
				<p style="margin: 2px 0;">- %EMAIL_PERMALINK%</p><br />
				<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('title');" class="button" />
			</td>
			<td><input type="text" id="email_template_title" name="email_template_title" value="<?php echo htmlspecialchars(stripslashes(get_option('email_template_title'))); ?>" size="82" /></td>
		</tr>
		<tr> 
			<td width="30%">
				<strong><?php _e('E-Mail Page Subtitle:', 'wp-email'); ?></strong><br /><br />
				<?php _e('Allowed Variables:', 'wp-email'); ?><br />
				<p style="margin: 2px 0;">- %EMAIL_POST_TITLE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_AUTHOR%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_DATE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_CATEGORY%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_URL%</p>
				<p style="margin: 2px 0;">- %EMAIL_PERMALINK%</p><br />
				<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('subtitle');" class="button" />
			</td>
			<td><input type="text" id="email_template_subtitle" name="email_template_subtitle" value="<?php echo htmlspecialchars(stripslashes(get_option('email_template_subtitle'))); ?>" size="82" /></td> 
		</tr>
	</table>

	<h3><?php _e('E-Mail Templates', 'wp-email'); ?></h3>
	<table class="form-table">
		 <tr>
			<td width="30%">
				<strong><?php _e('E-Mail Subject:', 'wp-email'); ?></strong><br /><br />
				<?php _e('Allowed Variables:', 'wp-email'); ?><br />
				<p style="margin: 2px 0;">- %EMAIL_YOUR_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_YOUR_EMAIL%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_TITLE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_AUTHOR%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_DATE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_CATEGORY%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_URL%</p>
				<p style="margin: 2px 0;">- %EMAIL_PERMALINK%</p><br />
				<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('subject');" class="button" />
			</td>
			<td><input type="text" id="email_template_subject" name="email_template_subject" value="<?php echo htmlspecialchars(stripslashes(get_option('email_template_subject'))); ?>" size="82" /></td>
		</tr>
		<tr> 
			<td width="30%">
				<strong><?php _e('E-Mail Body:', 'wp-email'); ?></strong><br /><br />
				<?php _e('Allowed Variables:', 'wp-email'); ?><br />
				<p style="margin: 2px 0;">- %EMAIL_YOUR_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_YOUR_EMAIL%</p>
				<p style="margin: 2px 0;">- %EMAIL_YOUR_REMARKS%</p>
				<p style="margin: 2px 0;">- %EMAIL_FRIEND_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_FRIEND_EMAIL%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_TITLE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_AUTHOR%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_DATE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_CATEGORY%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_EXCERPT%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_CONTENT%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_URL%</p>
				<p style="margin: 2px 0;">- %EMAIL_PERMALINK%</p><br />
				<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('body');" class="button" />
			</td>
			<td><textarea cols="80" rows="15" id="email_template_body" name="email_template_body"><?php echo htmlspecialchars(stripslashes(get_option('email_template_body'))); ?></textarea></td> 
		</tr>
		<tr> 
			<td width="30%">
				<strong><?php _e('E-Mail Alternate Body:', 'wp-email'); ?></strong><br /><br />
				<?php _e('Allowed Variables:', 'wp-email'); ?><br />
				<p style="margin: 2px 0;">- %EMAIL_YOUR_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_YOUR_EMAIL%</p>
				<p style="margin: 2px 0;">- %EMAIL_YOUR_REMARKS%</p>
				<p style="margin: 2px 0;">- %EMAIL_FRIEND_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_FRIEND_EMAIL%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_TITLE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_AUTHOR%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_DATE%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_CATEGORY%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_EXCERPT%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_CONTENT%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_URL%</p>
				<p style="margin: 2px 0;">- %EMAIL_PERMALINK%</p><br />
				<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('bodyalt');" class="button" />
			</td>
			<td><textarea cols="80" rows="15" id="email_template_bodyalt" name="email_template_bodyalt"><?php echo htmlspecialchars(stripslashes(get_option('email_template_bodyalt'))); ?></textarea></td> 
		</tr>
	</table>

	<h3><?php _e('After Sending E-Mail Templates', 'wp-email'); ?></h3>
	<table class="form-table">
		 <tr>
			<td width="30%">
				<strong><?php _e('Sent Successfully:', 'wp-email'); ?></strong><br /><br />
				<?php _e('Allowed Variables:', 'wp-email'); ?><br />
				<p style="margin: 2px 0;">- %EMAIL_FRIEND_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_FRIEND_EMAIL%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_TITLE%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_URL%</p>
				<p style="margin: 2px 0;">- %EMAIL_PERMALINK%</p><br />
				<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('sentsuccess');" class="button" />
			</td>
			<td><textarea cols="80" rows="10" id="email_template_sentsuccess" name="email_template_sentsuccess"><?php echo htmlspecialchars(stripslashes(get_option('email_template_sentsuccess'))); ?></textarea></td>
		</tr>
		<tr> 
			<td width="30%">
				<strong><?php _e('Sent Failed:', 'wp-email'); ?></strong><br /><br />
				<?php _e('Allowed Variables:', 'wp-email'); ?><br />
				<p style="margin: 2px 0;">- %EMAIL_FRIEND_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_FRIEND_EMAIL%</p>
				<p style="margin: 2px 0;">- %EMAIL_ERROR_MSG%</p>
				<p style="margin: 2px 0;">- %EMAIL_POST_TITLE%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_URL%</p>
				<p style="margin: 2px 0;">- %EMAIL_PERMALINK%</p><br />
				<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('sentfailed');" class="button" />
			</td>
			<td><textarea cols="80" rows="10" id="email_template_sentfailed" name="email_template_sentfailed"><?php echo htmlspecialchars(stripslashes(get_option('email_template_sentfailed'))); ?></textarea></td> 
		</tr>
	</table>
	<h3><?php _e('E-Mail Misc Templates', 'wp-email'); ?></h3>
	<table class="form-table">
		 <tr>
			<td width="30%">
				<strong><?php _e('E-Mail Error:', 'wp-email'); ?></strong><br /><br />
				<?php _e('Allowed Variables:', 'wp-email'); ?>
				<p style="margin: 2px 0;">- %EMAIL_ERROR_MSG%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_NAME%</p>
				<p style="margin: 2px 0;">- %EMAIL_BLOG_URL%</p>
				<p style="margin: 2px 0;">- %EMAIL_PERMALINK%</p><br />
				<input type="button" name="RestoreDefault" value="<?php _e('Restore Default Template', 'wp-email'); ?>" onclick="email_default_templates('error');" class="button" />
			</td>
			<td><textarea cols="80" rows="10" id="email_template_error" name="email_template_error"><?php echo htmlspecialchars(stripslashes(get_option('email_template_error'))); ?></textarea></td>
		</tr>
	</table>
	<p class="submit">
		<input type="submit" name="Submit" class="button" value="<?php _e('Save Changes', 'wp-email'); ?>" />
	</p>
</div>
</form>