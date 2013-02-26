<?php
/**
 *	@package WordPress
 *	@subpackage Grid_Focus
 */
?>
<div class="secondaryColumn">
	<?php if ( function_exists('dynamic_sidebar') && dynamic_sidebar('Primary - Index') ) : else : ?>
	<?php endif; ?>
</div>