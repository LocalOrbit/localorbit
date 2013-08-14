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
$config = array(
	'days':1,
	'code':'all',
);



array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

echo("\nbeginning processing. using the following config:\n\n".print_r($config,true)."\n\n");
 
//CompanyInfo 
$mycompanyinfo = new CompanyInfo;
$mycompanyinfo -> SSS = "RPP";
$mycompanyinfo -> LocID = "2764";
$mycompanyinfo -> Company = "LOCALORBITLLC001";
$mycompanyinfo -> CompanyKey = 'QSFTHJJP3JCMFBXGQEDBZWKDBPPHFM2'; 
 
$myDateFrom = date('Y-m-d',time() - (86400 * $config['days']); //include leading zero for mm and dd e.g. 01 for Jan 
$myDateTo = date('Y-m-d',time() + 86400);   //include leading zero for mm and dd e.g. 01 for Jan 
 
 
$soap_do = curl_init(); 
curl_setopt($soap_do, CURLOPT_URL,            $url );   
curl_setopt($soap_do, CURLOPT_CONNECTTIMEOUT, 10); 
curl_setopt($soap_do, CURLOPT_TIMEOUT,        10); 
curl_setopt($soap_do, CURLOPT_RETURNTRANSFER, true );
curl_setopt($soap_do, CURLOPT_SSL_VERIFYPEER, false);  
curl_setopt($soap_do, CURLOPT_SSL_VERIFYHOST, false); 
curl_setopt($soap_do, CURLOPT_POST,           true ); 
curl_setopt($soap_do, CURLOPT_POSTFIELDS,     '<soap:Envelope>...</soap:Envelope>'); 
curl_setopt($soap_do, CURLOPT_POSTFIELDS,    $post_string); 
curl_setopt($soap_do, CURLOPT_HTTPHEADER,     array('Content-Type: text/xml; charset=utf-8', 'Content-Length: '.strlen($post_string) )); 
#curl_setopt($soap_do, CURLOPT_USERPWD, $user . ":" . $password);

$result = curl_exec($soap_do);
$err = curl_error($soap_do);  


//SOAP call ‐ test server 
$myclient = new SoapClient("https://securesoap.achworks.com/dnet/achws.asmx?WSDL"); 
$myresult = $myclient->GetResultFile(
		array(
			"InpCompanyInfo"=>$mycompanyinfo, 
			"ResultDateFrom"=>$myDateFrom, 
			"ResultDateTo"=>$myDateTo
		)
	);


echo("Results: \n");
$ignore_methods = array('GetResultFile','GetErrorFile');
foreach($myresult->GetResultFileResult->TransResults->TransResult as $item)
{
	if(!in_array($item->CallMethod,$ignore_methods))
	{
		if($config['code'] == 'all' || $item['ResponseCode'] == $config['code'])
			print_r($item);
	}
}
exit("Done\n");
?>