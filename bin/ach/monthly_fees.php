#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('crypto');

$actually_do_payment = $argv[1] == 'yes';

if($actually_do_payment)
	echo("REALLY DOING IT\n");


# get the list of all domains
$domains = core::model('domains')
	->autojoin(
		'left',
		'organization_payment_methods',
		'(domains.opm_id=organization_payment_methods.opm_id)',
		array('organization_payment_methods.*')
	)->collection()->filter('domain_id','=',26);
	
	
# loop through the domains and calculate the fee
foreach($domains as $domain)
{
	
	echo('checking '.$domain['name']."\n");
	echo("\tservice fee is:      ".$domain['service_fee']."\n");
	echo("\tservice schedule is: ".$domain['sfs_id']."\n");
	echo("\tlast paid is:        ".$domain['service_fee_last_paid']."\n");   
	
	# get some date info
	$do_fee = false;
	$last = explode('-',date('Y-m',$domain['service_fee_last_paid']));
	$now  = explode('-',date('Y-m',time()));
	
	# if the year has changed, adjust the number of months accordingly.
	if($now[0] != $last[0])
	{
	}

	echo('difference between last paid is: '.$last_paid_difference."\n");
	switch($domain['sfs_id'])
	{
		case 1:
			$min_diff = 1;
			break;
		case 2:
			$min_diff = 6;
			break;
		case 3:
			$min_diff = 12;
			break;
	}
	
	echo('months: '.intval($now[1]).' / '.intval($last[1])."\n");
	
	# check if we need to charge the client
	if((intval($now[1]) - intval($last[1])) > $min_diff)
	{
		echo("need to do payment\n");
		do_monthly_payment($domain);
	}
	else
	{
		echo("no need to do payment\n");
	}
}

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


function do_monthly_payment($domain)
{
	global $core;
	echo("called\n");
	
	$account_nbr = core_crypto::decrypt($domain['nbr1']);
	$routing_nbr = core_crypto::decrypt($domain['nbr2']);
	
	if(!is_numeric($account_nbr) || !is_numeric($routing_nbr))
	{
		core::process_command('emails/ach_error',false,
			'ACH Error: bank account not setup for '.$domain['name'],
			'It appears that this domain does not have their bank account fully setup. Please verify the details with the client'
		);
	}
	else
	{
	
		echo('creating payment using '.$domain['name_on_account'].' / ');
		echo(core_crypto::decrypt($domain['nbr1']));
		echo('/');
		echo(core_crypto::decrypt($domain['nbr2']));
		echo("\n");
		
		
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
		
		$transaction->FrontEndTrace = 'test00003';
		$transaction->CustomerName  = strtoupper($domain['name_on_account']);
		$transaction->CustomerRoutingNo  = 
		$transaction->CustomerAcctNo     = core_crypto::decrypt($domain['nbr1']);
		$transaction->TransAmount   = $domain['service_fee'];
		$transaction->TransactionCode = 'WEB';
		$transaction->CustomerAcctType = 'C';
		$transaction->OriginatorName  = $core->config['ach']['Company'];
		$transaction->OpCode = 'R';
		$transaction->CustTransType = 'D';
		$transaction->Memo = 'Service Fee for domain '.$domain['name'];
		$transaction->CheckOrTransDate = date('Y-m-d');
		$transaction->EffectiveDate = date('Y-m-d');
		$transaction->AccountSet = $core->config['ach']['AccountSet'];

		echo('ready to transact: '.print_r($transaction,true)."\n");
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
		
		#print_r($myresult);
	}
	
}

exit("done\n");

?>