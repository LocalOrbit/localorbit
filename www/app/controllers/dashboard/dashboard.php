<?php

class core_controller_dashboard extends core_controller
{
	function get_cycle_numbers($status_exclude)
	{
      global $core;
		# first get the first second of this wweek
		$date_info  = explode('-',date('w-j-n-Y-d', time() + $core->config['domain']['offset_seconds']));
		core::log(print_r($date_info,true));
		$week_seconds = 86400 * 7;

		$time_offset = (($core->config['domain']['offset_seconds'] / 3600) * -1);

      core::log($time_offset);
		# generate day ranges
		$d = array();
		$d[0][0] = mktime($time_offset,0,0,$date_info[2],$date_info[4],$date_info[3]);
		$d[0][1] = $d[0][0] + 86399;
		$d[1][0] = $d[0][0] - 86400;
		$d[1][1] = $d[0][1] - 86400;

		# generate the week date ranges
		$w = array();
		$w[0][0] = mktime($time_offset,0,0,$date_info[2],$date_info[1] - $date_info[0],$date_info[3]);
		$w[0][1] = $w[0][0] + $week_seconds;

		$w[1][0] = $w[0][0] - $week_seconds;
		$w[1][1] = $w[0][1] - $week_seconds;

		$w[2][0] = $w[1][0] - $week_seconds;
		$w[2][1] = $w[1][1] - $week_seconds;



		# generate month date ranges
		$m = array();
		$m[0][0] = mktime($time_offset,0,0,$date_info[2],1,$date_info[3]);
		$m[0][1] = mktime($time_offset,0,0,$date_info[2]+1,1,$date_info[3]);

		$m[1][0] = mktime($time_offset,0,0,$date_info[2]-1,1,$date_info[3]);
		$m[1][1] = mktime($time_offset,0,0,$date_info[2],1,$date_info[3]);

		$m[2][0] = mktime($time_offset,0,0,$date_info[2]-2,1,$date_info[3]);
		$m[2][1] = mktime($time_offset,0,0,$date_info[2]-1,1,$date_info[3]);

		# now that we have the ranges, populate the data for weeks
		$data = array('day'=>array(),'week'=>array(),'month'=>array());

		for($i=0;$i<3;$i++)
		{
			core::log('looping: '.$i.' '.$w[$i][0].':'.$w[$i][1].' '.$m[$i][0].':'.$m[$i][1].' ');



			# full sales total
			$data['week'][$i] = core_db::col('
				select sum(grand_total) as mytotal
				from lo_order
				'.$status_exclude.'
				and UNIX_TIMESTAMP(order_date) >= '.$w[$i][0].'
				and UNIX_TIMESTAMP(order_date) <  '.$w[$i][1].'
				and domain_id not in (1,3,6,23,24,25,26)
			','mytotal');
			if($i<2)
			{
				$data['day'][$i] = core_db::col('
					select sum(grand_total) as mytotal
					from lo_order
					'.$status_exclude.'
					and UNIX_TIMESTAMP(order_date) >= '.$d[$i][0].'
					and UNIX_TIMESTAMP(order_date) <  '.$d[$i][1].'
					and domain_id not in (1,3,6,23,24,25,26)
				','mytotal');
			}

			# hub fee total
			$data['week'][$i+3] = core_db::col('
				select sum((grand_total * (fee_percen_hub / 100))) as mytotal
				from lo_order
				'.$status_exclude.'
				and UNIX_TIMESTAMP(order_date) >= '.$w[$i][0].'
				and UNIX_TIMESTAMP(order_date) <  '.$w[$i][1].'
				and domain_id not in (1,3,6,23,24,25,26)
			','mytotal');
			if($i<2)
			{
				$data['day'][$i+3] = core_db::col('
					select sum((grand_total * (fee_percen_hub / 100))) as mytotal
					from lo_order
					'.$status_exclude.'
					and UNIX_TIMESTAMP(order_date) >= '.$d[$i][0].'
					and UNIX_TIMESTAMP(order_date) <  '.$d[$i][1].'
					and domain_id not in (1,3,6,23,24,25,26)
				','mytotal');
			}

			# lo fee total
			$data['week'][$i+6] = core_db::col('
				select sum((grand_total * (fee_percen_lo / 100))) as mytotal
				from lo_order
				'.$status_exclude.'
				and UNIX_TIMESTAMP(order_date) >= '.$w[$i][0].'
				and UNIX_TIMESTAMP(order_date) <  '.$w[$i][1].'
				and domain_id not in (1,3,6,23,24,25,26)
			','mytotal');
			if($i<2)
			{
				$data['day'][$i+6] = core_db::col('
					select sum((grand_total * (fee_percen_lo / 100))) as mytotal
					from lo_order
					'.$status_exclude.'
					and UNIX_TIMESTAMP(order_date) >= '.$d[$i][0].'
					and UNIX_TIMESTAMP(order_date) <  '.$d[$i][1].'
					and domain_id not in (1,3,6,23,24,25,26)
				','mytotal');
			}


			$data['month'][$i] = core_db::col('
				select sum(grand_total) as mytotal
				from lo_order
				'.$status_exclude.'
				and UNIX_TIMESTAMP(order_date) >= '.$m[$i][0].'
				and UNIX_TIMESTAMP(order_date) <  '.$m[$i][1].'
				and domain_id not in (1,3,6,23,24,25,26)
			','mytotal');

			# hub fee total
			$data['month'][$i+3] = core_db::col('
				select sum((grand_total * (fee_percen_hub / 100))) as mytotal
				from lo_order
				'.$status_exclude.'
				and UNIX_TIMESTAMP(order_date) >= '.$m[$i][0].'
				and UNIX_TIMESTAMP(order_date) <  '.$m[$i][1].'
				and domain_id not in (1,3,6,23,24,25,26)
			','mytotal');

			# lo fee total
			$data['month'][$i+6] = core_db::col('
				select sum((grand_total * (fee_percen_lo / 100))) as mytotal
				from lo_order
				'.$status_exclude.'
				and UNIX_TIMESTAMP(order_date) >= '.$m[$i][0].'
				and UNIX_TIMESTAMP(order_date) <  '.$m[$i][1].'
				and domain_id not in (1,3,6,23,24,25,26)
			','mytotal');
		}
		core::log(print_r($data,true));

		#echo(date('Y-m-s H:i:s',$m[1][0]));
		#echo(date('Y-m-s H:i:s',$m[1][1]));

		return $data;
	}

	function home()
	{
		global $core;
		#echo('<pre>');
		#print_r($core->session);
		$this->dashboard_note();
		if(lo3::is_admin())
		{
			#$this->release_news();
			$this->admin_dashboard();
		}
		else if(lo3::is_market())
		{
			$this->release_news();
			$this->market_dashboard();
		}
		else if(lo3::is_customer())
		{
			core::log('user active state: '.$core->session['is_active']);
			core::log('org  active state: '.$core->session['org_is_active']);
			if($core->session['allow_sell'] == 1)
			{
				core::log('this is a seller');
				#echo('<h1>login note viewed: '.$core->session['login_note_viewed'].'</h1>');
				$this->release_news();
				if($core->session['is_active'] == 1 && $core->session['org_is_active'] == 1)
				{
					$this->seller_dashboard();
				}
				else
				{
					if($core->session['is_active'] != 1)
						$this->buyer_awaiting_emailconfirm();
					else
						$this->buyer_awaiting_mm();

				}
			}
			else
			{
				core::log('this is a buyer');
				if($core->session['is_active'] == 1 && $core->session['org_is_active'] == 1)
				{
					$this->buyer_dashboard();
				}
				else
				{
					if($core->session['is_active'] != 1)
						$this->buyer_awaiting_emailconfirm();
					else
						$this->buyer_awaiting_mm();

				}
			}
		}
	}
}

?>
