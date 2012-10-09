<?if($core->config['domain']['dashboard_note'] != ''){?>
	<div id="dashboard_note"<?
	if(is_numeric($core->config['domain']['bubble_offset']) && $core->config['domain']['bubble_offset']>0)
	{
		echo(' style="left: '.$core->config['domain']['bubble_offset'].'px;"');
	}
?>>
		<?=$core->config['domain']['dashboard_note']?>
	</div>
<?}?>