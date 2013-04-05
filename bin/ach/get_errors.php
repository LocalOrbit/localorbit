<?php
//ACHWORKS‐SOAP Ver3.0 GetErrorFile (gets send transaction errors (only) at specified date range) 
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
$mycompanyinfo -> SSS = "TST";
$mycompanyinfo -> LocID = "9561";
$mycompanyinfo -> Company = "TSTLOCALORBIT";
$mycompanyinfo -> CompanyKey = 'TESTKEY2764'; 
 
$myDateFrom = date('Y-m-d' - 86400); //include leading zero for mm and dd e.g. 01 for Jan 
$myDateTo = date('Y-m-d',time() + 86400);   //include leading zero for mm and dd e.g. 01 for Jan 
 
 
//SOAP call ‐ test server 
$myclient = new SoapClient("http://tstsvr.achworks.com/dnet/achws.asmx?WSDL"); 
$myresult = $myclient->GetErrorFile(
		array(
			"InpCompanyInfo"=>$mycompanyinfo, 
			"ErrorDateFrom"=>$myDateFrom, 
			"ErrorDateTo"=>$myDateTo
		)
	); 
print_r($myresult);
exit();
//print status and details 
print($myresult‐>Status . ", " . $myresult->Details . "\n\n"); 
 
//print ErrorRecords if there is any 
print("PAST CONNECTION AND TRANSACTION ERRORS:\n"); 
foreach ($myresult->ErrorRecords‐>ErrorRecord as $myErrorRecord) { 
	echo("DateTime:" . $myErrorRecord->CallDateTime . ",");
	echo(" Method:" . $myErrorRecord->CallMethod . ", ");
	echo("Status:" . $myErrorRecord->Status . ", ");
	echo("FileName:" . $myErrorRecord->FileName . ", ");
	echo("No of Errors: " . $myErrorRecord->TotalNumErrors  . "\n");  
	foreach ($myErrorRecord->Errors‐>string as $myError) { 
		print("\tError=>" . $myError . "\n");    
	} 
} 
?>