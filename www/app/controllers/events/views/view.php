<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Events','Events');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');
$data = core::model('events')->load();
?>
<h1>Event Information</h1>
<?=core_ui::tab_switchers('exampletabs',array('Info'))?>
<div class="tabarea" id="exampletabs-a1">
	<table class="form">
		<?=core_form::value('Event Type',$data['event_type'])?>
		<?=core_form::value('Organization','<a href="#!organizations-edit--org_id-'.$data['org_id'].'">'.$data['org_name'].'</a>')?>
		<?=core_form::value('User','<a href="#!users-edit--entity_id-'.$data['customer_id'].'">'.$data['first_name'].' '.$data['last_name'].'</a>')?>
		<?=core_form::value('E-mail','<a href="mailTo:'.$data['email'].'">'.$data['email'].'</a>')?>
		<?=core_form::value('Domain','<a href="#!market-edit--domain_id-'.$data['domain_id'].'">'.$data['domain_name'].'</a>')?>
		<?=core_form::value('IP Address',$data['ip_address'])?>
		<?=core_form::value('Date',core_format::date($data['creation_date'],'long'))?>
		<?
		switch($data['event_type'])
		{
			default:
				echo(core_form::value('Object 1 ID',$data['obj_id1']));
				echo(core_form::value('Object 2 ID',$data['obj_id2']));
				echo(core_form::value('Text 1',$data['varchar1']));
				echo(core_form::value('Text 2',$data['varchar2']));
			break;
		}
		?>
	</table>
</div>