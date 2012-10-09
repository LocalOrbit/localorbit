

<?if(trim($core->config['domain']['market_profile']) != ''){?>
	<h3>Market Info</h3>
	<?=$core->config['domain']['market_profile']?>
	<br />&nbsp;<br />
<?
}
core::replace('market_profile');
?>
<?if(trim($core->config['domain']['market_policies']) != ''){?>
	<h3>Market Info</h3>
	<?=$core->config['domain']['market_policies']?>
	<br />&nbsp;<br />
<?
}
core::replace('market_policies');

core::replace('market_title',$core->config['domain']['detailed_name']);

core::js("core.loginFailedMsg='".addslashes($core->i18n['error:customer:login_fail'])."';");
core::js("core.accountSuspendedMsg='".addslashes($core->i18n['error:customer:account_suspended'])."';");

?>