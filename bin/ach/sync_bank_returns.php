<?php
//ACHWORKS‐SOAP Ver3.0 GetACHReturnsHist (gets ach return and settlement records at specified date range) 
//3.25.2010 ‐ rico pamplona, rpamplonaATachworksDOTcom 
//company info 

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();

class CompanyInfo { 
      public $SSS; 
      public $Company; 
      public $CompanyKey; 
} 
 
 
//CompanyInfo 
$mycompanyinfo = new CompanyInfo;
$mycompanyinfo -> SSS = "RPP";
$mycompanyinfo -> LocID = "2764";
$mycompanyinfo -> Company = "LOCALORBITLLC001";
$mycompanyinfo -> CompanyKey = 'QSFTHJJP3JCMFBXGQEDBZWKDBPPHFM2'; 
 
$myDateFrom = date('Y-m-d',time() - (2* 86400)); //include leading zero for mm and dd e.g. 01 for Jan 
$myDateTo  = date('Y-m-d',time() + 86400);   //include leading zero for mm and dd e.g. 01 for Jan 
 
 
//SOAP call ‐ test server 
$myclient = new SoapClient("https://securesoap.achworks.com/dnet/achws.asmx?WSDL"); 
$myresult = $myclient->GetACHReturnsHist(array("InpCompanyInfo"=>$mycompanyinfo, "ReturnDateFrom"=>$myDateFrom, "ReturnDateTo"=>$myDateTo))->GetACHReturnsHistResult; 
 
//print status and details 
print($myresult->Status . ", " . $myresult->Details . "\n"); 
 
echo("results received, determining records to update\n");
$trace_nbrs = array();
if(is_object($myresult->ACHReturnRecords->ACHReturnRecord))
{	
	foreach ($myresult->ACHReturnRecords->ACHReturnRecord as $myACHReturnRecord)
	{
		if($myACHReturnRecord->FrontEndTrace.'' != '')
			$trace_nbrs[$myACHReturnRecord->FrontEndTrace] = true;
		#print_r($myresult->ACHReturnRecords->ACHReturnRecord); 
		//~ print("FrontEndTrace:" . $myACHReturnRecord->FrontEndTrace . ", EffectiveDate:" . $myACHReturnRecord->EffectiveDate . ", 
			//~ Name:" . $myACHReturnRecord->CustomerName . ", Amount:" . $myACHReturnRecord->TransAmount . ", 
			//~ ResponseCode:" . $myACHReturnRecord->ResponseCode . ", ActionDetail:" . $myACHReturnRecord->ActionDetail . 
			//~ "\n");
		
	}
}
else
{
	exit("no history to enter\n");
}

if(count($trace_nbrs) == 0)
{
	exit("no history to enter\n");
}

echo("Trace Nbrs assembled: \n");
$trace_nbrs = array_keys($trace_nbrs);
$payment_ids = array();
print_r($trace_nbrs);

$trace_history = array();
echo("\nLooping over traces to build history hash\n");

foreach($trace_nbrs as $trace)
{
	# get the payment info
	$payment = core_db::row('select * from payments where payment_method_id=3 and ref_nbr=\''.mysql_escape_string($trace).'\';');

	# if there's a valid payment, get the history and hash it by the ach works unique id
	if(is_numeric($payment['payment_id']))
	{
		echo("Found a valid payment: ".$payment['payment_id'].", looking for history\n");
		$payment_ids[$trace] = $payment['payment_id'];
		$sql = "select * from payments_ach_history where payment_id=".$payment['payment_id'];
		$col = new core_collection($sql);
		$trace_history[$trace] = $col->to_hash('event_id');
	}
}


foreach ($myresult->ACHReturnRecords->ACHReturnRecord as $record)
{
	#print_r($record);
	echo("Looping over events for ".$record->FrontEndTrace." to save\n");
	if(is_numeric($payment_ids[$record->FrontEndTrace]))
	{
		if(!isset($trace_history[$record->FrontEndTrace][$record->BackEndSN]))
		{
			echo("\tFound new event: ".$record->BackEndSN."\n");
			$event = core::model('payments_ach_history');
			$event['event_id'] = $record->BackEndSN;
			$event['payment_id'] = $payment_ids[$record->FrontEndTrace];
			$event['response_code'] = trim($record->ResponseCode);
			$event['action_detail'] = trim($record->ActionDetail);
			$event['effective_date'] = str_replace('T',' ',$record->EffectiveDate);
			$event['action_date'] = str_replace('T',' ',$record->ActionDate);
			$event->save();
		}
		else
		{
			echo("\tDupe found: ".$record->BackEndSN."\n");
		}
	}
}

exit("---------------------\nProcessing complete\n");
?> 