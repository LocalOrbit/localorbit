<?php

class core_collection implements Iterator,ArrayAccess
{
	function __construct($source,$fields=array())
	{
		$this->__loaded = false;
		$this->__source = $source;
		$this->__num_rows = 0;
		$this->__current  = (-1);
		$this->__data   = null;
		$this->__row    = null;
		$this->__model  = null;
		$this->__formatters = array();
		$this->__output_type = 'html';
		
		# query clauses
		$this->__fields  = $fields;
		$this->__filters = array();
		$this->__sorts   = array();
		$this->__groups  = array();
		$this->__joins   = array();
		$this->__determine_max_page = false;
		$this->__page    = -1;
		$this->__size    = -1;
	}

	function html_dump($echo_output = true)
	{
		$out = '';
		$out .= '<table>';
		$first = true;
		foreach($this as $row)
		{
			if($first)
			{
				$first = false;
				$out .= '<tr>';
				if(is_array($row))
				{
					foreach($row as $field=>$value)
					{
						$out .= '<th>'.$field.'</th>';
					}
				}
				else
				{
					for($i=0;$i<count($row->__fields);$i++)
					{
						$out .= '<th>'.$row->__fields[$i]->name.'</th>';
					}
					foreach($row->__autojoin_cols as $col)
					{
						$out .= '<th>'.$col['name'].'</th>';
					}

				}
				$out .= '</tr>';
			}
			
			$out .= '<tr>';
			if(is_array($row))
			{
				foreach($row as $field=>$value)
				{
					$out .= '<td>'.$value.'</td>';
				}
			}
			else
			{
				for($i=0;$i<count($row->__fields);$i++)
				{
					$out .= '<td>'.$row->__data[$row->__fields[$i]->name].'</td>';
				}
				foreach($row->__autojoin_cols as $col)
				{
					$name = explode('.',$col['name']);
					$out .= '<td>'.$row->__data[array_pop($name)].'</td>';
				}
			}
			$out .= '</tr>';
		}
		$out .= '</table>';
		
		if($echo_output)
		{
			echo($out);
			return true;
		}
		else
		{
			return $out;
		}
	}
	
	function add_formatter($formatter)
	{
		$this->__formatters[] = $formatter;
		return $this;
	}

	function construct($source,$fields=array())
	{
		$col = new core_collection($source,$fields);
		
		return $col;
	}
	
	function row()
	{
		#core::log('row called');
		if(!$this->__loaded)
		{
			$this->load();
		}
		
		$data = core_db::fetch_assoc($this->__data);
		if($data)
		{
			if(is_null($this->__model))
			{
				return $data;
			}
			else
			{
				return $this->__model->import($data);
			}
		}
		else
		{
			return $false;
		}
	}
	
	function filter($field,$val_or_op=null,$val=null)
	{
		$arg_count = func_num_args();
		if($arg_count == 1)
		{
			$this->__filters[] = $field;
		}
		else if($arg_count == 2)
		{
			if(in_array($val_or_op,array('is null','is not null')))
			{
				$this->__filters[] = array(
					'field'=>$field,
					'operator'=>$val_or_op,
					'value'=>null,
				);
			}
			else
			{
				$this->__filters[] = array(
					'field'=>$field,
					'operator'=>'=',
					'value'=>$val_or_op,
				);
			}
		}
		else if($arg_count == 3)
		{
			$this->__filters[] = array(
				'field'=>$field,
				'operator'=>$val_or_op,
				'value'=>$val,
			);
		}
		return $this;
	}
	
	function sort($field,$dir='asc')
	{
		if($dir == 'asc')
			array_unshift($this->__sorts,$field);
		else
			array_unshift($this->__sorts,$field.' desc');
		return $this;
	}
	
	function group($field)
	{
		$this->__groups[] = $field;
		return $this;
	}
	
	function limit($new_limit)
	{
		$this->__size = $new_limit;
		return $this;
	}
	
