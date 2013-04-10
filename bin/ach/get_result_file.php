<?php
//ACHWORKS‐SOAP Ver3.0 GetResultFile (gets send transaction results/responses including errors at specified date range) 
//3.25.2010 ‐ rico pamplona, rpamplonaATachworksDOTcom 
//company info 
class CompanyInfo { 
      public $SSS; 
      public $LocID; 
      public $Company; 
      public $CompanyKey; 
} 
 

//CompanyInfo 
$mycompanyinfo = new CompanyInfo; 
$mycompanyinfo -> SSS = "RPP";
$mycompanyinfo -> LocID = "2764";
$mycompanyinfo -> Company = "LOCALORBITLLC001";
$mycompanyinfo -> CompanyKey = 'QSFTHJJP3JCMFBXGQEDBZWKDBPPHFM2'; 

$myDateFrom = date('Y-m-d',time() - 86400); //include leading zero for mm and dd e.g. 01 for Jan 
$myDateTo  = date('Y-m-d',time() + 86400);   //include leading zero for mm and dd e.g. 01 for Jan 
 
 
 
//SOAP call ‐ test server 
$myclient = new SoapClient("https://securesoap.achworks.com/dnet/achws.asmx?WSDL"); 
$myresult = $myclient->GetResultFile(array("InpCompanyInfo"=>$mycompanyinfo, "ResultDateFrom"=>$myDateFrom, "ResultDateTo"=>$myDateTo))->GetResultFileResult; 
 
//print status and details 
print($myresult->Status . ", " . $myresult->Details . "\n\n"); 
 
//print TransResults if there is any 
print("PAST CONNECTION AND TRANSACTION RESULTS:\n"); 
foreach ($myresult->TransResults->TransResult as $myTransResult) { 
print("DateTime:" . $myTransResult->CallDateTime . ", Method:" . $myTransResult->CallMethod . ", Status:" . $myTransResult->Status 
. ", FileName:" . $myTransResult->FileName  . "\n"); 
	if($myTransResult->Errors->string)
	{
		foreach ($myTransResult->Errors->string as $myError) { 
			print("&nbsp&nbsp&nbsp Error=>" . $myError . "\n");    
		}
	}
} 
?> 