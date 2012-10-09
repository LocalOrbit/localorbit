<?php get_header(); ?>
        
        
        <div id="topbanner_single" class="column span-14">   <!-- start top banner -->
            <div class="pagetitle">
                // you&#8217;re reading...
            </div>
        </div>   <!-- end top banner -->
        
        <div id="post_content" class="column span-14">   <!-- start home_content -->
        
        <?php if (have_posts()) : ?>
			
        <?php while (have_posts()) : the_post(); ?>
        
        	<div class="column span-11 first">
        		<h2 class="post_cat"><?php $cat = get_the_category(); $cat = $cat[0]; echo $cat->cat_name; ?></h2>
        		
            	<h2 class="post_name" id="post-<?php the_ID(); ?>"><?php the_title(); ?></h2>
            	
            	<div class="post_meta">
            		By <?php the_author_posts_link(); ?> <span class="dot">&sdot;</span> <?php the_time('F j, Y'); ?> <span class="dot">&sdot;</span> <?php if(function_exists('wp_email')) { ?> <?php email_link(); ?> <span class="dot">&sdot;</span> <?php } ?> <?php if(function_exists('wp_print')) { ?> <?php print_link(); ?> <span class="dot">&sdot;</span> <?php } ?> <a href="#comments">Post a comment</a>
            	</div>

				<div class="post_meta">
            		<?php the_tags('<span class="filedunder"><strong>Filed Under</strong></span> &nbsp;', ', ', ''); ?>
            	</div>
            	
				<div class="post_text">

            		<?php the_content('<p>Continue reading this post</p>'); ?>

					<?php wp_link_pages(array('before' => '<p><strong>Pages:</strong> ', 'after' => '</p>', 'next_or_number' => 'number')); ?>
				
					<?php edit_post_link('Edit this entry.','<p>','</p>'); ?>

				</div>
				
				
				<div id="comments">   <!-- start comments -->
				
					<div id="commenthead">
					
						<h2 class="post_comm">Discussion</h2>
	    
						<?php if ('open' == $post-> comment_status) {
							// Both Comments and Pings are open ?>							
							<h3 class="mast5"><?php comments_number('No comments', 'One comment', '% comments'); ?> for &#8220;<?php the_title(); ?>&#8221;</h3>	

						<?php } else {
							// Neither Comments, nor Pings are open ?>
							<h3 class="mast5">Comments are disallowed for this post.</h3>

						<?php } ?>
						
					</div>
							
							
					<?php comments_template(); ?>
					
				</div>   <!-- end comments -->
            	
            </div>
            
        <?php endwhile; else: ?>

		<p>Lost? Go back to the <a href="<?php echo get_option('home'); ?>/">home page</a>.</p>

		<?php endif; ?>    
            
            <?php get_sidebar(); ?>     
            
        
        </div>   <!-- start home_content -->
        
        
<?php get_footer(); ?>
