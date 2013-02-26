<?php
########################################################
# Script Info
# ===========
# File: ImageEditor.php
# Created: 05/06/03
# Original Author: Ash Young (ash@evoluted.net)
# Website: http://evoluted.net/php/image-editor.htm
# Requirements: PHP with the GD Library
#
# Description
# ===========
# This class allows you to edit an image easily and
# quickly via php.
#
# If you have any functions that you like to see 
# implemented in this script then please just send
# an email to ash@evoluted.net
#
# Limitations
# ===========
# - GIF Editing: this script will only edit gif files
#   if your GD library allows this.
#
# Image Editing Functions
# =======================
# resize(int width, int height)
#    resizes the image to proportions specified.
#
# crop(int x, int y, int width, int height)
#    crops the image starting at (x, y) into a rectangle
#    width wide and height high.
#
# addText(String str, int x, int y, Array color)
#    adds the string str to the image at position (x, y)
#    using the colour given in the Array color which
#    represents colour in RGB mode.
#
# addLine(int x1, int y1, int x2, int y2, Array color)
#    adds the line starting at (x1,y1) ending at (x2,y2)
#    using the colour given in the Array color which
#    represents colour in RGB mode.
#
# setSize(int size)
#    sets the size of the font to be used with addText()
#
# setFont(String font)
#    sets the font for use with the addText function. This
#    should be an absolute path to a true type font
#
# shadowText(String str, int x, int y, Array color1, Array color2, int shadowoffset)
#    creates show text, using the font specified by set font.
#    adds the string str to the image at position (x, y)
#    using the colour given in the Array color which
#    represents colour in RGB mode.
#
# Useage
# ======
# First you are required to include this file into your
# php script and then to create a new instance of the
# class, giving it the path and the filename of the
# image that you wish to edit. Like so:
#
# include("ImageEditor.php");
# $imageEditor = new ImageEditor("filename.jpg", "directoryfileisin/");
#
# After you have done this you will be able to edit the
# image easily and quickly. You do this by calling a
# function to act upon the image. See below for function
# definitions and descriptions see above. An example
# would be:
#
# $imageEditor->resize(400, 300);
#
# This would resize our imported image to 400 pixels by
# 300 pixels. To then export the edited image there are
# two choices, out put to file and to display as an image.
# If you are displaying as an image however it is assumed
# that this file will be viewed as an image rather than
# as a webpage. The first line below saves to file, the
# second displays the image.
#
# $imageEditor->outputFile("filenametosaveto.jpg", "directorytosavein/");
#
# $imageEditor->outputImage();
#
# Adds
# ====
#
# Resize and crop at once
# Rounded corner, AddText, Sharpness masks, and png save
# added by Alakhnor
# Last Modified: 26/11/07
#
########################################################

class ImageEditor {
	var $x;
	var $y;
	var $type;
	var $img;
	var $font;
	var $error;
	var $img_error=false;
	var $size;
	var $use_png;
	var $use_jpg;
	var $unsharp;
	var $unsharp_amount;
	var $unsharp_radius;
	var $unsharp_threshold;
	var $corner_ratio;
	var $exttype = array('jpg', 'png', 'jpeg', 'gif');

