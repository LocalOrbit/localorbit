<?php

# these classes are needed to make a payment
class CompanyInfo {
	public $SSS;
	public $LocID;
	public $Company;
	public $CompanyKey;
}

class  InpACHTransRecord{
	public $SSS;
	public $LocID;
	public $FrontEndTrace;
	public $CustomerName;
	public $CustomerRoutingNo;
	public $CustomerAcctNo;
	public $CompanyKey;
}



class core_model_organization_payment_methods extends core_model_base_organization_payment_methods
{
	function make_payment($trace='',$memo='',$amount='')
	{
		global $core;
		
		$CustTransType = 'D';
		if($amount < 0)
		{
			$amount = (-1) * $amount;
			$CustTransType = 'C';
		}
		
		$option=array('trace'=>1);
		$myclient = new SoapClient($core->config['ach']['url'], $option);
		$mycompanyinfo = new CompanyInfo();
		$mycompanyinfo->SSS        = $core->config['ach']['SSS'];
		$mycompanyinfo->LocID      = $core->config['ach']['LocID'];
		$mycompanyinfo->Company    = $core->config['ach']['Company'];
		$mycompanyinfo->CompanyKey = $core->config['ach']['CompanyKey'];
		
		$transaction = new InpACHTransRecord;
		$transaction->SSS        = $core->config['ach']['SSS'];
		$transaction->LocID      = $core->config['ach']['LocID'];
		$transaction->CompanyKey = $core->config['ach']['CompanyKey'];
		
		
		$transaction->FrontEndTrace = $trace;
		$transaction->CustomerName  = substr(strtoupper($this['name_on_account']),0,22);
		$transaction->CustomerRoutingNo  = core_crypto::decrypt($this['nbr2']);
		$transaction->CustomerAcctNo     = core_crypto::decrypt($this['nbr1']);
		$transaction->TransAmount   = $amount;
		
		if($CustTransType == 'D')
		{
			# if this is a debit, we can use the WEB trans code
			$transaction->TransactionCode = 'WEB';
		}
		else
		{
			# if it's a credit ,we need to use either PPD or CCD
			$transaction->TransactionCode = 'CCD';
		}
		
		$transaction->CustomerAcctType = 'C';
		$transaction->OriginatorName  = $core->config['ach']['Company'];
		$transaction->OpCode = 'S';
		$transaction->CustTransType = $CustTransType;
		$transaction->Memo = $memo;
		$transaction->CheckOrTransDate = date('Y-m-d');
		$transaction->EffectiveDate = date('Y-m-d');
		$transaction->AccountSet = $core->config['ach']['AccountSet'];
		
		$myresult = $myclient->SendACHTrans(array(
			'InpCompanyInfo'=>$mycompanyinfo,
			'InpACHTransRecord'=>$transaction,
		));


		$this['request'] = $myclient->__getLastRequest();		
		$this['response'] = $myclient->__getLastResponse();	
		
		core::log(print_r($myresult,true));		
		
		
		if($myresult->SendACHTransResult->Status !='SUCCESS')
		{
			core::log("ERROR\n");
			core::log('Transaction message: '.print_r($myresult,true)."\n------------\nTransaction Details:".print_r($transaction,true));
			#core::process_command('emails/ach_error',false,'test','test');
			#echo("EMAIL SENT\n");
			
			core::process_command('emails/ach_error',false,
				'ACH FAIL for '.$domain['name'].' monthly fees',
				'Transaction message: '.print_r($myresult,true)."\n------------\nTransaction Details:".print_r($transaction,true)
			);
			
			return false;
		}
		else
		{
			core::log("PAYMENT SUCCESS!\n");
			return true;
		}

	}
}

function organization_payment_methods__formatter_dropdown($data)
{
	$data['dropdown_text']  = 'ACH: '.$data['name_on_account'];
	$data['dropdown_text'] .= ' - *********'.$data['nbr1_last_4'];
	return $data;
}


?>