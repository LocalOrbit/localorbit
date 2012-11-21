	<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
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
if(in_array(1,$groups))
	$data['send_seller'] = 1;
if(in_array(3,$groups) || in_array(2,$groups))
	$data['send_buyer'] = 1;
if(in_array(4,$groups))
	$data['send_market'] = 1;



echo(
	core_form::page_header('Editing '.$data['title'],'#!newsletters-list','cancel').
	core_form::form('nlForm','/newsletters/update',null,
		core_form::tab_switchers('newslettertabs',array('Newsletter')),
		core_form::tab('newslettertabs',
			core_form::table_nv(
				((lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)?
					core_form::input_select('Hub','domain_id',$data,$hubs,array(
						'default_show'=>true,
						'default_text'=>'Select a Hub',
						'text_column'=>'name',
						'value_column'=>'domain_id',
				)):''),
				core_form::value(
					'Send to these groups',
					core_ui::checkdiv('send_seller','Sellers',$data['send_seller']).
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
			core_form::hidden('domain_id',$core->session['domains_by_orgtype_id'][2][0]):''
		),
		core_form::input_hidden('do_test',0),
		core_form::input_hidden('do_send',0),
		core_form::input_hidden('cont_id',$data['cont_id']),
		core_form::save_buttons()
	)
);
?>
<!--
<?
page_header('Editing '.$data['title'],'#!newsletters-list','cancel');
?>
<form name="nlForm" method="post" action="/newsletters/update" onsubmit="return core.submit('/newsletters/update',this);" enctype="multipart/form-data">
	<div class="tabset" id="newslettertabs">
		<div class="tabswitch" id="newslettertabs-s1">
			Newsletter
		</div>
	</div>
	<div class="tabarea" id="newslettertabs-a1">
		<table class="form">
		<?if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1){?>
			<tr>
				<td class="label">Hub</td>
				<td class="value">
					<select name="domain_id" style="width: 500px;">
						<option value="0">Select a hub</option>
						<?=core_ui::options($hubs,$data['domain_id'],'domain_id','name')?>
					</select>
				</td>
			</tr>
		<?}?>		
			<tr>
				<td class="label">Send to these groups</td>
				<td class="value">
					<?=core_ui::checkdiv('send_seller','Sellers',$data['send_seller'])?>
					<?=core_ui::checkdiv('send_buyer','Buyers',$data['send_buyer'])?>
					<div class="error" style="display:none;" id="checkMsg">You must check at least one group that will receive this newsletter.</div>
				</td>
			</tr>
			<tr>
				<td class="label">Subject</td>
				<td class="value"><input type="text" name="title" value="<?=$data['title']?>" /></td>
			</tr>
			<tr>
				<td class="label">Header</td>
				<td class="value"><input type="text" name="header" value="<?=$data['header']?>" /></td>
			</tr>
			<tr id="img_msg_row" style="<?=(($show_img_row)?'display:none;':'')?>">
				<td class="label">Upload a new image (No larger than 600 pixels wide and 300 pixels tall)</td>
				<td class="value">
					You must save this newsletter before you can upload an image. Saving the newsletter will not send it.
				</td>
			</tr>
			<tr id="img_upload_row" style="<?=(($show_img_row)?'':'display:none;')?>">
				<td class="label">Upload a new image (No larger than 600 pixels wide and 300 pixels tall)</td>
				<td class="value">
					<img id="newsletterImage" src="<?=$webpath?>" />
					<br />
					<input type="file" name="new_image" value="" />
					<input type="button" class="button_secondary" value="Upload" onclick="core.ui.uploadFrame(document.nlForm,'uploadArea','core.newsletters.refreshImage({params});','app/newsletters/save_image');" />
					<input type="button" id="removenlimage" class="button_secondary" value="Remove Image" onclick="core.doRequest('/newsletters/remove_nlimage',{'cont_id':<?=$data['cont_id']?>});" />
					<iframe name="uploadArea" id="uploadArea" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;"></iframe>
				</td>
			</tr>
			
		</table>
		<div class="buttonset" id="sendNewsletterButton">
			<span id="testLabel" style="display: none;">Send test to&nbsp;</span>
			<input type="text" name="test_email" id="testEmail" value="" style="display: none;" />
			<input type="button" id="cancelTest" style="display: none;" class="button_secondary" value="cancel test" onclick="core.newsletters.toggleTestEmail();" />
			<input type="button" id="sendTest" style="display: none;" class="button_secondary" value="send now" onclick="core.newsletters.sendTest();" />
			<input type="button" id="showTest" class="button_secondary" value="send test" onclick="core.newsletters.toggleTestEmail();" />
			<input type="button" id="sendCustomers" class="button_secondary" value="send to customers" onclick="core.newsletters.sendNewsletter(this.form);" />
		</div>
	<br />
	</div>
	<?if(lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) == 1){?>
		<input type="hidden" name="domain_id" value="<?=$core->session['domains_by_orgtype_id'][2][0]?>" />
	<?}?>
	<input type="hidden" name="do_test" value="0" />
	<input type="hidden" name="do_send" value="0" />
	<input type="hidden" name="cont_id" value="<?=$data['cont_id']?>" />
	<? save_buttons(); ?>
</form>
-->