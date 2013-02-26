<?php
/**
 * WPZOOM_Video_API Class
 *
 * @package WPZOOM
 * @subpackage Video_API
 */


class WPZOOM_Video_API {
	/**
	 * Fetches and returns extended video data for the embedded video (if there is one) in the current post (if within the Loop) or a specified post
	 */
	public static function fetch_extended_video_data($post = null) {
		$post = get_post($post);
		if($post === null) return false;

		$embed = trim(get_post_meta($post->ID, 'wpzoom_post_embed_code', true));
		if(empty($embed)) return false;

		$url = self::extract_url_from_embed($embed);
		if(empty($url) || filter_var($url, FILTER_VALIDATE_URL) === false) return false;

		$video = self::extract_video_id($url);
		if($video === false || !is_array($video)) return false;

		if($video['provider'] == 'youtube') {
			$datauri = 'http://gdata.youtube.com/feeds/api/videos/' . $video['id'] . '?v=2&alt=jsonc';
		} elseif($video['provider'] == 'vimeo') {
			$datauri = 'http://vimeo.com/api/v2/video/' . $video['id'] . '.json';
		} elseif($video['provider'] == 'dailymotion') {
			$datauri = 'https://api.dailymotion.com/video/' . $video['id'] . '?fields=id,title,description,duration,owner,url,embed_html,created_time,modified_time';
		}

		$response = wp_remote_get($datauri, array('sslverify' => false));
		if(is_wp_error($response)) return false;

		$body = wp_remote_retrieve_body($response);
		if(empty($body)) return false;

		$decoded = json_decode($body, true);
		if(is_array($decoded) && !empty($decoded)) {
			if($video['provider'] == 'youtube') {
				return $decoded['data'];
			} elseif($video['provider'] == 'vimeo') {
				return $decoded[0];
			} elseif($video['provider'] == 'dailymotion') {
				return $decoded;
			}

			return false;
		}

		return false;
	}

	/**
	 * Takes a video embed code and returns the source URL
	 */
	public static function extract_url_from_embed($embed_code) {
		$embed_code = trim($embed_code);
		if(empty($embed_code)) return false;

		if(!class_exists('DOMDocument')) return false;
		libxml_use_internal_errors(true);
		$DOM = new DOMDocument;
		if($DOM->loadHTML($embed_code) === false) return false;

		$iframes = $DOM->getElementsByTagName('iframe');
		if(empty($iframes) || $iframes->length < 1) return false;

		$iframe = $iframes->item(0);
		if($iframe == null || !$iframe->hasAttributes()) return false;

		$src = trim($iframe->attributes->getNamedItem('src')->nodeValue);
		return !empty($src) && filter_var($src, FILTER_VALIDATE_URL) ? $src : false;
	}

	/**
	 * Takes an embed code URL and tries to figure out the oEmbed-compatible URL equivalent
	 * by extracting the domain and video ID
	 */
	public static function convert_embed_url($url) {
		$url = html_entity_decode(trim($url));
		if(empty($url) || filter_var($url, FILTER_VALIDATE_URL) === false) return false;

		$url_parts = parse_url($url);
		if($url_parts === false || empty($url_parts) || !is_array($url_parts) ||
		   !isset($url_parts['host']) || empty($url_parts['host']) ||
		   !isset($url_parts['path']) || empty($url_parts['path'])) return false;

		$host = preg_replace('#^www\.(.+\.)#i', '$1', $url_parts['host']);

		if($host == 'youtube.com' || $host == 'youtube-nocookie.com') {
			$id = trim(preg_replace('#^/embed/#i', '', $url_parts['path']));
			return !empty($id) ? 'http://youtube.com/watch?v=' . $id : false;
		} elseif($host == 'player.vimeo.com') {
			$id = trim(preg_replace('#^/video/#i', '', $url_parts['path']));
			return !empty($id) ? 'http://vimeo.com/' . $id : false;
		} elseif($host == 'dailymotion.com') {
			$id = trim(preg_replace('#^/embed/video/#i', '', $url_parts['path']));
			return !empty($id) ? 'http://dailymotion.com/video/' . $id : false;
		}

		return false;
	}

	/**
	 * Extracts a video ID (and provider) from a video URL
	 */
	public static function extract_video_id($url) {
		$url = html_entity_decode(trim($url));
		if(empty($url) || filter_var($url, FILTER_VALIDATE_URL) === false) return false;

		$url_parts = parse_url($url);
		if($url_parts === false || empty($url_parts) || !is_array($url_parts) ||
			 !isset($url_parts['host']) || empty($url_parts['host']) ||
			 !isset($url_parts['path']) || empty($url_parts['path'])) return false;

		$host = preg_replace('#^www\.(.+\.)#i', '$1', $url_parts['host']);

		$provider = $id = '';

		if($host == 'youtube.com' || $host == 'youtube-nocookie.com') {
			$provider = 'youtube';
			$id = trim(preg_replace('#^/embed/#i', '', $url_parts['path']));
		} elseif($host == 'player.vimeo.com') {
			$provider = 'vimeo';
			$id = trim(preg_replace('#^/video/#i', '', $url_parts['path']));
		} elseif($host == 'dailymotion.com') {
			$provider = 'dailymotion';
			$id = trim(preg_replace('#^/embed/video/#i', '', $url_parts['path']));
		}

		return !empty($provider) && !empty($id) ? array('id' => $id, 'provider' => $provider) : false;
	}
}
