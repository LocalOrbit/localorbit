<?php
class core_model_organizations extends core_model_base_organizations
{
	function init_fields()
	{
		global $core;
			
		$this->autojoin(
			'left',
			'organizations_to_domains',
			'(organizations.org_id = organizations_to_domains.org_id and organizations_to_domains.is_home =1)',
			array('organizations_to_domains.orgtype_id')
		);
		$this->autojoin(
			'left',
			'domains',
			'(organizations_to_domains.domain_id=domains.domain_id)',
			array('domains.domain_id','domains.name as domain_name','domains.hostname','CONCAT(domains.name,\': \',organizations.name) as full_org_name','domains.fee_percen_lo','domains.fee_percen_hub','domains.paypal_processing_fee','domains.feature_sellers_enter_price_without_fees','domains.feature_sellers_cannot_manage_cross_sells')
		);		

		
		parent::init_fields();
	}

	function get_list_for_dropdown()
	{
		global $core;
		
		if(lo3::is_admin())
		{
			/*
			$sql = '
				select org_id,CONCAT(domains.name,\': \',organizations.name) as org_name
				from organizations
				left join domains on domains.domain_id=organizations.domain_id
				where organizations.name <> \'\'
				and organizations.name is not null
			';
			*/
			$sql = '
				select organizations.org_id,CONCAT(domains.name,\': \',organizations.name) as org_name
				from organizations
				left join organizations_to_domains on organizations_to_domains.org_id = organizations.org_id
				left join domains on domains.domain_id=organizations_to_domains.domain_id
				where organizations.name <> \'\'
				and organizations.name is not null
				and organizations.is_deleted=0
			';
			$col = new core_collection($sql);
			$col->sort('organizations.name');
			$col->sort('domains.name');
		}
		else if(lo3::is_market())
		{
			$sql = '
				select organizations.org_id,CONCAT(domains.name,\': \',organizations.name) as org_name
				from organizations
				left join organizations_to_domains on organizations_to_domains.org_id = organizations.org_id
				left join domains on domains.domain_id=organizations_to_domains.domain_id
				where organizations.name <> \'\'
				and organizations.name is not null
				and organizations.is_deleted=0
				and organizations_to_domains.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
			';
			$col = new core_collection($sql);
			$col->sort('organizations.name');
			$col->sort('domains.name');
		}

		return $col;
	}
	
	function get_image($org_id=null)
	{
		global $core;
		if(is_null($org_id))
		{
			$org_id = $this['org_id'];
		}
		
		
		$filepath = $core->paths['base'].'/../img/organizations/'.$org_id.'.';
		$webpath  = '/img/organizations/cached/'.$org_id.'.320.260.jpg';
		$imgpath = '/img/blank.png';
		$extension = '';
		
		if(file_exists($filepath.'png'))	
			$extension = 'png';
		if(file_exists($filepath.'jpg'))	
			$extension = 'jpg';
		if(file_exists($filepath.'gif'))	
			$extension = 'gif';
			
		core::log($filepath.'jpg');
		if($extension == '')
		{
			return array(false,$imgpath,$core->paths['base'].'/..'.$imgpath);
		}
		else
		{
			return array(true,$webpath.$extension,$filepath);
		}
		
	}
	
	function join_default_billing()
	{
	

		$this->autojoin(
			'left',
			'addresses',
			'(organizations.org_id=addresses.org_id and addresses.default_billing=1)',
			array('address','city','postal_code','telephone')
		);
		$this->autojoin(
			'left',
			'directory_country_region',
			'(directory_country_region.region_id=addresses.region_id)',
			array('directory_country_region.code')
		);
		return $this;
	}
	
	function join_default_shipping()
	{
	

		$this->autojoin(
			'left',
			'addresses',
			'(organizations.org_id=addresses.org_id and addresses.default_shipping=1)',
			array('address','city','postal_code','telephone')
		);
		$this->autojoin(
			'left',
			'directory_country_region',
			'(directory_country_region.region_id=addresses.region_id)',
			array('directory_country_region.code')
		);
		return $this;
	}
	
	function get_pricing_domains($org_id = 0) 
	{
		global $core;
		
		$org_id = ($org_id > 0)?$org_id:$core->session['org_id'];
		
		$sql = '
			select domain_id,name 
			from domains 
			where domain_id in (select domain_id from organizations_to_domains where org_id='.$org_id.')
			or domain_id in (
				select sell_on_domain_id
				from organization_cross_sells
				where org_id='.$org_id.'
			)
			order by name
		';
		$col = new core_collection($sql);
		return $col;
	}
}
?>