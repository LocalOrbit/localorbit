<?php
global $current_blog;

$ms = array();
$this->checkPermissions();
if (isset($_POST['submit'])) { // process options
    $key = $_POST['key'];

    if (empty($key)) {
        $ms[] = 'API_KEY_RESET';
        delete_option('umapper_api_key');
    } else {
        $ms[] = 'API_KEY_SAVED';
        update_option('umapper_api_key', $key);
    }
}

?>
<script type="text/javascript">
    //<![CDATA[
    jQuery(document).ready(function($){
        var keyValidated = false;
        $('#umapper_save_opts').click(function(){
            if(!keyValidated) {
                $("#umapper-dialog").dialog('open');
                return false;
            }
        });
        $('#umapper-validate-key').click(function(e){
            keyValidated = true;
            var processProviders = function(resp){
            };
            var processTemplates = function(resp){
            };

            var apiKey = $('#key').val();

            $('#umapper-ajax-messages-top').html('<?php _e('Request is being processed..', 'umapper');?>');
            $('#umapper-ajax-messages-top').show('slow');
            $.umap.rpc(umapperOptions.rpcUri, 'maps.verifyApiKey', [apiKey], function(resp){
                if((!resp.error) && resp.result) {
                    umapperAjax.getToken(apiKey, function(token){
                        $('#umapper-ajax-messages-top').html('<?php _e('Requesting list of map providers..', 'umapper');?>');
                        $.umap.rpc(umapperOptions.rpcUri, 'maps.getMapProviders', [token, apiKey], function(resp){
                            if((!resp.error) && resp.result) {
                                // post the results
                                jQuery.ajax({
                                    "url": umapperOptions.rpcUri + '?update_option=umapper_providers',
                                    "dataType": 'json',
                                    "type": "POST",
                                    "data": $.umap.array2json(resp.result),
                                    "success": function(resp) {
                                        $('#umapper-ajax-messages-top').html('<?php _e('Saved..', 'umapper');?>');
                                        $('#umapper-ajax-messages-top').html('<?php _e('Requesting list of map templates..', 'umapper');?>');
                                        $.umap.rpc(umapperOptions.rpcUri, 'maps.getMapTemplates', [token,apiKey], function(resp){
                                            if((!resp.error) && resp.result) {
                                                // post the results
                                                jQuery.ajax({
                                                    "url": umapperOptions.rpcUri + '?update_option=umapper_templates',
                                                    "dataType": 'json',
                                                    "type": "POST",
                                                    "data": $.umap.array2json(resp.result),
                                                    "success": function(resp) {
                                                        $('#umapper-ajax-messages-top').html('<?php _e('Saved..', 'umapper');?>');
                                                        $('#umapper-status-message').html('<?php echo Umapper_Messages::getInstance()->infoMessage('API_KEY_VALID');?>');
                                                        $('#umapper-ajax-messages-top').hide('slow');
                                                    },
                                                    "processData": false,
                                                    "contentType": "application/json"
                                                });
                                            }
                                        });
                                    },
                                    "processData": false,
                                    "contentType": "application/json"
                                });
                            }
                        });
                    });
                } else { // error occured
                    $('#umapper-status-message').html('<?php echo Umapper_Messages::getInstance()->infoMessage('API_KEY_INVALID');?>');
                }
            });
        });

        $("#umapper-dialog").dialog({
            autoOpen: false,
            closeOnEscape: true,
            bgiframe: true,
            resizable: false,
            //height:140,
            modal: true,
            //show: 'highlight',
            hide : 'slow',
            buttons: {
                '<?php _e('Ok', 'umapper');?>': function() {
                    $(this).dialog('close');
                }
            }
        });

    });
    //]]>
</script>

