<?
global $core;
$data = $core->view[0];

core::log('render csv started');
core::clear_response();
header("Content-type: application/csv");
header('Content-Type: application/force-download'); 
header("Content-Type: application/download"); 
header("Content-Disposition: attachment; filename=metrics.csv");
header("Pragma: no-cache");
header("Expires: 0");

function render_row($label,$data=array(),$style='')
{
	core::log('rendering '.$label);
	echo('"'.$label.': ",');
	for($i=1;$i < count($data);$i++)
	{
		echo('"'.$data[$i].'",');
	}
	echo("\n");
}

function render_ranges($breakdown_by,$ranges)
{
	echo('" ",');
	for($i=1;$i < (count($ranges) - 1);$i++)
	{
		switch($breakdown_by)
		{
			case 'day':
				echo('"'.date('n/j',$ranges[$i][0]).'",');
				break;
			case 'week':
				echo('"'.date('n/j',$ranges[$i][0]).' - '.date('n/j',$ranges[$i][1] - 1).'",');
				break;
			case 'month':
				echo('"'.date('M y',$ranges[$i][0]).'",');
				break;
		}
	}
	echo("TOTAL\n");
}

echo("Markets\n");
render_ranges($core->data['breakdown_by'],$data['ranges']);
render_row('# of Actively Trading Markets',$data['markets']['active_markets']);
render_row('# of Live Markets',$data['markets']['live_markets'],1);

echo("\n\nOrganizations\n");
render_ranges($core->data['breakdown_by'],$data['ranges']);
render_row('# of Buyers',$data['organizations']['nbr_buyers']);
render_row('# of Buyers',$data['organizations']['buyer_percent_growth'],1);
render_row('# of Sellers',$data['organizations']['nbr_sellers']);
render_row('# of Sellers',$data['organizations']['seller_percent_growth'],1);

echo("\n\nFinancials\n");
render_ranges($core->data['breakdown_by'],$data['ranges']);
render_row('# of Orders',$data['financials']['nbr_orders']);
render_row('Total Sales',$data['financials']['total_sales'],1);
render_row('Average Order',$data['financials']['avg_order'],1);
render_row('Average # Items',$data['financials']['avg_items'],1);
render_row('Average LO Fees',$data['financials']['avg_lo_fee'],1);
render_row('Average LO Fees %',$data['financials']['avg_lo_fee_percent'],1);
render_row('Sales % Growth',$data['financials']['sales_growth'],1);
render_row('Local Orbit Fees',$data['financials']['lo_fees']);
render_row('Fee % Growth',$data['financials']['fee_growth'],1);
echo($this->get_financials_note());
core::log('render complete');
core::deinit(false);
?>