	function load()
	{
		global $core;
		$this->__loaded = true;
		#core::log('loading collection');
		if(is_string($this->__source))
		{
			$this->__sql = $this->__source;
		}
		else
		{
			$this->__sql = $this->__source->build_query($this->__fields);
		}
		
		$this->apply_clauses();
		
		$this->__data = core_db::query($this->__sql);
		$this->__num_rows = core_db::num_rows($this->__data);
		$this->__current = (-1);
		#core::log('there appear to be '.$this->__num_rows.' rows');
		
		if($this->__determine_max_page && $this->__size < 0)
		{
			$this->__max_page = 0;
		}
		return $this;
	}
	
	function apply_clauses()
	{
		# apply filters
		#core::log('apply clauses called: '.$this->__sql);
		$has_where = (strpos($this->__sql,'where') !== false);
		for ($i = 0; $i < count($this->__filters); $i++)
		{
			$this->__sql .= ($has_where)?' and ':' where ';
			if(is_array($this->__filters[$i]))
			{
				switch($this->__filters[$i]['operator'])
				{
					case '=~':
					case 'like%':
						$this->__sql .= $this->__filters[$i]['field'];
						$this->__sql .= ' like ';
						$this->__sql .= "'".core_db::escape_string($this->__filters[$i]['value'])."%'";
						break;
					case '~=':
					case '%like':
						$this->__sql .= $this->__filters[$i]['field'];
						$this->__sql .= ' like ';
						$this->__sql .= "'%".core_db::escape_string($this->__filters[$i]['value'])."'";
						break;
					case '~':
					case 'like':
						$this->__sql .= $this->__filters[$i]['field'];
						$this->__sql .= ' like ';
						$this->__sql .= "'%".core_db::escape_string($this->__filters[$i]['value'])."%'";
						break;
					case '=':
					case '>':
					case '<':
					case '>=':
					case '<=':
					case '<>':
						$this->__sql .= $this->__filters[$i]['field'];
						$this->__sql .= $this->__filters[$i]['operator'];
						if(is_string($this->__filters[$i]['value']))
							$this->__sql .= "'".core_db::escape_string($this->__filters[$i]['value'])."'";
						else
							$this->__sql .= $this->__filters[$i]['value'];
						break;
					case 'in':
					case 'not in':
						$this->__sql .= $this->__filters[$i]['field'].' ';
						$this->__sql .= $this->__filters[$i]['operator'].' (';
						$vals = array();
						if(is_string($this->__filters[$i]['value']))
						{
							$this->__sql .= $this->__filters[$i]['value'].')';
						}
						else
						{
							foreach($this->__filters[$i]['value'] as $val)
							{
								if(is_string($val))
									$vals[] = "'".core_db::escape_string($val)."'";
								else
									$vals[] = $val;
							}
							$this->__sql .= implode(',',$vals).') ';
						}
						break;
					case 'is null':
					case 'is not null':
						$this->__sql .= $this->__filters[$i]['field'].' ';
						$this->__sql .= $this->__filters[$i]['operator'];
						break;
				}
			}
			else
			{
				$this->__sql .= $this->__filters[$i];
			}
			$has_where = true;
		}
		
		# apply groups
		if(count($this->__groups) > 0)
		{
			$this->__sql .= ' group by ';
			$this->__sql .= implode(',',$this->__groups);
		}


		# apply sorts
		if(count($this->__sorts) > 0)
		{
			$this->__sql .= ' order by ';
			$this->__sql .= implode(',',$this->__sorts);
		}
		
		
		#core::log('size is: '.$this->__size);
		
		
		if($this->__determine_max_page && $this->__size > 0)
		{
			$this->__max_page = core_db::num_rows($this->__sql);
			$this->__max_page = ceil ( $this->__max_page / $this->__size);
		}

		
		
		# apply limit
		if($this->__size >= 0)
		{
			$this->__sql .= ' limit '.$this->__size;
			
			# apply limit
			if($this->__page >= 0)
			{
				$this->__sql .= ' offset '.($this->__page * $this->__size);
			}
		}
		
		return $this->__sql;
	}
	
	function to_array()
	{
		if(!$this->__loaded)
			$this->load();
		$return = array();
		core_db::data_seek($this->__data,0);
		while($res = core_db::fetch_assoc($this->__data))
		{
			foreach($this->__formatters as $formatter)
			{
				$res = $formatter($res);
			}
			$return[] = $res;
		}
		return $return;
	}
	
