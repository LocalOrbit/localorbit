<?php
$currentTab = isset($_REQUEST['tab']) ? $_REQUEST['tab'] : 'umapper_meta';
$mapId = isset($_REQUEST['map_id']) ? (int)$_REQUEST['map_id'] : 0;
?>

<div class="umapper" id="umapper" style="padding:1px 2px 1px 2px;height:438px;display:none;">
    <!-- Ajax messages div -->
    <div id="umapper-ajax-messages" class="updated">&nbsp;</div>

    <!-- Delete map dialogue -->
    <div id="dialog" title="<?php _e('Are you sure?', 'umapper');?>">
        <p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span><?php _e('This map will be permanently deleted and cannot be recovered. Are you sure?', 'umapper');?></p>
    </div>

    <!-- Warning dialogue-->
    <div id="warning-dialog" title="NONE">
        <p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span><span id="warning-message">NONE</span></p>
    </div>

    <!-- Map Insert dialogue -->
    <?php Umapper_Page_Dialogue::show('InsertOptions')?>

    <!-- Main tabs -->
    <div id="tabs">
        <ul>
            <?php if($mapId):?>
            <li><a href="#tab-meta"><?php  _e('Edit Map Info', 'umapper');?></a></li>
            <?php else:?>
            <li><a href="#tab-meta"><?php _e('Create New Map', 'umapper');?></a></li>
            <?php endif;?>
            <!--<li><a href="<?php echo Umapper_Plugin::getPluginUri()?>content/views/blank.php"><?php _e('Map Editor', 'umapper');?></a></li>-->
            <li><a href="#tab-map-editor"><?php _e('Map Editor', 'umapper');?></a></li>
            <li><a href="#tab-map-list"><?php _e('My Maps', 'umapper');?></a></li>
        </ul>
        <div id="tab-meta" class="ui-tabs-hide">
            <div id="btn_set_meta_edit" class="button-set" style="display:none;">
                <a href="#" id="button" act="new_map" class="ui-state-default ui-corner-all"><?php _e('New Map', 'umapper');?></a>
                <a href="#" id="button" act="save_map" class="ui-state-default ui-corner-all"><?php _e('Save Map', 'umapper');?></a>
            </div>
            <div id="btn_set_meta_new" class="button-set">
                <a href="#" id="button" act="create_map" class="ui-state-default ui-corner-all"><?php _e('Create Map', 'umapper');?></a>
            </div>
            <?php Umapper_Page_Dialogue::show('NewMap')?>
        </div>
        <div id="tab-map-editor" class="ui-tabs-hide" style="height:395px;padding:5px 0px 0px 0px;">
            <div id="btn_set_map_editor" class="button-set" style="display:none;">
                <a href="#" id="button" act="new_map" class="ui-state-default ui-corner-all"><?php _e('New Map', 'umapper');?></a>
                <a href="#" id="button" act="insert_map" class="ui-state-default ui-corner-all"><?php _e('Insert Map', 'umapper');?></a>
            </div>
            <iframe id="map-editor-frame" height="100%" width="100%" frameborder="0" scrolling="NO" vspace="0" hspace="0" src="<?php echo Umapper_Plugin::getPluginUri()?>content/views/blank.php"></iframe>
        </div>
        <div id="tab-map-list" class="ui-tabs-hide"> <!-- My Maps-->
            <div class="button-set">
                <a href="#" id="button" act="reload_map_list" class="ui-state-default ui-corner-all"><?php _e('Refresh', 'umapper');?></a>
            </div>
            <?php Umapper_Page_Dialogue::show('MapList')?>
        </div>
    </div>
</div>
