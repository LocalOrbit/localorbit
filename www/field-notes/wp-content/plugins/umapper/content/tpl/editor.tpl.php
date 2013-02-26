<script language="JavaScript" type="text/javascript">
<!--
// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
var umap_hasProductInstall = DetectFlashVer(6, 0, 65);

// Version check based upon the values defined in globals
var umap_hasRequestedVersion = DetectFlashVer(umap_requiredMajorVersion, umap_requiredMinorVersion, umap_requiredRevision);

if ( umap_hasProductInstall && !umap_hasRequestedVersion ) {
	// DO NOT MODIFY THE FOLLOWING FOUR LINES
	// Location visited after installation is complete if installation is required
	var umap_MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
	var umap_MMredirectURL = window.location;
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var umap_MMdoctitle = document.title;

	AC_FL_RunContent(
		"src", "<?php echo $this->editorInstallerSrc;?>",
		"FlashVars", "MMredirectURL="+umap_MMredirectURL+'&MMPlayerType='+umap_MMPlayerType+'&MMdoctitle='+umap_MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "<?php echo $this->editorSrc;?>",
		"quality", "high",
		"bgcolor", "#000000",
		"name", "editor",
		"allowScriptAccess","always",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (umap_hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
	        "FlashVars", "<?php echo $this->mapToken?>",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"src", "<?php echo $this->editorSrc;?>",
			"id", "<?php echo $this->editorSrc;?>",
			"quality", "high",
			"wmode", "transparent",
			"bgcolor", "#000000",
			"name", "editor",
			"allowScriptAccess","always",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = 'Alternate HTML content should be placed here. '
  	+ 'This content requires the Adobe Flash Player. '
   	+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content
  }
// -->
</script>
<noscript>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="<?php echo $this->editorSrc;?>" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="<?php echo $this->editorSrc;?>.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="#000000" />
			<param name="src" value="<?php echo $this->editorSrc;?>" />
			<param name="name" value="editor" />
			<param name="wmode" value="transparent" />
			<param name="FlashVars" value="<?php echo $this->mapToken?>" />
			<param name="allowScriptAccess" value="always" />
			<embed FlashVars="<?php echo $this->mapToken?>" src="<?php echo $this->editorSrc;?>.swf" id="<?php echo $this->editorSrc;?>" quality="high" bgcolor="#000000"
				width="100%" height="100%" name="editor" align="middle"
				play="true"
				loop="false"
				wmode="transparent"
				quality="high"
				allowScriptAccess="always"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>