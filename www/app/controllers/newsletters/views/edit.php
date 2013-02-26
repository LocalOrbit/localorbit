<?php
global $core;
core::ensure_navstate(array('left'=>'left_dashboard'),'newsletters-list','marketing');
core_ui::fullWidth();
core::head('Edit Newsletter','Edit Newsletter');
lo3::require_permission();
lo3::require_login();

core_ui::load_library('js','newsletters.js');

if(!is_numeric($core->data['cont_id']))
{
	$data = array('cont_id'=>0);
	$has_image = false;
	$show_img_row = false;
}
else
{
	$data = core::model('newsletter_content')->load();
	list($has_image,$webpath,$filepath) = $data->get_image();
	$show_img_row = true;
}

if(!lo3::is_admin() && !lo3::is_market())
{
	# kick them out.
	lo3::require_orgtype('market');
}

$hubs = core::model('domains')->collection();
if (lo3::is_market()) {
	$hubs = $hubs->filter('domain_id', 'in', implode(',', $core->session['domains_by_orgtype_id'][2]));
}
$hubs = $hubs->sort('name');

$groups = explode(',',$data['send_to_groups']);
$data['send_seller'] = (in_array(1,$groups));
$data['send_buyer']  = (in_array(2,$groups));
$data['send_market'] = (in_array(3,$groups));

$this->save_rules()->js();

echo(core_form::page_header('Editing '.$data['title']));
?>
<div class="buttonset pull-right" id="sendNewsletterButton">
	<span id="testLabel" style="display: none;">Send test to&nbsp;</span>
	<input type="text" name="test_email" id="testEmail" value="" style="display: none;" />
	<button id="cancelTest" style="display: none;" class="btn btn-danger" onclick="core.newsletters.toggleTestEmail();">cancel test</button>
	<button id="sendTest" style="display: none;" class="btn btn-info" onclick="core.newsletters.sendTest();">send now</button>
	<button id="showTest" class="btn btn-info" onclick="core.newsletters.toggleTestEmail();">send test</button>
	<button id="sendCustomers" class="btn btn-primary" onclick="core.newsletters.sendNewsletter('<?=addslashes($core->i18n['error:newsletter:must_choose_group'])?>');">send to customers</button>
</div>
<?
echo(
	core_form::form('nlForm','/newsletters/update',null,
		core_form::tab('newslettertabs',
			core_form::table_nv(
				((lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)?
					core_form::input_select('Market','domain_id',$data['domain_id'],$hubs,array(
						'default_show'=>true,
						'default_text'=>'Select a Market',
						'text_column'=>'name',
						'value_column'=>'domain_id',
				)):''),
				core_form::value(
					'Send to these groups',
					core_ui::checkdiv('send_seller','Sellers',$data['send_seller']).'&nbsp;&nbsp;&nbsp;&nbsp;'.
					core_ui::checkdiv('send_buyer','Buyers',$data['send_buyer']).
					'<div class="error" style="display:none;" id="checkMsg">You must check at least one group that will receive this newsletter.</div>'
				),
				core_form::input_image_upload('Upload a new image','newsletters',array(
					'display_row'=>($data['cont_id']>0),
					'sublabel'=>'(No larger than 600 pixels wide and 300 pixels tall)',
					'img_id'=>'newsletterImage',
					'src'=>$webpath,
				)),
				core_form::input_text('Subject','title',$data),
				core_form::input_text('Header','header',$data),
				core_form::input_rte('Body','body',$data)
			)
		),
		((lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) == 1)?
			core_form::input_hidden('domain_id',$core->session['domains_by_orgtype_id'][2][0]):''
		),
		core_form::input_hidden('do_test',0),
		core_form::input_hidden('test_email',0),
		core_form::input_hidden('do_send',0),
		core_form::input_hidden('cont_id',$data['cont_id']),
		core_form::save_only_button(array('cancel_button' => true, 'on_cancel' => 'location.href=\'#!newsletters-list\';core.go(\'#!newsletters-list\');'))
	)
);
?>