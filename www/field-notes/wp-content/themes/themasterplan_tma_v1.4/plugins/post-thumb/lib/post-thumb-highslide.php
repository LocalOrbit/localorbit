<?php
/****************************************************************/
/* Usage :
	iframe or ajax
	
		$h = new pt_highslide($url, $thumb_url, $title, $src_url);
		
		$h->set_colors($bgcolor, $hdcolor, $ftcolor);
		$h->set_borders($hsframe, $ovtopframe);
		$h->set_padding($hsmargin);
		$h->set_href_text($img_title, $myclassimg);
		$h->set_myclasshref($myclasshref);
		$h->set_bottom($title, $link);
		$h->set_size(550, 1200);

		$html = $h->highslide_link('ajax');
			or
		$html = $h->highslide_link('iframe');

	image
		$h = new pt_highslide($image_url, $thumb_url, $title);

		$h->set_borders ($ovframe);
		$h->set_imgalt($imgalt)
		$h->set_myclasshref($myclasshref);
		$h->set_myclassimg($myclassimg);
		$h->set_href_text($text, $add_attr);
		$h->set_caption($title);

		$html = $h->highslide_link('overlay');

	swf ogject
	
$return_str = $h->highslide_link($objectType, $so='');

/****************************************************************/

class pt_highslide {

	var $main_url;          // If src_url empty, url to link thumbnail to. Otherwise, url to display.
	var $thumb_url = '';	// thumbnail url.
	var $src_url = '';	// src url. url to link thumbnail to.
	var $main_text;		// Title of the link.

	// The parts of the code
	var $href_text = '';	// Line to display in the 'a' tag
	var $header;
	var $has_bottom=false;
	var $footext='';
	var $foohref='';
	var $captionText='';

	// The parameters
	var $objectType;
	var $ID;
	var $htmlID = 'html-';
	var $hrefID = 'href-';
	var $outlineType = "outlineType: 'drop-shadow'";
	var $align= ", align: 'center'";				// Centered on screen
	var $align1= ", position: 'center center'";			// Centered on link
	var $align2= ", targetX: 'hsanchor', targetY: 'hsanchor'";	// Centered anchor
	var $align3= ", align: 'center'";				// Centered on screen

	var $objectWidth = 0;
	var $objectHeight = 0;
	var $rawWidth = 0;
	var $rawHeight = 0;
	var $rawMargin = 0;

	var $objectLoadTime = ", objectLoadTime: 'after'";
	var $bgcolor = 'background-color: #000;';
	var $hdcolor = 'style="background-color: #000;"';
	var $ftcolor = 'style="background-color: #000;"';
	var $move_text = '<a href="#" onclick="return false" class="highslide-move control control2">Move</a>';
	var $close_text = '<a href="#" onclick="return hs.close(this)" class="control">Close</a>';
	var $width = 0;
	var $height = 0;
	var $displaywidth = '';
	var $displayheight = '';
	var $contentId;
	
	var $wrapClass = '';

	var $title = '';
	var $hreftitle = '';
	var $imgtitle = '';
	var $imgalt = '';
	var $alt_text = '';

	var $main_div;
	var $body='';
	var $padding = 'padding: 0;';
	var $padding_content = '';
	
	var $myclasshref = 'highslide';
	var $myclassimg = '';
	var $contentclass = 'highslide-html-content';
	var $topclass = 'highslide-header';
	var $bottomclass = 'highslide-footer';
	var $spanresize = '<span class="highslide-resize" title="Resize"><span></span></span>';

	/****************************************************************/
	/* Constructor
	/****************************************************************/
	function pt_highslide (	$main_url,
                                $thumb_url,
                                $main_text = '',
                                $src_url = ''
                                ) {

		$this->ID 		= 'a'.mt_rand(0,10000);
		$this->htmlID		.= $this->ID;
		$this->hrefID		.= $this->ID;
		$this->href_ID		= $this->hrefID;

		$this->main_url		= $main_url;
		$this->thumb_url 	= $thumb_url;
		$this->src_url 		= $src_url;
		$this->main_text	= $main_text;

		$this->hreftitle	= htmlspecialchars(str_replace("'", "\'", $this->main_text), ENT_QUOTES);
		$this->imgtitle		= __('Click to enlarge: ', 'post-thumb').$this->main_text;
		$this->imgalt		= $this->hreftitle;

		$this->title 		= $this->hreftitle;
		$this->alt_text		= $this->hreftitle;
		$this->contentId 	= ", contentId: 'html-".$this->ID."'";

	}

