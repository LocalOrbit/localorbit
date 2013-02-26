<?php get_header(); ?>

		<div id="topbanner" class="column span-14">   <!-- start top banner -->
            <div class="pagetitle">
                // home
            </div>
        </div>   <!-- end top banner --> 
        
        <div id="home_content" class="column span-14">   <!-- start home_content -->
        
            <div id="home_left" class="column span-7 first">   <!-- start home_left -->
            
            	<?php $catid = $wpdb->get_var("SELECT term_ID FROM $wpdb->terms WHERE name='Asides'"); ?>

				<?php $catid2 = $wpdb->get_var("SELECT term_ID FROM $wpdb->terms WHERE name='Featured'"); ?>
            
				<?php $the_query = new WP_Query('cat=-' .$catid. '&showposts=1&orderby=post_date&order=desc');
			
				while ($the_query->have_posts()) : $the_query->the_post();

				$do_not_duplicate = $post->ID; ?>
        
				<div id="latest_post">   <!-- start latest_post -->
					<h3 class="mast">Latest Post</h3>
					
					<?php if ( get_post_meta($post->ID, 'latest_home_img', true) ) { ?>
					
					<div id="latest_post_image">
					<a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><img src="<?php bloginfo('stylesheet_directory'); ?>/images/latest/<?php echo get_post_meta($post->ID, "latest_home_img", $single = true); ?>" alt="<?php bloginfo('name'); ?>: Latest post" width="470" height="175" /></a>
					</div>
					
					<?php } ?>
					
					<h3 class="latest_post_title" id="post-<?php the_ID(); ?>"><a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a></h3>
					
					<p><?php echo strip_tags(get_the_excerpt(), '<a><strong>'); ?></p>
					
					<div class="latest_post_meta">
						<span class="latest_read_on"><a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>">Continue Reading</a></span>
						<span class="latest_comments"><?php comments_popup_link('Post a comment', 'One comment', '% comments', '', 'Comments off'); ?></span>						
						<?php $cat = get_the_category(); $cat = $cat[0]; ?>
						<span class="latest_category"><a href="<?php echo get_category_link($cat->cat_ID);?>"><?php echo $cat->cat_name; ?></a></span>
					</div>
				</div>   <!-- end latest_post -->
				
				<?php endwhile; ?>
				
				
				<div id="home_featured">   <!-- start home_featured -->
					<h3 class="home_featured">Featured Post</h3>
					
					<?php $the_query = new WP_Query('category_name=featured&showposts=1');
			
					while ($the_query->have_posts()) : $the_query->the_post();

					$do_not_duplicate = $post->ID; ?>
					
					<div class="feat_content">
					
						<?php if ( get_post_meta($post->ID, 'featured_home_img', true) ) { ?>
					
						<div class="feat_thumb"><a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><img src="<?php bloginfo('stylesheet_directory'); ?>/images/featured/<?php echo get_post_meta($post->ID, "featured_home_img", $single = true); ?>" alt="<?php the_title(); ?>" /></a></div>
						
						<?php } else { ?>

						<div class="feat_thumb">
							<a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php
							the_title(); ?>"><?php if (function_exists('the_thumb')) { the_thumb('altappend=recent_&subfolder=recent&width=64&height=64&keepratio=0'); } ?></a>
						</div>

						<?php } ?>
						
						<div class="feat_title"><a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a></div>
						
						<div class="feat_exc">						
							<p><?php echo strip_tags(get_the_excerpt(), '<a><strong>'); ?></p>
						</div>
											
					</div>
					
					<?php endwhile; ?>
						
				</div>   <!-- end home_featured -->
				
				
				<div id="home_asides">   <!-- start asides -->
				
					<h3 class="mast">Asides</h3>
					
					<ul class="arrow">
						<?php $the_query = new WP_Query('category_name=asides&showposts=5&orderby=post_date&order=desc');
			
						while ($the_query->have_posts()) : $the_query->the_post();

						$do_not_duplicate = $post->ID; ?>
						
						<li><?php echo strip_tags(get_the_content(), '<a>'); ?> <a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>">#</a></li>
						
						<?php endwhile; ?>
					</ul>
				</div>   <!-- end asides -->
            
            </div>   <!-- end home_left -->
            
            
            <div id="home_right" class="column span-7 last">
            
            	<div id="home_about">
					
					<h3 class="mast3">Welcome to <?php bloginfo('name'); ?></h3>
					
					<?php $the_query = new WP_Query('pagename=description');
			
					while ($the_query->have_posts()) : $the_query->the_post();

					$do_not_duplicate = $post->ID; ?>
					
					<?php the_content(); ?>
					
					<?php endwhile; ?>				
				
				</div>
					
				<div class="column span-4 first">
            
					<h3 class="mast">Recent Posts</h3>
					
					<?php $the_query = new WP_Query('cat=-' .$catid. '&showposts=5&offset=1&orderby=post_date&order=desc');
			
					while ($the_query->have_posts()) : $the_query->the_post();

					$do_not_duplicate = $post->ID; ?>
					
					<div class="home_recent_post">
					
						<?php if ( get_post_meta($post->ID, 'thumb_home_img', true) ) { ?>
						<div class="home_recent_thumb">
							<a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><img src="<?php bloginfo('stylesheet_directory'); ?>/images/thumbs/<?php echo get_post_meta($post->ID, "thumb_home_img", $single = true); ?>" alt="<?php the_title(); ?>" /></a>
						</div>
						<?php } else { ?>
						<div class="home_recent_thumb">
							<a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php
							the_title(); ?>"><?php if (function_exists('the_thumb')) { the_thumb('altappend=recent_&subfolder=recent&width=48&height=48&keepratio=0'); } ?></a>
						</div>
						<?php } ?>
	
						
						<div class="home_recent_title" id="post-<?php the_ID(); ?>">
							<a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a>
						</div>
						
						<div class="home_recent_date">
							<?php the_time('F j, Y'); ?>
						</div>
						
						<div class="home_recent_auth">
							By <?php the_author(); ?>
						</div>
						
					</div>
					
					<?php endwhile; ?>
					
					
					<?php include('ad_home.php'); ?>
					
					<?php if ( !function_exists('dynamic_sidebar')
					        || !dynamic_sidebar('MiddleColumn') ) : ?>
					
					<div id="side_tag_cloud">
            
						<h3 class="mast">Browse</h3>
						
						<?php wp_tag_cloud(''); ?>
            		
            		</div>					
					
					<?php endif; ?>
            	
            	</div>
            
                <?php get_sidebar(); ?>         
            	
            
            </div>
        
        </div>   <!-- end home_content -->        
        
<?php get_footer(); ?>     
