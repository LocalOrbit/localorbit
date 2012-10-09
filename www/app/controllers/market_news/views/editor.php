<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Market News Editor','Edit Market News.');
lo3::require_permission();

?>

<h1>Market News Editor</h1>      
<a href="#!market_news-list" onclick="core.go(this.href);">View Market News</a>
