module Octopress
  module Multilingual
    class SiteHookRead < Hooks::Site
      priority :high
      # Generate site_payload so other plugins can access
      def post_read(site)
        Octopress::Multilingual.site = site
      end
    end

    class SiteHook < Hooks::Site
      # Use a low priority so that other hooks can act on posts
      # without having to be designed for mutlilingual sites.
      priority :high

      #
      def merge_payload(payload, site)
        { 'site' => Octopress::Multilingual.site_payload }
      end
    end

    class PagePayloadHook < Hooks::All
      priority :high

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
