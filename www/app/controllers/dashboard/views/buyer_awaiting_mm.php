<?
core_ui::fullWidth();
?>

<div class="alert alert-block">
	<h1>Uh-oh! Wait a sec...</h1>
	<p>Hi, <?=$core->session['first_name']?> <?=$core->session['last_name']?>!</p>
	<p>You've confirmed your email account, but the market manager must approve your account before you can shop. We'll let you know as soon as that happens!</p>
</div>
