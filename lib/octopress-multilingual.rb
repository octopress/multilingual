require "octopress-multilingual/version"
require "octopress-multilingual/set_lang-tag"
require 'octopress-hooks'

module Octopress
  module Multilingual
    extend self
    attr_accessor :site, :posts

    def main_language
      if @lang ||= site.config['lang']
        @lang.downcase
      else
        abort "Build canceled by Octopress Multilingual.\n".red \
             << "Your Jekyll site configuration must have a main language. For example:\n\n" \
             << "  lang: en\n\n"
      end
    end
    
    def languages
      posts_by_language.keys
    end

    def posts_by_language
      @posts_by_language ||= begin 
        posts = site.posts.reverse.select(&:lang).group_by(&:lang) \
        ## Add posts that crosspost to all languages
        .each do |lang, posts|
          if lang != main_language
            posts.concat(crossposts).sort_by(&:date).reverse
          end
        end

        posts[main_language] = main_language_posts

        posts
      end
    end

    def main_language_posts
      site.posts.reverse.reject do |post|
        post.lang && post.lang != main_language
      end
    end

    def crossposts
      @cross_posts ||= begin
        posts = site.posts.reverse.select do |post|
          post.data['crosspost_languages']
        end
      end
    end

    def posts_without_lang
      @posts_without_lang ||= site.reject(&:lang)
    end

    def site_payload
      if defined?(Octopress::Docs) && Octopress::Docs.enabled?
        {}
      else
        return unless main_language

        @payload ||= begin
          payload = {
            'posts'             => main_language_posts,
            'posts_by_language' => posts_by_language,
            'languages'         => languages
          }

          if defined? Octopress::Linkblog
            payload.merge!({
              'linkposts' => linkposts_by_language[main_language],
              'articles'  => articles_by_language[main_language],
              'linkposts_by_language' => linkposts_by_language,
              'articles_by_language' => articles_by_language
            })
          end
          payload
        end
      end
    end

    def articles_by_language
      @articles_by_language ||= begin 
        articles = {}

        languages.each do |lang|
          articles[lang] = posts_by_language[lang].reject do |p|
            p.data['linkpost']
          end
        end

        articles
      end
    end

    def linkposts_by_language
      @linkposts_by_language ||= begin 
        linkposts = {}

        languages.each do |lang|
          linkposts[lang] = posts_by_language[lang].select do |p|
            p.data['linkpost']
          end
        end

        linkposts
      end
    end

    class SiteHookRead < Hooks::Site
      priority :high
      # Generate site_payload so other plugins can access 
      def post_read(site)
        Octopress::Multilingual.site = site 
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
          'site' => Octopress::Multilingual.site_payload,
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

    def next
      language = lang || site.config['lang']
      posts = Octopress::Multilingual.posts_by_language[language] 
      pos = posts.index {|post| post.equal?(self) }
      if pos && pos < posts.length - 1
        posts[pos + 1]
      else
        nil
      end
    end

    def previous
      language = lang || site.config['lang']
      posts = Octopress::Multilingual.posts_by_language[language] 
      pos = posts.index {|post| post.equal?(self) }
      if pos && pos > 0
        posts[pos - 1]
      else
        nil
      end
    end
    
  end
end

if defined? Octopress::Docs
  Octopress::Docs.add({
    name:        "Octopress Multilingual",
    gem:         "octopress-multilingual",
    version:     Octopress::Multilingual::VERSION,
    description: "Add multilingual features to your Jekyll site",
    path:        File.expand_path(File.join(File.dirname(__FILE__), "..")),
    source_url:  "https://github.com/octopress/multilingual"
  })
end
