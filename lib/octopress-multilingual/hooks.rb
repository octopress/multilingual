module Octopress
  module Multilingual
    class SiteHook < Hooks::Site
      priority :high
      # Generate site_payload so other plugins can access
      def post_read(site)
        Octopress::Multilingual.site = site
        site.config['languages'] = site.languages
      end

      def pre_render(site)

        # Add translation page data to each page or post.
        #
        [site.pages, site.posts].flatten.each do |item|
          if item.translations && !item.translations.empty?
            # Access array of translated items via (post/page).translations
            item.data.merge!({'translations' => item.translations})
          end
        end
      end

      def merge_payload(payload, site)
        { 'site' => Octopress::Multilingual.site_payload }
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
          { 'site' => Octopress::Multilingual.page_payload(item.lang) }
        end
      end

    end
  end
end
