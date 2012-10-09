<?php
/**
 * Handles all shortcodes supported by plugin. Functionality includes both manipulation of content and editor options.
 *
 * @category   Wordpress
 * @package    Umapper
 * @subpackage Shortcode
 * @copyright  2008 Advanced Flash Components
 * @version    1.0.0
 */

/**
 * Zend_XmlRpc_Client
 */
require_once 'Zend/XmlRpc/Client.php';

/**
 * Umapper_Pages_MediaPages
 */
require_once 'Umapper/Pages/MediaPages.php';

/**
 * @category   Wordpress
 * @package    Umapper
 * @subpackage Shortcode
 * @copyright  2008 Advanced Flash Components
 * @version    Release: 1.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */ 
class Umapper_Shortcode
{
    /**
     * Uri where plugin is located
     *
     * @var string
     */
    protected $pluginUri;
    
    /**
     * Instance to RPC client
     *
     * @var Zend_XmlRpc_Client
     */
    protected $rpcClient;
    
    /**
     * Matrix of allowable map sizes
     *
     * @var array
     */
    protected $mapSizes = array(
        'sq'    => array(225, 225, 'px', 'px'),
        't'     => array(300, 200, 'px', 'px'),
        's'     => array(440, 280, 'px', 'px'),
        'm'     => array(520, 340, 'px', 'px'),
        'l'     => array(800, 600, 'px', 'px'),
    );

    /**
     * Matrix of possible align options
     *
     * @var array
     */
    protected $mapAlign = array(
        'none' => '',
        'left' => 'left',
        'center' => 'center',
        'right' => 'right',
    );
    
    /**
     * Singleton instance.
     *
     * Set as protected to allow extension of the class. To extend simply override the {@link getInstance()}
     * @var Umapper_Shortcode
     */
    protected static $_instance;
    
    /**
     * Singleton instance.
     *
     * @return Umapper_Shortcode
     */
    public static function getInstance()
    {
        if (null == self::$_instance) {
            self::$_instance = new self();
        }
        return self::$_instance;
    }
    
    /**
     * @return void
     */
    public function __construct() 
    {
        $this->pluginUri = get_option('siteurl') . '/wp-content/plugins/umapper/';
        $this->rpcClient = new Zend_XmlRpc_Client('http://www.umapper.com/services/xmlrpc/');
        
    }
    
    /**
     * [umap] shortcode
     * Syntax for short code: [umap mapId="ID"]MAP TITLE[/umap]
     * This function is used in order to render code on client side.
     *
     * @param array  $atts Array of shortcode attributes
     * @param string $content Content value enclosed in shortcode tags
     * @return string
     */
    public function shortcodeUmap($atts, $content = null) 
    {
        // filter attributes
        $defaults = array('id' => 0 , 'size' => 's', 'alignment' => '', 'w' => 0, 'h' => 0);
        $atts = shortcode_atts($defaults, $atts);
        $xHtml = '';
        
        if (0 != $atts['id']) {
            // get dimensions
            if (isset($this->mapSizes[$atts['size']])) {
                $size = $this->mapSizes[$atts['size']];
            } else {
                $size = $this->mapSizes['s'];
            }
            
            // process custom sizes
            if (('c' == $atts['size']) && $atts['w'] && $atts['h']) { // custom map size
                $size = array();
                if ('%' == substr($atts['w'], -1)) {
                    $size[0] = str_replace('%', '', $atts['w']);
                    $size[2] = '%';
                } else {
                    $size[0] = str_replace('px', '', $atts['w']);
                    $size[2] = 'px';
                }
                if ('%' == substr($atts['h'], -1)) {
                    $size[1] = str_replace('%', '', $atts['h']);
                    $size[3] = '%';
                } else {
                    $size[1] = str_replace('px', '', $atts['h']);
                    $size[3] = 'px';
                }
            }
            
            // get alignment
            if (isset($this->mapAlign[$atts['alignment']])) {
                $align = $this->mapAlign[$atts['alignment']];
            } else {
                $align = $this->mapAlign['center'];
            }
            
            ob_start();
            // setup required parameters
            $this->contSize = $size;
            $this->contAlign = $align;
            $this->mapToken = 'kmlPath=http://www.umapper.com/download/maps/kml/' . $atts['id'] . '.kml';
            //$this->swfSrc = $this->pluginUri . '/content/swf/view';
            //$this->swfInstallerSrc = $this->pluginUri . '/content/swf/playerProductInstall';
            require dirname(__FILE__) . '/../content/tpl/viewer.tpl.php';
            $xHtml = ob_get_clean();
        }
        
        return $xHtml;
    }
    
    
    