	/****************************************************************/
	/* Constructor
	/****************************************************************/
	function ImageEditor($filename=0, $path=0, $col=NULL, $settings='', $is_remote=true) {
		if ($settings == '') $settings = get_option('post_thumbnail_settings');
		$this->unsharp = ($settings['unsharp'] == 'true');

                // Load options
		if ($settings['unsharp_amount'] == 0)
	       	 	$this->unsharp_amount = 80;
	        else
	                $this->unsharp_amount = $settings['unsharp_amount'];

		if ($settings['unsharp_radius'] == 0)
	        	$this->unsharp_radius = 0.5;
	        else
	                $this->unsharp_radius = $settings['unsharp_radius'];

		if ($settings['unsharp_threshold'] == 0)
	        	$this->unsharp_threshold = 3;
	        else
	                $this->unsharp_threshold = $settings['unsharp_threshold'];

		if ($settings['corner_ratio'] == 0)
	        	$this->corner_ratio = 0.15;
	        else
	                $this->corner_ratio = $settings['corner_ratio'];
	        unset($settings);

		$this->font = false;
		$this->error = false;
		$this->size = 15;
		// If no image specified create blank image
		if(is_numeric($filename) && is_numeric($path)) {

			$this->x = $filename;
			$this->y = $path;
			$this->type = "jpg";
			$this->img = imagecreatetruecolor($this->x, $this->y);

			// Set background colour of image
			if(is_array($col)) {
				$colour = ImageColorAllocate($this->img, $col[0], $col[1], $col[2]);
				ImageFill($this->img, 0, 0, $colour);
			}
		}

		// Image specified so load this image
		else {

			// First see if we can find image
			if(remote_file_exists($path . $filename)) {
				$file = $path . $filename;
			}

			else if (remote_file_exists($path . "/" . $filename)) {
				$file = $path . "/" . $filename;
			}

			else {
				$this->errorImage("File Could Not Be Loaded");
			}

			if(!$this->error) {

				// Load our image with correct function
				$this->type = end(explode('.', $filename));
				if ($this->type == '' || !in_array($this->type, $this->exttype)) $this->type='jpg';

				if (is_cURL() && $is_remote) {
					if($tmpimg = ImageCreateFromcURL ($file)) $this->img_error = false; else $this->img_error = true;
				}

				elseif ($this->type == 'jpg' || $this->type == 'jpeg') {
					if (setMemoryForImage($file)) {
						if($tmpimg = @imagecreatefromjpeg ($file)) { 
							$this->img_error = false; 
						} else $this->img_error = true;
					} else $this->img_error = true;
				}

				elseif ($this->type == 'png') {
					if (setMemoryForImage($file)) {
						if($tmpimg = @imagecreatefrompng ($file)) 
							$this->img_error = false; 
						else 
							$this->img_error = true;
					} else $this->img_error = true;
				}

				elseif ($this->type == 'gif') {
					if (setMemoryForImage($file)) {
						if($tmpimg = @imagecreatefromgif ($file)) {
							$this->img_error = false;
						} else {
							$this->img_error = true;
						}
					} else $this->img_error = true;
				}
				else {
					if (setMemoryForImage($file)) {
						$tmpimg = ImageCreateFromgetContents ($file);
						if ($tmpimg === false) 
							$this->img_error = false; 
						else 
							$this->img_error = true;
					} else $this->img_error = true;
				}

				// Set our image variables
				if (!$this->img_error) {

					if ($this->unsharp)
						$this->img = UnsharpMask($tmpimg, $this->unsharp_amount, $this->unsharp_radius, $this->unsharp_threshold);
					else
						$this->img = $tmpimg;

	        			$this->x = imageSX($this->img);
	        			$this->y = imageSY($this->img);
				}
			}
		}
	}

	/****************************************************************/
	/* Resize image given x and y
	/****************************************************************/
	function resize($new_width, $new_height, $crop_w=0, $crop_h=0, $keep_ratio = true, $max = false) {
	
		if(!$this->error) {

			// Calcul des variables
			$orig_width = $this->x - 2 * $crop_w;
			$orig_height = $this->y - 2 * $crop_h;
			if ($new_width == 0) $new_width = $orig_width;
			if ($new_height == 0) $new_height = $orig_height;

			$L_ratio = $new_width / ( $orig_width );
			$H_ratio = $new_height / ( $orig_height );

			// calcul image destination
			$dst_x = 0;
			$dst_y = 0;
			if ($keep_ratio) {
				if ($max && ($new_width > $orig_width) && ($new_height > $orig_height)) {
					$dst_w = $orig_width;
					$dst_h = $orig_height;
				} elseif ($L_ratio > $H_ratio) {
					$dst_w = ( $orig_width )* $H_ratio;
					$dst_h = $new_height;
				}
				else {
					$dst_w = $new_width;
					$dst_h = ( $orig_height ) * $L_ratio;
				}
			}
			else {
				$dst_w = $new_width;
				$dst_h = $new_height;
			}

			// calcul image source
			$L_ratio = $dst_w / ( $orig_width );
			$H_ratio = $dst_h / ( $orig_height );

			if ($H_ratio > $L_ratio) {
				$src_w = $orig_height * $dst_w / $dst_h;
				$src_x = ($this->x - $src_w)/2 ;
				$src_y = $crop_h;
				$src_h = $orig_height;
			}
			else {
				$src_h = $orig_width * $dst_h / $dst_w;
				$src_y = ($this->y - $src_h)/2 ;
				$src_x = $crop_w;
				$src_w = $orig_width;
			}

			// sizes should be integers
			settype($src_x, 'integer');
			settype($src_y, 'integer');
			settype($src_w, 'integer');
			settype($src_h, 'integer');
			settype($dst_w, 'integer');
			settype($dst_h, 'integer');

			// create new image: imageresampled whill result in a much higher quality than imageresized
			$tmpimage = imagecreatetruecolor($dst_w, $dst_h);
			if ($this->type == 'gif') { 
				$colorTransparent = imagecolortransparent($tmpimage);
				$im2 = imagecreate($dst_w,$dst_h);
				imagepalettecopy($im2,$tmpimage);
				imagefill($im2,0,0,$colorTransparent);
				imagecolortransparent($im2, $colorTransparent);
				$tmpimage = $im2;
				unset($im2);
			} 
			if ($this->type == 'png') imagealphablending($tmpimage, false);
			imagecopyresampled($tmpimage, $this->img, $dst_x, $dst_y, $src_x, $src_y, $dst_w, $dst_h, $src_w, $src_h);

			imagedestroy($this->img);
			$this->img = $tmpimage;
			$this->y = $dst_h;
			$this->x = $dst_w;
		}
	}
	/****************************************************************/
	/* Resize image given x and y
	/****************************************************************/
	function rounded ($corner_ratio) {
	
		$dst_h = $this->y;
		$dst_w = $this->x;

                if ($dst_w > $dst_h)
		{
			$rad_y = $dst_h * $corner_ratio; if ($rad_y <5) $rad_y = 5;
			$rad_x = $rad_y;
		}
		else
		{
			$rad_x = $dst_w * $corner_ratio; if ($rad_x <5) $rad_x = 5;
			$rad_y = $rad_x;
		}
                settype($rad_x, 'integer');
                settype($rad_y, 'integer');
		RoundedImageCorners ($this->img, $rad_x, $rad_y);
	}

