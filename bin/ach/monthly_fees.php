#!/usr/bin/php
<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();

core::load_library('crypto');

global $actually_do_payment;
$actually_do_payment = ($argv[1] == 'do-ach');

if($actually_do_payment)
	echo("REALLY DOING IT\n");


# get the list of all domains
$domains = core::model('domains')
	->autojoin(
		'left',
		'organization_payment_methods',
		'(domains.opm_id=organization_payment_methods.opm_id)',
		array('organization_payment_methods.*')
	)
	->collection()
	->filter('service_fee','>',0)
	->filter('is_live','=',1);
	

	
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
		$now[1] + 12;
	}
	$last_paid_difference  = $now[1] - $last[1];

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
	if((intval($now[1]) - intval($last[1])) >= $min_diff)
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
	global $core,$actually_do_payment;
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
		
		$trace = 'LSO-';
		if($core->config['stage'] != 'production')
		{
			$trace .= $core->config['stage'].time().'-';
		}
		$trace .= $domain['domain_id'].'-';
		$trace .= date('Ym');
		echo "trace is: ".$trace."\n";
		
		$transaction->FrontEndTrace = $trace;
		$transaction->CustomerName  = strtoupper($domain['name_on_account']);
		$transaction->CustomerRoutingNo  = core_crypto::decrypt($domain['nbr2']);
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

		if($actually_do_payment)
		{
			
			echo('ready to transact: '.print_r($transaction,true)."\n");
			$myresult = $myclient->SendACHTrans(array(
				'InpCompanyInfo'=>$mycompanyinfo,
				'InpACHTransRecord'=>$transaction,
			));
			
			echo("trans sent \n");
			
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
				
				
			}
			else
			{
				# since the transation succeeded, we need to add all of the payable info
				# to the database and update the last paid date.
				
				$payable = core::model('payables');
				$payable['from_org_id'] = $domain['payable_org_id'];
				$payable['to_org_id'] = 1;
				$payable['domain_id'] = $domain['domain_id'];
				$payable['payable_type_id'] = 5;
				$payable['parent_obj_id'] = $domain['domain_id'];
				$payable['amount'] = $domain['service_fee'];
				$payable['description'] = $trace;
				#exit('description is: '.$payable['description']);
				$payable->save();
				
				$invoice = core::model('invoices');
				$invoice['from_org_id'] = $domain['payable_org_id'];
				$invoice['to_org_id'] = 1;
				$invoice['amount'] = $domain['service_fee'];
				$invoice->save();
				
				$payable['invoice_id'] = $invoice['invoice_id'];
				$payable->save();
				
				$payment = core::model('payments');
				$payment['from_org_id'] = $domain['payable_org_id'];
				$payment['to_org_id'] = 1;
				$payment['amount'] = $domain['service_fee'];
				$payment['payment_method_id'] = 3;
				$payment['ref_nbr'] = $trace;
				$payment->save();
				
				$xpi = core::model('x_invoices_payments');
				$xpi['invoice_id']  = $invoice['invoice_id'];
				$xpi['payment_id']  = $payment['payment_id'];
				$xpi['amount_paid'] = $domain['service_fee'];
				$xpi->save();
				
				#core_db::
			}
		}
		else
		{
			echo "NOT actually performing monthly fees\n";
		}
		
		#print_r($myresult);
	}
	
}

exit("done\n");

?>