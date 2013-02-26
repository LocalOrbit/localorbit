<?php 
$opts = core::model('template_options')->get_options(array('footer'));


?>
<br />
<table width="100%">
	<col width="4%" />
	<col width="16%" />
	<col width="20%" />
	<col width="20%" />
	<col width="20%" />
	<col width="20%" />
	<tr>
		<td>&nbsp;</td>
		<td>
			<a href="#!misc-home"><img src="/img/default/logo_gray.png" /></a>
		</td>
<?
if($core->config['domain']['domain_id'] > 1)
{
	echo('<td colspan="4">&nbsp;</td>');
}
else
{

	for ($i = 1; $i < 5; $i++){?>
	<?if($opts['footer-col'.$i.'-label'] != ''){?>
		<td>
			<img src="<?=$opts['footer-col'.$i.'-image']?>" /><br />
			<b class="footer"><?=$opts['footer-col'.$i.'-label']?></b>
			<ul class="footer">
			<?for ($j = 1; $j < 12; $j++){?>
				<?if($opts['footer-col'.$i.'-link'.$j.'-href'] !=''){?>
				<li class="footer">
					<? if($i == 4 && $j == 2){?>
					<a class="footer" href="#" onclick="$('#overlay,#popup3,#popup_closer').fadeIn(150);">Send Us A Note Today!</a>
					<?}else{?>
					<a class="footer"<?
					
					# if a link is external to LO, open it in a new tab/window
					if(strpos($opts['footer-col'.$i.'-link'.$j.'-href'],'http') === false)
					{
						if(strpos($opts['footer-col'.$i.'-link'.$j.'-href'],'#!') !== false)
						{
							echo(' onclick="core.go(this.href);"');
						}
					}
					else
					{
						echo(' target="_blank"');
					}
					
					?> href="<?=$opts['footer-col'.$i.'-link'.$j.'-href']?>">
						<?=$opts['footer-col'.$i.'-link'.$j.'-label']?>
					</a>
					<?}?>
				</li>
				<?}?>
			<?}?>
			</ul>
		</td>
	<?}?>
<?
	}
}
?>	
	</tr>
</table>

<br />&nbsp;<br />
<div class="footer">&nbsp; &nbsp; &nbsp; &copy; <?=date('Y')?> | <a class="footer" style="font-size: 100%;" href="app.php#!misc-tos" onclick="core.go(this.href);">Terms of Service</a> | <a style="font-size: 100%;" class="footer" href="app.php#!misc-localorbit_privacy" onclick="core.go(this.href);">Privacy</a> | <a class="footer" href="http://localorbit.zendesk.com/forums" style="font-size: 100%;" target="_blank">Help</a></div>
<br />
<? 

core::replace('footer'); ?>