<?php
$prefix = $core->view[0];
$suffix1 = (isset($core->view[1]))?($core->view[1]):((lo3::is_market() || lo3::is_seller() || lo3::is_admin())?'Sales':'Purchases');
$suffix2 = (isset($core->view[2]))?($core->view[2]):('Fees');
?>
<div<?=((lo3::is_customer())?' style="display: none;"':'')?>>
<h2>Total <?=$suffix1?></h2>
<table class="dt table table-striped">
	<thead>
	<tr>
		<th class="dt">Gross <?=$suffix1?></th>
		<th class="dt">Discounts</th>
		<?
if(lo3::is_market() || lo3::is_seller() || lo3::is_admin())
{
	?>
		<th class="dt">Hub <?=$suffix2?></th>
		<th class="dt">LO <?=$suffix2?></th>
		<th class="dt">Payment Processing <?=$suffix2?></th>
	<?
}
	?>
		<th class="dt">Net <?=$suffix1?></th>
	</tr>
	</thead>
	<tbody>
	<tr class="dt">
		<td class="dt" id="<?=$prefix?>gross">$0.00</td>
		<td class="dt" id="<?=$prefix?>discount">$0.00</td>
		<?
if(lo3::is_market() || lo3::is_seller() || lo3::is_admin())
{
	?>
		<td class="dt" id="<?=$prefix?>hub">$0.00</td>
		<td class="dt" id="<?=$prefix?>lo">$0.00</td>
		<td class="dt" id="<?=$prefix?>proc">$0.00</td>
	<?
}
	?>
		<td class="dt" id="<?=$prefix?>net">$0.00</td>
	</tr>
	</tbody>
</table>
</div>