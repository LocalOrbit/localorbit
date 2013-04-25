<?

class core_controller_metrics extends core_controller 
{
	function do_dump()
	{
		global $core;
		$prod_price_cmd ='/usr/bin/mysql localorb_www_'.$core->config['stage'].' -u localorb_www -p\'l0cal1sdab3st\' < /var/www/'.$core->config['stage'].'/bin/log_product_price_changes.sql';
		$prod_cmd = '/usr/bin/mysql localorb_www_'.$core->config['stage'].' -u localorb_www -p\'l0cal1sdab3st\' < /var/www/'.$core->config['stage'].'/bin/log_product_changes.sql';  	
		core::log($prod_cmd);
		shell_exec($prod_price_cmd);
		shell_exec($prod_cmd);
		core_ui::notification('dump in progress');
	}
	
	public function get_financials_note()
	{
		global $core;
		$note = 'Financial growth rates (%) are based on the average rate of growth in report the date range, over the same period of time immediately preceding breakdown.

That is, if you are showing 4 weeks broken down by week, the Sales % Growth rate is calculated by averaging the total weekly sales in the report and calculating the rate of change from the same time period (one week) immediately preceding the period from which the average is calculated. 

The math:
(Avg Weekly Sales during a given time frame) minus (total sales of the previous week) divided by (total sales of the previous week).';
		if($core->data['output_as'] == 'html')
		{
			$note = str_replace("\n\n",'<br />&nbsp;<br />',$note);
			$note = str_replace("\n",'<br />',$note);
			return $note;
		}
		else
		{
			
			$note = str_replace("\n\n","\"----\"",$note);
			$note = str_replace("\n",'',$note);
			$note = str_replace("----","\n\n",$note);
			core::log('"'.$note.'"');
			#$note = str_replace("\n",'',$note);
			return '"'.$note.'"';
		}
	}
	
	# this does all the magic! deceptively simple.
	public function render_metrics()
	{
		global $core;
		$data = $this->build_data();
		$output_function = 'render_'.$core->data['output_as'];
		$this->$output_function($data);
	}
	
	function default_values()
	{
		global $core;
		
		$date_info = getdate();
		
		# the default is the last 2 months, broken down by week
		# figure out the start time of last month
		$start_month = $date_info['mon'] - 1;
		$start_year  = $date_info['year'];
		$end_month   = $date_info['mon'] + 1;
		$end_year    = $start_year;
		
		# build final epoch
		$start_epoch = mktime(0,0,0,$start_month,1,$start_year) - $core->session['time_offset'];
		$end_epoch   = mktime(0,0,0,$end_month,1,$end_year) - $core->session['time_offset'];
		
		# build the final default values
		$core->data['start_date']   = core_format::date($start_epoch,'short');
		$core->data['end_date']     = core_format::date($end_epoch - 1,'short');
		$core->data['domain_id']    = 0;
		$core->data['breakdown_by'] = 'week';
		$core->data['output_as'] = 'html';
		
		return $core->data;
	}
	
	public function build_data()
	{
		global $core;
		
		core::log('building metrics data using params '.print_r($core->data,true));
		
		# build the list of ranges
		$ranges = $this->get_ranges();
		
		# populate the initial data set to return
		$data = array(
			'ranges'=>$ranges,
			'markets'=>array(
				'active_markets'=>$this->get_metric_data_active_markets($ranges),
				'live_markets'=>$this->get_metric_data_live_markets($ranges),
			),
			'organizations'=>array(
				'nbr_buyers'=>$this->get_metric_data_nbr_buyers($ranges),
				'nbr_sellers'=>$this->get_metric_data_nbr_sellers($ranges),
			),
			'financials'=>array(
				'nbr_orders'=>$this->get_metric_data_nbr_orders($ranges),
				'total_sales'=>$this->get_metric_data_total_sales($ranges),
				'avg_order'=>$this->get_metric_data_avg_orders($ranges),
				'lo_fees'=>$this->get_metric_data_lo_fees($ranges),
			)
		);
		
		# these are special because they require previous data to work with
		$data['financials']['sales_growth'] = $this->get_metric_data_percent_growth($data['financials']['total_sales'],true);
		$data['financials']['fee_growth'] = $this->get_metric_data_percent_growth($data['financials']['lo_fees'],true);
		$data['organizations']['buyer_percent_growth'] = $this->get_metric_data_percent_growth($data['organizations']['nbr_buyers']);
		core::log('calcing seller % growth');
		$data['organizations']['seller_percent_growth'] = $this->get_metric_data_percent_growth($data['organizations']['nbr_sellers']);
		
		# apply some final formatting (prices, percentages)
		$data = $this->apply_formatting($data);
		
		return $data;
	}
	
