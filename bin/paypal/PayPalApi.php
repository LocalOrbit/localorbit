<?php
 
class PayPalApi {	
	public function PayPalApi() {
	}

	
	private function getPaypalApiRS($rqParamStringVars) {
		global $core;
		
		try {
			$rqParamString .= 'VERSION=85.0';
			$rqParamString .= '&USER='.$core->config['payments']['paypal']['username'];
			$rqParamString .= '&PWD='.$core->config['payments']['paypal']['password'];
			$rqParamString .= '&SIGNATURE='.$core->config['payments']['paypal']['signature'];
			$rqParamString .= '&'.$rqParamStringVars;
		
			//echo $url;
			
			# setup curl
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $core->config['payments']['paypal']['url']);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
			curl_setopt($ch, CURLOPT_TIMEOUT, 8);
 			curl_setopt ($ch, CURLOPT_POSTFIELDS, $rqParamString);
				
			$response = curl_exec($ch);
			
			curl_close($ch);
				
			return $response;
				
		} catch (Exception $e) {
			 throw new Exception('Error with Paypal: '.$e->getMessage());
		}
	}


	public function getExpressCheckoutButton() {
		// popup
		//$js = 'javascript:void window.open(\'/app/controllers/catalog/views/payment_paypal_express_popup.php\',\'123654786441\',\'width=960,height=800,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0\');return false;';

		$js = 'javascript:core.paypalWindow=window.open(\'/app/catalog/payment_paypal_express_popup\',\'123654786441\',\'width=960,height=800,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0\');$(\'#checkout_buttons\').hide();return true;';
		
		
		$button.= '<label class="radio">';
			$button.= '<input id="payment_method_paypal" name="payment_method" type="radio" value="paypal" onclick="'.$js.'"/>';
			$button.= 'Pay by Credit Card';
		$button.= '</label>';
		return $button;
	}
	
	public function getExpressCheckoutRedirect($cart) {
		global $core;
		
		$rqParamString = 'METHOD=SetExpressCheckout';
	
		// popup
		$rqParamString .= '&RETURNURL='.$this->getDomainUrl().'/app/catalog/payment_paypal_express_popup_return';
		$rqParamString .= '&CANCELURL='.$this->getDomainUrl().'/app/controllers/catalog/views/payment_paypal_express_popup_close.php';
		$rqParamString .= '&SOLUTIONTYPE=Sole';
		$rqParamString .= '&L_PAYMENTTYPE0=InstantOnly';	

		
		
		// Items
		$items_total = 0;
		$discount_total = 0;
		$count = 0;
		foreach($cart->items as $item) {			
			$discount_total += $item['row_adjusted_total'] - $item['row_total'] ;
			$items_total += $item['row_total'];

			$rqParamString .= '&L_PAYMENTREQUEST_0_NAME'.$count.'='.urlencode($item['product_name']);
			$rqParamString .= '&L_PAYMENTREQUEST_0_DESC'.$count.'='.urlencode('');
			$rqParamString .= '&L_PAYMENTREQUEST_0_AMT'.$count.'='.round($item['unit_price'],2);
			$rqParamString .= '&L_PAYMENTREQUEST_0_QTY'.$count.'='.$item['qty_ordered'];
			$rqParamString .= '&L_PAYMENTREQUEST_0_TAXAMT'.$count.'=0';
			$count++;
		}
		
		$rqParamString .= '&PAYMENTREQUEST_0_PAYMENTACTION=Sale';
		$rqParamString .= '&PAYMENTREQUEST_0_CURRENCYCODE=USD';
		$rqParamString .= '&PAYMENTREQUEST_0_DESC='.urlencode('Local Orbit EC payment');

		$rqParamString .= '&PAYMENTREQUEST_0_SHIPPINGAMT='.round($cart['delivery_fee'],2);
		$rqParamString .= '&PAYMENTREQUEST_0_SHIPDISCAMT='.round($discount_total,2);
		$rqParamString .= '&PAYMENTREQUEST_0_TAXAMT=0';
		$rqParamString .= '&PAYMENTREQUEST_0_ITEMAMT='.round($items_total,2);
		$rqParamString .= '&PAYMENTREQUEST_0_AMT='.round($cart['grand_total'],2);
		
		core::log('paypal rqParamString: '.$rqParamString);
		/* echo 'delivery_fee = '.$cart['delivery_fee']."<br>";
		echo 'discount_total = '.$discount_total."<br>";
		echo 'items_total = '.$items_total."<br>";
		echo 'grand_total = '.$total."<br>"; */
		
		
		
		$button = '';
		try {
			$response = $this->getPaypalApiRS($rqParamString);
	
			parse_str($response,$response_vars);
	
			if ($response_vars['ACK'] == 'Success') {
				// DIGITAL You are not signed up to accept payment for digitally delivered goods. 
				// $payalUrl = 'https://www.paypal.com/incontext?token='.$response_vars['TOKEN'];
				
				$paypalUrl = 'https://www.';
				$paypalUrl .= ($core->config['stage'] == 'production')?'':'sandbox.';
				$paypalUrl .= 'paypal.com/cgi-bin/webscr?cmd=_express-checkout&token='.$response_vars['TOKEN'];
				#header ( "Location: ".$paypalUrl);
				//return $paypalUrl;				
			} else {
				throw new Exception("PayPal Error: ".$response_vars['L_LONGMESSAGE0']);
			}
		} catch (Exception $e) {
			throw new Exception("PayPal Error: ".$response_vars['L_LONGMESSAGE0']);
		}
	
		return $paypalUrl;
	}


	public function confirmTransaction() {
		global $core;

		// HACKER CHECK - confirm amount returned is same as cart
		$cart = core::model('lo_order')->get_cart();		
		$cart_total = str_replace(",", "", core_format::parse_price($cart['grand_total']));		//return core_format::parse_price($cart['grand_total']);
		
		
		// 1. paypal returns to page with vars in URL
		$token = $_GET["token"];
		core::log("PayPal API SUCCESS 1. paypal returns to page with vars in URL token = ".$token);
		
		// 2. confirm transaction
		$rqParamString = 'METHOD=GetExpressCheckoutDetails';
		$rqParamString .= '&TOKEN='.$token;
				
		$response = $this->getPaypalApiRS($rqParamString);
		parse_str($response,$response_vars);
		core::log("PayPal API SUCCESS 2. confirm transaction response = ".$response);
			
			
		if ($response_vars['AMT'] != $cart_total) {
			core::log("PayPal Error: Amounts do not match ".$response_vars['AMT']. " != ".$cart_total);
			throw new Exception("PayPal Error: Amounts do not match ".$response_vars['AMT']. " != ".$cart_total);
		}
		
				

		if ($response_vars['ACK'] == 'Success') {
			$token = $response_vars['TOKEN'];
			$payerID = $response_vars['PAYERID'];
			

			// 3. process transaction
			$rqParamString = 'METHOD=DoExpressCheckoutPayment';
			$rqParamString .= '&TOKEN='.$token;
			$rqParamString .= '&PAYERID='.$payerID;
			$rqParamString .= '&PAYMENTREQUEST_0_AMT='.$cart_total;
			$rqParamString .= '&PAYMENTREQUEST_0_PAYMENTACTION=Sale';
			
			
			
			$response = $this->getPaypalApiRS($rqParamString);
			parse_str($response,$response_vars);
			if ($response_vars['ACK'] == 'Success') {
				core::log("PayPal API SUCCESS 3. process transaction response = ".$response);
				
				return $response_vars['PAYMENTINFO_0_TRANSACTIONID'];				
			} else {
				throw new Exception("PayPal Error1: ".$response_vars['L_LONGMESSAGE0']." cart total=".$cart['grand_total']);
				
			}
		} else {
			throw new Exception("PayPal Error2: ".$response_vars['L_LONGMESSAGE0']." cart total=".$cart['grand_total']);
		}
	}
	
	
		
	private function getDomainUrl() {		
		if ($_SERVER['SERVER_PORT'] == "80") { 
			return "http://".$_SERVER['HTTP_HOST'];
		} else {
			return "https://".$_SERVER['HTTP_HOST'];
		}
		
	}
}




