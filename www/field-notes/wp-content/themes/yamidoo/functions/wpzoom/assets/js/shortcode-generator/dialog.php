<?php 
// Get the path to the root.
$full_path = __FILE__;

$path_bits = explode( 'wp-content', $full_path );

$url = $path_bits[0];

// Require WordPress bootstrap.
require_once( $url . '/wp-load.php' );

$wpz_framework_path = dirname(__FILE__) .  '/../../../';

$wpz_framework_url = get_template_directory_uri() . '/functions/wpzoom/';

$wpz_shortcode_css = $wpz_framework_path . 'assets/css/shortcodes.css';
                                  
$iswpzTheme = file_exists($wpz_shortcode_css);

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
</head>
<body>
<div id="wpz-dialog">

<?php if (  $iswpzTheme ) { ?>

<div id="wpz-options-buttons" class="clear">
    <div class="alignleft">
    
        <input type="button" id="wpz-btn-cancel" class="button" name="cancel" value="Cancel" accesskey="C" />
        
    </div>
    <div class="alignright">
    
        <input type="button" id="wpz-btn-preview" class="button" name="preview" value="Preview" accesskey="P" />
        <input type="button" id="wpz-btn-insert" class="button-primary" name="insert" value="Insert" accesskey="I" />
        
    </div>
    <div class="clear"></div><!--/.clear-->
</div><!--/#wpz-options-buttons .clear-->

<div id="wpz-options" class="alignleft">
    <h3><?php echo __( 'Customize the Shortcode', 'wpzoom' ); ?></h3>
    
    <table id="wpz-options-table">
    </table>

</div>

<div id="wpz-preview" class="alignleft">

    <h3><?php echo __( 'Preview', 'wpzoom' ); ?></h3>

    <iframe id="wpz-preview-iframe" frameborder="0" style="width:100%;height:250px" scrolling="no"></iframe>   
    
</div>
<div class="clear"></div>


<script type="text/javascript" src="<?php echo $wpz_framework_url; ?>assets/js/shortcode-generator/js/column-control.js"></script>
<script type="text/javascript" src="<?php echo $wpz_framework_url; ?>assets/js/shortcode-generator/js/tab-control.js"></script>
<?php  }  else { ?>

<div id="wpz-options-error">

    <h3><?php echo __( 'Error', 'wpzoom' ); ?></h3>
    
    <?php if ( $iswpzTheme  ) { ?>
    <p><?php echo sprinf ( __( 'Your version of theme does not yet support shortcodes.', 'wpzoom' ), $wpzoom_framework_version, $MIN_VERSION ); ?></p>
    

<?php } else { ?>

    <p><?php echo __( 'Looks like your active theme is not from WPZOOM. The shortcode generator only works with themes from WPZOOM.', 'wpzoom' ); ?></p>

<?php } ?>

<div style="float: right"><input type="button" id="wpz-btn-cancel"
    class="button" name="cancel" value="Cancel" accesskey="C" /></div>
</div>

<?php  } ?>

<script type="text/javascript" src="<?php echo $wpz_framework_url; ?>assets/js/shortcode-generator/js/dialog-js.php"></script>

</div>

</body>
</html>
