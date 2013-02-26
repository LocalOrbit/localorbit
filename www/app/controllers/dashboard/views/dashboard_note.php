<?if($core->config['domain']['dashboard_note'] != ''){?>
	<div class="alert">
		<button type="button" class="close" data-dismiss="alert"><u><small>dismiss this message</small></u> &times;</button>
		<?=$core->config['domain']['dashboard_note']?>
	</div>
<?}?>