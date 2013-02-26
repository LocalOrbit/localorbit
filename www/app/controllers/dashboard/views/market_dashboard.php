<?
core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
/*
echo('<h1>home domain is: '.$core->session['home_domain_id'].'</h1>Domain ids: ');
echo('<pre>');
echo(print_r($core->session['domains_by_orgtype_id'],true));
echo('</pre><br />');
echo('<pre>');
echo(print_r($core->session['all_domains'],true));
echo('</pre><br />');
*/
$this->market_orders();
echo('<hr>');
$this->market_products();
?>