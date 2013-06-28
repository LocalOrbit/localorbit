<?php

class PayPalApi {	
	public function PayPalApi() {
	}

	
	private function getPaypalApiRS($rqParamString) {
		global $core;
		
		try {
			$url  = $core->config['payments']['paypal']['url'];
			$url .= '?VERSION=85.0';
			$url .= '&USER='.$core->config['payments']['paypal']['username'];
			$url .= '&PWD='.$core->config['payments']['paypal']['password'];
			$url .= '&SIGNATURE='.$core->config['payments']['paypal']['signature'];
			//$url .= '&'.urlencode($rqParamString);
			$url .= '&'.$rqParamString;
		
			//echo $url;
			
			# setup curl
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $url);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
			curl_setopt($ch, CURLOPT_TIMEOUT, 8);
				
			$response = curl_exec($ch);
			
			curl_close($ch);
				
			return $response;
				
		} catch (Exception $e) {
			 throw new Exception('Error with Paypal: '.$e->getMessage());
		}
	}

	
	public function getExpressCheckoutButton() {
		global $core;
	
		$cart_total = $this->getCartTotal();
	
		$rqParamString = 'METHOD=SetExpressCheckout';
		$rqParamString .= '&PAYMENTREQUEST_0_AMT='.$cart_total;
		$rqParamString .= '&PAYMENTREQUEST_0_CURRENCYCODE=USD';
	
		///$rqParamString .= '&RETURNURL='.$this->getDomainUrl().'/test.php';
		//$rqParamString .= '&CANCELURL='.$this->getDomainUrl().'/test.php';
		
		// inline  *change checkout.php page too
		//$rqParamString .= '&RETURNURL='.$this->getDomainUrl().'/app/controllers/catalog/views/payment_paypal_express_inline.php';

		// popup
		$rqParamString .= '&RETURNURL='.$this->getDomainUrl().'/app/controllers/catalog/views/payment_paypal_express_popup.php';
		$rqParamString .= '&CANCELURL='.$this->getDomainUrl().'/app/controllers/catalog/views/payment_paypal_express_popup_close.php';
		$rqParamString .= '&SOLUTIONTYPE=Sole';
		$rqParamString .= '&L_PAYMENTTYPE0=InstantOnly';
	

		// Items
		$rqParamString .= '&PAYMENTREQUEST_0_PAYMENTACTION=Sale';	
		$rqParamString .= '&PAYMENTREQUEST_0_AMT='.$cart_total;	
		$rqParamString .= '&PAYMENTREQUEST_0_SHIPPINGAMT=0';	
		$rqParamString .= '&PAYMENTREQUEST_0_TAXAMT=0';
		$rqParamString .= '&PAYMENTREQUEST_0_SHIPDISCAMT=0';
		$rqParamString .= '&PAYMENTREQUEST_0_CURRENCYCODE=USD';	
		$rqParamString .= '&PAYMENTREQUEST_0_DESC='.urlencode('Local Orbit EC payment');
		

		$rqParamString .= '&L_PAYMENTREQUEST_0_NAME0='.urlencode('misc items');	
		$rqParamString .= '&L_PAYMENTREQUEST_0_DESC0='.urlencode('');	
		$rqParamString .= '&L_PAYMENTREQUEST_0_AMT0='.$cart_total;	
		//$rqParamString .= '&L_PAYMENTREQUEST_0_NUMBER0=';		
		$rqParamString .= '&L_PAYMENTREQUEST_0_QTY0=1';		
		$rqParamString .= '&L_PAYMENTREQUEST_0_TAXAMT0=0';
		
		

		//$rqParamString .= 'PAYMENTREQUEST_0_PAYMENTACTION=Sale&PAYMENTREQUEST_0_AMT=4&PAYMENTREQUEST_0_ITEMAMT=2&PAYMENTREQUEST_0_SHIPPINGAMT=1&PAYMENTREQUEST_0_TAXAMT=2&PAYMENTREQUEST_0_SHIPDISCAMT=-1&PAYMENTREQUEST_0_CURRENCYCODE=USD&PAYMENTREQUEST_0_DESC=test EC payment&L_PAYMENTREQUEST_0_NAME0=item1&L_PAYMENTREQUEST_0_DESC0=item1 description&L_PAYMENTREQUEST_0_AMT0=1&L_PAYMENTREQUEST_0_NUMBER0=a&L_PAYMENTREQUEST_0_QTY0=1&L_PAYMENTREQUEST_0_TAXAMT0=1&L_PAYMENTREQUEST_0_NAME1=item2&L_PAYMENTREQUEST_0_DESC1=item2 description&L_PAYMENTREQUEST_0_AMT1=1&L_PAYMENTREQUEST_0_NUMBER1=b&L_PAYMENTREQUEST_0_QTY1=1&L_PAYMENTREQUEST_0_TAXAMT1=1';
		
		//echo $rqParamString;
		
		
		$button = '';
		try {
			$response = $this->getPaypalApiRS($rqParamString);
	
			parse_str($response,$response_vars);
	
			if ($response_vars['ACK'] == 'Success') {
				// DIGITAL You are not signed up to accept payment for digitally delivered goods. 
				// $payalUrl = 'https://www.paypal.com/incontext?token='.$response_vars['TOKEN'];
				
				$paypalUrl = 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token='.$response_vars['TOKEN'];

		
				
				// popup
				$js = 'javascript:void window.open(\''.$paypalUrl.'\',\'123654786441\',\'width=950,height=800,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0\');return false;';
				
				// inline
				//$js = "window.location='".$paypalUrl."';";
	
				$button.= '<label class="radio">';				
					$button.= '<input id="payment_method_paypal_popup" name="payment_method" type="radio" value="paypal_popup" onclick="'.$js.'"/>';
					$button.= 'Pay by Credit Card';
				$button.= '</label>';
				//$button.= '<a href="'.$paypalUrl.'" onclick="javascript:void window.open(\''.$paypalUrl.'\',\'1371801313845\',\'width=950,height=800,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0\');return false;">';
				//$button.= '<img src="https://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif" style="margin-right:7px;">';
				//$button.= '</a>';
			} else {
				$button = 'Error with Paypal: '.$response_vars['L_SHORTMESSAGE0'];
				$button = 'Error with Paypal: '.$response_vars['L_LONGMESSAGE0'];
			}
		} catch (Exception $e) {
			$button = 'Error with Paypal: '.$response_vars['L_SHORTMESSAGE0'];
			$button = 'Error with Paypal: '.$response_vars['L_LONGMESSAGE0'];
		}
	
		return $button;
	}


	public function confirmTransaction() {
		global $core;

		// HACKER CHECK - confirm amount returned is same as cart
		$cart_total = $this->getCartTotal();
		
		
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
				throw new Exception("PayPal Error: ".$response_vars['L_SHORTMESSAGE0']);
				
			}
		} else {
			throw ("PayPal Error: ".$response_vars['L_SHORTMESSAGE0']);
		}
	}
	
	
	
	
	

	private function getCartTotal() {
		global $core;
		
		$cart = core::model('lo_order')->get_cart();
		return core_format::parse_price($cart['grand_total']);
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


// paypal_express_checkout_success.php
//
/* 

call GetExpressCheckoutDetails 
	get token
call DoExpressCheckoutPayment
	get &ACK=Success
	get token
call DoExpressCheckoutPayment 
	dbase &PAYMENTREQUEST_0_TRANSACTIONID=043144440L487742J

Apps
	https://developer.paypal.com/webapps/developer/applications/myapps#account/createApps


		<a href="http://google.com" onclick="javascript:void window.open('http://google.com','1371801313845','width=400,height=500,toolbar=0,menubar=0,location=0,status=1,scrollbars=1,resizable=1,left=0,top=0');return false;">Pop-up Window</a>
		
Paypal
	https://www.paypal.com/webapps/customerprofile/summary.view
	vavuljohn
	1j2o3h4n
	
	RAGANERICKSON
	gr0wnl0cally

	Express Checkout as popup
	https://paypalmanager.paypal.com/reskinning.do?reskinExternalUrlServiceKey=paypal&reskinSection=profile&reskinRelativeUrl=cgi-bin/webscr?cmd=_additional-payment-integration
	https://developer.paypal.com/webapps/developer/docs/classic/express-checkout/integration-guide/ECGettingStarted/
	
Customize Buyer Experience
	https://cms.paypal.com/us/cgi-bin/marketingweb?cmd=_render-content&content_ID=acct_setup/Buyer_Experience_EC&fli=true


API
	Endpoint 	api.sandbox.paypal.com
	Client 		ID Afvd9hDXcR8FFEkr1XYXQFQPNppS-ONHBkSiT_v2c9XNibtUOulEQzGzZOXQ
	Secret 		EPvhehDAv8oqCXDDObNrPHiCPmSkfzOqX4ggB330VPizjidOQB4mEIBc-Rmp


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