	public function get_ranges()
	{
		global $core;
		
		# get the start/end epoch
		$start_date = core_format::parse_date($core->data['start_date'],'timestamp');
		$end_date   = core_format::parse_date($core->data['end_date'],'timestamp');
		
		#core::log('start date: '.$start_date);
		#core::log('end date: '.$end_date);
		
		
		$ranges = array();
		# based on the kind of breakdown we want, build an array of date ranges 
		# that will be used in the queries
		switch($core->data['breakdown_by'])
		{
			case 'day':
				$ranges = $this->build_ranges($start_date - 86400,$end_date,86400);
				$ranges[] = array($start_date,$end_date);
				break;
			case 'week':
				# move start to first day of week
				$start_date -= (86400 * date('w',$start_date));
				# move end to last day of week
				$end_date += (86400 * (6 - date('w',$end_date)));
				
				$ranges = $this->build_ranges($start_date - 604800,$end_date,604800);
				
				# the final range should be the entire time period
				$ranges[] = array($start_date,$end_date);
				break;
			case 'month':
				# move start to first day of month
				$start_date -= (86400 * (date('j',$start_date) - 1));
				# move end to last day of month
				$end_date += (86400 * (date('t',$end_date) - date('j',$end_date)));
				
				# figure out the start month/year, move one month earlier
				$start_month_nbr = date('n',$start_date);
				$start_year_nbr = date('Y',$start_date);
				$start_month_nbr -=2;
				$range_end = 0;

				# add more months until the end of the month
				# is after the final day that the user selected
				while(($range_end +2) < $end_date)
				{
					# get the epochs for the next month's start/end
					$start_month_nbr++;
					$range_start = mktime(0,0,0,$start_month_nbr,1,$start_year_nbr);
					$range_end   = (mktime(0,0,0,$start_month_nbr+1,1,$start_year_nbr) - 1);
					
					$ranges[] = array($range_start,$range_end);
				}
				
				# the final range should be the entire time period
				$ranges[] = array($ranges[1][0],$ranges[(count($ranges) -1)][1]);
				break;
		}
		core::log('ranges: '.print_r($ranges,true));	
		return $ranges;
	}
	
	# this function builds a range of dates using a start, end, and increment amount
	function build_ranges($start,$end,$increment)
	{
		global $core;
		$ranges = array();
		while($start < $end)
		{
			$ranges[] = array($start,$start + $increment);
			$start += $increment;
		}
		return $ranges;
	}
	
	function format_percents($input,$html=true)
	{
		if($html)
		{
			if($input == '∞' and !is_numeric($input))
			{
				#core::log('input '.$input.' is infinity sign');
				$input = '<b style="font-size: 200%;">&infin;</b>';
			}
			else if($input < 0)
			{
				#core::log('input '.$input.' is less than zero');
				$input = '<div class="error">'.$input.'%</div>';
			}
			else
			{
				#core::log('input '.$input.' is a normal %');
				$input .= '%';
			}
		}
		else
		{
			if($input != '∞')
				$input .= '%';
		}
		return $input;
	}
	
	function apply_formatting($data)
	{
		global $core;
		for($i=0;$i<count($data['ranges']);$i++)
		{
			$data['financials']['total_sales'][$i] = core_format::price($data['financials']['total_sales'][$i],false);
			$data['financials']['lo_fees'][$i]     = core_format::price($data['financials']['lo_fees'][$i],false);
			$data['financials']['avg_order'][$i]     = core_format::price($data['financials']['avg_order'][$i],false);
			
			# format infinities and negativs nicely
			$data['financials']['sales_growth'][$i] = $this->format_percents($data['financials']['sales_growth'][$i],($core->data['output_as'] == 'html'));
			$data['financials']['fee_growth'][$i] = $this->format_percents($data['financials']['fee_growth'][$i],($core->data['output_as'] == 'html'));
			$data['organizations']['buyer_percent_growth'][$i] = $this->format_percents($data['organizations']['buyer_percent_growth'][$i],($core->data['output_as'] == 'html'));
			$data['organizations']['seller_percent_growth'][$i] = $this->format_percents($data['organizations']['seller_percent_growth'][$i],($core->data['output_as'] == 'html'));

		}
		return $data;
	}
	
