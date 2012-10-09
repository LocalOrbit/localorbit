<?php
/****************************************************************/
/* Usage :
$h = new pt_highslide ($main_url, $thumb_url, $main_text = '', $src_url = '' );

$h->set_borders ($outlineType='');
$h->set_title ($title);
$h->set_href_text($alt_text='');
$h->set_size ($objectWidth=0, $objectHeight=0);
$h->set_colors ($bgcolor, $hdcolor='', $ftcolor='');
$h->set_body ($body_text = '');
$h->set_bottom ($bottom_text = '', $bottom_url='');
$h->set_caption();

$return_str = $h->highslide_link($objectType, $so='');

/****************************************************************/
class pt_thickbox {

	// The parameters
	var $objectType;
	var $objectWidth = 0;
	var $objectHeight = 0;
	var $bgcolor = '#FFF';
	var $hdcolor;
	var $ftcolor;
	var $body ='';

	var $img_url;
	var $thumb_url = '';
	var $link_url;
	var $src_url = '';

	var $title = '';
	var $alt_text = '';
	var $href_text = '';

	var $ID;
	var $myclass = 'thickbox';

	/****************************************************************/
	/* Constructor
	/****************************************************************/
	function pt_thickbox (	$main_url,
                                $thumb_url,
                                $main_text = '',
                                $src_url = ''
                                ) {

		$this->ID 		= 'a'.mt_rand(0,10000);
		$this->img_url 		= $main_url;
		$this->link_url 	= $main_url;
		$this->thumb_url 	= $thumb_url;
		$this->src_url 		= $src_url;
		$this->title 		= $main_text;
		$this->alt_text		= $main_text;
	}
	/****************************************************************/
	/* This sets the content of the frame (html & body).
	/****************************************************************/
	function set_body ($body_text = '') {
	
		$this->has_body = true;
		$this->body = $body_text;
	}
	/****************************************************************/
	/* This sets the title
	/****************************************************************/
	function set_title ($title) {
	
		$this->title = $title;
	}
	/****************************************************************/
	/* This sets the size of the frame
	/****************************************************************/
	function set_size ($objectWidth=0, $objectHeight=0) {
	
		$this->objectWidth 	= $objectWidth;
		$this->objectHeight 	= $objectHeight;
	}
	/****************************************************************/
	/* this sets the display part, wether a thumbnail or a text
	/****************************************************************/
	function set_href_text ($alt_text='', $add_tags='') {
	
		if ($alt_text == '') $alt_text = __('Click to enlarge: ', 'post-thumb').$this->title;
		if ($this->thumb_url=='')
			$this->href_text = $alt_text;
		else {
		
			if ($this->width == 0) $tag_width = ''; else $tag_width = ' width="'.$this->width.'"';
			if ($this->height == 0) $tag_height = ''; else $tag_height = ' height="'.$this->height.'"';
			$this->href_text = "\n\t".'<img src="'.$this->thumb_url.'" alt="'.$this->title.'" title="'.$alt_text.'"'.$tag_width.$tag_height.' '.$add_tags.' />';
		}
	}
	/****************************************************************/
	/* this sets the caption (for overlay only)
	/****************************************************************/
	function set_myclasshref ($myclasshref = '') {

		if ($myclasshref != '') $this->myclass .= ' '.$myclasshref;
	}
	/****************************************************************/
	/* Returns html code
	/****************************************************************/
	function thickbox_link($objectType='overlay', $ID='') {

		switch ($objectType) :
			case 'iframe' :
				if ($this->src_url == '')
					$html_string = "\n".'<a href="'.$this->link_url.'?KeepThis=true&amp;TB_iframe=true&amp;height='.$this->objectHeight.'&amp;width='.$this->objectWidth.'" class="'.$this->myclass.'" >'.
						$this->href_text.
						"\n".'</a>'."\n";
				else
					$html_string = "\n".'<a href="'.$this->src_url.'?KeepThis=true&amp;TB_iframe=true&amp;height='.$this->objectHeight.'&amp;width='.$this->objectWidth.'" src="'.$this->src_url.'" class="'.$this->myclass.'" >'.
						$this->href_text.
						"\n".'</a>'."\n";
				break;
			case 'ajax' :
				if ($this->src_url == '')
					$html_string = "\n".'<a href="'.$this->link_url.'?height='.$this->objectHeight.'&amp;width='.$this->objectWidth.'" class="'.$this->myclass.'" >'.
						$this->href_text.
						"\n".'</a>'."\n";
				else
					$html_string = "\n".'<a href="'.$this->src_url.'?height='.$this->objectHeight.'&amp;width='.$this->objectWidth.'" src="'.$this->src_url.'" class="'.$this->myclass.'" >'.
						$this->href_text.
						"\n".'</a>'."\n";
				break;
			case 'swfObject' :
				$html_string = 	"\n".'<a href="#TB_inline?height='.$this->objectHeight.'&amp;width='.$this->objectWidth.'&amp;inlineId=myBody'.$ID.'" class="'.$this->myclass.'">'.
						$this->href_text.
						'</a>'.
						"\n".'<div id="myBody'.$ID.'" style="display: none" >No content</div>'."\n".
						$this->body;
				break;
			case 'html' :
				$html_string = 	'<a href="#TB_inline?height='.$this->objectHeight.'&amp;width='.$this->objectWidth.'&amp;inlineId=myBody'.$this->ID.'" class="'.$this->myclass.'">'.
							'<img src="'.$this->thumb_url.'" alt="'.$this->alt_text.'" />'.
						'</a>'.
						'<div id="myBody'.$this->ID.'" style="display: none" >'.$this->body.'</div>';
				break;
			default :
				if ($this->href_text == '')
					$html_string = '<a href="'.$this->img_url.'" class="'.$this->myclass.'"  rel="WP_ptr_gallery" title="'.$this->title.'" ><img src="'.$this->thumb_url.'" alt="'.$this->alt_text.'" /></a>';
				else
					$html_string = '<a href="'.$this->img_url.'" class="'.$this->myclass.'" rel="WP_ptr_gallery" title="'.$this->title.'" >'.$this->href_text.'</a>';
				
                endswitch;

		return $html_string;
	}

}  // End of pt_thickbox class

?>