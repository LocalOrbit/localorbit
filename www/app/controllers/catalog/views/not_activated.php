<?
core::ensure_navstate(array('left'=>'left_blank')); 
?>
<h1>Uh-oh! Wait a sec...</h1>

Hi, <?=$core->session['first_name']?> <?=$core->session['last_name']?>! 

<br />&nbsp;<br />
You've confirmed your email account, but the market manager must approve your account before you can shop. We'll let you know as soon as that happens!
<br />&nbsp;<br />
<?
#core::replace('center');
#core::deinit();
?>