	/*
	 * All functions below are used to generate queries that actually build the metrics
	 * 
	 * Each function should take an array that represents a range of dates, and 
	 * returns an array which represents the values for that range of dates
	 */
	function get_metric_data_active_markets($ranges)
	{
		global $core;
		$data = array();
		foreach($ranges as $range)
		{
			$sql = '
				select count(distinct domain_id) as mycount
				from organizations_to_domains
				where org_id in (
					select org_id
					from lo_order
					where ldstat_id not in (1,3)
					and order_date >= \''.date('Y-m-d H:i:s',$range[0]).'\'
					and order_date < \''.date('Y-m-d H:i:s',$range[1]).'\'
				)
				and domain_id not in (1,3,6,23,24,25,26)
			';
			$data[] = core_db::col($sql,'mycount');
		}
		return $data;
	}
	
	function get_metric_data_live_markets($ranges)
	{
		global $core;
		$data = array();
		foreach($ranges as $range)
		{
			
			$sql = '
				select count(distinct domain_id) as mycount
				
				from domains_is_live_history
				where domain_id > 0
				and (
			';
			
			# there are several possible conditions where a domain should be counted:
			# 1: the date range is entirely within an is_live range
			$sql .= '
				(
					is_live_start >= \''.date('Y-m-d H:i:s',$range[0]).'\'
					and 
					is_live_end < \''.date('Y-m-d H:i:s',$range[1]).'\'
				)
			';
			
			
			# 2: the date range starts before the range, and ends after the start
			$sql .= '
				or
				(
					is_live_start < \''.date('Y-m-d H:i:s',$range[0]).'\'
					and 
					is_live_end > \''.date('Y-m-d H:i:s',$range[0]).'\'
				)
			';
			# 3: the date range starts after the range starts
			# and ends after the end
			$sql .= '
				or
				(
					is_live_start >= \''.date('Y-m-d H:i:s',$range[0]).'\'
					and 
					is_live_start < \''.date('Y-m-d H:i:s',$range[1]).'\'
					and 
					is_live_end > \''.date('Y-m-d H:i:s',$range[1]).'\'
				)
			';
						
			# close up the conditions
			$sql .= '
				)
				and domain_id not in (1,3,6,23,24,25,26);
			';
			$val = core_db::col($sql,'mycount');
			$data[] = $val;
			#core::log($sql);
			#core::log('val for '.date('Y-m-d H:i:s',$range[0]).'/'.date('Y-m-d H:i:s',$range[1]).' is '.$val);
			
		}
		#core::log(print_r($data,true));
		#exit();

		return $data;
	}
	
	function get_metric_data_nbr_buyers($ranges)
	{
		global $core;
		$data = array();
		foreach($ranges as $range)
		{
			$sql = '
				select count(org_id) as mycount
				from organizations
				where allow_sell=0
				and creation_date < \''.date('Y-m-d H:i:s',$range[1]).'\'
				and org_id not in (
					select org_id
					from organizations_to_domains
					where domain_id in (1,3,6,23,24,25,26)
				)
			';
			if(intval($core->data['domain_id']) > 0)
			{
				
				$sql .= '
					and org_id in (
						select org_id
						from organizations_to_domains
						where domain_id='.intval($core->data['domain_id']).'
					)
				';
			}
			$data[] = core_db::col($sql,'mycount');
		}
		return $data;
	}
	
	function get_metric_data_nbr_sellers($ranges)
	{
		global $core;
		$data = array();
		foreach($ranges as $range)
		{
			$sql = '
				select count(org_id) as mycount
				from organizations
				where allow_sell=1
				and creation_date < \''.date('Y-m-d H:i:s',$range[1]).'\'
				and org_id not in (
					select org_id
					from organizations_to_domains
					where domain_id in (1,3,6,23,24,25,26)
				)
			';
			if(intval($core->data['domain_id']) > 0)
			{
				
				$sql .= '
					and org_id in (
						select org_id
						from organizations_to_domains
						where domain_id='.intval($core->data['domain_id']).'
					)
				';
			}
			$data[] = core_db::col($sql,'mycount');
		}
		return $data;
	}
	
	function get_metric_data_nbr_orders($ranges)
	{
		global $core;
		$data = array();
		foreach($ranges as $range)
		{
			$sql = '
				select count(lo_oid) as mycount
				from lo_order
				where ldstat_id not in (1,3)
				and order_date >= \''.date('Y-m-d H:i:s',$range[0]).'\'
				and order_date < \''.date('Y-m-d H:i:s',$range[1]).'\'
				and org_id not in (
					select org_id
					from organizations_to_domains
					where domain_id in (1,3,6,23,24,25,26)
				)	
			';
			if(intval($core->data['domain_id']) > 0)
			{
				
				$sql .= '
					and org_id in (
						select org_id
						from organizations_to_domains
						where domain_id='.intval($core->data['domain_id']).'
					)
				';
			}
			$data[] = core_db::col($sql,'mycount');
		}
		return $data;
	}
	
