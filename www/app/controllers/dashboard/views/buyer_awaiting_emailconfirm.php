<?
core_ui::fullWidth();
?>

<div class="alert alert-block">
	<h1>Welcome, <?=$core->session['first_name']?> <?=$core->session['last_name']?></h1>
	<p>You'll need to verify your email address before you can buy or sell through <?=$core->session['hub_name']?>.</p>
	<p>We sent an email to: <?=$core->session['email']?>.</p>
	<p>If you don't see it, check your spam folder or email <a href="mailto:service@localorb.it">service@localorb.it</a>.</p>
</div>