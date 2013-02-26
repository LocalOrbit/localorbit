<?php
class core_model implements ArrayAccess
{
	function __construct($table)
	{
		$this->__table = $table;
		$this->__fields = array();
		$this->__field_index = array();
		$this->__custom_fields = array();
		$this->__data  = array();
		$this->__orig_data = array();
		$this->__autojoin_cols = array();
		$this->__autojoin_tables = array();
		
		$this->__formatters = array();

		$this->init_fields();
		
		
		$this->__has_array_fields = false;
	}
	
	function add_formatter($formatter)
	{
		$this->__formatters[] = $formatter;
		return $this;
	}
	
	function autojoin($type,$table,$rule,$cols=array())
	{
		global $core;
		
		foreach($cols as $col)
		{
			$col = explode(' as ',$col);
			if(count($col) > 1)
			{
				$col = array(
					'orig_name'=>$col[0],
					'name'=>$col[1],
				);
			}
			else
			{
				$col = array(
					'orig_name'=>$col[0],
					'name'=>$col[0],
				);

			}
			$this->__autojoin_cols[] = $col;
		}
		
		$this->__autojoin_tables[] = array(
			'type'=>$type,
			'table'=>$table,
			'rule'=>$rule
		);
		return $this;
	}
	
	function add_field($field)
	{
		$this->__fields[] = $field;
		$this->__field_index[$field->name] = $field->index;
		return $this;
	}
	
	function add_custom_field($field)
	{
		$this->__custom_fields[] = $field;
		return $this;
	}
		
	function check_load_permission()
	{
		return true;
	}
	
	function load($id = null)
	{
		global $core;
		if(!is_null($id))
		{
			$this->__data[$this->__fields[0]->name] = $id;
		}
		else
		{
			#core::log('trying to load: '.$core->data[$this->__fields[0]->name]);
			$this->__data[$this->__fields[0]->name] = $core->data[$this->__fields[0]->name];
		}
		
		$col =  new core_collection($this->build_query());
		foreach($this->__fields as $field)
		{
			if(isset($this->__data[$field->name]))
			{
				$col->filter($this->__table.'.'.$field->name,$this->__data[$field->name]);
			}
		}
		$this->import($col->row());
		$this->check_load_permission();
		
		return $this;
	}
	
	# this function is required by the ArrayAccess interface
	public function offsetExists (  $offset )
	{
		return isset($this->__data[$offset]);
	}
	
	# this function is required by the ArrayAccess interface
	public function offsetGet (  $offset )
	{
		if(!isset($this->__data[$offset]))
			return null;
			
		return $this->__data[$offset];
	}
	
	# this function is required by the ArrayAccess interface
	public function offsetSet (  $offset ,  $value )
	{
		$this->__data[$offset] = $value;
	}
	
	# this function is required by the ArrayAccess interface
	public function offsetUnset (  $offset )
	{
		unset($this->__data[$offset]);
	}
	
	# this function can be used to set values in the model more explicitly.
	# it MUST be used when trying to set specific array offsets for array 
	# database types (such as int8[])
	function set($field,$value,$secondary=null)
	{
		#core::log('setting '.$field.': '.$value);
		$index = $this->__field_index[$field];
		if($this->__fields[$index]->type == 'int[]')
		{
			if(!is_array($this->__data[$field]))
			{
				$this->__data[$field] = array();
			}
			$this->__data[$field][$value] = $secondary;
		}
		else
		{
			$fieldobj = $this->__fields[$this->__field_index[$field]];
			if($fieldobj)
			{
				if($fieldobj->type == 'int')
				{
					if($value != '')
						$this->__data[$fieldobj->name] = intval($value);
				}
				else
				{
					$this->__data[$field] = $value;
				}
			}
		}
		return $this;
	}
	
	# this function exists to make database array fields easier to work with
	function push($field,$value)
	{
		if(!is_array($this->__data[$field]))
		{
			$this->__data[$field] = array();
		}
		return $this->__data[$field][] = $value;
	}
	
	# this function exists to make database array fields easier to work with
	function pop($field)
	{
		if(!is_array($this->__data[$field]))
		{
			$this->__data[$field] = array();
		}
		return array_pop($this->__data[$field]);
	}
	
