jQuery(function($) {
    
/*-----------------------------------------------------------------------------------
  Tabs shortcode
-----------------------------------------------------------------------------------*/
    
    if ( jQuery( '.shortcode-tabs').length ) {    
        
        jQuery( '.shortcode-tabs').each( function () {
        
            var tabCount = 1;
        
            jQuery(this).children( '.tab').each( function ( index, element ) {
            
                var idValue = jQuery(this).parents( '.shortcode-tabs').attr( 'id' );
            
                var newId = idValue + '-tab-' + tabCount;
            
                jQuery(this).attr( 'id', newId );
                
                jQuery(this).parents( '.shortcode-tabs').find( 'ul.tab_titles').children( 'li').eq(index).find( 'a').attr( 'href', '#' + newId );
                
                tabCount++;
            
            });
        
            var thisID = jQuery(this).attr( 'id' );
        
            jQuery(this).tabs( { fx: { opacity: 'toggle', duration: 200 } } );
        
        });


    } // End IF Statement
    
/*-----------------------------------------------------------------------------------
  Toggle shortcode
-----------------------------------------------------------------------------------*/
    
    if ( jQuery( '.shortcode-toggle').length ) {    
        
        jQuery( '.shortcode-toggle').each( function () {
            
            var toggleObj = jQuery(this);
            
            toggleObj.closedText = toggleObj.find( 'input[name="title_closed"]').attr( 'value' );
            toggleObj.openText = toggleObj.find( 'input[name="title_open"]').attr( 'value' );
            
            toggleObj.find( 'input[name="title_closed"]').remove();
            toggleObj.find( 'input[name="title_open"]').remove();
            
            toggleObj.find( 'h4.toggle-trigger a').click( function () {
            
                toggleObj.find( '.toggle-content').animate({ opacity: 'toggle', height: 'toggle' }, 300);
                toggleObj.toggleClass( 'open' ).toggleClass( 'closed' );
                
                if ( toggleObj.hasClass( 'open') ) {
                
                    jQuery(this).text(toggleObj.openText);
                
                } // End IF Statement
                
                if ( toggleObj.hasClass( 'closed') ) {
                
                    jQuery(this).text(toggleObj.closedText);
                
                } // End IF Statement
                
                return false;
            
            });
                    
        });


    } // End IF Statement
    
}); // jQuery()
