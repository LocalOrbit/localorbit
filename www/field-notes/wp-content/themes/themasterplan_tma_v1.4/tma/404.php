<?php get_header(); ?>        
        
        <div id="topbanner" class="column span-14">   <!-- start top banner -->
            <div class="pagetitle">
                // uh oh!
            </div>
        </div>   <!-- end top banner -->
        
        
        <div id="arch_content" class="column span-14">   <!-- start home_content -->
        
           	<div class="column span-3 first">        
            	<h2 class="archive_name"><?php bloginfo('name'); ?></h2>        
            	
            	<div class="archive_meta">
            	
            		<div class="archive_feed">
            			<a href="<?php bloginfo('rss2_url'); ?>">RSS feed for <?php bloginfo('name'); ?></a>		
            		</div>
            	
            	</div>
            </div>
            
                        
            <div class="column span-8">
            
            	<p><strong>Oops!</strong></p>
            
            	<p>Looks like the page you're looking for has been moved or had its name changed. Or maybe it's just fate. You could use the search box in the header to search for what you're looking for, or begin again from the <a href="<?php echo get_option('home'); ?>/">home page</a>.
            	
            </div>
            
            <?php get_sidebar(); ?>
        
        </div>   <!-- start home_content -->
        
        
<?php get_footer(); ?>
