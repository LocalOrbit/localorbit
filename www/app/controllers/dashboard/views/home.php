<h1>Welcome to Local Orbit: <?=$core->i18n['hello']?></h1>
<pre>
<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
#echo(dirname(__FILE__).'<br />');
#print_r($core->config);
?>
</pre>

<hr />

<?php

echo(core_ui::map('mymap','400px','400px',8));
core_ui::map_center('mymap','100 main st, ann arbor, mi');
core_ui::map_add_point('mymap',42.284866,-83.748418,'this is a test point 1');
core_ui::map_add_point('mymap','6902 Kingsley Circle, Dexter, MI 48130','this is a test point 2');

#
?>