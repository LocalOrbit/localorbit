<?
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();
core::load_library('crypto');

$domains = core_db::query('select * from domains');
while($domain = core_db::fetch_assoc($domains))
{
	# move over the market news to being associated by domain_id
	core_db::query('update market_news set domain_id='.$domain['domain_id'].' where website_id='.$domain['mag_store']);

	#echo($domain['accept_products_from']."\n");
	$accepts = explode(',',$domain['accept_products_from']);
	foreach($accepts as $accept)
	{
		if(is_numeric($accept))
		{
			core_db::query('
				insert into domain_cross_sells 
					(domain_id,accept_from_domain_id) 
				values 
					('.$domain['domain_id'].','.$accept.');
			');
		}
	}
	
	
	$dev = explode('-',$domain['dev_hours']);
	$dev[0] = str_replace(':30','.5',str_replace('am','',trim($dev[0])));
	if(strpos($dev[0],'pm') !== false)
		$dev[0] = intval(str_replace('pm','',$dev[0])) + 12;
		
	$dev[1] = str_replace(':30','.5',str_replace('am','',trim($dev[1])));
	if(strpos($dev[1],'pm') !== false)
		$dev[1] = intval(str_replace('pm','',$dev[1])) + 12;

	$pickup = explode('-',$domain['pickup_hours']);
	$pickup[0] = str_replace(':30','.5',str_replace('am','',trim($pickup[0])));
	if(strpos($pickup[0],'pm') !== false)
		$pickup[0] = intval(str_replace('pm','',$pickup[0])) + 12;

	$pickup[1] = str_replace(':30','.5',str_replace('am','',trim($pickup[1])));
	if(strpos($pickup[1],'pm') !== false)
		$pickup[1] = intval(str_replace('pm','',$pickup[1])) + 12;


	if($pickup[1] == '')
		$pickup[1] = $pickup[0];		
	if($pickup[0] == '')
	{
		$pickup[0] = 'null';
		$pickup[1] = 'null';
	}
	if($dev[0] == '')
	{
		$dev[0] = 'null';
		$dev[1] = 'null';
	}
	
	$days_before = ($domain['ship_day'] - $domain['due_day']);
	if($days_before < 0) $days_before += 7;
	
	core_db::query('
		insert into delivery_days
			(domain_id,cycle,day_nbr,deliv_address_id,delivery_start_time,delivery_end_time,pickup_start_time,pickup_end_time,hours_due_before)
		values
			(
				'.$domain['domain_id'].',
				\'weekly\',
				'.$domain['ship_day'].',
				(
					select address_id 
					from addresses 
					where org_id in (
						select org_id
						from organizations
						where orgtype_id=2
						and domain_id='.$domain['domain_id'].'
					) limit 1
				),
				'.$dev[0].',
				'.$dev[1].',
				'.$pickup[0].',
				'.$pickup[1].',
				'.($days_before * 24).'
			);
	
	');
	
	# move over hub profile pic
	if(!file_exists('/var/www/testing/www/img/'.$domain['domain_id']))
		mkdir('/var/www/testing/www/img/'.$domain['domain_id']);
	if(!file_exists('/var/www/qa/www/img/'.$domain['domain_id']))
		mkdir('/var/www/qa/www/img/'.$domain['domain_id']);
	if(!file_exists('/var/www/production/www/img/'.$domain['domain_id']))
		mkdir('/var/www/production/www/img/'.$domain['domain_id']);
	exec('scp lo-old:/home/localorb/sites/production/www/lo2/img/hubprofiles/'.$domain['domain_id'].'.jpg /var/www/testing/www/img/'.$domain['domain_id'].'/profile.jpg');
	sleep(2);
	if(file_exists('/var/www/testing/www/img/'.$domain['domain_id'].'/profile.jpg'))
		exec('php -f /var/www/testing/bin/resize_photo.php /var/www/testing/www/img/'.$domain['domain_id'].'/profile.jpg 400 400 /var/www/testing/www/img/'.$domain['domain_id'].'/profile.jpg');
}


core_db::query('alter table domains drop accept_products_from;');
exit();

#mysql_connect('localhost','localorb_magg','nAvAswu4');
#mysql_select_db('localorb_mag_lo3');

# id == 1, in theory :)
#


#echo("starting stage 3!\n");

?>