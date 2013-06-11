<?php

class core_datacolumn
{
	function __construct($dbname,$label,$sortable,$width,$template_html='',$template_csv='',$template_pdf='',$autoformat='')
	{
		$this->index = 0;
		$this->parent = null;
		$this->dbname = $dbname;
		
		if(is_array($label))
		{
			$this->label      = $label[0];
			$this->csv_label  = $label[1];
			$this->pdf_label  = $label[2];
		}
		else
		{
			$this->label      = $label;
			$this->csv_label  = $label;
			$this->pdf_label  = $label;
		}
		
		$this->sortable = $sortable;
		$this->width  = $width;
		$this->template_html = $template_html;
		$this->template_csv = $template_csv;
		$this->template_pdf = $template_pdf;
		
		$this->autoformat = $autoformat;
	}
	
	function render_width()
	{
		echo('<col width="'.$this->width.'" />');
	}
	
	
	public function render_header($format='html')
	{
		global $core;
		
		if($format == 'html')
		{
			$out = '<th id="dt_'.$this->parent->name.'_col'.$this->index.'" class="dt';
			if($this->sortable)
			{
				if($this->parent->sort_column == $this->index)
				{
					$out .= ' dt_sortable dt_sort_'.$this->parent->sort_direction;
				}
				$out .= '"';
				
				
				
				$out .= ' onclick="core.ui.dataTables[\''.$this->parent->name.'\'].changeSort('.$this->index.');"';
				
				$out .= '>'.$this->label.'</th>';
			}
			else
			{
				$out .= '">'.$this->label.'</th>';
			}
			
			return $out;
		}
		else if($format == 'csv')
		{
			return $this->csv_label;
		}
		else if($format == 'pdf')
		{
			return $this->pdf_label;
		}
	}
	
	
	function render_data($format='html')
	{
		global $core;
		
		#core::log('chekcing format on ');
		
		
		$out = '';
		
		# if there's no template, just output the field's value
		$template_type = 'template_'.$format;
		if($this->$template_type == '')
		{
			return '{'.$this->dbname.'}';
		}
		else
		{
			return $this->$template_type;
		}
	}
	
	function determine_pdf_num_rows($data,$pdf,$row_height)
	{
		return 1;
	}
	
	function handle_autoformat($data)
	{
		switch($this->autoformat)
		{
			case 'price':
				$data[$this->dbname] = core_format::price($data[$this->dbname],false);
				break;
			case 'date-long':
				$data[$this->dbname] = core_format::date($data[$this->dbname],'long');
				break;
			case 'date-long-wrapped':
				if($format == 'html')
					$data[$this->dbname] = core_format::date($data[$this->dbname],'long-wrapped');
				else
					$data[$this->dbname] = core_format::date($data[$this->dbname],'long');
					
				break;
			case 'date-short':
				$data[$this->dbname] = core_format::date($data[$this->dbname],'short');
				
				break;
		}
		return $data;
	}
}

?>