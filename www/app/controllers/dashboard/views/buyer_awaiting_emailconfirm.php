<?
core::ensure_navstate(array('left'=>'left_dashboard'));
?>
<h1>Welcome, <?=$core->session['first_name']?> <?=$core->session['last_name']?></h1>

You'll need to verify your email address before you can buy or sell through <?=$core->session['hub_name']?>.
<br />&nbsp;<br />
We sent you an email to: <?=$core->session['email']?>
<br />&nbsp;<br />
If you don't see it, check your spam folder or email service@localorb.it 
<br />&nbsp;<br />