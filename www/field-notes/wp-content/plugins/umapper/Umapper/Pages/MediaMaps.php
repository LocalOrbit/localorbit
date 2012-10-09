<?php
/**
 * Displays media page
 * 
 * TODO Once wp/wp-admin/includes/media.php page is fixed to accept object instead of plain funciton, upgrade to Class
 *
 * @return void
 */
function umapperMediaMaps() 
{
    Umapper_Shortcode::getInstance()->mediaFramePageMaps();
}