    /**
     * Adds media buttons to WP editor
     *
     * @return void
     */
    public function mediaButtons() 
    {
        global $post_ID, $temp_ID;
        $uploading_iframe_ID = (int) (0 == $post_ID ? $temp_ID : $post_ID);
        $media_upload_iframe_src = "media-upload.php?post_id=$uploading_iframe_ID";

        $media_umap_iframe_src = apply_filters('media_umapper_iframe_src', "$media_upload_iframe_src&amp;type=umapper_meta&amp;tab=umapper_meta");
        $title = __('Add UMapper Map', 'umapper');
        
        echo <<<EOD
<a href="javascript://" onClick="tb_show('{$title}', '{$media_umap_iframe_src}' + umapper.parseShortTag(window.tinyMCE.activeEditor.selection.getContent({format : 'text'})) + '&TB_iframe=true&height=500&width=640', false)"><img src="{$this->pluginUri}content/img/umapper.gif" alt="{$title}" title="{$title}"/></a>
EOD;
    }
    
    /**
     * Echoes the custom media iframe
     *
     * @return void
     */
    public function mediaFrameMapMeta() 
    {
        //  we cannot use our object because of the bug in wp/wp-admin/includes/media/
        wp_iframe('umapperMediaMapMeta'); // workaround -  Umapper_Shortcode::getInstance()->mediaFramePageMapMeta(); called
    }
    
    /**
     * Echoes the map editor media iframe
     *
     * @return void
     */
    public function mediaFrameMapEditor() 
    {
        // we cannot use our object because of the bug in wp/wp-admin/includes/media/
        wp_iframe('umapperMediaMapEditor'); // workaround -  Umapper_Shortcode::getInstance()->mediaFramePageMapEditor(); called
    }
    
    /**
     * Echoes my maps media iframe
     *
     * @return void
     */
    public function mediaFrameMaps() 
    {
        // we cannot use our object because of the bug in wp/wp-admin/includes/media/
        wp_iframe('umapperMediaMaps'); // workaround -  Umapper_Shortcode::getInstance()->mediaFramePageMaps(); called
    }
    
    /**
     * Returns media tabs
     *
     * @return array
     */
    public function mediaTabs() 
    {
        $currentTab = isset($_REQUEST['tab']) ? $_REQUEST['tab'] : 'umapper_meta';
        $mapId = isset($_REQUEST['map_id']) ? (int)$_REQUEST['map_id'] : 0;
        if (!$mapId) {
            return array(
                'umapper_meta' =>  __('Create New Map', 'umapper'),
                'umapper_maps' =>  __('My Maps', 'umapper'),
            );
        }
        
        // decide whether edit or create new action is triggered
        switch ($currentTab) {
            case 'umapper_meta':
                return array(
                    'umapper_meta' =>  __('Edit Map Info', 'umapper'),
                    'umapper_maps' =>  __('My Maps', 'umapper'),
                );
            break;
            case 'umapper_editor':
                return array(
                    'umapper_editor' =>  __('Map Editor', 'umapper'),
                    'umapper_maps' =>  __('My Maps', 'umapper'),
                );
            break;
            case 'umapper_maps':
        	default:
                return array(
                    'umapper_meta' =>  __('Map Info', 'umapper'),
                    'umapper_editor' =>  __('Map Editor', 'umapper'),
                    'umapper_maps' =>  __('My Maps', 'umapper'),
                );
        	break;
        }
    }
    