	# this function exists to make database array fields easier to work with
	function shift($field)
	{
		if(!is_array($this->__data[$field]))
		{
			$this->__data[$field] = array();
		}
		return array_shift($this->__data[$field]);
	}
	
	# this function exists to make database array fields easier to work with
	function unshift($field,$value)
	{
		if(!is_array($this->__data[$field]))
		{
			$this->__data[$field] = array();
		}
		return array_unshift($this->__data[$field],$value);
	}
	
	# this function exists to make database array fields easier to work with
	function arr_count($field)
	{
		if(!is_array($this->__data[$field]))
		{
			$this->__data[$field] = array();
			return 0;
		}
		return count($this->__data[$field]);
	}
	
	# this function exists as dummy. It can be used to auto format data in a model
	function formatter($data)
	{
		return $data;
	}
	
	function collection($fields=array())
	{
		$col = new core_collection($this,$fields);
		$col->__model = $this;
		return $col;
	}
	
	function build_query($fields=array())
	{
		global $core;
		$sql = 'select ';
		
		if(count($fields) == 0)
		{
			$sql .= $this->__table.'.*';
			
			for ($i = 0; $i < count($this->__fields); $i++)
			{
				if($this->__fields[$i]->type == 'timestamp')
				{
					$sql .= ',unix_timestamp('.$this->__table.'.'.$this->__fields[$i]->name.') as '.$this->__fields[$i]->name;
				}
				#$fields[] = $this->__table.'.'.$this->__fields[$i]->name;
			}
			
			for ($i = 0; $i < count($this->__custom_fields); $i++)
			{
				$sql .= ','.$this->__custom_fields[$i];
			}
			
			for ($i = 0; $i < count($this->__autojoin_cols); $i++)
			{
				if($this->__autojoin_cols[$i]['orig_name'] != $this->__autojoin_cols[$i]['name'])
				{
					$sql .= ','. $this->__autojoin_cols[$i]['orig_name'].' as '.$this->__autojoin_cols[$i]['name'];
				}
				else
				{
					$sql .= ','. $this->__autojoin_cols[$i]['name'];
				}
			}
			
			#$sql .= ','.implode(',',$fields);
			
		}
		else
		{
			$sql .= implode(',',$fields);
		}
		
		$sql .= ' from '.$this->__table;
		for ($i = 0; $i < count($this->__autojoin_tables); $i++)
		{
			$sql .= ' '.$this->__autojoin_tables[$i]['type'];
			$sql .= ' join '.$this->__autojoin_tables[$i]['table'];
			$sql .= ' on '.$this->__autojoin_tables[$i]['rule'];
		}
		return $sql;
	}
	
	function init_fields()
	{
	}
	
	function init_data()
	{
		foreach($this->__field_index as $name=>$index)
		{
			$this->__orig_data[$name] = null;
			$this->__data[$name] = null;
		}
	}
	
	function save($form_name='')
	{
		global $core;
		#core::log('val in first col: '.$this->__data[$this->__fields[0]->name]);
		if(isset($this->__data[$this->__fields[0]->name]) && $this->__data[$this->__fields[0]->name] != 0)
		{
			# do update
			#core::log('doing update on '.$this->__table);
			$this->__update();
		}
		else
		{
			# do insert
			#core::log('doing insert on '.$this->__table);
			$this->__insert($form_name);
		}
		return $this;
	}
	
	function __update()
	{
		global $core;
		$sql = ' update '.$this->__table.' set ';
		list($fields,$values) = $this->get_saveable_fields();
		
		if(count($fields) > 0)
		{
			for($i=0;$i<count($fields);$i++)
			{
				$sql .= ($i == 0)?'':',';
				$sql .= $fields[$i].'=';
				$sql .= $values[$i];	
			}
			$sql .= ' where '.$this->__fields[0]->name.'='.$this->__fields[0]->escape_value($this->__data[$this->__fields[0]->name]);
			
			core_db::query($sql);
		}
	}
	
	function __insert($form_name='')
	{
		global $core;
		$sql = 'insert into '.$this->__table.' ';
		list($fields,$values) = $this->get_saveable_fields();
		$sql .= ' ('.implode(',',$fields).') values ';
		$sql .= ' ('.implode(',',$values).')';
		core_db::query($sql);
		$this->set($this->__fields[0]->name,core_db::get_insert_id($this->__table,$this->__fields[0]->name));
		
		if($form_name != '')
		{
			core::js('document.'.$form_name.'.'.$this->__fields[0]->name.'.value='.$this[$this->__fields[0]->name].';');
		}
	}
	
