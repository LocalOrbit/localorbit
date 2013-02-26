<?php
$mapData = array('providerId' => 0, 'embedTemplateId' => 0);
?>
<div style="margin-top:15px;background-color: rgb(255, 251, 204);display:none;" id="umapper-warning" class="updated fade">
    <p><strong><?php _e('UMapper requires API key.');?></strong> <?php _e('You must enter your umapper.com API key for plugin to work.');?></p>
</div>
<div>
    <form name="mapForm" id="mapForm" action="">
        <div>
            <div class="frmElement" style="padding-top:0px;margin-top:0px;">
                <div class="elTitle"><label for="mapTitle"><?php _e('Map Title', 'umapper')?>:</label></div>
                <div><input type="text" name="mapTitle" id="mapTitle" maxlength="255" class="elInput" value="<?php echo (isset($mapData['mapTitle']) ? stripslashes($mapData['mapTitle']) : '')?>"/></div>
                <div class="clear"></div>
            </div>
            <div class="frmElement">
                <div class="elTitle"><label for="mapDesc"><?php _e('Map Description', 'umapper')?>:</label></div>
                <div><textarea name="mapDesc" id="mapDesc" rows="2" class="elTextarea"><?php echo (isset($mapData['mapDesc']) ? stripslashes($mapData['mapDesc']) : '')?></textarea></div>
                <div class="clear"></div>
            </div>
            <div class="frmElement" style="float:left;width:285px;">
                <div class="elTitle"><label for="providerId"><?php _e('Map Provider', 'umapper')?>:</label></div>
                <div style="font-size:0.9em;">
                    <select name="providerId" id="providerId" class="elSelect" style="width:283px;">
                        <?php
                        $mapProviders = json_decode(get_option('umapper_providers'), true);
                        if(is_array($mapProviders) && count($mapProviders)) {
                            foreach($mapProviders as $provider) {
                                echo '<option value="' . $provider['id'] . '" ' . ($mapData['providerId']==$provider['id']?'selected="selected"':'') . '>' . $provider['providerTitle'];
                            }
                        }
                        ?>
                    </select>
                </div>
            </div>
            <div class="frmElement" style="float:left;width:285px;">
                <div class="elTitle"><label for="embedTemplateId"><?php _e('Map Template', 'umapper')?>:</label></div>
                <div style="font-size:0.9em;">
                    <select name="embedTemplateId" id="embedTemplateId" class="elSelect" style="width:283px;">
                        <?php
                        $mapTemplates = json_decode(get_option('umapper_templates'), true);
                        if(is_array($mapTemplates) && count($mapTemplates)) {
                            foreach($mapTemplates as $template) {
                                echo '<option value="' . $template['id'] . '" ' . ($mapData['embedTemplateId']==$template['id']?'selected="selected"':'') . '>' . $template['title'];
                            }
                        }
                        ?>
                    </select>
                </div>
            </div>
            <div style="clear:both"></div>
        </div>
    </form>
</div>