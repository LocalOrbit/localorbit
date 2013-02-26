function wpz_js_querystring(ji) {

    hu = window.location.search.substring(1);
    gy = hu.split( "&" );
    for (i=0;i<gy.length;i++) {
    
        ft = gy[i].split( "=" );
        if (ft[0] == ji) {
        
            return ft[1];
        
        } // End IF Statement
        
    } // End FOR Loop
    
} // End wpz_js_querystring()
    
(
    
    function(){
    
        // Get the URL to this script file (as JavaScript is loaded in order)
        // (http://stackoverflow.com/questions/2255689/how-to-get-the-file-path-of-the-currenctly-executing-javascript-code)
        
        var scripts = document.getElementsByTagName( "script"),
        src = scripts[scripts.length-1].src;
        
        if ( scripts.length ) {
        
            for ( i in scripts ) {

                var scriptSrc = '';
                
                if ( typeof scripts[i].src != 'undefined' ) { scriptSrc = scripts[i].src; } // End IF Statement
    
                var txt = scriptSrc.search( 'shortcode-generator' );
                
                if ( txt != -1 ) {
                
                    src = scripts[i].src;
                
                } // End IF Statement
            
            } // End FOR Loop
        
        } // End IF Statement

        var framework_url = src.split( '/js/' );
        
        var icon_url = framework_url[0] + '/images/shortcode-icon.png';
    
        tinymce.create(
            "tinymce.plugins.wpzoomShortcodes",
            {
                init: function(d,e) {
                        d.addCommand( "wpzVisitwpzoom", function(){ window.open( "http://wpzoom.com/" ) } );
                        
                        d.addCommand( "wpzOpenDialog",function(a,c){
                            
                            // Grab the selected text from the content editor.
                            selectedText = '';
                        
                            if ( d.selection.getContent().length > 0 ) {
                        
                                selectedText = d.selection.getContent();
                                
                            } // End IF Statement
                            
                            wpzSelectedShortcodeType = c.identifier;
                            wpzSelectedShortcodeTitle = c.title;
                            
                            
                            jQuery.get(e+"/dialog.php",function(b){
                                
                                jQuery( '#wpz-options').addClass( 'shortcode-' + wpzSelectedShortcodeType );
                                jQuery( '#wpz-preview').addClass( 'shortcode-' + wpzSelectedShortcodeType );
                                
                                // Skip the popup on certain shortcodes.
                                
                                switch ( wpzSelectedShortcodeType ) {
                            
                                    // Highlight
                                    
                                    case 'highlight':
                                
                                    var a = '[highlight]'+selectedText+'[/highlight]';
                                    
                                    tinyMCE.activeEditor.execCommand( "mceInsertContent", false, a);
                                
                                    break;
                                    
                                    // Dropcap
                                    
                                    case 'dropcap':
                                
                                    var a = '[dropcap]'+selectedText+'[/dropcap]';
                                    
                                    tinyMCE.activeEditor.execCommand( "mceInsertContent", false, a);
                                
                                    break;
                            
                                    default:
                                    
                                    jQuery( "#wpz-dialog").remove();
                                    jQuery( "body").append(b);
                                    jQuery( "#wpz-dialog").hide();
                                    var f=jQuery(window).width();
                                    b=jQuery(window).height();
                                    f=720<f?720:f;
                                    f-=80;
                                    b-=84;
                                
                                tb_show( "Insert "+ wpzSelectedShortcodeTitle +" Shortcode", "#TB_inline?width="+f+"&height="+b+"&inlineId=wpz-dialog" );jQuery( "#wpz-options h3:first").text( "Customize the "+c.title+" Shortcode" );
                                
                                    break;
                                
                                } // End SWITCH Statement
                            
                            }
                                                     
                        )
                         
                        } 
                    );
                        
                        // d.onNodeChange.add(function(a,c){ c.setDisabled( "wpzoom_shortcodes_button",a.selection.getContent().length>0 ) } ) // Disables the button if text is highlighted in the editor.
                    },
                    
                createControl:function(d,e){
                
                        if(d=="wpzoom_shortcodes_button"){
                        
                            d=e.createMenuButton( "wpzoom_shortcodes_button",{
                                title:"Insert Shortcode",
                                image:icon_url,
                                icons:false
                                });
                                
                                var a=this;d.onRenderMenu.add(function(c,b){
                                
                                    a.addWithDialog(b,"Button","button" );
                                    a.addWithDialog(b,"Icon Link","ilink" );b.addSeparator();
                                    a.addWithDialog(b,"Info Box","box" );
                                     b.addSeparator();
                                    a.addWithDialog(b,"Column Layout","column" );
                                     b.addSeparator();
                                        c=b.addMenu({title:"List Generator"});
                                            a.addWithDialog(c,"Unordered List","unordered_list" );
                                            a.addWithDialog(c,"Ordered List","ordered_list" );
                                         c=b.addMenu({title:"Social Buttons"});
                                            a.addWithDialog(c,"Social Profile Icon","social_icon" );
                                            c.addSeparator();
                                            a.addWithDialog(c,"Twitter","twitter" );
                                             a.addWithDialog(c,"Digg","digg" );
                                            a.addWithDialog(c,"Like on Facebook","fblike" );
        /*b.add({title:"Visit wpzoom.com","class":"wpz-wpzlink",onclick:function(){tinyMCE.activeEditor.execCommand( "wpzVisitwpzoom",false,"")}})*/ });
                            return d
                        
                        } // End IF Statement
                        
                        return null
                    },
        
                addImmediate:function(d,e,a){d.add({title:e,onclick:function(){tinyMCE.activeEditor.execCommand( "mceInsertContent",false,a)}})},
                
                addWithDialog:function(d,e,a){d.add({title:e,onclick:function(){tinyMCE.activeEditor.execCommand( "wpzOpenDialog",false,{title:e,identifier:a})}})},
        
                getInfo:function(){ return{longname:"wpzoom Shortcode Generator",author:"VisualShortcodes.com",authorurl:"http://visualshortcodes.com",infourl:"http://visualshortcodes.com/shortcode-ninja",version:"1.0"} }
            }
        );
        
        tinymce.PluginManager.add( "wpzoomShortcodes",tinymce.plugins.wpzoomShortcodes)
    }
)();