	function get_saveable_fields()
	{
		global $core;
		$fields = array();
		$values = array();
		
		#foreach($this->__fields as $field)
		for($i=1; $i<count($this->__fields); $i++)
		{
			#core::log('checking: '.$this->__fields[$i]->name.': '.isset($this->__data[$this->__fields[$i]->name]));
			if($this->__fields[$i]->table == $this->__table)
			{
				#core::log('trying to determine difference from orig value: '.$this->__data[$this->__fields[$i]->name].'/'.$this->__orig_data[$this->__fields[$i]->name]);
				if($this->__data[$this->__fields[$i]->name] !== $this->__orig_data[$this->__fields[$i]->name])
				{
					$fields[] = $this->__fields[$i]->name;
					$values[] = $this->__fields[$i]->escape_value($this->__data[$this->__fields[$i]->name]);
				}
			}
		}
		#core::log(print_r($core->data,true));
		#core::log('saveable: '.print_r(array($fields,$values),true));
		return array($fields,$values);
	}
	
	# this function sets all of teh data fields in the model based based on a $source,
	# either passed as the first paramter, or from $_REQUEST if no source is passed.
	function import($source = null,$format='html')
	{
		#core::log('importing data: '.$source['name']);
		# if no source is passed, assume we're trying to import from the request
		if(is_null($source))
		{
			$source = $_REQUEST;
		}
		
		# run through all the formatters
		foreach($this->__formatters as $formatter)
		{
			$source = $formatter($source,$format);
		}

		#print_r($source);
		#exit();
		
		foreach($source as $fieldname=>$value)
		{
			#core::log($fieldname.': '.$value);
			if(isset($this->__field_index[$fieldname]))
			{
				$field = $this->__fields[$this->__field_index[$fieldname]];
				if($field->type == 'int[]' && !is_array($value))
				{
					# take into account empty array values being imported
					if($value == '{}')
					{
						$value = array();
					}
					else
					{
						$value = substr($source[$field->name],1,strlen($value)-2);
						$value = explode(',',$value);
					}					
				}
				$this->__orig_data[$fieldname] = $value;
				$this->__data[$fieldname] = $value;
			}
			else
			{
				$this->__orig_data[$fieldname] =$value;
				$this->__data[$fieldname] =$value;
			}
		}
		return $this;
	}
	
	function import_fields()
	{
		global $core;
		$fields = func_get_args();
		foreach($fields as $field)
		{
			$this->set($field,$core->data[$field]);
		}
		return $this;
	}
	
	function duplicate_exists($field,$value,$case_sensitive=false)
	{
		$sql = 'select count('.$this->__fields[0]->name.') as mycount from '.$this->__table;
		$sql .= ' where lower('.$field.')=';
		$sql .= strtolower($this->__fields[$this->__field_index[$field]]->escape_value($value));
		$res = core_db::query($sql);
		$res = core_db::fetch_assoc($res);
		return (intval($res['mycount']) > 0);
	}
	
	function dump()
	{
		echo('<pre>');
		print_r($this->__data);
		
		echo('</pre>');
		return $this;
	}
	
	function to_array()
	{
		return $this->__data;
	}
	
	function to_json()
	{
		return json_encode($this->__data);
	}
	
	function delete($id=0)
	{
		if($id == 0 && isset($this->__data[$this->__fields[0]->name]))
			$id = $this->__data[$this->__fields[0]->name];
		
		core_db::query('delete from '.$this->__table.' where '.$this->__fields[0]->name.'='.$id);
	}
	
	function get_value($col,$id)
	{
		return core_db::col('
			select '.$col.'
			from '.$this->__table.'
			where '.$this->__fields[0]->name.'='.$id,
			$col
		);
	}
	
	# this is used to dynamically create load functions
	# for example, using this you can query any table,filtered by any field
	# 
	# ex: core::model('domains')->loadrow_by_hostname('blah');
	function __call($method,$params)
	{
		$method = explode('_by_',$method);
		$col = $this->collection();
		$col->filter($method[1],$params[0]);
		
		if($method[0] == 'loadrow')
		{
			
			return $col->row();
		}
		else if($method[0] == 'load')
		{
			return $col;
		}
	}
}
?>