    /**
     * Gets necessarty tab URI
     *
     * @return string
     */
    public function getTabUri($tab, $extraVars = array()) 
    {
        $requestVars = $_GET;
        $tabUri = 'media-upload.php?';
        if (strlen($tab)) {
            $requestVars['tab'] = $tab;    
        }elseif (isset($requestVars['tab'])) {
            unset($requestVars['tab']);
        }
        
        // no need to auto-refresh
        if (isset($requestVars['refresh'])) {
            unset($requestVars['refresh']);
        }
        foreach ($extraVars as $varName=>$varValue) {
            if (($varName == 'map_id') && ($requestVars['map_id']) && (!$varValue)) {
                unset($requestVars['map_id']);
            } else {
                $requestVars[$varName] = $varValue;    
            }
            
        }
        
        foreach ($requestVars as $k=>$v) {
            $tabUri .= $k . '=' . $v . '&';
        }
        return $tabUri;
        
    }
    
    /**
     * Returns HTML for a require MSGBOX
     *
     * @param   string  $title  Message box title
     * @param   string  $body   Main body message
     * @return  string
     */
    public function getMsgBox($id, $title, $body) 
    {
        $oHtml = '<div id="msg_box_' . $id . '" style="display:none;"><div>';
        $oHtml .= '<div class="indicator_m"><img src="' . $this->pluginUri . 'content/img/indicator_m.gif" height=32" width="32" border=0 /></div>';
        $oHtml .= '<div style="float:left;text-align:left;"><b>' . $title . '</b><br>'. $body .'</div>';
        $oHtml .= '<div class="clear"></div></div></div>';
        return $oHtml;
    }
    
