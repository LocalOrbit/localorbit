<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit','Edit');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

$data = core::model('sent_emails')->load();
page_header($data['subject'],'#!sent_emails-list','Cancel');
?>

<table class="form">
	<tr>
		<td class="label">Sent On</td>
		<td class="value"><?=core_format::date($data['sent_date'])?></td>
	</tr>
	<tr>
		<td class="label">To</td>
		<td class="value"><a href="mailTo:<?=$data['to_address']?>"><?=$data['to_address']?></a></td>
	</tr>
	<tr>
		<td class="label">Body</td>
		<td class="value">
			<div class="email_view">
				<?=$data['body']?>
			</div>
		</td>
	</tr>
</table>