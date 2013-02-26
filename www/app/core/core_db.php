<?php
class core_db
{	
	public static function init()
	{
		global $core;
		switch($core->config['db']['type'])
		{
			case 'mysql':
				if(!defined('__CORE_DB_NOCONNECT__'))
				{
					mysql_connect(
						$core->config['db']['hostname'],
						$core->config['db']['username'],
						$core->config['db']['password']
					);				
					mysql_query("SET time_zone ='+00:00';");
					mysql_select_db($core->config['db']['database']);
					$core->config['db']['connected'] = true;
				}
				
				$core->config['db']['aliases'] = array(
					'query'=>'mysql_query',
					'fetch_assoc'=>'mysql_fetch_assoc',
					'fetch_array'=>'mysql_fetch_array',
					'fetch_row'=>'mysql_fetch_row',
					'num_rows'=>'mysql_num_rows',
					'escape_string'=>'mysql_escape_string',
					'num_rows'=>'mysql_num_rows',
					'data_seek'=>'mysql_data_seek',
					'close'=>'mysql_close',
					'error'=>'mysql_error',
				);
				break;
			case 'postgres':
				pg_connect('
					host='.$core->config['db']['hostname'].'
					port=5432
					dbname='.$core->config['db']['database'].'
					user='.$core->config['db']['username'].'
					password='.$core->config['db']['password'].'
				');
				$core->config['db']['aliases'] = array(
					'query'=>'pg_query',
					'fetch_assoc'=>'pg_fetch_assoc',
					'fetch_array'=>'pg_fetch_array',
					'fetch_row'=>'pg_fetch_row',
					'num_rows'=>'pg_num_rows',
					'escape_string'=>'pg_escape_string',
					'num_rows'=>'pg_num_rows',
					'data_seek'=>'pg_result_seek',
					'close'=>'pg_close',
					'error'=>'pg_last_error',
				);
				break;
		}
	}
	
	public static function get_insert_id($table='',$field0='')
	{
		global $core;
		if($core->config['db']['type'] == 'mysql')
			return mysql_insert_id();
		else
		{
			$res = core_db::query('select currval(\''.$table.'_'.$field0.'_seq\') as myval');
			$res = core_db::fetch_assoc($res);
			return $res['myval'];
		}
	}
	
	public static function num_rows($result)
	{
		global $core;
		if(is_string($result))
		{
			$result = core_db::query($result);
		}
		return $core->config['db']['aliases']['num_rows']($result);
	}
	
	public static function query($sql)
	{
		global $core;
		core::log($sql,'sql');
		$time_start = microtime(true);
		$result = $core->config['db']['aliases']['query']($sql);
		$execution_time_ms = round((microtime(true) - $time_start) * 1000);
		core::log($execution_time_ms.' ms','sql');
		
		if(!$result)
		{
			#core::log('an exception!');
			core::log($core->config['db']['aliases']['error'](),'error');
			core_ui::error($core->config['error_ui_msg']);
			#throw new Exception(pg_last_error());
		}
		
		return $result;
	}
	
	public static function row($sql)
	{
		return core_db::fetch_assoc(core_db::query($sql));
	}
	
	public static function col($sql,$column)
	{
		$row = core_db::row($sql);
		return $row[$column];
	}
	
	public static function col_array($sql)
	{
		$results = array();
		$all = core_db::query($sql);
		while($row = core_db::fetch_row($all))
			$results[] = $row[0];
		return $results;
	}
		
	public static function fetch_array($sql)
	{
		global $core;
		return $core->config['db']['aliases']['fetch_array']($sql);
	}
	
	public static function fetch_assoc($sql)
	{
		global $core;
		#core::log('mysql error: '.mysql_error());
		#core::log($sql);
		$assoc = $core->config['db']['aliases']['fetch_assoc']($sql);
		#core::log('fetch assoc called. '.print_r($assoc,true));
		return $assoc;
	}
	
	public static function fetch_row($sql)
	{
		global $core;
		#core::log('mysql error: '.mysql_error());
		#core::log($sql);
		$row = $core->config['db']['aliases']['fetch_row']($sql);
		#core::log('fetch assoc called. '.print_r($assoc,true));
		return $row;
	}
	
	public static function escape_string($sql)
	{
		global $core;
		return $core->config['db']['aliases']['escape_string']($sql);
	}

	static function data_seek($sql,$row,$max_row = null)
	{
		global $core;
		
		if(is_null($max_row))
		{	
			$max_row = $core->config['db']['aliases']['num_rows']($sql);
		}
		
		if($max_row > $row)
		{
			return $core->config['db']['aliases']['data_seek']($sql,$row);
		}
		return false;
	}
	
	static function deinit()
	{
		global $core;
		$core->config['db']['aliases']['close']();
	}
	
	public static function list_tables()
	{
		global $core;
		if($core->config['db']['type'] == 'mysql')
			return core_db::query('show tables');
		else
			return core_db::query('SELECT tablename  FROM pg_tables WHERE tablename !~* \'pg_*\' and tablename !~*\'sql_*\'');
	}
	
	public static function describe($table_name)
	{
		global $core;
		if($core->config['db']['type'] == 'mysql')
			return core_db::query('describe '.$table_name);
		else
			return core_db::query('
				SELECT a.attnum, a.attname AS Field, t.typname AS Type,
				       a.attlen AS length, a.atttypmod AS length_var,
				       a.attnotnull AS not_null, a.atthasdef as has_default
				  FROM pg_class c, pg_attribute a, pg_type t
				 WHERE c.relname = \''.$table_name.'\'
				   AND a.attnum > 0
				   AND a.attrelid = c.oid
				   AND a.atttypid = t.oid
				 ORDER BY a.attnum;');
		
	}
}
?>