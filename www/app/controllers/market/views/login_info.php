

<?if(trim($core->config['domain']['market_profile']) != ''){?>
	<h3>Market Info</h3>
	<?=$core->config['domain']['market_profile']?>
	<br />&nbsp;<br />
<?
}
core::replace('market_profile');
?>
<?if(trim($core->config['domain']['market_policies']) != ''){?>
	<h3>Market Policies</h3>
	<?=$core->config['domain']['market_policies']?>
	<br />&nbsp;<br />
<?
}
core::replace('market_policies');

core::replace('market_title',$core->config['domain']['detailed_name']);

core::js("core.loginFailedMsg='".addslashes($core->i18n['error:customer:login_fail'])."';");
core::js("core.accountSuspendedMsg='".addslashes($core->i18n['error:customer:account_suspended'])."';");

if($core->config['domain']['domain_id'] > 1)
{
	core::js("$('#requestAccountLink').show();");
}

	if ($core->config['domain']['social_option_id'] == 1 && !empty($core->config['domain']['facebook'])) {
		//echo $seller['facebook'] ;
		//core::js('$("#facebook").attr("src", "//www.facebook.com/' . $seller['facebook'] . '").fadeIn();');
	} else if ($core->config['domain']['social_option_id'] == 2 && !empty($core->config['domain']['twitter'])) {
		core::js('var tweets = new jqTweet("'.$core->config['domain']['twitter'].'", "#tweets div.twitter-feed", 10);			
		tweets.loadTweets(function() { $("#tweets").fadeIn();  console.log("tweets loaded");
			$("#tweets div.twitter-header").append(\'<iframe allowtransparency="true" frameborder="0" scrolling="no" src="//platform.twitter.com/widgets/follow_button.html?show_screen_name=false&show_count=false&screen_name='.$core->config['domain']['twitter'].'" style="width:60px; height:20px;"></iframe>\');
		});');
	}
?>