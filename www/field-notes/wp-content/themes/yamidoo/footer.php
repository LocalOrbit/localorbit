		<div class="clear"></div>
		</div> <!-- /#content-wrap -->

	<div class="clear"></div>
	</div> <!-- /#main-wrap -->

	<div id="footer">

		<div class="widget-area">
		
			<div class="column">
				<?php if (function_exists('dynamic_sidebar')) { dynamic_sidebar('Footer (column 1)'); } ?>
			</div><!-- / .column -->
			
			<div class="column">
				<?php if (function_exists('dynamic_sidebar')) { dynamic_sidebar('Footer (column 2)'); } ?>
			</div><!-- / .column -->
			
			<div class="column last">
				<?php if (function_exists('dynamic_sidebar')) { dynamic_sidebar('Footer (column 3)'); } ?>
			</div><!-- / .column -->
 
			<div class="clear"></div>
		</div><!-- /.widget-area-->		
		<div class="clear"></div>


		<div id="footer_right">
			<?php wp_nav_menu( array( 'container' => '', 'container_class' => '', 'menu_class' => '', 'sort_column' => 'menu_order', 'theme_location' => 'tertiary', 'depth' => '1' ) ); ?>
			
			<span><?php _e('Designed by', 'wpzoom');?> <a href="http://www.wpzoom.com" target="_blank" title="WPZOOM WordPress Themes">WPZOOM</a></span>

			<?php _e('Copyright', 'wpzoom');?> &copy; <?php echo date("Y"); ?> &mdash; <a href="<?php echo home_url(); ?>/" class="on"><?php bloginfo('name'); ?></a>. <?php _e('All Rights Reserved.', 'wpzoom');?>
		</div>

	</div> <!-- /#footer -->

	<div class="clear"></div>

</div> <!-- /#page-wrap -->

<?php 
if ( is_home() && $paged < 2 && option::get('featured_enable') == 'on' ) { 
	ui::js("slider");
	?>
	<script type="text/javascript">
	jQuery(document).ready(function() {
		jQuery("#navi ul").tabs("#panes > div", {
			effect: 'fade',
			rotate: true
		}).slideshow({
			clickable: false,
			autoplay: <?php echo option::get('featured_rotate') == 'on' ? "true" : "false"; ?>,
			interval: <?php echo option::get('featured_interval'); ?>
		});
	});
	</script>
	<?php 
}

wp_reset_query();
if ( is_single() ) { ?><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><?php } // Google Plus button

wp_footer();
?>
</body>
</html>