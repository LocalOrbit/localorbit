<?php
/**
 * Displays media page
 * 
 * TODO Once wp/wp-admin/includes/media.php page is fixed to accept object instead of plain funciton, upgrade to Class
 *
 * @return void
 */
function umapperMediaMapEditor() 
{
    Umapper_Shortcode::getInstance()->mediaFramePageMapEditor();
}