	/****************************************************************/
	/* Crops the image, give a start co-ordinate and
	/* length and height attributes
	/****************************************************************/
	function crop($x, $y, $width, $height)
	{
		if(!$this->error)
		{
			$tmpimage = imagecreatetruecolor($width, $height);
			imagecopyresampled($tmpimage, $this->img, 0, 0, $x, $y, $width, $height, $width, $height);
			imagedestroy($this->img);
			$this->img = $tmpimage;
			$this->y = $height;
			$this->x = $width;
		}
	}

	/****************************************************************/
	/* Adds text to an image, takes the string, a starting
	/* point, plus a color definition as an array in rgb mode
	/****************************************************************/
	function addText($str='', $x=0, $y=0, $col=array(0,0,0), $f_size=2)
	{
		$this->setSize ($f_size);
		if(!$this->error)
		{
			if($this->font) {
				$colour = ImageColorAllocate($this->img, $col[0], $col[1], $col[2]);
				if(!imagettftext($this->img, $this->size, 0, $x, $y, $colour, $this->font, $str)) {
					$this->font = false;
					$this->errorImage("Error Drawing Text");
				}
			}
			else {
				$base_font_size = $f_size/5;
				$colour = ImageColorAllocate($this->img, $col[0], $col[1], $col[2]);
				Imagestring($this->img, $base_font_size, $x, $y, $str, $colour);
			}
		}
	}

	/****************************************************************/
	/*
	/****************************************************************/
	function shadowText($str, $x, $y, $col1, $col2, $offset=2)
	{
		$this->addText($str, $x, $y, $col1);
		$this->addText($str, $x-$offset, $y-$offset, $col2);
	}

	/****************************************************************/
	/* Adds a line to an image, takes a starting and an end
	/* point, plus a color definition as an array in rgb mode
	/****************************************************************/
	function addLine($x1, $y1, $x2, $y2, $col)
	{
		if(!$this->error)
		{
			$colour = ImageColorAllocate($this->img, $col[0], $col[1], $col[2]);
			ImageLine($this->img, $x1, $y1, $x2, $y2, $colour);
		}
	}
	/****************************************************************/
	/* Return our edited file as an image
	/****************************************************************/
	function outputImage() {

		switch ($this->type) :

			case 'jpeg' :
	       	        case 'jpg'  :
				header("Content-type: image/jpeg");
				imagejpeg($this->img);
				break;
			case 'png' :
				header("Content-type: image/png");
				imagepng($this->img);
				break;
			case 'gif' :
				header("Content-type: image/gif");
				imagegif($this->img);
				break;
		endswitch;
	}
	/****************************************************************/
	/* Create our edited file on the server
	/****************************************************************/
	function outputFile($filename, $path, $quality=75, $compression=6) {

		switch ($this->type) :

			case 'jpeg' :
        	        case 'jpg'  :
      				imagejpeg($this->img, ($path . $filename), $quality);
				break;
			case 'png' :
				imagesavealpha($this->img, true);
				if ($compression == '6')
					imagepng($this->img, ($path . $filename));
				else
					imagepng($this->img, ($path . $filename), $compression);
				break;
			case 'gif' :
				imagegif($this->img, ($path . $filename));
				break;
		endswitch;
	}
	/****************************************************************/
  	/* Set output type in order to save in different type than we loaded
	/****************************************************************/
	function setImageType($type) {

		$this->type = $type;
	}
	/****************************************************************/
	/* Adds text to an image, takes the string, a starting
	/* point, plus a color definition as an array in rgb mode
	/****************************************************************/
	function setFont($font) {

		$this->font = $font;
	}
	/****************************************************************/
	/* Sets the font size
	/****************************************************************/
	function setSize($size)
	{
		$this->size = $size;
	}
	/****************************************************************/
	/* Get variable functions
	/****************************************************************/
	function getWidth()                {return $this->x;}
	function getHeight()               {return $this->y;}
	function getImageType()            {return $this->type;}

