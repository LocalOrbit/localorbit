<?php
$prefix = $core->view[0];
$suffix1 = (isset($core->view[1]))?($core->view[1]):((lo3::is_market() || lo3::is_seller() || lo3::is_admin())?'Sales':'Purchases');
$suffix2 = (isset($core->view[2]))?($core->view[2]):('Fees');
?>
<div<?=((lo3::is_seller() || lo3::is_admin() || lo3::is_market())?'':' style="display: none;"')?>>
	<h2 class="pull-left">Total <?=$suffix1?></h2> <i class="helpslug icon-question-sign pull-left" rel="popover" data-title="Total <?=$suffix1?>" data-content="<?=core::i18n('note:totals_table_current_view')?>" data-original-title="" data-placement="right" style="margin-left:5px;margin-top:11px;"></i>
	

	<table class="dt table table-striped">
		<thead>
			<tr>
				<th class="dt">Gross <?=$suffix1?></th>
				<th class="dt">Discounts</th>
		<?
if(lo3::is_market() || lo3::is_admin())
{
	?>
				<th class="dt">Market <?=$suffix2?></th>
				<th class="dt">LO <?=$suffix2?></th>
				<th class="dt">Payment Processing</th>
	<?
}else  if(lo3::is_seller()){
	?>
				<th class="dt">Transaction <?=$suffix2?></th>
				<th class="dt">Payment Processing</th>
	<?}?>
				<th class="dt">Net <?=$suffix1?></th>
			</tr>
		</thead>
		<tbody>
			<tr class="dt">
				<td class="dt" id="<?=$prefix?>gross">$0.00</td>
				<td class="dt" id="<?=$prefix?>discount">$0.00</td>
		<?
if(lo3::is_market() || lo3::is_admin())
{
	?>
				<td class="dt" id="<?=$prefix?>hub">$0.00</td>
				<td class="dt" id="<?=$prefix?>lo">$0.00</td>
				<td class="dt" id="<?=$prefix?>proc">$0.00</td>
	<?
}
else if(lo3::is_seller())
{
	?>
				<td class="dt" id="<?=$prefix?>combined">$0.00</td>
				<td class="dt" id="<?=$prefix?>proc">$0.00</td>
<?}?>
				<td class="dt" id="<?=$prefix?>net">$0.00</td>
			</tr>
		</tbody>
	</table>
</div>