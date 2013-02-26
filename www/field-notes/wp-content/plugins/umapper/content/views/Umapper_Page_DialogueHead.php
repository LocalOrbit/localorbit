<style>
    body {font-size:10px;}
</style>
<script type="text/javascript">
    //<![CDATA[
    jQuery(document).ready(function($){
        // init global map selection
        var mapId = 0;
        var mapIdPrev = 0;
        var currentMapData = {};

        // pre-load necessary images
        new Image().src = umapperOptions.pluginUri + 'content/img/alignment_none.png';
        new Image().src = umapperOptions.pluginUri + 'content/img/alignment_left.png';
        new Image().src = umapperOptions.pluginUri + 'content/img/alignment_center.png';
        new Image().src = umapperOptions.pluginUri + 'content/img/alignment_right.png';

        new Image().src = umapperOptions.pluginUri + 'content/img/size_sq.png';
        new Image().src = umapperOptions.pluginUri + 'content/img/size_t.png';
        new Image().src = umapperOptions.pluginUri + 'content/img/size_s.png';
        new Image().src = umapperOptions.pluginUri + 'content/img/size_m.png';
        new Image().src = umapperOptions.pluginUri + 'content/img/size_l.png';
        new Image().src = umapperOptions.pluginUri + 'content/img/size_c.png';

        var resetCurrentMap = function(){
            mapId = 0;
            mapIdPrev = 0;
            currentMapData = {};
        };

        var setCurrentMap = function(id, callback) {
            if((mapIdPrev != id) || (!currentMapData.id)) { // new global map is selected
                umapperAjax.getMapMeta(id, function(mapData){
                    mapIdPrev = id;
                    mapId = id;
                    currentMapData = mapData;
                    callback();
                });
            } else { // no need to refetch map data
                callback();
            }
        }

        var confirmDialog = function(id) {
            mapId = id;
            $("#dialog").dialog('open');
        };

        var loadEditor = function(id){
            mapId = id;
            $('a[href=#tab-meta]').html(umaptxt.EDIT_MAP_META);
            $('#tabs').tabs('enable', 1);
            $('#tabs').tabs('select', 1);
        };

        var displayMaps = function(start, limit, curPage){
            curPage = curPage || 1;
            umapperAjax.getMaps(start, limit, function(mapsCount, maps){
                $('#map-count').html(mapsCount);
                $('#map-list').html('');

                var i;
                var item;
                for (i = 0; i < maps.length; i += 1) {
                    var item = '<div class="map-item" id="map-item' + maps[i].id + '"><div style="float:left;margin-right:10px;">'
                        + '<div style="width:525px;float:left;margin-bottom:5px;">'
                        + '<a href="javascript://" act="view" mapId="' + maps[i].id + '" title="' + maps[i].viewCount + ' ' + umaptxt.VIEWS + '">' + maps[i].mapTitle + '</a>'
                        + '</div>'
                        + '<div style="width:50px;float:left;text-align:center;"><a href="http://www.umapper.com/maps/stats/oid/' + maps[i].id + '/" target="blank">' + maps[i].viewCount + '</a></div>'
                        + '<div style="width:16px;float:left;margin-bottom:5px;"><a title="' + umaptxt.DELETE_MAP + '" href="javascript://" act="delete" mapId="' + maps[i].id + '"><img src="' + umapperOptions.pluginUri + 'content/img/delete.gif" width="16" height="16" border=0 alt="' + umaptxt.DELETE_MAP + '"/></a></div>'
                        + '</div><div class="clear"></div></div>';
                    $('#map-list').append(item);
                }

                var totalPages = Math.ceil(mapsCount/limit);
                $('#map-pages').html('');
                for(i = 1; i <= totalPages; i += 1) {
                    $('#map-pages').append('<a act="paging" class="page-link" style="background-color:' + (i==curPage?'#CCC':'#fff') + '" page="' + i + '" href="javascript://">' + i + '</a>&nbsp;')
                }

                // bind actions
                $('a[act="view"]').click(function(){
                    loadEditor($(this).attr('mapId'))
                });
                $('a[act="delete"]').click(function(){
                    confirmDialog($(this).attr('mapId'));
                });
                $('a[act="paging"]').click(function(){
                    var page = $(this).attr('page');
                    displayMaps((page - 1) * 10, 10, page);
                });
            });
        };

        var mapsLoaded = false;

        /**
         * TABS - Actions
         */
        $('#tabs').bind('tabsshow', function(e, ui){
            $('#umapper:hidden').show('fast');
            switch (ui.index) {
                case 2: // My Maps
                    $('a[href=#tab-meta]').html(umaptxt.CREATE_NEW_MAP);
                    resetCurrentMap(); // no global map selected
                    $('#tabs').tabs('disable', 1); // make editor tab unavailble
                    if(!mapsLoaded) { // load maps only once
                        displayMaps(0, 10);
                        mapsLoaded = true;
                    }

                    // hide buttons on map editor page (they should be loaded only after we obtain map data)
                    $('#btn_set_map_editor').css('display', 'none');
                    break;
                case 1: // Map Editor
                    setCurrentMap(mapId, function(){
                        $('#btn_set_map_editor').css('display', 'block');
                    });
                    $('#map-editor-frame').attr('src', umapperOptions.pluginUri + 'content/views/Umapper_Page_DialogueMapEditor.php?token=' + umapperOptions.rpcToken + '&mapId=' + mapId);
                    break;
                case 0: // Map Meta
                    $('input#mapTitle').val('');
                    $('textarea#mapDesc').val('');
                    $('select#providerId').val(0);
                    $('select#embedTemplateId').val(0);

                    if(mapId > 0) { // edit meta
                        // reload previous map data
                        setCurrentMap(mapId, function(){
                            $('input#mapTitle').val(currentMapData.mapTitle);
                            $('textarea#mapDesc').val(currentMapData.mapDesc);
                            $('select#providerId').val(currentMapData.providerId);
                            $('select#embedTemplateId').val(currentMapData.embedTemplateId);

                            // update actions set
                            $('#btn_set_meta_edit').css('display', 'block');
                            $('#btn_set_meta_new').css('display', 'none');
                        });
                    } else { // new map
                        $('#btn_set_meta_edit').css('display', 'none');
                        $('#btn_set_meta_new').css('display', 'block');
                    }
                    // hide buttons on map editor page (they should be loaded only after we obtain map data)
                    $('#btn_set_map_editor').css('display', 'none');
                    break;
                default:
                    break;
            }
        });

        /**
         * TABS - Init
         */
        $('#tabs').tabs({
            'selected'   : 0,
            'disabled' : [1],
            fx: { opacity: 'toggle' }
        });
        $('#tabs').height(438 - 6);

        /**
         * Dialog (map delete) - Init
         */
        $("#dialog").dialog({
            autoOpen: false,
            closeOnEscape: true,
            bgiframe: true,
            resizable: false,
            height:140,
            modal: true,
            //show: 'highlight',
            hide : 'slow',
            overlay: {
                backgroundColor: '#000',
                opacity: 0.5
            },
            buttons: {
                '<?php _e('Delete', 'umapper');?>': function() {
                    var that = this;
                    umapperAjax.loadingMsg(true);
                    umapperAjax.deleteMap(mapId, function(){
                        //displayMaps(0, 10);
                        $(that).dialog('close');
                        $('#map-item'+mapId).hide('slow');
                        umapperAjax.loadingMsg(false);
                    });
                },
                '<?php _e('Cancel', 'umapper');?>': function() {
                    umapperAjax.loadingMsg(false);
                    $(this).dialog('close');
                }
            }
        });

        /**
         * Dialog (map insertion) init
         */
        $('#insert_map_dialog').dialog({
            autoOpen: false,
            closeOnEscape: true,
            bgiframe: true,
            resizable: true,
            width:450,
            minWidth:450,
            height:310,
            minHeight:310,
            modal: true,
            hide : 'slow',
            overlay: {
                backgroundColor: '#000',
                opacity: 0.5
            },
            buttons: {
                '<?php _e('Insert', 'umapper');?>': function() {
                    if((mapId > 0) && (currentMapData.id)) { // we have actual map data
                        $('#insert_map_frm #tp').val(currentMapData.embedTemplateId); // update embed template id
                        // generate UMapper shortcode
                        top.send_to_editor(function(){
                            var attrs = ' id="' + mapId + '"';
                            $('#insert_map_frm').find('input:not(input:radio):not(input:disabled),input:radio:checked').each(function(){
                                if (this.value != '') {
                                    attrs += ' ' + this.name + '="' + this.value + '"';
                                }
                            });
                            return '[umap' + attrs + ']';
                        }());
                    }
                    return false;
                },
                '<?php _e('Cancel', 'umapper');?>': function() {
                    $(this).dialog('close');
                }
            }

        });
        
        /**
         * Dialog (warning)
         */
        $("#warning-dialog").dialog({
            autoOpen: false,
            closeOnEscape: true,
            bgiframe: true,
            resizable: false,
            height:140,
            modal: true,
            //show: 'highlight',
            hide : 'slow',
            overlay: {
                backgroundColor: '#000',
                opacity: 0.5
            },
            buttons: {
                '<?php _e('Ok', 'umapper');?>': function() {
                    $(this).dialog('close');
                }
            }
        });

        // ACTIONS

        // toggle map size (insertion dialog)
        $('input[name=size]').change(function(){
            $('#size_image').attr('src', umapperOptions.pluginUri + 'content/img/size_' + $(this).val() + '.png');
            $('input#w').attr('disabled', !('c' == $(this).val()));
            $('input#h').attr('disabled', !('c' == $(this).val()));
        });

        // toggle map alignment (insertion dialog)
        $('input[name=alignment]').change(function(){
            $('#alignment_image').attr('src', umapperOptions.pluginUri + 'content/img/alignment_' + $(this).val() + '.png');
        });

        // Init new map screen
        $('[id^=button][act=new_map]').click(function(){
            //console.log('here we should check whether map is saved before leaving the editor screen..');
            $('a[href=#tab-meta]').html(umaptxt.CREATE_NEW_MAP);

            // nullify input fields
            $('input#mapTitle').val('');
            $('textarea#mapDesc').val('');
            $('select#providerId').val(0);
            $('select#embedTemplateId').val(0);

            // clear global selected map
            resetCurrentMap();

            // make sure that proper actions are enabled
            $('#btn_set_meta_edit').css('display', 'none');
            $('#btn_set_meta_new').css('display', 'block');


            // show required tabs
            $('#tabs').tabs('select', 0);
            $('#tabs').tabs('disable', 1);

        });

        // Save meta-data
        $('[id^=button][act=save_map]').click(function(){
            if(mapId > 0) {
                umapperAjax.saveMapMeta(mapId, $('input#mapTitle').val(), $('textarea#mapDesc').val(), $('select#providerId').val(), $('select#embedTemplateId').val(), function(){
                    mapsLoaded = false; // when user accesses My Maps list would be reloaded
                    mapIdPrev = 0; // we need to refetch current maps data
                });
            }
        });

        // Save meta-data
        $('[id^=button][act=insert_map]').click(function(){
            //console.log('we should ask whether to save map..or maybe save automatically');
            $('#insert_map_dialog').dialog('open');
        });

        // Create meta-data
        $('[id^=button][act=create_map]').click(function(){
            var warningMsg = '';
            var showWarning = false;
            if(!$('#mapTitle').val()) {
                warningMsg += '<?php _e('Map Title', 'umapper');?><br>';
                showWarning = true;
            }
            if(!$('#mapDesc').val()) {
                warningMsg += '<?php _e('Map Description', 'umapper');?><br>';
                showWarning = true;
            }
            if(showWarning) {
                $('#warning-dialog').dialog('option', 'title', '<?php _e('Required fields are empty!', 'umapper');?>');
                $('#warning-message').html('<?php _e('Required fields left blank:<br />', 'umapper')?>' + warningMsg);
                $('#warning-dialog').dialog('open');
            } else {
                umapperAjax.createMap($('#mapTitle').val(), $('#mapDesc').val(), $('#providerId').val(), $('#embedTemplateId').val(), function(id){
                    mapId = id;
                    mapsLoaded = false;
                    loadEditor(mapId);
                });
            }
        });

        $('[id^=button][act=reload_map_list]').click(function(){
            displayMaps(0, 10);
            return false;
        });

        // if RPC key not found - there's no reason to proceed
        if(!umapperOptions.rpcKey){
            $('#umapper-warning').show();
            return false;
        }

    });
    //]]>
</script>