    /**
     * Map Meta-data iframe page
     *
     * @return void
     */
    public function mediaFramePageMapMeta() 
    {
        if (!get_option('umapper_api_key')) {
            echo '<div style="margin-top:15px;background-color: rgb(255, 251, 204);" id="umapper-warning" class="updated fade"><p><strong>Umapper requires API key.</strong> You must enter your umapper.com API key for plugin to work.</p></div>';            
            return;
        }
        // add tabs
        add_filter('media_upload_tabs', array($this, 'mediaTabs'));
        
        media_upload_header();
        
        $xHtmlMessage = '';
        if (isset($_REQUEST['map_id'])) {
            $mapId = (int)$_REQUEST['map_id'];
            $mapSize = isset($_REQUEST['map_size']) ? 'size_' . $_REQUEST['map_size'] : 'size_s';
            $mapAlign = isset($_REQUEST['map_alignment']) ? 'alignment_' . $_REQUEST['map_alignment'] : 'alignment_center';
            $mapW = isset($_REQUEST['map_w']) ? str_replace('_', '%', $_REQUEST['map_w']) : 0;
            $mapH = isset($_REQUEST['map_h']) ? str_replace('_', '%', $_REQUEST['map_h']) : 0;
            
            // get map data
            $apiKey = get_option('umapper_api_key');
            try {
                $token = $this->rpcClient->call('maps.connectByKey', array($apiKey));
                $mapData = $this->rpcClient->call('maps.getMapMeta', array($token, $apiKey, $mapId));
             } catch (Exception $e){
                 $xHtmlMessage =  $e->getMessage();
             }
              
        } else {
            $mapData['providerId'] = 2; // MS
        }
        ?>
            <div id="umapper-ajax-messages" style="position:absolute;top:0px;right:10px;padding:0px;margin-top:7px;padding-right:10px;height:20px;"></div>
        <div class="umapper" style="height:438px;">
            <div id="msg_box_background"></div>
            <div id="msg_box_dialog"></div>
        <?php
        echo $this->getMsgBox('redirect_editor', __('Redirecting', 'umapper'), __('Redirecting to map editor..', 'umapper'));
        echo $this->getMsgBox('redirect_meta_new', __('Redirecting', 'umapper'), __('Redirecting to map creation screen..', 'umapper'));
        if (!strlen($xHtmlMessage)) { // no error messages
            ?>
            <form name="mapForm" id="mapForm" action="">
            <div>
                <div class="frmElement" style="padding-top:0px;margin-top:0px;">
                    <div class="elTitle"><?php _e('Map Title', 'umapper')?>:</div>
                    <div><input type="text" name="mapTitle" id="mapTitle" maxlength="255" class="elInput" value="<?php echo (isset($mapData['mapTitle']) ? stripslashes($mapData['mapTitle']) : '')?>"/></div>
                    <div class="clear"></div>
                </div>
                <div class="frmElement">
                    <div class="elTitle"><?php _e('Map Description', 'umapper')?>:</div>
                    <div><textarea name="mapDesc" id="mapDesc" rows="2" class="elTextarea"><?php echo (isset($mapData['mapDesc']) ? stripslashes($mapData['mapDesc']) : '')?></textarea></div>
                    <div class="clear"></div>
                </div>
                <div class="frmElement">
                    <div class="elTitle"><?php _e('Map Provider', 'umapper')?>:</div>
                    <div style="font-size:0.9em;">
                        <div style="padding:5px;"><label style="white-space: nowrap;"><input name="providerId" value="2" <?php echo (isset($mapData['providerId'])&&($mapData['providerId']==2)?'checked="checked"':'')?> type="radio">&nbsp;Microsoft Virtual Earth</label></div>
                        <div style="padding:5px;"><label style="white-space: nowrap;"><input name="providerId" value="1" <?php echo (isset($mapData['providerId'])&&($mapData['providerId']==1)?'checked="checked"':'')?> type="radio">&nbsp;Google</label></div>
                        <div style="padding:5px;"><label style="white-space: nowrap;"><input name="providerId" value="3" <?php echo (isset($mapData['providerId'])&&($mapData['providerId']==3)?'checked="checked"':'')?> type="radio">&nbsp;OpenStreetMap</label></div>
                        <div style="padding:5px;"><label style="white-space: nowrap;"><input name="providerId" value="4" <?php echo (isset($mapData['providerId'])&&($mapData['providerId']==4)?'checked="checked"':'')?> type="radio">&nbsp;Yahoo</label></div>
                    </div>
                    <div class="clear"></div>
                </div>
                <div class="frmElement" style="text-align:right;">
                    <div style="width:600px;">
                        <div style="float:left;">
                            <?php if (isset($mapId)):?>
                                <input id="mapBtnSubmit" type="button" onClick="umapper.redirect('<?php echo $this->getTabUri('umapper_meta', array('map_id'=>0));?>', 'redirect_meta_new');" value="<?php _e('New Map', 'umapper');?>" class="button" />
                                <!--<input id="mapBtnInsert" type="button" onClick="umapper.showInsertDialog('<?php echo $mapSize;?>', '<?php echo $mapAlign;?>', '<?php echo $mapW;?>', '<?php echo $mapH;?>')" value="<?php _e('Insert Map', 'umapper');?>" class="button" />-->
                            <?php endif;?>
                        </div>
                        <div style="float:right;">
                            <?php if (isset($mapId)):?>
                                <?php echo $this->getMsgBox('save_map', __('Save Map', 'umapper'), __('Map is being saved..', 'umapper'));?>
                                <input id="mapBtnSubmit" type="button" onClick="umapper.redirect('<?php echo $this->getTabUri('umapper_editor');?>', 'redirect_editor');" value="<?php _e('Map Editor', 'umapper');?>" class="button" />
                                <input id="mapBtnSubmit" type="button" onClick="umapperAjax.saveMapMeta('<?php echo $this->getTabUri('');?>', '<?php echo $mapId?>', '<?php echo get_option('umapper_api_key')?>', document.getElementById('mapTitle').value, document.getElementById('mapDesc').value, umapper.getCheckedValue(document.forms['mapForm'].elements['providerId'])); return false;" value="<?php _e('Save Changes', 'umapper');?>" class="button" />
                            <?php else:?>
                                <?php echo $this->getMsgBox('create_map', __('New Map', 'umapper'), __('Map is being created..', 'umapper'));?>
                                <input id="divBtnSubmit" id="mapBtnSubmit" type="button" onClick="umapperAjax.createMap('<?php echo $this->getTabUri('');?>','<?php echo get_option('umapper_api_key')?>', document.getElementById('mapTitle').value, document.getElementById('mapDesc').value, umapper.getCheckedValue(document.forms['mapForm'].elements['providerId'])); return false;" value="<?php _e('Create Map', 'umapper');?>" class="button" />
                            <?php endif;?>
                        </div>
                        <div class="clear"></div>
                    </div>
                </div>
                
            </div>
            </form>
            <div class="clear"></div>
            <?php
        } else {
            ?>
            <div style="padding:15px"><?php echo $xHtmlMessage;?></div>
            <?php            
        }
        ?>
        <?php $this->echoMapInsertWindow($mapId);?>
        
        </div>
        <?php
    }
    
