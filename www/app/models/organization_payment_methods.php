<?php
class core_model_organization_payment_methods extends core_model_base_organization_payment_methods
{
	
	function make_payment($trace_nbr,$amount)
	{
		global $core;
		core::log('making a payment now. Heres the info: '.print_r($this->__data,true));
		
	
		
		$account_nbr = core_crypto::decrypt($this['nbr1']);
		$routing_nbr = core_crypto::decrypt($this['nbr2']);
		
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
		
		$transaction->FrontEndTrace = $trace_nbr;
		$transaction->CustomerName  = strtoupper($this['name_on_account']);
		$transaction->CustomerRoutingNo  = $routing_nbr;
		$transaction->CustomerAcctNo     = $account_nbr;
		$transaction->TransAmount   = $amount;
		$transaction->TransactionCode = 'WEB';
		$transaction->CustomerAcctType = 'C';
		$transaction->OriginatorName  = $core->config['ach']['Company'];
		$transaction->OpCode = 'R';
		$transaction->CustTransType = 'D';
		$transaction->Memo = '';
		$transaction->CheckOrTransDate = date('Y-m-d');
		$transaction->EffectiveDate = date('Y-m-d');
		$transaction->AccountSet = $core->config['ach']['AccountSet'];

		echo('ready to transact: '.print_r($transaction,true)."\n");
		/*
		$myresult = $myclient->SendACHTrans(array(
			'InpCompanyInfo'=>$mycompanyinfo,
			'InpACHTransRecord'=>$transaction,
		));
		
		echo("trans sent \n");
		
		if($myresult->SendACHTransResult->Status !='SUCCESS')
		{
			echo("ERROR\n");
			#echo('Transaction message: '.print_r($myresult,true)."\n------------\nTransaction Details:".print_r($transaction,true));
			#core::process_command('emails/ach_error',false,'test','test');
			#echo("EMAIL SENT\n");
			
			core::process_command('emails/ach_error',false,
				'ACH FAIL for '.$domain['name'].' monthly fees',
				'Transaction message: '.print_r($myresult,true)."\n------------\nTransaction Details:".print_r($transaction,true)
			);
			
			
		}
		*/
	
	}
	
	
	
}


/* UTILITY CLASSES FOR ACH */

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

?>