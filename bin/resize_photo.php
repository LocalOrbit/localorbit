<?
global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();
core::load_library('image');

$img_path   = $argv[1];
$max_width  = $argv[2];
$max_height = $argv[3];
$new_img_path   = $argv[4];


$image = new core_image($img_path);
$image->load_image();

list($x,$y) = $image->determine_new_dimens($max_width,$max_height);
echo('resizing '.$image->extension.' from '.$image->width.'x'.$image->height.' to '.$x.'x'.$y."\n");
$image->resize_to($x,$y);


$image->save_as($new_img_path);
?>