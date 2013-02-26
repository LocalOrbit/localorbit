<ul class="nav pull-right">
	<li class="divider-vertical"></li>
	<li><a onclick="$('#overlay,#popup3,#popup_closer').fadeIn(150);">Contact</a></li>
	<li class="divider-vertical"></li>
	<li><a style="color: #555;" href="/login.php" onclick="core.go(this.href);"><?=$core->i18n['nav1:login']?></a></li>
</ul>
<? core::replace('nav1top');?>
<li><a href="<?=$core->config['app_page']?>#!catalog-shop" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:shop']?></a></li>
<li><a href="#">News</a></li>
<li><a href="<?=$core->config['app_page']?>#!market-info" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:marketinfo']?></a></li>
<? core::replace('mainnav');?>