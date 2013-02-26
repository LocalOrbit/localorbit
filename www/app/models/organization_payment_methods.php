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
		
		
		$myclient = new SoapClient($core->config['ach']['url']);
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
		$transaction->CustomerName  = strtoupper($this['name_on_account']);
		$transaction->CustomerRoutingNo  = core_crypto::decrypt($this['nbr2']);
		$transaction->CustomerAcctNo     = core_crypto::decrypt($this['nbr1']);
		$transaction->TransAmount   = $amount;
		$transaction->TransactionCode = 'WEB';
		$transaction->CustomerAcctType = 'C';
		$transaction->OriginatorName  = $core->config['ach']['Company'];
		$transaction->OpCode = 'R';
		$transaction->CustTransType = $CustTransType;
		$transaction->Memo = $memo;
		$transaction->CheckOrTransDate = date('Y-m-d');
		$transaction->EffectiveDate = date('Y-m-d');
		$transaction->AccountSet = $core->config['ach']['AccountSet'];
		
		$myresult = $myclient->SendACHTrans(array(
			'InpCompanyInfo'=>$mycompanyinfo,
			'InpACHTransRecord'=>$transaction,
		));
		
		if($myresult->SendACHTransResult->Status !='SUCCESS')
		{
			echo("ERROR\n");
			echo('Transaction message: '.print_r($myresult,true)."\n------------\nTransaction Details:".print_r($transaction,true));
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
			echo("PAYMENT SUCCESS!\n");
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