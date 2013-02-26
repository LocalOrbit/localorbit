<?
global $core;
		
if($core->session['user_id'] == 0)
{
	header('Location: http://'.$_SERVER['HTTP_HOST'].'/#!auth-form--returnto-http%3A%2F%2Flocalorbit.zendesk.com%2Flogin');
	exit();
	#lo2::redirect('authentication','login','?return_to=http%3A%2F%2Flocalorbit.zendesk.com%2Flogin');
	
}
$sso_url = $this->zendesk_work();
#header("Location: ".$sso_url);
exit($sso_url);
?>
