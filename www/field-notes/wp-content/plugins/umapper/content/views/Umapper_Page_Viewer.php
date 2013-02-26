<div>
    <?php if ($this->contAlign == 'center'):?><center><?php endif;?>

    <div style="width:<?php echo $this->contSize[0]?><?php echo $this->contSize[2]?>;height:<?php echo $this->contSize[1]?><?php echo $this->contSize[3]?>;float:<?php echo $this->contAlign?>">

    <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="100%" height="100%" id="<?php echo $this->mapToken?>">
    <param name="FlashVars" value="<?php echo $this->mapToken?>" />
    <param name="movie" value="<?php echo $this->embedTemplate;?>.swf" />
    <param name="quality" value="high" />
    <param name="allowScriptAccess" value="always" />
    <param name="allowFullScreen" value="true" />
    <embed src="<?php echo $this->embedTemplate;?>.swf" FlashVars="<?php echo $this->mapToken?>" allowScriptAccess="always" allowFullScreen="true" quality="high" width="100%" height="100%" name="<?php echo $this->mapToken?>" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
    </object>
    </div>
    <?php if ($this->contAlign == 'center'):?></center><?php endif;?>
</div>