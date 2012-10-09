<?

$special = core::model('weekly_specials')
	->collection()
	->filter('weekly_specials.domain_id',$core->config['domain']['domain_id'])
	->filter('is_active',1)
	->load()
	->row();
	
if($special)
{
	list($has_image,$webpath) = $special->get_image();
?>

<div id="weekly_special"<?=(($core->session['weekly_special_noshow'] == 1)?' style="display:none;"':'')?>>
	<table>
		<tr>
			<td class="weeklyspecial_popup_top">&nbsp;</td>
		</tr>
		<tr>
			<td class="weeklyspecial_popup_middle">
				<table style="width: 900px;margin: 0px 32px;">
					<col width="300" />
					<col width="20" />
					<col width="660" />
					<tr>
						<td style="vertical-align: top;">
							<img src="<?=$webpath?>?_time_=<?=$core->config['time']?>" />
						</td>
						<td>&nbsp;&nbsp;</td>
						<td style="vertical-align: top;">
							<table>
								<col width="1%" />
								<col width="1%" />
								<col width="98%" />
								<col width="1%" />
								<col width="1%" />
								<tr>
									<td>
										<img src="<?=image('weekly_special_large')?>?_time_=<?=$core->config['time']?>" />
									</td>
									<td>&nbsp;</td>
									<td style="vertical-align: top;">
										<div class="weekly_header">the featured deal:</div>
										<div class="weekly_title"><?=$special['title']?></div>
										
									</td>
									<td>&nbsp;</td>
									<td style="vertical-align: top;">
										<a href="#!catalog-shop" onclick="$('#weekly_special').fadeOut('fast');"><img src="<?=image('deal_close')?>" /></a>
									</td>
								</tr>
								<tr>
									<td colspan="5" style="height: 140px;">
										<?=$special['body']?>
									</td>
								</tr>
								<tr>
									<td colspan="5">
										<div class="buttonset">
											<input type="button" class="button_primary" onclick="location.href='#!catalog-view_product--prod_id-<?=$special['product_id']?>';core.go('#!catalog-view_product--prod_id-<?=$special['product_id']?>');" value="add to cart" />
											<input type="button" class="button_secondary" onclick="$('#weekly_special').fadeOut('fast');" value="start shopping" />
										</div>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="weeklyspecial_popup_bottom">&nbsp;</td>
		</tr>
	</table>
</div>
<a id="weekly_special_icon" href="#!catalog-shop" onclick="$('#weekly_special').fadeIn('fast');"><img src="<?=image('weekly_special_small')?>" /></a>
<?
	$core->session['weekly_special_noshow'] = 1;
}
?>