//ConnectionCheck Method
//using PHP5 SOAP Extension
<?php
class CompanyInfo {
   public $SSS;
   public $LocID;
   public $Company;
   public $CompanyKey;
}

$mycompanyinfo = new CompanyInfo;
$mycompanyinfo -> SSS = "TST";
$mycompanyinfo -> LocID = "9561";
$mycompanyinfo -> Company = "TSTLOCALORBIT";
$mycompanyinfo -> CompanyKey = 'TESTKEY2764'; 


$myclient = new 
   SoapClient("http://tstsvr.achworks.com/dnet/achws.asmx?WSDL");


//Important:  use InpCompanyInfo
$myresult = 
   $myclient->ConnectionCheck(
       array("InpCompanyInfo"=>$mycompanyinfo));

print($myresult->ConnectionCheckResult);
?>