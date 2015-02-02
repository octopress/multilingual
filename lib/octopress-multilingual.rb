require 'octopress-hooks'

require "octopress-multilingual/version"
require "octopress-multilingual/set_lang-tag"
require "octopress-multilingual/hooks"
require "octopress-multilingual/jekyll"
require "octopress-multilingual/command"

module Octopress
  module Multilingual
    extend self
    attr_accessor :site

    def main_language
      if @lang ||= site.config['lang']
        @lang.downcase
      else
        abort "Build canceled by Octopress Multilingual.\n".red \
             << "Your Jekyll site configuration must have a main language. For example:\n\n" \
             << "  lang: en\n\n"
      end
    end

    def site
      @site ||= Octopress.site
    end

    def translated_posts
      @translated_posts ||= site.posts.reverse.select(&:translated).group_by(&:translated)
    end

    def translated_pages
      @translated_pages ||= site.pages.select(&:translated).group_by(&:translated)
    end

    def languages
      posts_by_language.keys
    end

    def posts_by_language
      @posts_by_language ||= begin
        posts = site.posts.reverse.select(&:lang).group_by(&:lang)
        ## Add posts that crosspost to all languages
        
        posts.each do |lang, lang_posts|
          if lang != main_language
            lang_posts.concat(crossposts).sort_by!(&:date).reverse!
          end
        end

        posts[main_language] = main_language_posts

        posts
      end
    end

    def crossposts
      site.posts.select(&:crosspost_languages)
    end

    def main_language_posts
      site.posts.reverse.select do |post|
        post.lang.nil? || post.lang == main_language
      end
    end

    def posts_without_lang
      @posts_without_lang ||= site.reject(&:lang)
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

    def page_payload(lang)
      { 
        'posts'     => posts_by_language[lang],
        'linkposts' => linkposts_by_language[lang],
        'articles'  => articles_by_language[lang]
      }
    end

    def site_payload
      # Skip when when showing documentation site
      if defined?(Octopress::Docs) && Octopress::Docs.enabled?
        {}
      else
        return unless main_language

        @payload ||= {
          'posts_by_language'     => posts_by_language,
          'linkposts_by_language' => linkposts_by_language,
          'articles_by_language'  => articles_by_language,
          'languages'             => languages
        }
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
