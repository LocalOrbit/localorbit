<?php
# this library contains functions for formatting all kinds of data, such as
# dates, prices, etc

class core_format
{
	function remove_newlines($input)
	{
		$input = str_replace("\r",'',$input);
		$input = str_replace("\n",' ',$input);
		return $input;
	}

	function addDaysToDate($date,$days){
		$endDate = date("Y-m-d", strtotime("$date +".$days." days"));
		return $endDate;
	}
	
	function hex2rgb($color)
	{
		core::log('color passed: '.$color);
		if ($color[0] == '#')
			$color = substr($color, 1);

		if (strlen($color) == 6)
			list($r, $g, $b) = array($color[0].$color[1],$color[2].$color[3],$color[4].$color[5]);
		elseif (strlen($color) == 3)
			list($r, $g, $b) = array($color[0].$color[0], $color[1].$color[1], $color[2].$color[2]);
		else
			return false;

		$r = hexdec($r);
		$g = hexdec($g);
		$b = hexdec($b);

		return array($r, $g, $b);
	}

	function parse_price($input)
	{
		$input = str_replace('$','',$input);
		$input = str_replace(' ','',$input);
		return number_format(floatval($input),2,'.','');
	}

	function parse_prices()
	{
		global $core;
		$prices = func_get_args();
		foreach($prices as $price)
		{
			$core->data[$price] = core_format::parse_price($core->data[$price]);
		}
	}

	function parse_date($input,$return_format='db')
	{
		if(is_numeric($input))
		{
		}

		$months=array(
			'jan'=>'01',
			'feb'=>'02',
			'mar'=>'03',
			'apr'=>'04',
			'may'=>'05',
			'jun'=>'06',
			'jul'=>'07',
			'aug'=>'08',
			'sep'=>'09',
			'oct'=>'10',
			'nov'=>'11',
			'dec'=>'12',
		);
		$input =  preg_split("/[\s,]+/",trim(strtolower($input)));
		
		$month = substr($input[0],0, 3);
		
		#core::log('parts of date: '.print_r($input,true));
		switch($return_format)
		{
			case 'db':
				return $input[2].'-'.$months[$input[0]].'-'.$input[1];
				break;
			case 'timestamp':				
				return mktime(0,0,0,intval($months[$month]),$input[1],$input[2]);
				break;
			default:
				exit('unknown return type for core_format::parse_date();');
				break;
		}
	}

	function price($input_price,$return_blank_zero=true)
	{
		global $core;
		$input_price = floatval($input_price);

		if($input_price == 0 && $return_blank_zero)
			return '';

		#$prefix = ;

		$input_price =((($input_price < 0)?'-':'').'$') . str_replace('-','',''.number_format(
			floatval($input_price),
			2
		));
		return $input_price;
	}

	public static function plaintext2html($input)
	{
		$output = $input;
		$output = str_replace("\n",'<br />',$output);
		$output = str_replace("\r",'',$output);
		return $output;
	}
	
	public static function fix_unix_date_range($start,$end)
	{
		global $core;
		//$trace = "fix_unix_dates ";
		$fields = func_get_args();
		
		
		if(isset($core->data[$start]))
		{
			#core::log('start date sent: '.strtotime($core->data[$start]));
			$core->data[$start] =  date("U",strtotime($core->data[$start].'T00:00:00+00:00'));
			$core->data[$start]  -= intval($core->session['time_offset']);
		}
		if(isset($core->data[$end]))
		{
			#core::log('end date sent: '.strtotime($core->data[$end]));
			$core->data[$end] =  date("U",strtotime($core->data[$end].'T00:00:00+00:00'));
			$core->data[$end]  -= intval($core->session['time_offset']);
			$core->data[$end] +=  86399;
		}
	}