    /**
     * Map Editor iframe page
     *
     * @return void
     */
    public function mediaFramePageMapEditor() 
    {
        // add tabs
        add_filter('media_upload_tabs', array($this, 'mediaTabs'));
        media_upload_header();
        echo $this->getMsgBox('redirect_meta', __('Redirecting', 'umapper'), __('Redirecting to map info page..', 'umapper'));
        echo $this->getMsgBox('redirect_meta_new', __('Redirecting', 'umapper'), __('Redirecting to map creation screen..', 'umapper'));
        ?>
        <script language="JavaScript">
            window.onbeforeunload = umapper.checkUmapperMapSave;        
        </script>
        <div class="umapper">
            <div id="msg_box_background"></div>
            <div id="msg_box_dialog"></div>
        <?php if (!isset($_REQUEST['map_id'])):?>
            <div style="padding:10px;">
                Map not found! You have to <a href="<?php echo $this->getTabUri('umapper_meta')?>">create map</a> to gain access to map editor.
            </div>
        <?php else:?>
            <div style="height:432px;width:638;z-index:5;">
                <?php
                    $mapId = (int)$_REQUEST['map_id'];
                    $mapSize = isset($_REQUEST['map_size']) ? 'size_' . $_REQUEST['map_size'] : 'size_s';
                    $mapW = isset($_REQUEST['map_w']) ? str_replace('_', '%', $_REQUEST['map_w']) : 0;
                    $mapH = isset($_REQUEST['map_h']) ? str_replace('_', '%', $_REQUEST['map_h']) : 0;
                    $mapAlign = isset($_REQUEST['map_alignment']) ? 'alignment_' . $_REQUEST['map_alignment'] : 'alignment_center';
                    $apiKey = get_option('umapper_api_key'); 
                    $token = $this->rpcClient->call('maps.connectByKey', array($apiKey));
                    $this->mapToken = 'token=' . $token . '&mapid=' . $mapId;
                    
                    // setup required parameters
                    $this->editorSrc = 'http://umapper.s3.amazonaws.com/assets/swf/edit';
                    $this->editorInstallerSrc = $this->pluginUri . '/content/swf/playerProductInstall';
                    require_once dirname(__FILE__) . '/../content/tpl/editor.tpl.php';
                ?>
                <div class="clear"></div>
            </div>
            <div style="margin-left:15px;margin-right:15px;margin-top:3px;">
                <div style="float:left;">
                    <?php if (isset($mapId)):?>
                        <input id="mapBtnSubmit" type="button" onClick="umapper.redirect('<?php echo $this->getTabUri('umapper_meta', array('map_id'=>0));?>', 'redirect_meta_new');" value="<?php _e('New Map', 'umapper');?>" class="button" />
                        <!--<input id="mapBtnInsert" type="button" onClick="umapper.showInsertDialog('<?php echo $mapSize;?>', '<?php echo $mapAlign;?>', '<?php echo $mapW;?>', '<?php echo $mapH;?>')" value="<?php _e('Insert Map', 'umapper');?>" class="button" />-->
                    <?php endif;?>
                </div>
                <div style="text-align:right;float:right;">
                    <input id="mapBtnInsert" type="button" onClick="umapper.redirect('<?php echo $this->getTabUri('umapper_meta');?>', 'redirect_meta');" value="<?php _e('Edit Info', 'umapper');?>" class="button" />                
                    <input id="mapBtnInsert" type="button" onClick="umapper.showInsertDialog('<?php echo $mapSize;?>', '<?php echo $mapAlign;?>', '<?php echo $mapW;?>', '<?php echo $mapH;?>')" value="<?php _e('Insert Map', 'umapper');?>" class="button" />                
                </div>
                <div class="clear"></div>
                <?php $this->echoMapInsertWindow($mapId);?>
            </div>
        <?php endif;?>
        </div>
        
        <?php
    }
    