$payPalApi = new PayPalApi();

/* 
Apps
	https://developer.paypal.com/webapps/developer/applications/myapps#account/createApps
		<a href="http://google.com" onclick="javascript:void window.open('http://google.com','1371801313845','width=400,height=500,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0');return false;">Pop-up Window</a>
		
Paypal
	https://www.paypal.com/webapps/customerprofile/summary.view
	vavuljohn
	1j2o3h4n
	
	RAGANERICKSON
	gr0wnl0cally
	
https://www.paypal.com/us/cgi-bin/webscr?cmd=_flow&SESSION=phzKC4vWlAp3Kql4K_lT8Er6g9JTIwzTLUgmaK_A44vgU-MwewRbDAE8tNS&dispatch=5885d80a13c0db1f8e263663d3faee8d4e181b3aff599f99a338772351021e7d
	RAGANERICKSON
	gr0wnl0cally

Customize Buyer Experience
	https://cms.paypal.com/us/cgi-bin/marketingweb?cmd=_render-content&content_ID=acct_setup/Buyer_Experience_EC&fli=true


API
	Endpoint 	api.sandbox.paypal.com
	Client 		ID Afvd9hDXcR8FFEkr1XYXQFQPNppS-ONHBkSiT_v2c9XNibtUOulEQzGzZOXQ
	Secret 		EPvhehDAv8oqCXDDObNrPHiCPmSkfzOqX4ggB330VPizjidOQB4mEIBc-Rmp
	
Express Checkout as popup
	https://paypalmanager.paypal.com/reskinning.do?reskinExternalUrlServiceKey=paypal&reskinSection=profile&reskinRelativeUrl=cgi-bin/webscr?cmd=_additional-payment-integration
	https://developer.paypal.com/webapps/developer/docs/classic/express-checkout/integration-guide/ECGettingStarted/
	

Test accounts
	https://developer.paypal.com/webapps/developer/applications/accounts
	test-buyer@localorb.it
	a1b2c3d4 

Payment Page setttings
	https://paypalmanager.paypal.com/settings.do
	i dont have admin to that
	
	
Adaptive Payments (nice popup)
	http://paypal.github.io/ ***************
	https://developer.paypal.com/webapps/developer/docs/classic/adaptive-payments/integration-guide/APIntro/	
		section "Setting Up Web Pages to Invoke the Embedded Payment Flow Using a Lightbox"
	https://developer.paypal.com/webapps/developer/docs/classic/adaptive-payments/gs_AdaptivePayments/	
	
*/

?>