	public static function fix_unix_dates()
	{
		global $core;
		//$trace = "fix_unix_dates ";
		$fields = func_get_args();
		
		foreach($fields as $field)
		{
			if(isset($core->data[$field]))
			{
				$core->data[$field] =  date("U",strtotime($core->data[$field].'T00:00:00+00:00'));
				$core->data[$field]  += intval($core->session['time_offset']);
			}
			
		}
		return;
		
		foreach($fields as $field) {
			//core::log($trace." fix_unix_dates() field=".$field);
			
			if(isset($core->data[$field]) && $core->data[$field] != '' && !is_numeric(substr($core->data[$field],0,4)))	{
				//core::log($trace." fix_unix_dates() data found and is date | field=".$field." data=".$core->data[$field]);
				$core->data[$field] = strtotime($core->data[$field]);

			} else if (isset($core->data[$field])) {
				//core::log($trace." fix_unix_dates() data is set | field=".$field." data=".$core->data[$field]);	
				
				// set default dates to big range
				if (strpos($field, "createdat1") > 0) {	
					$core->data[$field] = $core->config['time'] - (86400*30);
					//core::log($trace." fix_unix_dates() data1 found | field=".$field." data=".$core->data[$field]);		
				} else if (strpos($field, "createdat2") > 0) {
					$core->data[$field] = $core->config['time'];
					//core::log($trace." fix_unix_dates() data1 found | field=".$field." data=".$core->data[$field]);						
				}				
			}
		}
	}

	public static function fix_dates()
	{
		global $core;
		$fields = func_get_args();

		foreach($fields as $field)
		{
			if(isset($core->data[$field]) && $core->data[$field] != '' && !is_numeric(substr($core->data[$field],0,4)))
			{
				$core->data[$field] = core_format::parse_date($core->data[$field],'db');
			}
		}
	}

	public static function date($int,$format='long',$do_session_adjust=true,$do_daylight_savings_adjust=true)
	{
		global $core;
		
		//date_default_timezone_set($core->session['tz_code']);
			
		if($int == 0 || $int == '')
			return '';
		
		if(!is_numeric($int) && is_string($int)) {
			// jan 13, 2013
			if (strpos($int, ",")) {
				$int = core_format::parse_date($int,'timestamp');
				
			// 2013-09-16 22:37:48
			} else {
				$int = strtotime($int);
			}
		}

		if($do_session_adjust) {
			$int += intval($core->session['time_offset']);			
		}
		if($do_daylight_savings_adjust) {
			if (date("I", $delivery_start_time) == 0) {
				$int += 3600; 
			}
		}

		#echo('adjusted is '.date($core->config['formats']['dates'][$format],$int).'<br />');
		$format = (isset($core->config['formats']['dates'][$format]))?$core->config['formats']['dates'][$format]:$format;
		$date = date($format,$int);
		$date = str_replace('am','a.m.',$date);
		$date = str_replace('pm','p.m.',$date);
		return $date;
	}

	public static function dbdate($int,$format='long')
	{
		global $core;
		$int = ($int + $core->session['time_offset']);
		return date($core->config['formats']['dates'][$format],$int);
	}

	public static function time($time,$always_mins=false)
	{
		$suffix = ($time >= 12)?'pm':'am';
		$time = ($time > 12)?($time - 12):$time;

		$hours = intval($time);
		$mins = ($time - $hours) * 60;
		$mins = str_pad($mins,2,'0',STR_PAD_RIGHT);

		if($hours == 0)
			$hours = '12';


		$final = $hours;

		if($always_mins || $mins!='00')
			$final .= ':'.$mins;

		$final .= ' '.$suffix;


		return $final;
	}

	public static function ordinal($num)
	{
		$new_num = $num;
		if($new_num > 10) $new_num -= 10;
		if($new_num > 10) $new_num -= 10;
		if($new_num > 10) $new_num -= 10;

		switch($new_num)
		{
			case 1:
				return $num.'st';
				break;
			case 2:
				return $num.'nd';
				break;
			case 3:
				return $num.'rd';
				break;
			default:
				return $num.'th';
				break;
		}
	}

	public static function get_hex_code($value, $default = 0xFFFFFF) {
		$numValue = isset($value) ? $value : $default;
		$string = dechex($numValue);
		return '#'.str_pad($string, 7-strlen($string),'0', STR_PAD_LEFT);
	}
}

?>