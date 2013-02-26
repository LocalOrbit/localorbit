=== Smart Slug ===
Contributors: wet
Tags: admin, slug, plugin, Post, posts, administration, seo, permalink, url, hindi
Requires at least: 3.3
Tested up to: 3.6-alpha
Stable tag: trunk

Smartify your post and page slugs by removing too short or insignificant stopwords automatically.

== Description ==

Smartify your post and page slugs and let them convey the very essence of your content's titles by removing too short or insignificant stopwords - automatically, that is. **Smart Slug** comes preloaded with an easily expandable and configurable set of German, Dutch, Russian, Portuguese and English stopwords.

Please visit my [Smart WordPress Slug Plugin](http://talkpress.de/blip/wet-smartslug-wordpress-plugin) article to review additional screenshots, grasp implementation details and contribute to a related discussion on how search engines evaluate words in URL fragments.

= Credits =

- Russian translation by [Natalya Pastukhova](http://www.luxpar.de/)
- Ukrainian translation by [Natalya Pastukhova](http://www.pastukhova-floeder.de/)
- Dutch translation by [Patricia Ritsema van Eck](http://www.patriciaritsemavaneck.name/)
- Portuguese translation by [Raoni Del Pérsio](http://www.centralwordpress.com.br/)
- Hindi translation by [Outshine Solutions](http://outshinesolutions.com/)
- Indonesian translation by [Syamsul Alam](http://www.syamsulalam.net/)

= Limitations =

- Smart Slug overrides all manual slug modifications which would violate its rule set, even if you are making them deliberately.
- WordPress appends a unique number to ambigous slugs (e.g. hello-word, hello-world-2 et cetera). Smart Slug may not notice this behaviour when an article is saved for the first time. If this happens you may simply re-save the post to attach a smart slug.

== Installation ==

1. Unzip the downloaded plugin file and upload the contained files to the `/wp-content/plugins/smart-slug/` directory.
1. Activate the plugin through the 'Plugins' menu in WordPress.

== Changelog ==

= 1.7 =

1. Added Indonesian translation
1. Compatibility check with WordPress 3.6-alpha.

= 1.6 =

1. Use `wp_unique_post_slug` filter instead of `editable_slug`. Requires WP 3.3.
1. Keep numerical slug parts unaltered.

= 1.5 =

1. Fix for multi-byte characters in titles

= 1.4.2 =

1. Added Hindi translation

= 1.4.0 =

1. Fixed default english stopwords set.
2. Compatibility check with WordPress 3.4.

= 1.3.0 =

1. Added Portuguese translation by Raoni Del Pérsio.
2. Compatibility check with WordPress 3.1.

= 1.2.0 =

1. Realignment with market feedback and customer expectations.

= 0.2.1 =

1. Added Dutch translation.
1. Added Russian translation.
1. Compatibility check with WordPress 2.9-rare.