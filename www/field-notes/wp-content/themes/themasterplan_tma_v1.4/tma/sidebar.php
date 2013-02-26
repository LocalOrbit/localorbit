                <div class="column span-3 last">
										              
                	<div id="side_categories">
            
						<h3 class="mast">Categories</h3>

						<?php $catid = $wpdb->get_var("SELECT term_ID FROM $wpdb->terms WHERE name='Asides'"); ?>

						<?php $catid2 = $wpdb->get_var("SELECT term_ID FROM $wpdb->terms WHERE name='Featured'"); ?>
						
						<ul class="cat">
							<?php wp_list_categories('title_li=&sort_column=name&show_count=0&show_last_updated=1&use_desc_for_title=1&exclude=' .$catid. ',' .$catid2. '') ?>
						</ul>
            		
            		</div>

					<?php if ( !function_exists('dynamic_sidebar')
					        || !dynamic_sidebar('RightColumn') ) : ?>
            		
            		<?php if (!( is_home() )) { ?>
            		
            		<?php include('ad_side.php'); ?>
            		
            		<?php } ?>					
            		
            		<?php if (function_exists('c2c_get_recent_comments')) { ?>
            		
            		<div id="side_recent_comments">
            
						<h3 class="mast">Recent Comments</h3>
						
						<ul class="reccom">							
							<?php c2c_get_recent_comments(5, "<li>%comment_author% on %comments_URL%</li>"); ?>
						</ul>
            		
            		</div>
            		
            		<?php } ?>

					<?php if (function_exists('get_mostemailed')): ?>
            		
            		<div id="side_most_emailed">
            
						<h3 class="mast">Most Emailed</h3>
						
						<ul class="email">
							<?php get_mostemailed('post', 5); ?>									
						</ul>
            		
            		</div>

					<?php endif; ?>
					
					<?php endif; ?>
					
            	</div>
