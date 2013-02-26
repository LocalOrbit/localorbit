<!--
<ul class="nav pull-right">
	<li><a onclick="$('#overlay,#popup3,#popup_closer').fadeIn(150);">Contact</a></li>
	<li class="divider-vertical"></li>
	<li><a href="/login.php">Log In</a></li>
</ul>
-->
<? core::replace('nav1top');?>
&nbsp;
<? core::replace('nav1sub');?>
<h1>
	<i class="icon-home"/> <?=$core->config['domain']['name']?>
	
</h1>
<? core::replace('mainnav');?>
