<?
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

$old_drafts = new core_collection('select * from newsletter_content where is_draft = 1 and (TIMESTAMPDIFF(DAY,created_date,now()) >= 1 or created_date = 0)');
$old_drafts->__model = core::model('newsletter_content');

foreach ($old_drafts as $draft) {
	$cont_id = $draft['cont_id'];
	$filepath = $core->paths['base'].'/../img/newsletters/'.$cont_id.'.' ;
	if(file_exists($filepath.'png'))
		unlink($filepath.'png');
	if(file_exists($filepath.'jpg'))
		unlink($filepath.'jpg');
	if(file_exists($filepath.'gif'))
		unlink($filepath.'gif');
	$draft->delete();
}
?>