	function get_metric_data_total_sales($ranges)
	{
		global $core;
		$data = array();
		foreach($ranges as $range)
		{
			$sql = '
				select sum(grand_total) as mycount
				from lo_order
				where ldstat_id not in (1,3)
				and order_date >= \''.date('Y-m-d H:i:s',$range[0]).'\'
				and order_date < \''.date('Y-m-d H:i:s',$range[1]).'\'
				and org_id not in (
					select org_id
					from organizations_to_domains
					where domain_id in (1,3,6,23,24,25,26)
				)
			';
			if(intval($core->data['domain_id']) > 0)
			{
				
				$sql .= '
					and org_id in (
						select org_id
						from organizations_to_domains
						where domain_id='.intval($core->data['domain_id']).'
					)
				';
			}
			$data[] = core_db::col($sql,'mycount');
		}
		return $data;
	}
	
	function get_metric_data_avg_orders($ranges)
	{
		global $core;
		$data = array();
		foreach($ranges as $range)
		{
			$sql = '
				select (sum(grand_total) / count(grand_total)) as mycount
				from lo_order
				where ldstat_id not in (1,3)
				and order_date >= \''.date('Y-m-d H:i:s',$range[0]).'\'
				and order_date < \''.date('Y-m-d H:i:s',$range[1]).'\'
				and org_id not in (
					select org_id
					from organizations_to_domains
					where domain_id in (1,3,6,23,24,25,26)
				)
			';
			if(intval($core->data['domain_id']) > 0)
			{
				
				$sql .= '
					and org_id in (
						select org_id
						from organizations_to_domains
						where domain_id='.intval($core->data['domain_id']).'
					)
				';
			}
			$data[] = core_db::col($sql,'mycount');
		}
		return $data;
	}
	function get_metric_data_lo_fees($ranges)
	{
		global $core;
		$data = array();
		foreach($ranges as $range)
		{
			$sql = '
				select sum(grand_total * (fee_percen_lo / 100)) as mycount
				from lo_order
				where ldstat_id not in (1,3)
				and order_date >= \''.date('Y-m-d H:i:s',$range[0]).'\'
				and order_date < \''.date('Y-m-d H:i:s',$range[1]).'\'
				and org_id not in (
					select org_id
					from organizations_to_domains
					where domain_id in (1,3,6,23,24,25,26)
				)
			';
			if(intval($core->data['domain_id']) > 0)
			{
				
				$sql .= '
					and org_id in (
						select org_id
						from organizations_to_domains
						where domain_id='.intval($core->data['domain_id']).'
					)
				';
			}
			$data[] = core_db::col($sql,'mycount');
		}

		return $data;
	}
	
	function get_metric_data_percent_growth($input_data,$accumulate_total=false)
	{
		$data = array(1);
		
		# calculate the growth rate for all columns EXCEPT the last column
		# this one must be done separately since it represents the entire range
		$total = 0;
		for($i=1;$i<(count($input_data) - 1);$i++)
		{
			# if the data value for the previous period is zero, don't 
			# calculate. Divide by zero == universe over
			#core::log('previous value is: '.$input_data[$i - 1]);
			if(floatval($input_data[$i - 1]) ==0)
			{
				#core::log('adding infinity');
				$data[] = '∞';
			}
			else
			{
				$nbr = ((floatval($input_data[$i]) - floatval($input_data[$i - 1])) / floatval($input_data[$i - 1])) * 100;
				$nbr = round($nbr,1);
				$data[] = $nbr;
				#core::log('nbr is NOT infinite: '.$nbr);
				if($accumulate_total)
				{
					$total += $input_data[$i];
				}
			}
		}
		
		# do the final column
		if(floatval($input_data[0]) == 0)
		{
			$data[] = '∞';
		}
		else
		{
			if($accumulate_total)
			{
				$total = $total / (count($input_data) - 2);
				$nbr = (($total - floatval($input_data[0])) / floatval($input_data[0])) * 100;
			}
			else
			{
				$nbr = ((floatval($input_data[(count($input_data) - 2)]) - floatval($input_data[0])) / floatval($input_data[0])) * 100;
			}
			$nbr = round($nbr,1);
			$data[] = $nbr;
		}
		
		return $data;
	}
}

?>
