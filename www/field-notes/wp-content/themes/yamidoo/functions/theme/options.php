<?php return array(

/* Theme Admin Menu */
"menu" => array(
	array("id"   => "1",
		"name" => "General"),

	array("id"   => "2",
		"name" => "Homepage"),

	array("id"    => "5",
				"name"  => "Styling"),

	array("id"   => "7",
		"name" => "Banners")
),

/* Theme Admin Options */
"id1" => array(
	array("type" => "preheader",
		"name" => "Theme Settings"),

	array("name" => "Logo Image",
			"desc" => "Upload a custom logo image for your site, or you can specify an image URL directly.",
			"id"   => "misc_logo_path",
			"std"  => "",
			"type" => "upload"),
 
    array("name"  => "Display Site Tagline under Logo?",
			"desc"  => "Tagline can be changed in <a href='options-general.php' target='_blank'>General Settings</a>",
			"id"    => "logo_desc",
			"std"   => "on",
			"type"  => "checkbox"),
 
	array("name" => "Favicon URL",
			"desc" => "Upload a favicon image (16&times;16px).",
			"id"   => "misc_favicon",
			"std"  => "",
			"type" => "upload"),

	array("name" => "Custom Feed URL",
			"desc" => "Example: <strong>http://feeds.feedburner.com/wpzoom</strong>",
			"id"   => "misc_feedburner",
			"std"  => "",
			"type" => "text"),

 	array("name"  => "Enable comments on static pages",
			"id"  => "comments_page",
			"std" => "off",
			"type" => "checkbox"),

	array("name" => "Sidebar Position",
			"id" => "sidebar_pos",
			"options" => array('Right', 'Left'),
			"std" => "Right",
			"type" => "select"),	


	array("type" => "preheader",
			"name" => "Header Icons"),

	array("type"  => "startsub",
          "name"  => "RSS Icon"),

		array("name" => "Display RSS Icon",
				"desc" => "Display RSS icon in the header",
				"id"   => "head_rss_show",
				"std"  => "on",
				"type" => "checkbox"),
				
	array("type"  => "endsub"),
	

	array("type"  => "startsub",
          "name"  => "Twitter Icon"),

		array("name" => "Display Twitter Icon",
				"desc" => "Display Twitter Icon in the header",
				"id"   => "head_twitter_show",
				"std"  => "on",
				"type" => "checkbox"),

		array("name" => "Twitter Username",
				"desc" => "Your Twitter username<br /> Example:<strong> wpzoom</strong>",
				"id"   => "head_twitter_user",
				"std"  => "",
				"type" => "text"),

	array("type"  => "endsub"),

	
	array("type"  => "startsub",
          "name"  => "Facebook Icon"),

		array("name" => "Display Facebook Icon",
				"desc" => "Display Facebook Icon in the header",
				"id"   => "head_facebook_show",
				"std"  => "on",
				"type" => "checkbox"),

		array("name" => "Facebook URL",
				"desc" => "Your Facebook URL<br /> Example:<strong> http://facebook.com/wpzoom</strong>",
				"id"   => "head_facebook_url",
				"std"  => "",
				"type" => "text"),
				
 	array("type"  => "endsub"),

  
	array("type" => "preheader",
			"name" => "Global Posts Options"),

	array("name"    => "Posts Display Type",
			"desc"    => "The number of articles displayed on homepage can be changed <a href='options-reading.php' target='_blank'>here</a>.",
			"id"      => "display_type",
			"options" => array('Post Excerpts', 'Full Content'),
			"std"     => "Post Excerpts",
			"type"    => "select"),

    array("name"  => "Excerpt length",
			"desc"  => "Default: <strong>50</strong> (words)",
			"id"    => "excerpt_length",
			"std"   => "50",
			"type"  => "text"),
		
					
	array("type"  => "startsub",
          "name"  => "Thumbnail"),
          
		array("name"  => "Display Thumbnail",
			  "id"    => "display_thumb",
			  "std"   => "on",
			  "type"  => "checkbox"),
				  
		array("name"  => "Thumbnail Width (in pixels)",
			  "desc"  => "Default: <strong>260</strong> (pixels)",
			  "id"    => "thumb_width",
			  "std"   => "260",
			  "type"  => "text"),
			  
		array("name"  => "Thumbnail Height (in pixels)",
			  "desc"  => "Default: <strong>260</strong> (pixels)",
			  "id"    => "thumb_height",
			  "std"   => "260",
			  "type"  => "text"),
			  
 	array("type"  => "endsub"),
 	

	array("name" => "Display Date/Time",
			"desc" => "<strong>Date/Time format</strong> can be changed <a href='options-general.php' target='_blank'>here</a>.",
			"id"   => "display_date",
			"std"  => "on",
			"type" => "checkbox"),

	array("name" => "Display Category",
			"id"   => "display_category",
			"std"  => "on",
			"type" => "checkbox"),
			
	array("name" => "Display Author Name",
			"id"   => "display_author",
			"std"  => "on",
			"type" => "checkbox"),

	array("name" => "Display Comments Count",
			"id"   => "display_comm_count",
			"std"  => "on",
			"type" => "checkbox"),
 
 
	array("type" => "preheader",
			"name" => "Single Post Options"),
			
    array("name"  => "Display Category",
          "id"    => "post_category",
          "std"   => "on",
          "type"  => "checkbox"),
           
	array("name"  => "Display Date/Time",
          "desc"  => "<strong>Date/Time format</strong> can be changed <a href='options-general.php' target='_blank'>here</a>.",
          "id"    => "post_date",
          "std"   => "on",
          "type"  => "checkbox"),  
          
    array("name"  => "Display Author Name",
          "desc"  => "You can edit your profile on this <a href='profile.php' target='_blank'>page</a>.",
          "id"    => "post_author",
          "std"   => "on",
          "type"  => "checkbox"),
          
    array("name"  => "Display Tags",
          "id"    => "post_tags",
          "std"   => "on",
          "type"  => "checkbox"),
            
	array("name" => "Display Share Buttons",
			"id"   => "post_share",
			"std"  => "on",
			"type" => "checkbox"),

    array("name"  => "Display Author Bio",
          "desc"  => "Display a box with information about post author.",
          "id"    => "post_authorbio",
          "std"   => "on",
          "type"  => "checkbox"),
			
    array("name"  => "Display Comments",
          "id"    => "post_comments",
          "std"   => "on",
          "type"  => "checkbox"),

 	array("name" => "Display Post Thumbnail in Sidebar",
			"id" => "sidebar_thumb_show",
			"std" => "on",
			"type" => "checkbox"),
			
 	array("name" => "Display Related Posts in Sidebar",
			"id" => "post_related",
			"std" => "on",
			"type" => "checkbox"),
),

"id2" => array(
	array("type"  => "preheader",
          "name"  => "Recent Posts"),
          
	array("name"  => "Display Recent Posts on Homepage",
          "id"    => "recent_posts",
          "std"   => "on",
          "type"  => "checkbox"),
          
  	array("name"  => "Title for Recent Posts",
          "desc"  => "Default: <em>Recent Posts</em>",
          "id"    => "recent_title",
          "std"   => "Recent Posts",
          "type"  => "text"), 
          
	array("name"  => "Exclude categories",
          "desc"  => "Choose the categories which should be excluded from the main Loop on the homepage.<br/><em>Press CTRL or CMD key to select/deselect multiple categories </em>",
          "id"    => "recent_part_exclude",
          "std"   => "",
          "type"  => "select-category-multi"),

	array("name"  => "Hide Featured Posts in Recent Posts?",
          "desc"  => "You can use this option if you want to hide posts which are featured in the slider on front page.",
          "id"    => "hide_featured",
          "std"   => "off",
          "type"  => "checkbox"),


	array("type" => "preheader",
			"name" => "Slider Settings"),

	array("name" => "Enable the featured slider",
			"desc" => "The featured slider will display featured posts. Edit posts which you want to feature, and check the box from editing page: <strong>Feature in Homepage Slider</strong> ",
			"id"   => "featured_enable",
			"std"  => "on",
			"type" => "checkbox"),

	array("name" => "Autoplay slider",
			"desc" => "Should the slider start rotating automatically?",
			"id"   => "featured_rotate",
			"std"  => "off",
			"type" => "checkbox"),

	array("name" => "Autoplay Interval",
			"desc" => "Select the interval (in miliseconds) at which the slider should change posts (if autoplay is enabled). Default: 3000 (3 seconds).",
			"id"   => "featured_interval",
			"std"  => "3000",
			"type" => "text"),
			

	array("type" => "preheader",
			"name" => "Featured Categories Blocks"),

	array("name" => "Display featured categories on homepage",
			"desc" => "Select if you want to show the 4 featured categories blocks on the homepage.",
			"id"   => "featured_cats_show",
			"std"  => "on",
			"type" => "checkbox"),

	array("name" => "Featured Category 1",
			"desc" => "Select the category which should be featured as #1 on the homepage.",
			"id"   => "featured_category_1",
			"std"  => "",
			"type" => "select-category"),

	array("name" => "Featured Category 2",
			"desc" => "Select the category which should be featured as #2 on the homepage.",
			"id"   => "featured_category_2",
			"std"  => "",
			"type" => "select-category"),

	array("name" => "Featured Category 3",
			"desc" => "Select the category which should be featured as #3 on the homepage.",
			"id"   => "featured_category_3",
			"std"  => "",
			"type" => "select-category"),

	array("name" => "Featured Category 4",
			"desc" => "Select the category which should be featured as #4 on the homepage.",
			"id"   => "featured_category_4",
			"std"  => "",
			"type" => "select-category")
),

"id4" => array(
	array("type" => "preheader",
			"name" => "Custom Field <small style=\"font-weight:normal\">(If&nbsp;Used&nbsp;in&nbsp;a&nbsp;Previous Theme for Thumbnails)</small>"),   

	array("name" => "Previous Theme Used Custom Fields for Thumbnails",
			"desc" => "If selected then theme will use images added via custom fields for thumbnails.",
			"id"   => "cf_use",
			"std"  => "off",
			"type" => "checkbox"),

	array("name" => "Custom Field Name",
			"desc" => "<strong>Used only if you checked the option above.</strong>",
			"id"   => "cf_photo",
			"std"  => "image",
			"type" => "text")
),

"id5" => array(
    array("type"  => "preheader",
          "name"  => "Colors"),

    array("name"  => "Page Background Color",
           "id"   => "bg_color",
           "type" => "color",
           "selector" => "#main-wrap",
           "attr" => "background-color"),

    array("name"  => "Logo Color",
           "id"   => "logo_color",
           "type" => "color",
           "selector" => "#logo h1 a",
           "attr" => "color"),

    array("name"  => "Slider Background Color",
           "id"   => "slidebg_color",
           "type" => "color",
           "selector" => "#feature",
           "attr" => "background-color"),
   
    array("name"  => "Link Color",
           "id"   => "a_css_color",
           "type" => "color",
           "selector" => "a",
           "attr" => "color"),
           
    array("name"  => "Link Hover Color",
           "id"   => "ahover_css_color",
           "type" => "color",
           "selector" => "a:hover",
           "attr" => "color"),

    array("name"  => "Widget Title Color",
           "id"   => "widget_color",
           "type" => "color",
           "selector" => ".widget h3.title",
           "attr" => "color"),

    array("name"  => "Widget Title Background",
           "id"   => "widget_background",
           "type" => "color",
           "selector" => ".widget h3.title, #sidebar .tabberlive, #articles .head_title, h3.archive_title, .post_author, ul.dropdown li ul",
           "attr" => "background"),

     array("name"  => "Widget Title Top Border",
           "id"   => "widget_border",
           "type" => "color",
           "selector" => ".widget h3.title, #sidebar .tabberlive, #articles .head_title, h3.archive_title, ul.dropdown li ul",
           "attr" => "border-color"),


    array("type"  => "preheader",
          "name"  => "Fonts"),

    array("name" => "General Text Font Style", 
          "id" => "typo_body", 
          "type" => "typography", 
          "selector" => "body" ),

    array("name" => "Logo Text Style", 
          "id" => "typo_logo", 
          "type" => "typography", 
          "selector" => "#logo h1 a" ),

    array("name"  => "Post Title Style",
           "id"   => "typo_post_title",
           "type" => "typography",
           "selector" => ".article h2.title a"),

    array("name"  => "Individual Post Title Style",
           "id"   => "typo_individual_title",
           "type" => "typography",
           "selector" => ".single .post h1.title a"),
 
     array("name"  => "Widget Title Style",
           "id"   => "typo_widget",
           "type" => "typography",
           "selector" => ".widget h3.title"),

),

"id7" => array(
	array("type" => "preheader",
			"name" => "Header Ad"),

	array("name" => "Enable ad space in the header?",
			"id"   => "ad_head_select",
			"std"  => "off",
			"type" => "checkbox"),

	array("name" => "HTML Code (Adsense)",
			"desc" => "Enter complete HTML code for your banner (or Adsense code) or upload an image below.",
			"id"   => "ad_head_code",
			"std"  => "",
			"type" => "textarea"),

	array("name" => "Upload your image",
			"desc" => "Upload a banner image or enter the URL of an existing image.<br/>Recommended size: <strong>468 &times; 60px</strong>",
			"id"   => "ad_head_imgpath",
			"std"  => "",
			"type" => "upload"),

	array("name" => "Destination URL",
			"desc" => "Enter the URL where this banner ad points to.",
			"id"   => "ad_head_imgurl",
			"type" => "text"),

	array("name" => "Banner Title",
			"desc" => "Enter the title for this banner which will be used for ALT tag.",
			"id"   => "ad_head_imgalt",
			"type" => "text"),
			

	array("type" => "preheader",
			"name" => "Sidebar Ad"),

	array("name" => "Enable ad space in sidebar?",
			"id"   => "ad_side_select",
			"std"  => "off",
			"type" => "checkbox"),

	array("name"    => "Ad Position",
			"desc"    => "Do you want to place the banner before the widgets or after the widgets?",
			"id"      => "ad_side_pos",
			"options" => array('Before widgets', 'After widgets'),
			"std"     => "After widgets",
			"type"    => "select"),

	array("name" => "HTML Code (Adsense)",
			"desc" => "Enter complete HTML code for your banner (or Adsense code) or upload an image below.",
			"id"   => "ad_side_code",
			"std"  => "",
			"type" => "textarea"),

	array("name" => "Upload your image",
			"desc" => "Upload a banner image or enter the URL of an existing image.<br/>Recommended size: <strong>300 &times; 250px</strong>",
			"id"   => "ad_side_imgpath",
			"std"  => "",
			"type" => "upload"),

	array("name" => "Destination URL",
			"desc" => "Enter the URL where this banner ad points to.",
			"id"   => "ad_side_imgurl",
			"type" => "text"),

	array("name" => "Banner Title",
			"desc" => "Enter the title for this banner which will be used for ALT tag.",
			"id"   => "ad_side_imgalt",
			"type" => "text")
)

/* end return */);