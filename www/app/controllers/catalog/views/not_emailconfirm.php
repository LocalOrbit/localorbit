<?
core::ensure_navstate(array('left'=>'left_blank')); 
?>
<h1>Uh-oh! Wait a sec...</h1>

Hi, <?=$core->session['first_name']?> <?=$core->session['last_name']?>! You must first verify your email address before using the service.

<br />&nbsp;<br />
We sent you an email to: <?=$core->session['email']?>
<br />&nbsp;<br />
Did you not receive this email? You may want to check your spam folder to see if it landed there. 
<br />&nbsp;<br />