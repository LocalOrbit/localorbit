<?

echo('<h1>'.$core->i18n['note:catalog:closedheader'].'</h1> ');
if(trim($core->config['domain']['closed_note']) != '')
{
	echo($core->config['domain']['closed_note']);
}
else
{
	echo($core->i18n('note:catalog:closed', $core->config['domain']['name']));
}
echo('<br />&nbsp;<br /><br />&nbsp;<br />');
core::replace('center');
core::ensure_navstate(array('left'=>'left_blank'), 'catalog-shop');
core::process_command('navstate/left_scarecrow');
core::write_navstate();
core::deinit();
?>