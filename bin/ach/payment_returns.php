<?php
//ACHWORKS‐SOAP Ver3.0 GetACHReturnsHist (gets ach return and settlement records at specified date range) 
//3.25.2010 ‐ rico pamplona, rpamplonaATachworksDOTcom 
//company info 
class CompanyInfo { 
      public $SSS; 
      public $Company; 
      public $CompanyKey; 
} 
 
$config = array(
	'days'=>1,
	'code'=>'2STL,3RET,4INT',
);


array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}
$config['code'] = explode(',',$config['code']);
echo("\nbeginning processing. using the following config:\n\n".print_r($config,true)."\n\n");


//CompanyInfo 
$mycompanyinfo = new CompanyInfo;
$mycompanyinfo -> SSS = "RPP";
$mycompanyinfo -> LocID = "2764";
$mycompanyinfo -> Company = "LOCALORBITLLC001";
$mycompanyinfo -> CompanyKey = 'QSFTHJJP3JCMFBXGQEDBZWKDBPPHFM2'; 
 
$myDateFrom = date('Y-m-d',time() - ($config['days'] * 86400)); //include leading zero for mm and dd e.g. 01 for Jan 
$myDateTo  = date('Y-m-d',time() + 86400);   //include leading zero for mm and dd e.g. 01 for Jan 
 
 
//SOAP call ‐ test server 
$myclient = new SoapClient("https://securesoap.achworks.com/dnet/achws.asmx?WSDL"); 
$myresult = $myclient->GetACHReturnsHist(array("InpCompanyInfo"=>$mycompanyinfo, "ReturnDateFrom"=>$myDateFrom, "ReturnDateTo"=>$myDateTo))->GetACHReturnsHistResult; 
 
//print status and details 
print($myresult->Status . ", " . $myresult->Details . "\n"); 
 
$codes = array(
	'1SNT'=>'Payment sent to ACHWorks',
	'2STL'=>'Settled',
	'3RET'=>'Returned',
	'4INT'=>'Cannot be processed',
	'5COR'=>'Correction',
	'9BNK'=>'Bank transaction update',
);
 
//print ACHReturnRecords if there is any 
if($myresult->ACHReturnRecords->ACHReturnRecord)
{
	
	foreach ($myresult->ACHReturnRecords->ACHReturnRecord as $myACHReturnRecord)
	{ 
		if($config['code'][0] == 'all' ||  in_array($myACHReturnRecord->ResponseCode,$config['code']))
		{
			echo($myACHReturnRecord->FrontEndTrace.'|'.$myACHReturnRecord->EffectiveDate.'|');
			echo($codes[$myACHReturnRecord->ResponseCode].'|');
			echo((($myACHReturnRecord->CustTransType == 'C')?'-':'').$myACHReturnRecord->TransAmount.'|');
			echo($myACHReturnRecord->ActionDetail."\n");
		}
		//~ print("FrontEndTrace:" . $myACHReturnRecord->FrontEndTrace . ", EffectiveDate:" . $myACHReturnRecord->EffectiveDate . ", 
			//~ Name:" . $myACHReturnRecord->CustomerName . ", Amount:" . $myACHReturnRecord->TransAmount . ", 
			//~ ResponseCode:" . $myACHReturnRecord->ResponseCode . ", ActionDetail:" . $myACHReturnRecord->ActionDetail . 
			//~ "\n"); 
	}
}
?> 