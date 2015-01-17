require "octopress-multi-language/version"
require 'octopress-hooks'

module Octopress
  module MultiLanguage
    class SiteHook < Hooks::Site
      def merge_payload(payload, site)

        # Group posts by language, { 'posts_en' => [posts,..] }
        #
        p = site.posts.select(&:lang).group_by(&:lang).map do |lang, posts|
          ["posts_#{lang}", posts]
        end

        { 'site' => Hash[p] }
      end
    end
  end
end

module Jekyll
  class URL
    def generate_url(template)
      @placeholders.inject(template) do |result, token|
        break result if result.index(':').nil? 
        if token.last.nil?
          result.gsub(/\/:#{token.first}/, '')
        else
          result.gsub(/:#{token.first}/, self.class.escape_path(token.last))
        end
      end
    end
  end

  class Post
    alias :template_orig :template
    alias :url_placeholders_orig :url_placeholders 
    
    def template
      template = template_orig

      if [:pretty, :none, :date, :ordinal].include? site.permalink_style
        template = File.join('/:lang', template)
      end

      template
    end

    def lang
      data['lang']
    end

    def url_placeholders
      url_placeholders_orig.merge({
        :lang => lang
      })
    end
  end
end
