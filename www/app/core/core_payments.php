<?php

class core_payments
{
	public static function get_cc_type($ccNum)
	{
		$ccNum = trim($ccNum).'';
		if (ereg("^5[1-5][0-9]{14}$", $ccNum))
		 return "MasterCard";

		if (ereg("^4[0-9]{12}([0-9]{3})?$", $ccNum))
		 return "Visa";

		if (ereg("^3[47][0-9]{13}$", $ccNum))
		 return "Amex";

		if (ereg("^3(0[0-5]|[68][0-9])[0-9]{11}$", $ccNum))
		 return "Diners Club";

		if (ereg("^6011[0-9]{12}$", $ccNum))
		 return "Discover";

		if (ereg("^(3[0-9]{4}|2131|1800)[0-9]{11}$", $ccNum))
		 return "JCB";
		/*
		$nbr = trim($nbr).'';
		if(substr($nbr,0,2) == '34' || substr($nbr,0,2) == '37')
			return 'Amex';
		if(substr($nbr,0,1) == '4')
			return 'Visa';
		if(substr($nbr,0,2) == '55')
			return 'MasterCard';
		if(substr($nbr,0,4) == '6011')
			return 'Discover';
		return 'unknown';
		*/
	}
	
	# returns an array with the following indices:
	# success:(bool)
	# payment_url:(varchar): this is what was sent to paypal, sans cc info
	# TRANSACTIONID:(varchar): returend by paypal
	# CORRELATIONID:(varchar): returend by paypal
	# ERROR_CODE:int: returend by paypal
	# SHORT_ERROR:varchar: returend by paypal
	# LONG_ERROR:varchar: returend by paypal
	public static function paypal_cc($first_name,$last_name,$street,$city,$state,$zip,$country,$amount,$cc_nbr,$cc_type,$exp_date,$cvv2)
	{
		global $core;
		
		# build basic url
		$url  = $core->config['payments']['paypal']['url'];
		$url .= '?VERSION=85.0';
		$url .= '&METHOD=DoDirectPayment';
		$url .= '&PAYMENTACTION=Sale';
		$url .= '&IPADDRESS='.$_SERVER['REMOTE_ADDR'];
		$url .= '&USER='.$core->config['payments']['paypal']['username'];
		$url .= '&PWD='.$core->config['payments']['paypal']['password'];
		$url .= '&SIGNATURE='.$core->config['payments']['paypal']['signature'];
		$url .= '&CURRENCYCODE=USD';
		
		# add the user fields
		$url .= '&FIRSTNAME='.urlencode($first_name);
		$url .= '&LASTNAME='.urlencode($last_name);
		$url .= '&STREET='.urlencode($street);
		$url .= '&CITY='.urlencode($city);
		$url .= '&STATE='.urlencode($state);
		$url .= '&ZIP='.urlencode($zip);
		$url .= '&COUNTRYCODE='.$country;
		
		core::log('PAYPAL: '.$url);
		$logable_url = $url;
		
		# add the cc fields
		$url .= '&AMT='.urlencode($amount);
		$url .= '&CREDITCARDTYPE='.urlencode($cc_type);
		$url .= '&EXPDATE='.urlencode($exp_date);
		$url .= '&CVV2='.urlencode($cvv2);
		$url .= '&ACCT='.urlencode($cc_nbr);

		
		# setup curl
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
		curl_setopt($ch, CUROPT_SSL_VERIFYHOST, 0);
		curl_setopt($ch, CURLOPT_VERBOSE, 1);

		$response = curl_exec($ch);
		curl_close($ch);
		$text = ob_get_clean();
		parse_str($text,$response_vars);
		
		# handle the response. If we've got an error, report it.
		if($response_vars['ACK'] == 'Success')
		{
			return array(
				'success'=>($response_vars['ACK'] == 'Success'),
				'payment_url'=>$logable_url,
				'TRANSACTIONID'=>$response_vars['TRANSACTIONID'],
				'CORRELATIONID'=>$response_vars['CORRELATIONID'],
			);
		}
		else
		{
			return array(
				'success'=>($response_vars['ACK'] == 'Success'),
				'payment_url'=>$logable_url,
				'ERROR_CODE'=>$response_vars['L_ERRORCODE0'],
				'CORRELATIONID'=>$response_vars['CORRELATIONID'],
				'SHORT_ERROR'=>$response_vars['L_SHORTMESSAGE0'],
				'LONG_ERROR'=>$response_vars['L_LONGMESSAGE0'],
			);
		}		
	}
	
	function authorize_cc()
	{
	}
	
}

?>