require "octopress-multilingual/version"
require "octopress-multilingual/set_lang-tag"
require 'octopress-hooks'

module Octopress
  module Multilingual
    extend self
    attr_accessor :site, :posts

    def main_language
      if @lang ||= site.config['main_language']
        @lang.downcase
      else
        abort "Build canceled by Octopress Multilingual.\n".red \
             << "Your Jekyll site configuration must have a main language. For example:\n\n" \
             << "  main_language: en\n\n"
      end
    end

    def site
      @site
    end
    
    def languages
      posts_by_language.keys
    end

    def posts_by_language
      @posts_by_language ||= begin 
        posts = site.posts.select(&:lang).group_by(&:lang) \
        ## Add posts that crosspost to all languages
        .each do |lang, posts|
          if lang == main_language
            posts.clear.concat(main_language_posts)
          else
            posts.concat(crossposts).sort_by(&:date)
          end
        end
        posts
      end
    end

    def main_language_posts
      site.posts.reject do |post|
        post.lang && post.lang != main_language
      end
    end

    def crossposts
      @cross_posts ||= begin
        posts = site.posts.select do |post|
          post.data['crosspost_languages']
        end
      end
    end

    def posts_without_lang
      @posts_without_lang ||= site.reject(&:lang)
    end

    def site_payload(site)
      @site = site

      if main_language
        {
          'posts'             => main_language_posts,
          'posts_by_language' => posts_by_language,
          'languages'         => languages,
          'lang'              => main_language
        }
      end
    end


    class SiteHook < Hooks::Site
      priority :low

      def merge_payload(payload, site)

        # Group posts by language, { 'en_post' => [posts,..] }
        #

        # Ensure that posts without an assigned language
        # appear in each language's feed
        #
        
        { 
          'site' => Octopress::Multilingual.site_payload(site),
        }
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
      data['lang'].downcase if data['lang'] 
    end

    def url_placeholders
      url_placeholders_orig.merge({
        :lang => lang
      })
    end
  end
end