	function to_json()
	{
		return json_encode($this->to_array());
	}
	
	function get_unique_values($field,$require_numeric=true,$is_array=false)
	{
		$results = array();
		foreach($this as $row)
		{
			if($is_array)
			{
				$row[$field] = explode(',',$row[$field]);
				foreach($row[$field] as $arow)
				{
					if(is_numeric($arow))			
						$results[] = $arow;
				}
			}
			else
			{
				if($require_numeric)
				{
					if(is_numeric($row[$field]))			
						$results[] = $row[$field];
				}
				else
				{
					$results[] = $row[$field];
				}
			}
		}
		return array_unique($results);
	}
	
	function to_hash($hash_by_field,$create_subarray=true)
	{
		if(!$this->__loaded)
			$this->load();
		
		$hash = array();
		foreach($this as $res)
		{
			if($create_subarray)
			{
				if(!is_array($hash[$res[$hash_by_field]]))
					$hash[$res[$hash_by_field]] = array();
					
				if(is_array($res->__data))
					$hash[$res[$hash_by_field]][] = $res->__data;
				else
					$hash[$res[$hash_by_field]][] = $res;
					
			}
			else
			{
				$hash[$res[$hash_by_field]] = $res->__data;
			}
		}
	
		return $hash;
	}
	
	# this function is required for the Iterator interface
	function rewind()
	{
		#core::log('rewind called');
		#core::log('rewind called');
		if(!$this->__loaded)
			$this->load();
		
		core_db::data_seek($this->__data,0);
		$this->__current = (-1);
		$this->next();
	}

	# this function is required for the Iterator interface
	function current()
	{
		#core::log('current called');
		if(!$this->__loaded)
			$this->load();
		#core::log('current called');
		return $this->__row;
	}

	# this function is required for the Iterator interface
	function key()
	{
		#core::log('rewind called');
		if(!$this->__loaded)
			$this->load();
		#core::log('key called');
		return $this->__current;
	}

	# this function is required for the Iterator interface
	function next()
	{
		#core::log('next called: '.$this->__current .'/'.$this->__num_rows);
		#core::log('next called');
		if(!$this->__loaded)
			$this->load();
		$this->__current++;
		
		if($this->__current < $this->__num_rows)
		{
			$this->__row = core_db::fetch_assoc($this->__data);
			#core::log('row data: '.print_r($this->__row,true));
	/*
			if(!is_null($this->__formatter))
			{
				$this->__row = $this->__formatter($this->__row);
			}
	*/

			# run through all the formatters
			foreach($this->__formatters as $formatter)
			{
				$this->__row = $formatter($this->__row,$this->__output_type);
				#core::log('data is now: '.print_r($this->__row,true));
			}
			
			# if there's a model, load the data into it.
			if(!is_null($this->__model))
			{
				#core::log('about to import');
				$this->__row = $this->__model->import($this->__row,$this->__output_type);
				#core::log('import success');
			}
		}
	}

	# this function is required for the Iterator interface
	function valid()
	{
		#core::log('valid called: '.$this->__current.'/'.$this->__num_rows);
		if(!$this->__loaded)
			$this->load();
		return (($this->__current) < $this->__num_rows and $this->__num_rows > 0);
	}
	
	
	# this function is required by the ArrayAccess interface
	public function offsetExists (  $offset )
	{
		return isset($this->__row[$offset]);
	}
	
	# this function is required by the ArrayAccess interface
	public function offsetGet (  $offset )
	{
		if(!isset($this->__row[$offset]))
			return null;
			
		return $this->__row[$offset];
	}
	
	# this function is required by the ArrayAccess interface
	public function offsetSet (  $offset ,  $value )
	{
		$this->__row[$offset] = $value;
	}
	
	# this function is required by the ArrayAccess interface
	public function offsetUnset (  $offset )
	{
		unset($this->__row[$offset]);
	}
	
	public function dump($return=false)
	{
		return print_r($this->to_array(),$return);
	}
	
	public function log()
	{
		core::log($this->dump(true));
	}
}

?>