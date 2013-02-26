<div class="clear"></div>
<div id="zoomWrap">
    <div id="zoomHead">
        <script type="text/javascript">
        var wpzoom_ajax_url = '<?php echo admin_url("admin-ajax.php"); ?>';
        </script>
        <div id="zoomLoading">
            <p>Loading</p>
        </div>
        <div id="zoomSuccess">
            <p>Options successful saved</p>
        </div>
        <div id="zoomFail"> 
            <p>Can't save options. Please contact <a href="http://wpzoom.com/forum">WPZOOM support</a>.</p>
        </div>
        <div id="zoomLogo">
            <?php if (!wpzoom::$tf) : ?>
            <a href="http://wpzoom.com/" target="_blank">
            <?php endif; ?>
                <img src="<?php echo WPZOOM::$wpzoomPath; ?>/assets/images/logo.png" alt="WPZOOM" />
            <?php if (!wpzoom::$tf) : ?>
            </a>
            <?php endif; ?>
        </div>
        <div id="zoomTheme">
            <h3><?php echo WPZOOM::$themeName . ' <span>' . WPZOOM::$themeVersion; ?></span></h3>
        </div>
     </div><!-- /#zoomHead -->

     <div class="head_meta">
        <div id="zoomFramework">
            <h5>Framework version <?php echo WPZOOM::$wpzoomVersion ?></h5>
        </div>
        <div id="zoomInfo">
            <ul>
                <?php if (!wpzoom::$tf) : ?>
                <li class="documentation">
                    <a href="http://www.wpzoom.com/documentation/<?php echo str_replace('_', '-', WPZOOM::$theme_raw_name); ?>" target="_blank">Documentation</a>
                </li>
                <?php endif; ?>

                <li class="support">
                    <a href="http://www.wpzoom.com/forum" target="_blank">Support Forum</a>
                </li>
            </ul>
        </div>
    </div>

    <div class="admin_main">
        <div id="zoomNav">
            <?php WPZOOM_Admin_Settings_Page::menu(); ?>
            <div class="cleaner">&nbsp;</div>
        </div><!-- end #zooNav -->

        <div class="tab_container">
            <form id="zoomForm" method="post">
                <?php WPZOOM_Admin_Settings_Page::content(); ?>

                <input type="hidden" name="action" value="save" />
                <?php wp_nonce_field('wpzoom-ajax-save'); ?>
                <input type="hidden" id="nonce" name="_ajax_nonce" value="<?php echo wp_create_nonce('wpzoom-ajax-save'); ?>" />
            </form>
            
        </div><!-- end .tab_container -->
        <div class="clear"></div>
    </div> <!-- /.admin_main -->
    
    <div class="zoomActionButtons">
       
        <form id="zoomReset" method="post">
            <p class="submit" style="float:right;" />
                <input name="reset" class="button-secondary" type="submit" value="Reset settings" />
                <input type="hidden" name="action" value="reset" />
            </p>
        </form>

        <p class="submit">
            <input id="submitZoomForm" name="save" class="button button-primary button-large" type="submit" value="Save all changes" />
        </p>
    </div><!-- end of .zoomActionButtons -->

</div><!-- end #zoomWrap -->

<div class="clear"></div>