	/****************************************************************/
	/* Creates an error image so a proper object is returned
	/****************************************************************/
	function errorImage($str) {
	
		$this->error = false;
		$this->x = 235;
		$this->y = 50;
		$this->type = "jpg";
		$this->img = imagecreatetruecolor($this->x, $this->y);
		$this->addText("AN ERROR OCCURED:", 10, 5, array(70,70,0));
		$this->addText($str, 10, 30, array(255,255,255));
		$this->error = true;
	}
	/****************************************************************/
	/* Add a semi-transparent box with optional text in it
	/****************************************************************/
  	function AddBox($foot=true, $r=0, $g=0, $b=0, $bh, $text_box='', $rt=255, $gt=255, $bt=255, $text_size=25) {
  	
		$box_x1 = '0';
		$box_xi1 = 0;
		$box_x2 = strval($this->GetWidth());
		$img_height = $this->GetHeight();
		$display_text = ' '.utf8_decode($text_box);

		if ($foot) $box_y1 = strval($img_height-$bh); else $box_y1 = '0';
		$box_yi1 = intval($box_y1);
		if ($foot) $box_y2 = strval($img_height); else $box_y2 = strval($bh);

		$colour = ImageColorAllocateAlpha ($this->img, $r, $g, $b, 80);
		Imagefilledrectangle ($this->img, $box_x1, $box_y1, $box_x2, $box_y2, $colour);

		if ($display_text != '') {
			$col[0]=$rt; $col[1]=$gt;$col[2]=$bt;
			$this->addText ($display_text, $box_xi1, $box_yi1, $col, $text_size);
		}
	}

}
// end of class Image Editor


