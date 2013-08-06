<?php

class core_controller_reports extends core_controller
{
	public static function master_formatter($prefix,$data)
	{
		global $core;
		if(is_numeric($data['order_date']))
			$data['formatted_order_date'] = core_format::date($data['order_date'],'short');
		else
			$data['formatted_order_date'] = $data['order_date'];
			
		if(!is_array($core->data['reporting_totals']))
			$core->data['reporting_totals'] = array();
		if(!is_array($core->data['reporting_totals'][$prefix]))
			$core->data['reporting_totals'][$prefix] = array('gross'=>0,'hub'=>0,'lo'=>0,'proc'=>0,'net'=>0);
		
		if($data['qty_delivered'] > 0 || $data['ldstat_id'] == 3)
		{
			$data['qty_ordered'] = intval($data['qty_delivered']);
		}
		
		$data['row_total'] = $data['qty_ordered'] * $data['unit_price'];

			
		$lo   = ($data['row_adjusted_total'] * (floatval($data['fee_percen_lo']) / 100));
		$hub  = ($data['row_adjusted_total'] * (floatval($data['fee_percen_hub']) / 100));
		$proc = ($data['row_adjusted_total'] * (floatval($data[$data['payment_method'].'_processing_fee']) / 100));
		$discount = $data['row_adjusted_total'] - $data['row_total'];
		$data['net_total'] = $data['row_adjusted_total'] - $lo - $hub - $proc;
		

				
			
		# only add up items if the item is NOT canceled.
		if($data['ldstat_id'] != 3)
		{
			$core->data['reporting_totals'][$prefix]['gross'] += $data['row_total'];
			$core->data['reporting_totals'][$prefix]['lo']   += $lo;
			$core->data['reporting_totals'][$prefix]['combined']   += ($lo + $hub);
			$core->data['reporting_totals'][$prefix]['hub']  += $hub;
			$core->data['reporting_totals'][$prefix]['proc'] += $proc;
			$core->data['reporting_totals'][$prefix]['discount'] += $discount;
			$core->data['reporting_totals'][$prefix]['net']  += $data['row_adjusted_total'] - $lo - $hub - $proc;;
		}
		
		return $data;
	}
	
	public static function master_output_formatter($prefix,$output_type,$dt)
	{
		global $core;
		
		if($output_type == 'data' || $output_type == 'html')
		{
			$js = '';
			$js .= "$('#".$prefix."gross').html('".core_format::price($core->data['reporting_totals'][$prefix]['gross'],false)."');";
			$js .= "$('#".$prefix."combined').html('".core_format::price($core->data['reporting_totals'][$prefix]['combined'],false)."');";
			$js .= "$('#".$prefix."hub').html('".core_format::price($core->data['reporting_totals'][$prefix]['hub'],false)."');";
			$js .= "$('#".$prefix."lo').html('".core_format::price($core->data['reporting_totals'][$prefix]['lo'],false)."');";
			$js .= "$('#".$prefix."proc').html('".core_format::price($core->data['reporting_totals'][$prefix]['proc'],false)."');";
			$js .= "$('#".$prefix."discount').html('".core_format::price($core->data['reporting_totals'][$prefix]['discount'],false)."');";
			$js .= "$('#".$prefix."net').html('".core_format::price($core->data['reporting_totals'][$prefix]['net'],false)."');";
			core::js($js);
		}
		if($output_type == 'csv' && (lo3::is_admin() || lo3::is_market() || lo3::is_seller()))
		{
			echo("\nTotals:\n");
			echo("Gross,Discounts,");
			if(lo3::is_seller())
			{
				echo("Transaction Fees,Payment Processing,Net\n");
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['gross'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['discount'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['combined'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['proc'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['net'],false).'",');
				
			}
			else
			{
				echo("Market,LO,Payment Processing,Net\n");
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['gross'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['discount'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['hub'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['lo'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['proc'],false).'",');
				echo('"'.core_format::price($core->data['reporting_totals'][$prefix]['net'],false).'",');
			}
			echo("\n");
			
		}
	}
}

?>
