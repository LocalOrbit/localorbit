
<?
$images = core::model('product_images')->collection()->filter('prod_id',$core->data['prod_id'])->to_array();

if(count($images) > 0)
{
echo('<img id="prod_image" class="homepage" src="/img/products/cache/'.$images[0]['pimg_id']);
echo('.'.$images[0]['width']);
echo('.'.$images[0]['height']);
echo('.400');
echo('.300');
echo('.'.$images[0]['extension']);
echo('" />');
}
else
{
	echo('<img class="homepage" id="prod_image" />');
}

?>
<div class="buttonset">
	<input type="file" id="new_image" name="new_image" value="" />
	<input type="button" class="btn btn-info" value="Upload" onclick="core.ui.uploadFrame(document.prodForm,'uploadArea','product.refreshImage(<?=intval($images[0]['pimg_id'])?>,{params});','app/products/save_image','new_image');" />
	<input type="button" id="removeLogo" class="btn btn-warning" value="Remove Image" onclick="core.doRequest('/products/remove_image',{'pimg_id':document.prodForm.old_pimg_id.value});" /> 
</div>
<input type="hidden" name="old_pimg_id" value="<?=$images[0]['pimg_id']?>" />
<iframe name="uploadArea" id="uploadArea" width="300" height="20" style="border-width: 0px;color:#fff;background-color:#fff;overflow:hidden;"></iframe>
<div id="output"></div>