/***********************************************************************************/
/* generate mask at twice desired resolution and downsample afterwards for easy antialiasing
/* mask is generated as a white double-size elipse on a triple-size black background and copy-paste-resampled
/* onto a correct-size mask image as 4 corners due to errors when the entire mask is resampled at once (gray edges)
/***********************************************************************************/
function RoundedImageCorners(&$gdimg, $radius_x, $radius_y)
{
	if ($gdimg_cornermask_triple = ImageCreateTrueColor($radius_x * 6, $radius_y * 6))
        {
		if ($gdimg_cornermask = ImageCreateTrueColor(ImageSX($gdimg), ImageSY($gdimg)))
                {
			$color_transparent = ImageColorAllocate($gdimg_cornermask_triple, 255, 255, 255);
			ImageFilledEllipse($gdimg_cornermask_triple, $radius_x * 3, $radius_y * 3, $radius_x * 4, $radius_y * 4, $color_transparent);

			ImageFilledRectangle($gdimg_cornermask, 0, 0, ImageSX($gdimg), ImageSY($gdimg), $color_transparent);

			ImageCopyResampled($gdimg_cornermask, $gdimg_cornermask_triple,                           0,                           0,     $radius_x,     $radius_y, $radius_x, $radius_y, $radius_x * 2, $radius_y * 2);
			ImageCopyResampled($gdimg_cornermask, $gdimg_cornermask_triple,                           0, ImageSY($gdimg) - $radius_y,     $radius_x, $radius_y * 3, $radius_x, $radius_y, $radius_x * 2, $radius_y * 2);
			ImageCopyResampled($gdimg_cornermask, $gdimg_cornermask_triple, ImageSX($gdimg) - $radius_x, ImageSY($gdimg) - $radius_y, $radius_x * 3, $radius_y * 3, $radius_x, $radius_y, $radius_x * 2, $radius_y * 2);
			ImageCopyResampled($gdimg_cornermask, $gdimg_cornermask_triple, ImageSX($gdimg) - $radius_x,                           0, $radius_x * 3,     $radius_y, $radius_x, $radius_y, $radius_x * 2, $radius_y * 2);

			ApplyMask($gdimg_cornermask, $gdimg);
			ImageDestroy($gdimg_cornermask);
			$DebugMessage = 'RoundedImageCorners('.$radius_x.', '.$radius_y.') succeeded'. __FILE__. __LINE__;
			return true;

		} else {
			$DebugMessage = 'FAILED: $gdimg_cornermask = ImageColorAllocate('.ImageSX($gdimg).', '.ImageSY($gdimg).')'. __FILE__. __LINE__;
		}
		ImageDestroy($gdimg_cornermask_triple);
	} else {
		$DebugMessage = 'FAILED: $gdimg_cornermask_triple = ImageColorAllocate('.($radius_x * 6).', '.($radius_y * 6).')'. __FILE__. __LINE__;
	}
	return false;
}
/***********************************************************************************/
/*
/***********************************************************************************/
function ApplyMask(&$gdimg_mask, &$gdimg_image)
{
	if (gd_version() < 2)
        {
		$DebugMessage = 'Skipping ApplyMask() because gd_version is "'.gd_version().'"'.__FILE__.__LINE__;
		return false;
	}
	if (version_compare_replacement(phpversion(), '4.3.2', '>='))
        {
		$DebugMessage = 'Using alpha ApplyMask() technique'. __FILE__. __LINE__;
		if ($gdimg_mask_resized = ImageCreateTrueColor(ImageSX($gdimg_image), ImageSY($gdimg_image)))
                 {
			ImageCopyResampled($gdimg_mask_resized, $gdimg_mask, 0, 0, 0, 0, ImageSX($gdimg_image), ImageSY($gdimg_image), ImageSX($gdimg_mask), ImageSY($gdimg_mask));
			if ($gdimg_mask_blendtemp = ImageCreateTrueColor(ImageSX($gdimg_image), ImageSY($gdimg_image)))
                        {
				$color_background = ImageColorAllocate($gdimg_mask_blendtemp, 0, 0, 0);
				ImageFilledRectangle($gdimg_mask_blendtemp, 0, 0, ImageSX($gdimg_mask_blendtemp), ImageSY($gdimg_mask_blendtemp), $color_background);
				ImageAlphaBlending($gdimg_mask_blendtemp, false);
				ImageSaveAlpha($gdimg_mask_blendtemp, true);
				for ($x = 0; $x < ImageSX($gdimg_image); $x++)
                                {
					for ($y = 0; $y < ImageSY($gdimg_image); $y++)
                                        {
						//$RealPixel = phpthumb_functions::GetPixelColor($gdimg_mask_blendtemp, $x, $y);
						$RealPixel = GetPixelColor($gdimg_image, $x, $y);
						$MaskPixel = GrayscalePixel(GetPixelColor($gdimg_mask_resized, $x, $y));
						$MaskAlpha = 127 - (floor($MaskPixel['red'] / 2) * (1 - ($RealPixel['alpha'] / 127)));
						$newcolor = ImageColorAllocateAlphaSafe($gdimg_mask_blendtemp, $RealPixel['red'], $RealPixel['green'], $RealPixel['blue'], $MaskAlpha);
						ImageSetPixel($gdimg_mask_blendtemp, $x, $y, $newcolor);
					}
				}
				ImageAlphaBlending($gdimg_image, false);
				ImageSaveAlpha($gdimg_image, true);
				ImageCopy($gdimg_image, $gdimg_mask_blendtemp, 0, 0, 0, 0, ImageSX($gdimg_mask_blendtemp), ImageSY($gdimg_mask_blendtemp));
				ImageDestroy($gdimg_mask_blendtemp);

			} else {
				$DebugMessage = 'ImageCreateFunction() failed'.__FILE__.__LINE__;
			}
			ImageDestroy($gdimg_mask_resized);
		} else {
			$DebugMessage = 'ImageCreateFunction() failed'.__FILE__.__LINE__;
		}

	} else {
		// alpha merging requires PHP v4.3.2+
		$DebugMessage = 'Skipping ApplyMask() technique because PHP is v"'.phpversion().'"'.__FILE__.__LINE__;
	}
	return true;
}
/***********************************************************************************/
/*
/***********************************************************************************/
function gd_version($fullstring=false) {

	static $cache_gd_version = array();
	if (empty($cache_gd_version)) {

		$gd_info = gd_info();
		if (eregi('bundled \((.+)\)$', $gd_info['GD Version'], $matches))
                {
			$cache_gd_version[1] = $gd_info['GD Version'];  // e.g. "bundled (2.0.15 compatible)"
			$cache_gd_version[0] = (float) $matches[1];     // e.g. "2.0" (not "bundled (2.0.15 compatible)")
		} else {
			$cache_gd_version[1] = $gd_info['GD Version'];                       // e.g. "1.6.2 or higher"
			$cache_gd_version[0] = (float) substr($gd_info['GD Version'], 0, 3); // e.g. "1.6" (not "1.6.2 or higher")
		}
	}
	return $cache_gd_version[intval($fullstring)];
}
/***********************************************************************************/
/*
/***********************************************************************************/
function GetPixelColor(&$img, $x, $y)
{
	if (!is_resource($img)) {
		return false;
	}
	return @ImageColorsForIndex($img, @ImageColorAt($img, $x, $y));
}
/***********************************************************************************/
/*
/***********************************************************************************/
function GrayscalePixel($OriginalPixel) {

	$gray = GrayscaleValue($OriginalPixel['red'], $OriginalPixel['green'], $OriginalPixel['blue']);
	return array('red'=>$gray, 'green'=>$gray, 'blue'=>$gray);
}
/***********************************************************************************/
/*
/***********************************************************************************/
function GrayscaleValue($r, $g, $b) {

	return round(($r * 0.30) + ($g * 0.59) + ($b * 0.11));
}
/***********************************************************************************/
/*
/***********************************************************************************/
function ImageColorAllocateAlphaSafe(&$gdimg_hexcolorallocate, $R, $G, $B, $alpha=false)
{
	if (version_compare_replacement(phpversion(), '4.3.2', '>=') && ($alpha !== false))
        {
		return ImageColorAllocateAlpha($gdimg_hexcolorallocate, $R, $G, $B, intval($alpha));
	} else {
		return ImageColorAllocate($gdimg_hexcolorallocate, $R, $G, $B);
	}
}
/***********************************************************************************/
/*
/***********************************************************************************/
function is_cURL() {

	return (!ini_get('allow_url_fopen') && function_exists('curl_init'));
}
/***********************************************************************************/
/*
/***********************************************************************************/
function ImageCreateFromgetContents($uri) {

	if ($file = @file_get_contents($uri)) {
		$file_size = strlen($file);
		if (setMemoryForImage($uri, 58, true, $file_size)) { 
			$new_image = @imagecreatefromstring($file);
			return $new_image;
		}
	}
	if (function_exists('curl_init')) {
		$new_image = ImageCreateFromcURL($uri);
		if ($new_image !== false) return $new_image;
	}
	
	return false;
}
/***********************************************************************************/
/*
/***********************************************************************************/
function ImageCreateFromcURL($uri) {

	$uri = str_replace ('&amp;','&', $uri);
	$handle = curl_init();
	$timeout = 30; // set to zero for no timeout
//	curl_setopt ($handle, CURLOPT_MUTE, TRUE);
	curl_setopt ($handle, CURLOPT_URL, $uri);
	curl_setopt ($handle, CURLOPT_HEADER,         1);
	curl_setopt ($handle, CURLOPT_FOLLOWLOCATION, 0);
	curl_setopt ($handle, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt ($handle, CURLOPT_CONNECTTIMEOUT, 0);
	curl_setopt ($handle, CURLOPT_TIMEOUT, $timeout);

	$file_contents = curl_exec ($handle);
	$file_size = curl_getinfo ($handle, CURLINFO_CONTENT_LENGTH_DOWNLOAD);
	$content_type = curl_getinfo( $handle, CURLINFO_CONTENT_TYPE );

	curl_close($handle);

	if (setMemoryForImage($uri, 58, true, $file_size)) {
		$new_image = @imagecreatefromstring($file_contents);
		return $new_image;
	} else return false;
}
/***********************************************************************************/
/* 	Reset Max memory if image size higher than memory available.
/***********************************************************************************/
function setMemoryForImage($filename, $TWEAKFACTOR = 1.7, $curl = false, $filesize=0 ) {

	$MB = 1048576;  // number of bytes in 1M
	$K64 = 65536;    // number of bytes in 64K
	if(function_exists('memory_get_usage')) 
		$memory_get_usage = memory_get_usage();
	else
		$memory_get_usage = memory_get_usage2();
	
	if ($curl) {
		$memoryNeeded = round($filesize * $TWEAKFACTOR);
	} else {
		$imageInfo = @getimagesize($filename);
		if ($imageInfo['channels'] == 'image/png') $imageInfo['channels']=4;
		$memoryNeeded = round( ( $imageInfo[0] * $imageInfo[1] * $imageInfo['bits'] * $imageInfo['channels'] / 8 + $K64) * $TWEAKFACTOR)  ;
	}
	//ini_get('memory_limit') only works if compiled with "--enable-memory-limit" also
	//Default memory limit is 8MB so well stick with that. 
	//To find out what yours is, view your php.ini file.
	$memoryLimitMB = str_replace('M', '', ini_get('memory_limit'));
	$memoryLimit = $memoryLimitMB * $MB ;

	// If additional memory is required, adds it
	$addMem = ceil( ( $memory_get_usage + $memoryNeeded - $memoryLimit ) / $MB);
   	if ($addMem > 0){
		$newLimit = $memoryLimitMB + $addMem;
		$m = ini_set( 'memory_limit', $newLimit . 'M' );
		if ($m === false) return true;
	}

	return true;
}
/***********************************************************************************/
/* 	Sets memory_get_usage function if it doesn't exist.
/***********************************************************************************/
if( !function_exists('memory_get_usage') ) {

	function memory_get_usage2() {

		//If its Windows
		//Tested on Win XP Pro SP2. Should work on Win 2003 Server too
		//Doesn't work for 2000
		//If you need it to work for 2000 look at http://us2.php.net/manual/en/function.memory-get-usage.php#54642
		if ( substr(PHP_OS,0,3) == 'WIN') {
			if ( substr( PHP_OS, 0, 3 ) == 'WIN' ) {
				$output = array();
				exec( 'tasklist /FI "PID eq ' . getmypid() . '" /FO LIST', $output );
        
				return preg_replace( '/[\D]/', '', $output[5] ) * 1024;
			}
		} else {

			//We now assume the OS is UNIX
			//Tested on Mac OS X 10.4.6 and Linux Red Hat Enterprise 4
			//This should work on most UNIX systems
			$pid = getmypid();

			// exec("ps -o rss -p $pid", $output);   // Uncomment this line for  MAC OS X 10.4 (Intel)
			exec("ps -eo%mem,rss,pid | grep $pid", $output); // Comment this line for MAC OS X 10.4 (Intel)
			$output = explode("  ", $output[0]);

			//rss is given in 1024 byte units
			return $output[1] * 1024;
		}
	}
} 


////////////////////////////////////////////////////////////////////////////////////////////////
////
////                  Unsharp Mask for PHP - version 2.1
////
////    Unsharp mask algorithm by Torstein H¯nsi 2003-06.
////             thoensi_at_netcom_dot_no.
////               Please leave this notice.
////
///////////////////////////////////////////////////////////////////////////////////////////////
function UnsharpMask($img, $amount=80, $radius=0.5, $threshold=3)
{
    // $img is an image that is already created within php using
    // imgcreatetruecolor. No url! $img must be a truecolor image.  

    // Attempt to calibrate the parameters to Photoshop:  
    if ($amount > 500)    $amount = 500;  
    $amount = $amount * 0.016;  
    if ($radius > 50)    $radius = 50;  
    $radius = $radius * 2;
    if ($threshold > 255)    $threshold = 255;  
      
    $radius = abs(round($radius));     // Only integers make sense.  
    if ($radius == 0) {  
        return $img; imagedestroy($img); break;        }  
    $w = imagesx($img); $h = imagesy($img);  
    $imgCanvas = imagecreatetruecolor($w, $h);  
    $imgBlur = imagecreatetruecolor($w, $h);  
      

    // Gaussian blur matrix:  
    //                          
    //    1    2    1          
    //    2    4    2          
    //    1    2    1
    //                          
    //////////////////////////////////////////////////  
          

    if (function_exists('imageconvolution')) { // PHP >= 5.1   
            $matrix = array(   
            array( 1, 2, 1 ),   
            array( 2, 4, 2 ),   
            array( 1, 2, 1 )   
        );   
        imagecopy ($imgBlur, $img, 0, 0, 0, 0, $w, $h);  
        imageconvolution($imgBlur, $matrix, 16, 0);   
    }   
    else {   

    // Move copies of the image around one pixel at the time and merge them with weight  
    // according to the matrix. The same matrix is simply repeated for higher radii.  
        for ($i = 0; $i < $radius; $i++)    {  
            imagecopy ($imgBlur, $img, 0, 0, 1, 0, $w - 1, $h); // left  
            imagecopymerge ($imgBlur, $img, 1, 0, 0, 0, $w, $h, 50); // right  
            imagecopymerge ($imgBlur, $img, 0, 0, 0, 0, $w, $h, 50); // center  
            imagecopy ($imgCanvas, $imgBlur, 0, 0, 0, 0, $w, $h);  

            imagecopymerge ($imgBlur, $imgCanvas, 0, 0, 0, 1, $w, $h - 1, 33.33333 ); // up  
            imagecopymerge ($imgBlur, $imgCanvas, 0, 1, 0, 0, $w, $h, 25); // down
        }  
    }  

    if($threshold>0){  
        // Calculate the difference between the blurred pixels and the original  
        // and set the pixels  
        for ($x = 0; $x < $w; $x++)    { // each row  
            for ($y = 0; $y < $h; $y++)    { // each pixel  
                      
                $rgbOrig = ImageColorAt($img, $x, $y);  
                $rOrig = (($rgbOrig >> 16) & 0xFF);  
                $gOrig = (($rgbOrig >> 8) & 0xFF);  
                $bOrig = ($rgbOrig & 0xFF);  
                  
                $rgbBlur = ImageColorAt($imgBlur, $x, $y);  
                  
                $rBlur = (($rgbBlur >> 16) & 0xFF);  
                $gBlur = (($rgbBlur >> 8) & 0xFF);  
                $bBlur = ($rgbBlur & 0xFF);  
                  
                // When the masked pixels differ less from the original  
                // than the threshold specifies, they are set to their original value.  
                $rNew = (abs($rOrig - $rBlur) >= $threshold)   
                    ? max(0, min(255, ($amount * ($rOrig - $rBlur)) + $rOrig))   
                    : $rOrig;  
                $gNew = (abs($gOrig - $gBlur) >= $threshold)   
                    ? max(0, min(255, ($amount * ($gOrig - $gBlur)) + $gOrig))   
                    : $gOrig;  
                $bNew = (abs($bOrig - $bBlur) >= $threshold)   
                    ? max(0, min(255, ($amount * ($bOrig - $bBlur)) + $bOrig))   
                    : $bOrig;  
                  
                  
                              
                if (($rOrig != $rNew) || ($gOrig != $gNew) || ($bOrig != $bNew)) {  
                        $pixCol = ImageColorAllocate($img, $rNew, $gNew, $bNew);  
                        ImageSetPixel($img, $x, $y, $pixCol);  
                    }  
            }  
        }
    }  
    else{
        for ($x = 0; $x < $w; $x++)    { // each row  
            for ($y = 0; $y < $h; $y++)    { // each pixel  
                $rgbOrig = ImageColorAt($img, $x, $y);  
                $rOrig = (($rgbOrig >> 16) & 0xFF);  
                $gOrig = (($rgbOrig >> 8) & 0xFF);  
                $bOrig = ($rgbOrig & 0xFF);  
                  
                $rgbBlur = ImageColorAt($imgBlur, $x, $y);  
                  
                $rBlur = (($rgbBlur >> 16) & 0xFF);  
                $gBlur = (($rgbBlur >> 8) & 0xFF);  
                $bBlur = ($rgbBlur & 0xFF);  
                  
                $rNew = ($amount * ($rOrig - $rBlur)) + $rOrig;  
                    if($rNew>255){$rNew=255;}  
                    elseif($rNew<0){$rNew=0;}  
                $gNew = ($amount * ($gOrig - $gBlur)) + $gOrig;  
                    if($gNew>255){$gNew=255;}  
                    elseif($gNew<0){$gNew=0;}  
                $bNew = ($amount * ($bOrig - $bBlur)) + $bOrig;  
                    if($bNew>255){$bNew=255;}  
                    elseif($bNew<0){$bNew=0;}  
                $rgbNew = ($rNew << 16) + ($gNew <<8) + $bNew;  
                    ImageSetPixel($img, $x, $y, $rgbNew);  
            }  
        }  
    }  
    imagedestroy($imgCanvas);  
    imagedestroy($imgBlur);  
      
    return $img;  

} 



?>
