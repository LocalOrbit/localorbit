<a onclick="$('#overlay,#popup3,#popup_closer').fadeIn(150);">contact</a>&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;<a style="color: #555;" href="/login.php" onclick="core.go(this.href);"><?=$core->i18n['nav1:login']?></a>
<? core::replace('nav1top');?>
	<a href="<?=$core->config['app_page']?>#!market-info" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:marketinfo']?></a>
	<a href="<?=$core->config['app_page']?>#!sellers-oursellers" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:oursellers']?></a>
	<a href="<?=$core->config['app_page']?>#!catalog-shop" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:shop']?></a>
<? core::replace('nav1sub');?>