    /**
     * Insert window
     *
     * @param int $mapId ID of map to get insert code for
     * @return string
     */
    public function echoMapInsertWindow($mapId) 
    {
        ?>
<div id="put_background"></div>
<form onsubmit="return false" id="put_dialog">
    <input type="hidden" name="id" value="<?php echo $mapId;?>">
    <input type="hidden" name="content" value="<?php echo $mapId;?>">
	<div id="select_size">
	    1. <?php _e('Select map size', 'umapper') ?>
	    <div id="size_preview"><img id="size_image" rel="none" src="<?php echo $this->pluginUri ?>/content/img/size_s.png" alt=""/></div>
	    <div id="sizes">
            <input type="radio" id="size_sq" name="size" value="sq" /> <label for="size_sq"><?php _e('Square', 'umapper') ?> (<?php echo $this->mapSizes['sq'][0] . ' x ' . $this->mapSizes['sq'][1];?>)</label><br />
            <input type="radio" id="size_t" name="size" value="t" /> <label for="size_t"><?php _e('Thumbnail', 'umapper') ?> (<?php echo $this->mapSizes['t'][0] . ' x ' . $this->mapSizes['t'][1];?>)</label><br />
            <input type="radio" id="size_s" name="size" value="s" /> <label for="size_s"><?php _e('Small', 'umapper') ?> (<?php echo $this->mapSizes['s'][0] . ' x ' . $this->mapSizes['s'][1];?>)</label><br />
            <input type="radio" id="size_m" name="size" value="m" /> <label for="size_m"><?php _e('Medium', 'umapper') ?> (<?php echo $this->mapSizes['m'][0] . ' x ' . $this->mapSizes['m'][1];?>)</label><br />
            <input type="radio" id="size_l" name="size" value="l" /> <label for="size_l"><?php _e('Large', 'umapper') ?> (<?php echo $this->mapSizes['l'][0] . ' x ' . $this->mapSizes['l'][1];?>)</label><br />
            <input type="radio" id="size_c" name="size" value="c" /> <label for="size_c"><?php _e('Custom', 'umapper') ?></label><br />
            <div style="margin:0px; padding:0px;margin-left:20px;">
                <input type="text" name="w" id="w" value="<?php echo $this->mapSizes['s'][0];?>px" style="width:45px;font-size:8pt;padding:0px;" maxlength="6" disabled>x<input type="text" name="h" id="h" value="<?php echo $this->mapSizes['s'][1];?>px" style="width:45px;font-size:8pt;padding:0px;" maxlength="6" disabled>
            </div>
            <br />
	    </div>
	</div>
	<div id="select_alignment">
	    2. <?php _e('Select map alignment', 'umapper') ?>
	    <div id="alignment_preview"><img id="alignment_image" rel="none" src="<?php echo $this->pluginUri ?>/content/img/alignment_center.png" alt=""/></div>
	    <div id="allignments">
	        <input type="radio" id="alignment_none" name="alignment" value="none" /> <label for="alignment_none"><?php _e('Default', 'umapper') ?></label><br />
	        <input type="radio" id="alignment_left" name="alignment" value="left" /> <label for="alignment_left"><?php _e('Left', 'umapper') ?></label><br />
	        <input type="radio" id="alignment_center" name="alignment" value="center" /> <label for="alignment_center"><?php _e('Center', 'umapper') ?></label><br />
	        <input type="radio" id="alignment_right" name="alignment" value="right" /> <label for="alignment_right"><?php _e('Right', 'umapper') ?></label><br />
	    </div>
	</div>
    <div id="buttons">
        <input type="button" value="<?php _e('Cancel', 'umapper') ?>" onclick="umapper.cancelMapInsert()" class="button"/>
        <input type="submit" value="<?php _e('Insert', 'umapper') ?>" onclick="umapper.insertMapTag(document.getElementById('put_dialog'))" class="button"/>
    </div>
</form>
<script type="text/javascript">
<!--
var is_msie = /*@cc_on!@*/false;
umapper.prepareInsertDialog('<?php echo $this->pluginUri ?>');
-->
</script>
        <?php
    }

