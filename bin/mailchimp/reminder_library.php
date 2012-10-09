<?
# load up stuff
global $core, $mc;
define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();

# start up mailchimp
core::load_library('mailchimp');
core::load_library('core_phpmailer');
$mc = new core_mailchimp();
ob_end_clean();

function send_campaign($config)
{
	global $mc, $core;
	
	#echo('currently on stage '.$core->config['stage']."\n");
	#echo('mc: '.$mc->key."\n");
	
	#exit();
	#set additional defaults:
	$config['from_email'] = 'service@localorb.it';
	$config['from_name']  = 'Local Orbit';
	$config['to_name']    = 'Local Orbit Customer';
	$config['do_domains'] = array();
	$list_id     = $mc->get_list_id($config['list_name']);
	
	# create a hash of all orgs/users with a flag  
	$all_users = array();
	$users = new core_collection('select org_id,email from customer_entity');
	foreach($users as $user)
	{
		if(!is_array($all_users[$user['org_id']]))
			$all_users[$user['org_id']] = array();
		$all_users[$user['org_id']][$user['email']] = 0;
	}
	
	# loop through all domains:
	$domains_sql = 'select domain_id,mag_store,name from domains where is_closed=0';
	$domains = new core_collection($domains_sql);
	foreach($domains as $domain)
	{
		echo('determining flags to set on domain '.$domain['domain_id']."\n");
	}
	
	# update mailchimp's db
	echo("updating mailchimp\n");
	$config['do_domains'] = set_flags($all_users,$list_id,$config['days_offset'],$config['seller_perspective']);
	
	
	# loop through all domains
	foreach($domains as $domain)
	{
		# only do domains that we have users to send for
		if($config['do_domains'][$domain['domain_id']])
		{
			echo('sending campaigns on domain '.$domain['domain_id']."\n");
			$template_id = $mc->get_template_id($config['template_name'],$domain['domain_id']);
			$camp_id = construct_campaign(
				$list_id,
				$config['subject'],
				$config['from_email'],
				$domain['name'],
				$config['to_name'],
				$template_id,
				$domain['domain_id']
			);
			real_send_campaign($config['subject'],$camp_id);
		}
	}
}

function set_flags($all_users,$list_id,$days_offset,$seller_perspective=true)
{
	global $mc;
	
	$domains = array();
	$today = explode('-',date('m-d-Y'));
	$start = mktime(0,0,0,intval($today[0]),intval($today[1]),intval($today[2]));
	$start += ($days_offset * 86400);
	$end   = $start + 86399;
	
	echo("\tfinding orders between ".date('Y-m-d H:i:s',$start).' and '.date('Y-m-d H:i:s',$end)."\n");
	echo("\t$start - $end\n");
	echo("\t".date('Y-m-d H:i',$start)." - ".date('Y-m-d H:i',$end)."\n");
	
	# first retrieve the list of applicable orgs
	if($seller_perspective)
	{
		$orgs_sql = '
			select o.org_id,o.name,o.domain_id
			from lo_fulfillment_order
			left join organizations o on lo_fulfillment_order.org_id=o.org_id
			where lo_foid in (
				select lo_foid
				from lo_order_deliveries
				where delivery_start_time >= '.$start.'
				and delivery_start_time <= '.$end.'
			)
			and lo_fulfillment_order.status=\'ORDERED\'
		';
	}
	else
	{
		$orgs_sql = '
			select o.org_id,o.name,o.domain_id
			from lo_order
			left join organizations o on lo_order.org_id=o.org_id
			where lo_oid in (
				select lo_oid
				from lo_order_deliveries
				where delivery_start_time >= '.$start.'
				and delivery_start_time <= '.$end.'
			)
			and lo_order.status=\'ORDERED\'
		';
	}
	$orgs = new core_collection($orgs_sql);
	
	# for each org, find all users
	foreach($orgs as $org)
	{
		# for each user, set do_email flag
		$domains[$org['domain_id']] = 1;
		$users_sql = 'select email from customer_entity where org_id='.$org['org_id'];
		$users = new core_collection($users_sql);
		foreach($users as $user)
		{
			echo("\t\tsending email to ".$org['org_id'].':'.$org['name'].':'.$user['email']."\n");
			$all_users[$org['org_id']][$user['email']] = 1;
		}
	}
	
	# transform our org->user->doemail hash to the mailchimp update format
	# and pass to mailchimp.
	$final_users = array();
	foreach($all_users as $org)
	{
		foreach($org as $email=>$flag)
		{
			$final_users[] = array(
				'EMAIL'=>$email,
				'EMAIL_TYPE'=>'html',
				'DO_EMAIL'=>$flag,
			);
		}
	}
	#print_r($final_users);
	#echo($list_id);
	#var_dump($mc);
	#exit();
	$errors = $mc->api->listBatchSubscribe($list_id,$final_users,false,true,false);
	if ($mc->api->errorCode){
		echo "Batch Subscribe failed!\n";
		echo "code:".$mc->api->errorCode."\n";
		echo "msg :".$mc->api->errorMessage."\n";
	} 
	#print_r($errors);
	return $domains;
}

function construct_campaign($list_id,$subject,$from_email,$from_name,$to_name,$template_id,$domain_id)
{
	global $mc, $config;
	
	$camp_id = 0;
	echo("\tcampaign settings: $list_id - $template_id - $domain_id \n");
	#return 0;
	
	$camp_id = $mc->campaignCreate(
		'regular',
		array(
			'list_id'=>$list_id,
			'template_id'=>$template_id,
			'subject'=>$subject,
			'from_email'=>$from_email,
			'from_name'=>$from_name,
			'to_name'=>$to_name,
			'title'=>$subject.'_'.date('Y-m-d').'_'.$domain_id,
		),
		array(
			'html'=>'testing',
			'text'=>'Please view the html version of this e-mail',
		),
		array(
			'match'=>'all',
			'conditions'=>array(
				array(
					'field'=>'DO_EMAIL',
					'op'=>'eq',
					'value'=>1,
				),
				array(
					'field'=>'DOMAIN_ID',
					'op'=>'eq',
					'value'=>$domain_id,
				),
			),
		)
	);
	if ($mc->api->errorCode){
		echo "Campaign create failed!\n";
		echo "code:".$mc->api->errorCode."\n";
		echo "msg :".$mc->api->errorMessage."\n";
		exit();
	} 
	return $camp_id;
}

function real_send_campaign($subject,$camp_id)
{
	global $mc;
	#$mc->campaignSendTest($camp_id,array('localorbit.testing@gmail.com'));
	$mc->api->campaignSendNow($camp_id);
	if ($mc->api->errorCode){
		echo "Campaign send failed!\n";
		echo "code:".$mc->api->errorCode."\n";
		echo "msg :".$mc->api->errorMessage."\n";
		core_phpmailer::send_email(
			'Error sending '.$subject,
			'Code: '.$mc->api->errorCode."\n".$mc->api->errorMessage,
			'mike@localorb.it'
		);
		exit();
	} 

	echo("\tcampaign sent\n");
	return;
	
}

?>