<div class="umapper">
    <div id="umapper-ajax-messages-top" class="updated" style="top:75px;z-index:2;">&nbsp;</div>

    <div id="umapper-dialog" title="<?php _e('API-key validation required!', 'umapper');?>">
        <p>
            <span class="ui-icon ui-icon-circle-check" style="float:left; margin:0 7px 50px 0;"></span>
            <?php _e('You must validate API key before saving!', 'umapper');?>
        </p>
    </div>

    <?php if ( !empty($_POST ) ) : ?>
    <div id="message" class="updated fade"><p><strong><?php _e('Options saved.', 'umapper') ?></strong></p></div>
    <?php endif; ?>
    <div class="wrap">
        <div id="icon-options-general" class="icon32"><br></div>
        <h2><?php _e('UMapper Configuration', 'umapper'); ?></h2>

        <div id="umapper-config-widgets" class="metabox-holder">
            <div class="postbox-container" style="width:69%">
                <div class="meta-box-sortabless umapper_padded">
                    <!--content-->
                    <?php echo $this->getBoxHeader('umapper_conf_main',__('API Key Configuraion:','umapper')); ?>
                    <form action="" method="post" id="umapper-conf" style="margin: auto;">
                        <p><?php printf(__('In order to get access to UMapper API you need to <a href="%1$s" target="blank">obtain API-key</a>. <br /> <i>This procedure is done only once.</i> (<a href="%2$s">More info</a>)', 'umapper'), 'http://www.umapper.com/account/signup/', 'http://wordpress.org/extend/plugins/umapper/faq/')?></p>
                        <h4><label for="key"><?php _e('UMapper.com API Key', 'umapper'); ?></label></h4>
                        <?php foreach ( $ms as $m ) : ?>
                        <?php echo Umapper_Messages::getInstance()->infoMessage($m)?>
                        <?php endforeach; ?>
                        <p><input id="key" name="key" type="text" size="32" maxlength="32" value="<?php echo get_option('umapper_api_key'); ?>" style="font-family: 'Courier New', Courier, mono; font-size: 1.5em;" /> (<a id="umapper-validate-key" href="#"><?php _e('Validate key', 'umapper'); ?></a>)</p>
                        <div id="umapper-status-message">
                            <p style="padding: .5em;font-weight: bold;">&nbsp;</p>
                        </div>
                        <p class="submit"><input id="umapper_save_opts" type="submit" name="submit" value="<?php _e('Save Changes', 'umapper'); ?> &raquo;" /></p>
                    </form>
                    <?php echo $this->getBoxFooter(); ?>
                    <!--content-->
                </div>
            </div>
            <div class="postbox-container" style="width:29%">
                <div class="meta-box-sortabless umapper_padded">
                    <!--content-->
                    <?php echo $this->getBoxHeader('umapper_conf_info',__('More Info:','umapper'),true); ?>
                    <?php
                    echo '<a class="umapper_btn" href="http://wordpress.org/extend/plugins/umapper/">' . __('Plugin Homepage','umapper'). '</a>';
                    echo '<a class="umapper_btn" href="http://wordpress.org/extend/plugins/umapper/faq/">' . __('UMapper FAQ','umapper'). '</a>';
                    echo '<a class="umapper_btn" href="http://groups.google.com/group/umapper?hl=en">' . __('UMapper Google Group','umapper'). '</a>';
                    ?>
                    <?php echo $this->getBoxFooter(true); ?>

                    <?php echo $this->getBoxHeader('umapper_conf_info',__('i18n Contributors:','umapper'),true); ?>
                    <?php
                    echo '<div style="padding:4px;">' . __('Italian', 'umapper') . ' <b><i>it_IT</i></b> - <a style="text-decoration:none;" href="http://gidibao.net/">Gianni Diurno</a>  </div>';
                    echo '<div style="padding:4px;">' . __('Russian', 'umapper') . ' <b><i>ru_RU</i></b> - <a style="text-decoration:none;" href="http://www.phpmag.ru">Victor Farazdagi</a>  </div>';
                    echo '<div style="padding:4px;">' . __('Finnish', 'umapper') . ' <b><i>fi_FI</i></b> - <a style="text-decoration:none;" href="http://kaljukopla.net/">Jaakko Kangosjärvi</a> </div>';
                    echo '<div style="padding:4px;">' . __('Czech', 'umapper') . ' <b><i>cs_CZ</i></b> - <a style="text-decoration:none;" href="http://svetkolecek.cz/trasy">Lukáš Daněk</a> </div>';
                    echo '<div style="padding:4px;">' . __('Chinese', 'umapper') . ' <b><i>zh_CN</i></b> - <a style="text-decoration:none;" href="http://www.geoinformatics.cn/">Bo Zhao</a> </div>';
                    echo '<div style="padding:4px;">' . __('Belorussian', 'umapper') . ' <b><i>by_BY</i></b> - <a style="text-decoration:none;" href="http://www.fatcow.com/">Fat Cower</a> </div>';
                    ?>
                    <?php echo $this->getBoxFooter(true); ?>

                    <!--content-->
                </div>
            </div>
        </div>
    </div>
</div>
