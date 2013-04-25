<?
global $core;
$data = $core->view[0];

core::log('render html started');

function render_row($label,$data,$style='')
{
	?>
	<tr class="dt<?=$style?>">
		<td class="dt"><b><?=$label?></b></td>
		<?for($i=1;$i < count($data);$i++){?>
		<td class="dt"<?=(($i == (count($data)-1))?' style="font-weight:bold;"':'')?>><?=$data[$i]?></td>
		<?}?>
	</tr>
	<?
}

function render_ranges($breakdown_by,$ranges)
{
	$total_rows = count($ranges);
	$total_rows--;
	?>
	<col width="20%" />
	<?for($i=0;$i<$total_rows;$i++){?>
	<col width="<?=round((80 / $total_rows),0)?>%" />
	<?}?>
	<tr>
		<th class="dt">&nbsp;</th>
		<?
		for($i=1;$i < $total_rows;$i++)
		{
			echo('<th class="dt">');
			switch($breakdown_by)
			{
				case 'day':
					echo(date('n/j',$ranges[$i][0]));
					break;
				case 'week':
					echo(date('n/j',$ranges[$i][0]).' - '.date('n/j',$ranges[$i][1] - 1));
					break;
				case 'month':
					echo(date('M Y',$ranges[$i][0]));
					break;
			}
			echo('</th>');
		}
		echo('<th class="dt"><b>TOTAL</b></th>');
		?>
	</tr>
	<?
}
?>
<h2>Markets</h2>
<table class="dt">
	<?
	render_ranges($core->data['breakdown_by'],$data['ranges']);
	render_row('# of Actively Trading Markets',$data['markets']['active_markets']);
	render_row('# of Live Markets',$data['markets']['live_markets'],1);
	?>
</table>
<br />
<h2>Organizations</h2>
<table class="dt">
	<?
	render_ranges($core->data['breakdown_by'],$data['ranges']);
	render_row('# of Buyers',$data['organizations']['nbr_buyers']);
	render_row('Buyer % Growth',$data['organizations']['buyer_percent_growth'],1);
	render_row('# of Sellers',$data['organizations']['nbr_sellers']);
	render_row('Seller % Growth',$data['organizations']['seller_percent_growth'],1);
	?>
</table>
<br />
<h2>Financials</h2>
<table class="dt">
	<?
	render_ranges($core->data['breakdown_by'],$data['ranges']);
	render_row('# of Orders',$data['financials']['nbr_orders'],1);
	render_row('Total Sales',$data['financials']['total_sales']);
	render_row('Average Order',$data['financials']['avg_order'],1);
	render_row('Average # Items',$data['financials']['avg_items'],1);
	render_row('Average LO Fees',$data['financials']['avg_lo_fee'],1);
	render_row('Average LO Fees %',$data['financials']['avg_lo_fee_percent'],1);
	render_row('Sales % Growth',$data['financials']['sales_growth'],1);
	render_row('Local Orbit Fees',$data['financials']['lo_fees']);
	render_row('Fee % Growth',$data['financials']['fee_growth'],1);
	?>
</table>
<div class="error"><?=$this->get_financials_note()?></div>
<?
core::replace('output_area');
?>