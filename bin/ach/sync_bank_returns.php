<?php
//ACHWORKS‐SOAP Ver3.0 GetACHReturnsHist (gets ach return and settlement records at specified date range) 
//3.25.2010 ‐ rico pamplona, rpamplonaATachworksDOTcom 
//company info 

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
ob_end_flush();


$config = array(
	'start-days-before'=>2,
	'end-days-before'=>0,
	'do-update'=>1,
	'report-sql'=>0,
);

core_db::query('
	update payments 
	set processing_status=\'confirmed\' 
	where payment_method in (\'paypal\',\'check\',\'cash\');
');


array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

echo("\nbeginning processing. using the following config:\n\n".print_r($config,true)."\n\n");






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
 
$myDateFrom = date('Y-m-d',time() - ($config['start-days-before']* 86400)); //include leading zero for mm and dd e.g. 01 for Jan 
$myDateTo  = date('Y-m-d',time() - ($config['end-days-before']* 86400));   //include leading zero for mm and dd e.g. 01 for Jan 

echo('From '.$myDateFrom.' till '.$myDateTo."\n"); 
 
//SOAP call ‐ test server 
$myclient = new SoapClient("https://securesoap.achworks.com/dnet/achws.asmx?WSDL"); 
$myresult = $myclient->GetACHReturnsHistRC(array(
	"InpCompanyInfo"=>$mycompanyinfo,
	"ReturnDateFrom"=>$myDateFrom,
	"ReturnDateTo"=>$myDateTo,
	'InpResponseCode'=>'2STL',
))->GetACHReturnsHistRCResult;

#->GetACHReturnsHistResult; 
 
//print status and details 
print($myresult->Status . ", " . $myresult->Details . "\n"); 
 
echo($myresult->TotalNumRecords." results received.\n");
for($i=0; $i <= $myresult->TotalNumRecords; $i++)
{
	echo('Payment '.$settlement->FrontEndTrace." was settled.\n");
	$payment_id = intval(str_replace('P-00','',$settlement->FrontEndTrace));
	$settlement = $myresult->ACHReturnRecords->ACHReturnRecord[$i];
	$sql = 'update payments set processing_status=\'confirmed\' where (ref_nbr=\''.$settlement->FrontEndTrace.'\' or payment_id='.$payment_id.') and payment_method=\'ACH\';';
	if($config['report-sql'] == 1)
		echo("\t".$sql."\n");
		
	if($config['do-update'] == 1)
		core_db::query($sql);
}

exit("\nDONE\n");
?> 
