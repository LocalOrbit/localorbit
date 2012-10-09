<?php
class core_model_events extends core_model_base_events
{
	function init_fields()
	{
		global $core;
			
		$this->autojoin(
			'left',
			'event_types',
			'(event_types.event_type_id=events.event_type_id)',
			array('event_types.name as event_type')
		);
			
		$this->autojoin(
			'left',
			'customer_entity',
			'(customer_entity.entity_id=events.customer_id)',
			array('customer_entity.first_name','customer_entity.last_name','customer_entity.email','customer_entity.org_id')
		);
		$this->autojoin(
			'left',
			'organizations',
			'(customer_entity.org_id=organizations.org_id)',
			array('organizations.name as org_name')
		);
		$this->autojoin(
			'left',
			'domains',
			'(domains.domain_id=events.domain_id)',
			array('domains.name as domain_name','domains.hostname','domains.domain_id')
		);
		
		
		parent::init_fields();
	}
	
	function add_record($type,$obj1_id=0,$obj2_id=0,$varchar1='',$varchar2='')
	{
		global $core;
		core_db::query('
			insert into events
				(event_type_id,customer_id,domain_id,obj_id1,obj_id2,varchar1,varchar2,ip_address)
			values
				(
					(select event_type_id from event_types where name=\''.mysql_escape_string($type).'\'),
					'.$core->session['user_id'].',
					'.$core->config['domain']['domain_id'].',
					'.intval($obj1_id).',
					'.intval($obj2_id).',
					\''.mysql_escape_string($varchar1).'\',
					\''.mysql_escape_string($varchar2).'\',
					\''.$_SERVER['REMOTE_ADDR'].'\'
				);
		
		');
	}
}
?>