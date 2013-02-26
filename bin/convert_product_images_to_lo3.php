<?

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

core_db::query('delete from product_images');

$base_path = '/home/localorb/sites/production/www/MAGstore/media/catalog/product';
$new_path  = '/var/www/production/www/img/products/raws/';
$base_copy_path = '/tmp/lo-old/';

$products = core_db::query('
	select cpe.entity_id,cpe.sku,cpe.product_id,
	cpev1.value as img1,
	cpev2.value as img2,
	cpev2.value as img3,
	cpemg.value as img4

	from catalog_product_entity cpe
	left join catalog_product_entity_varchar cpev1 on (cpev1.entity_id=cpe.entity_id and cpev1.attribute_id=70)
	left join catalog_product_entity_varchar cpev2 on (cpev2.entity_id=cpe.entity_id and cpev2.attribute_id=71)
	left join catalog_product_entity_varchar cpev3 on (cpev3.entity_id=cpe.entity_id and cpev3.attribute_id=72)
	left join catalog_product_entity_media_gallery cpemg on cpemg.entity_id=cpe.entity_id
');

while($product = core_db::fetch_assoc($products))
{
	#print_r($product);
	
	# figure out the final path
	$imgpath = '';
	if($product['img1'] != '' && $product['img1'] != 'no_selection')
		$imgpath = $product['img1'];
	if($product['img2'] != '' && $product['img2'] != 'no_selection')
		$imgpath = $product['img2'];
	if($product['img3'] != '' && $product['img3'] != 'no_selection')
		$imgpath = $product['img3'];
	if($product['img4'] != '' && $product['img4'] != 'no_selection')
		$imgpath = $product['img4'];
		
	# only run this if we actually find an image
	if(
		$imgpath != ''
		&& $imgpath != 'no_selection'
		&& $imgpath !='/f/i/file_52.jpg'
		&& $imgpath !='/f/i/file_102.jpg'
		&& $imgpath !='/f/i/file_121.jpg'
		&& $imgpath !='/f/i/file_136.jpg'
		&& $imgpath !='/f/i/file_236.jpg'
		&& $imgpath !='/f/i/file_237.jpg'
		&& $imgpath !='/f/i/file_236.jpg'
		&& $imgpath !='/f/i/file_236.jpg'
		&& $imgpath !='/f/i/file_236.jpg'
	)
	{
		$finalpath = $base_path.$imgpath;
		$copy_path = $base_copy_path.basename($imgpath);
		exec('scp lo-old:'.$finalpath.' /tmp/lo-old/');
		
		if(file_exists($copy_path) && $copy_path != '/tmp/lo-old/placeholder-l.gif')
		{
			$extension = 'unknown';
			try
			{
				$img = imagecreatefromjpeg($copy_path);
				$extension = 'jpg';
			}
			catch(Exception $e)
			{
			}
			
			if($extension == 'unknown')
			{
				try
				{
					$img = imagecreatefrompng($copy_path);
					$extension = 'png';
				}
				catch(Exception $e)
				{
				}
			}
			if($extension == 'unknown')
			{
				try
				{
					$img = imagecreatefromgif($copy_path);
					$extension = 'gif';
				}
				catch(Exception $e)
				{
				}
			}
			
			
					
			if($extension == 'unknown')
			{
				exit('wtffff');
			}
			
			
			$width = imagesx($img);
			$height = imagesy($img);
			
			core_db::query('
				insert into product_images 
				(prod_id,extension,width,height,priority)
				values
				('.$product['product_id'].',\''.$extension.'\','.$width.','.$height.',1);
			');
			$id = mysql_insert_id();
			
			copy($copy_path,$new_path.$id.'.dat');
		
		}
		else
		{
			echo("does not exist: ".$copy_path."\n");
		}
		
	}
}


?>