	/****************************************************************/
	/* This chooses the border type and set the close/move text
	/****************************************************************/
	function set_borders ($outlineType='') {
		if ($outlineType != '') $this->outlineType = "outlineType: '".$outlineType."'";
	}
	/****************************************************************/
	/* This sets the alt attribute of the thumbnail
	/****************************************************************/
	function set_imgalt ($imgalt) {
		$this->imgalt = $imgalt;
	}
	/****************************************************************/
	/* this sets href class
	/****************************************************************/
	function set_myclasshref ($myclasshref = '') {
		if ($myclasshref != '') $this->myclasshref .= ' '.$myclasshref;
	}
	/****************************************************************/
	/* this sets thumb class
	/****************************************************************/
	function set_myclassimg ($myclassimg = '') {
		if ($myclassimg != '') $this->myclassimg .= ' class="'.$myclassimg.'" ';
	}
	/****************************************************************/
	/* this sets the display part, wether a thumbnail or a text
	/* If no thumbnail is given, assume it's a text link
	/****************************************************************/
	function set_href_text ($title_text='', $add_tags='') {
	
		// Set text
		if ($this->thumb_url=='')
			$this->href_text = "\n\t".$this->main_text;
		
		// Set thumbnail
		else {
			// Set title
			if ($title_text != '') $this->imgtitle = $title_text;
		
			// Sets width and height attributes if given
			if ($this->width == 0) $tag_width = ''; else $tag_width = ' width="'.$this->width.'"';
			if ($this->height == 0) $tag_height = ''; else $tag_height = ' height="'.$this->height.'"';
			
			// Creates img tag
			$this->href_text = "\n\t".'<img src="'.$this->thumb_url.'" alt="'.$this->imgalt.'" title="'.htmlspecialchars($this->imgtitle, ENT_QUOTES).'"'.$this->myclassimg.$tag_width.$tag_height.' '.$add_tags.' />';
		}

                // Close 'a' tag
		$this->href_text .= "\n".'</a>';
	}
	/****************************************************************/
	/* this sets the caption (for overlay only)
	/****************************************************************/
	function set_caption ($caption_text = '') {

		if ($caption_text == '') $caption_text = htmlspecialchars($this->imgalt);
		$this->captionText = ", captionText: '".$caption_text."'";
		
	}
	/****************************************************************/
	/* Sets the a tag part of the HS code for Image
	/****************************************************************/
	function overlay_href($event='onclick') {

		$href_ID='';
       		$this->htmlexpand='return hs.expand(this, {'.$this->outlineType.$this->captionText.$this->align.'})';

		return	"\n".'<a href="'.$this->main_url.'" title="'.$this->title.'" class="'.$this->myclasshref.'" '.$href_ID.
                		$event.'="'.$this->htmlexpand.'">';
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
	function set_html_size ($width=0, $height=0) {
		$this->width 	= $width;
		$this->height 	= $height;
	}
	/****************************************************************/
	/* This sets the class of the content
	/****************************************************************/
	function set_content_class ($class='') {
		if ($class != '') $this->contentclass .= ' '.$class;
	}
	/****************************************************************/
	/* This sets the class of the content
	/****************************************************************/
	function set_bottom_class ($class='') {
		if ($class != '') $this->bottomclass .= ' '.$class;
	}
	/****************************************************************/
	/* This sets the class of the content
	/****************************************************************/
	function set_top_class ($class='') {
		if ($class != '') $this->topclass .= ' '.$class;
	}
	/****************************************************************/
	/* This sets the class of the content
	/****************************************************************/
	function set_href_ID ($ID='') {
		if ($ID != '') $this->href_ID .= ' '.$ID;
	}
	/****************************************************************/
	/* This sets the class of the content
	/****************************************************************/
	function set_padding ($padding=0) {
		$this->intpadding = $padding;
	}
	/****************************************************************/
	/* This sets the size of the frame
	/****************************************************************/
	function set_size ($rawWidth=0, $rawHeight=0, $margin=0, $diff=0) {

		$this->rawWidth 	= $rawWidth;
		$this->rawHeight 	= $rawHeight;
		$this->rawMargin 	= $margin;
		$this->objectWidth 	= $this->rawWidth+2*$this->rawMargin;
		$this->objectHeight 	= $this->rawHeight+2*$this->rawMargin;
	}
	/****************************************************************/
	/* This sets the content of the frame.
	/****************************************************************/
	function set_body ($body_text = '') {

		$this->has_body = true;
		$this->body = $body_text;
	}
	/****************************************************************/
	/* This sets the content of the frame.
	/****************************************************************/
	function set_wrapClass ($className = '') {
		$this->wrapClass = ", wrapperClassName: '".$className."' ";
	}
	/****************************************************************/
	/* This sets the bottom part of the frame
	/****************************************************************/
	function set_bottom ($bottom_text = '', $bottom_url = '') {

		$this->has_bottom = true;
		$this->footext = addslashes($bottom_text);
		$this->foohref = $bottom_url;

	}
	/****************************************************************/
	/*
	/****************************************************************/
	function highslide_main_div ($objectType='overlay') {
	
		return;
	}
	/****************************************************************/
	/* Returns html code / href part
	/****************************************************************/
	function highslide_href($objectType='overlay', $so='', $event='onclick') {

		switch ($objectType) :
			case 'iframe' :
				$html_string = $this->iframe_href($event);
				break;
			case 'ajax' :
				$html_string = $this->ajax_href($event);
				break;
			case 'swfObject' :
				$html_string = $this->swf_href($so, $event);
				break;
			case 'html' :
				$html_string = $this->html_href($event);
				break;
			default :
				$html_string = $this->overlay_href($event);
                endswitch;

		return $html_string.$this->href_text;
	}
	/****************************************************************/
	/* Returns html code
	/****************************************************************/
	function highslide_link($objectType='overlay', $so='', $event='onclick') {

		return $this->highslide_href($objectType, $so, $event);

	}
	/****************************************************************/
	/* Sets the a tag part of the HS code for iframe
	/****************************************************************/
	function url_href ($objectType, $event='onclick') {

		$href_ID='';
		if ($this->src_url == '') $var_srcurl = pt_return_get($this->main_url); else $var_srcurl = $this->src_url;
		$var_srcurl = ", src: '".$var_srcurl."'";


       		$this->htmlexpand="return hs.htmlExpand(this, { objectType: '".$objectType."', ".
                				$this->outlineType.
                                        	$this->align.
                                        	$this->wrapClass.
                	                        $var_srcurl.
                	                        ', objectWidth: '.$this->rawWidth.
                	                        ', objectHeight: '.$this->rawHeight.
                	                        ', allowSizeReduction: true'.
						$this->objectLoadTime.
				'},{'.
                                       	"footext: '".$this->footext."'".
                                       	", foohref: '".$this->foohref."'".
                                       	", conwidth: '".$this->objectWidth."'".
                                       	", hspadding: '0'".
                                       	", hsmargin: '".$this->rawMargin."'".
				'})';

		return	"\n".'<a href="'.$this->main_url.'" title="'.$this->title.'" class="'.$this->myclasshref.'" '.$href_ID.
                		$event.'="'.$this->htmlexpand.'">';
	}
	/****************************************************************/
	/* Sets the a tag part of the HS code for iframe
	/****************************************************************/
	function iframe_href ($event='onclick') {
		return $this->url_href ('iframe', $event='onclick');
	}
	/****************************************************************/
	/* Sets the a tag part of the HS code for iframe
	/****************************************************************/
	function ajax_href ($event='onclick') {
		return $this->url_href ('ajax', $event='onclick');
	}
	/****************************************************************/
	/* Sets the a tag part of the HS code for html
	/****************************************************************/
	function html_href ($event='onclick') {

		$link_url = '#';
		$href_ID = ' id="'.$this->href_ID.'" ';
		$var_objectWidth = ', objectWidth: '.$this->objectWidth;
		if ($this->objectHeight > 0) $var_objectHeight = ', objectHeight: '.$this->objectHeight;
		else $var_objectHeight = '';

       		$this->htmlexpand = "return hs.htmlExpand(this, { objectType: 'html', ".$this->outlineType.$this->contentId.$this->wrapClass.$this->align.$var_objectWidth.$var_objectHeight.
				'},{'.
                                       	"footext: '".htmlspecialchars($this->footext, ENT_QUOTES)."'".
                                       	", foohref: '".$this->foohref."'".
                                       	", conwidth: '".$this->objectWidth."'".
                                       	", hspadding: '".$this->rawMargin."'".
                                       	", hsmargin: '0'".
				'})';

		return	"\n".'<a href="'.$link_url.'" title="'.$this->title.'" class="'.$this->myclasshref.'" '.$href_ID.
                	$event.'="'.$this->htmlexpand.'">';
	}
	/****************************************************************/
	/* Returns html code / div part
	/****************************************************************/
	function html_div() {

		$this->main_div = "\n".'<div class="highslide-html-content" id="html-'.$this->ID.'" style="width: '.$this->objectWidth.'px; " >';
		$this->main_div .= "\n\t".'<div class="highslide-header">';
		$this->main_div .= "\n\t\t".'<ul>';
		$this->main_div .= "\n\t\t\t".'<li class="highslide-move">';
		$this->main_div .= "\n\t\t\t\t".'<a href="#" onclick="return false">'.MOVETEXT.'</a>';
		$this->main_div .= "\n\t\t\t".'</li>';
		$this->main_div .= "\n\t\t\t".'<li class="highslide-close">';
		$this->main_div .= "\n\t\t\t\t".'<a onclick="return hs.close(this)" title="" href="#">'.CLOSETEXT.'</a>';
		$this->main_div .= "\n\t\t\t".'</li>';
		$this->main_div .= "\n\t\t".'</ul>';
		$this->main_div .= "\n\t".'</div>';
		$this->main_div .= "\n\t".'<div class="hsclear"></div>';
		$this->main_div .= "\n\t".'<div class="highslide-body" style="height: '.$this->rawHeight.'px">'.$this->body;
		$this->main_div .= "\n\t\t".'<div class="hsclear"></div>';
		$this->main_div .= "\n\t".'</div>';
		$this->main_div .= "\n\t".'<div class="highslide-footer">';
		$this->main_div .= "\n\t\t".'<div>';
		$this->main_div .= "\n\t\t\t".'<span class="highslide-resize" title="">';
		$this->main_div .= "\n\t\t\t\t".'<span></span>';
		$this->main_div .= "\n\t\t\t".'</span>';
		$this->main_div .= "\n\t\t".'</div>';
		$this->main_div .= "\n\t".'</div>';
		$this->main_div .= "\n".'</div>';
		
		return $this->main_div;
	}
	/****************************************************************/
	/* Sets the a tag part of the HS code for swfobject
	/****************************************************************/
	function swf_href ($so='', $event='onclick') {

		$href_ID='';
		
       		$this->htmlexpand='return hs.htmlExpand(this, {swfObject: '.$so.', '.
		       				$this->outlineType.
                                        	$this->align.
                                        	$this->wrapClass.
                	                        ', objectWidth: '.$this->objectWidth.
                	                        ', objectHeight: '.$this->objectHeight.
                	                        ', allowSizeReduction: false'.
						$this->objectLoadTime.
				'},{'.
                                       	"footext: '".htmlspecialchars($this->footext, ENT_QUOTES)."'".
                                       	", foohref: '".$this->foohref."'".
                                       	", conwidth: '".$this->objectWidth."'".
                                       	", hspadding: '".$this->rawMargin."'".
                                       	", hsmargin: '0'".
				'})';

		return	"\n".'<a href="'.$this->main_url.'" title="'.$this->title.'" class="'.$this->myclasshref.'" '.$href_ID.
                	$event.'="'.$this->htmlexpand.'">';
	}
	
}  // End of pt_highslide class

?>