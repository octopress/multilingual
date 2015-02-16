module Octopress
  module Multilingual
    class SiteHook < Hooks::Site
      priority :high
      # Generate site_payload so other plugins can access
      def post_read(site)
        Octopress::Multilingual.site = site
        site.config['languages'] = Octopress::Multilingual.languages
      end

      def pre_render(site)

        # Add translation page data to each page or post.
        #
        [site.pages, site.posts].flatten.select(&:translated).each do |item|
          # Access array of translated items via (post/page).translations
          item.data.merge!({
            'translations' => item.translations,
            'translated' => item.translated
          })
        end
      end

      def merge_payload(payload, site)
        Octopress::Multilingual.site_payload
      end
    end

    class PagePayloadHook < Hooks::All
      priority :high

      def post_init(item)
        if item.lang == 'default'
          item.data['lang'] = item.site.config['lang']
        end
      end

      # Swap out post arrays with posts of the approrpiate language
      #
      def merge_payload(payload, item)
        if item.lang
          Octopress::Multilingual.page_payload(item.lang)
        end
      end

      # Override deep_merge to prevent categories and tags from being combined when they shouldn't
      #
      def deep_merge_payload(page_payload, hook_payload)
        %w{site page}.each do |key|
          hook_payload[key] = page_payload[key].merge(hook_payload[key] || {})
        end
        hook_payload
      end
    end
  end
end
