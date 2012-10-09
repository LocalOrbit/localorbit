<?=$core->i18n['greeting']?> <?=$core->session['first_name']?>&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://localorbit.zendesk.com/forums" target="_blank">help</a>&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;<a href="<?=$core->config['app_page']?>#!auth-logout" onclick="core.go(this.href);"><?=$core->i18n['nav1:logout']?></a>
<? core::replace('nav1top');?>
	<a href="<?=$core->config['app_page']?>#!dashboard-home" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:dashboard']?></a>
	<a href="<?=$core->config['app_page']?>#!market-info" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:marketinfo']?></a>
	<a href="<?=$core->config['app_page']?>#!sellers-oursellers" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:oursellers']?></a>
	<a href="<?=$core->config['app_page']?>#!catalog-shop" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:shop']?></a>
<? core::replace('nav1sub');?>