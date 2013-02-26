<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'sent_emails-list','marketing');
core_ui::fullWidth();
core::head('Edit','Edit');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

$data = core::model('sent_emails')->load();
page_header('Email Sent on ' . core_format::date($data['sent_date']),'#!sent_emails-list','Back');
?>

<table class="table">
	<tr>
		<td>Subject</td>
		<td><?= $data['subject'] ?>
	</tr>
	<tr>
		<td>Sent On</td>
		<td><?= core_format::date($data['sent_date']) ?></td>
	</tr>
	<tr>
		<td>To</td>
		<td><a href="mailTo:<?=$data['to_address']?>"><?=$data['to_address']?></a></td>
	</tr>
	<tr>
		<td>Body</td>
		<td>
			<div class="email_view">
				<?=$data['body']?>
			</div>
		</td>
	</tr>
</table>