    /**
     * My Maps iframe
     *
     * @return void
     */
    public function mediaFramePageMaps() 
    {
        //
        // add tabs
        add_filter('media_upload_tabs', array($this, 'mediaTabs'));
        media_upload_header();
        
        // get maps
        $apiKey = get_option('umapper_api_key');
        try {
            // try to get from cache
            if (isset($_REQUEST['refresh'])) {
                delete_option('umapper_maps');
            }
            if ($maps = get_option('umapper_maps')) {
                $maps = unserialize($maps);
            } else {
                $token = $this->rpcClient->call('maps.connectByKey', array($apiKey));
                $maps = $this->rpcClient->call('maps.getMaps', array($token, $apiKey));
            }
            $i = 0;
            ?>
            <div id="umapper-ajax-messages" style="position:absolute;top:0px;right:10px;padding:0px;margin-top:7px;padding-right:10px;height:20px;"></div>
            <div class="umapper">
                <div id="msg_box_background"></div>
                <div id="msg_box_dialog"></div>
                <?php echo $this->getMsgBox('delete_map', __('Delete Map', 'umapper'), __('Selected map is being deleted..', 'umapper'));?>            
                <?php echo $this->getMsgBox('redirect_maps', __('Delete Map', 'umapper'), __('Represhing map list..', 'umapper'));?>            
                <div style="padding:10px;">
                <div>
                    <div style="float:left;margin-right:10px;">
                        <img src="<?php echo $this->pluginUri;?>content/img/refresh.png" height="16" width="16" border="0" alt="refresh" />
                    </div>
                    <div style="float:left;">
                    <?php printf(__('Map list is cached for better perfomance. <a href="%1$s">Refresh</a> to get updated map list.','umapper'), $this->getTabUri('umapper_maps', array('refresh'=>1)))?>
                    </div>
                </div>
                <div class="clear" style="height:10px;"></div>
                <?php if (is_array($maps) && count($maps)):?>
                    <div><?php echo __('Total maps:', 'umapper') . count($maps);?></div>
                    <div class="clear" style="height:10px;"></div>
                    <?php foreach ($maps as $map):?>
                        <div style="float:left;margin-right:10px;background-color:<?php echo (($i%3) == 1) ? '#ccc' : 'white';?>">
                        <div style="width:185px;float:left;margin-bottom:5px;">
                            <a href="<?php echo $this->getTabUri('umapper_meta', array('map_id'=>$map['id']))?>" title="<?php echo $map['viewCount']?> views"><?php echo $map['mapTitle']?></a> (<?php echo $map['viewCount']?>) ~
                        </div>
                        <div style="width:16px;float:left;margin-bottom:5px;">
                            <a href="javascript://" onClick="if(confirm('Are you sure?'))umapperAjax.deleteMap('<?php echo $this->getTabUri('');?>','<?php echo get_option('umapper_api_key')?>', '<?php echo $map['id']?>')"><img src="<?php echo $this->pluginUri?>content/img/delete.gif" width="16" height="16" border=0 alt="delete"/></a>
                        </div>
                        </div>
                        <?php if(!(++$i%3)):?>
                            <div class="clear"></div>
                        <?php endif;?>
                        <?php
                            // cache the current list
                            update_option('umapper_maps', serialize($maps));
                        ?>
                    <?php endforeach;?>
                <?php endif;?>                
                <div class="clear"></div>
                </div>
            </div>
            <?php        
        } catch (Exception $e){
            ?>
                <div class="umapper">
                    <div style="padding:10px;">
                    <?php
                        echo $e->getMessage();
                    ?>
                    </div>
                </div>
            <?php
        }
        
    }
    
}