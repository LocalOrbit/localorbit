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
	'code'=>'all',
);

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
 
//print ACHReturnRecords if there is any 
if($myresult->ACHReturnRecords->ACHReturnRecord)
{
	foreach ($myresult->ACHReturnRecords->ACHReturnRecord as $myACHReturnRecord) { 
		if('all' == $config['code'] || $myACHReturnRecord->ResponseCode == $config['code'])
		{
			print_r($myACHReturnRecord);
		}
		//~ print("FrontEndTrace:" . $myACHReturnRecord->FrontEndTrace . ", EffectiveDate:" . $myACHReturnRecord->EffectiveDate . ", 
			//~ Name:" . $myACHReturnRecord->CustomerName . ", Amount:" . $myACHReturnRecord->TransAmount . ", 
			//~ ResponseCode:" . $myACHReturnRecord->ResponseCode . ", ActionDetail:" . $myACHReturnRecord->ActionDetail . 
			//~ "\n"); 
	}
}
?> 