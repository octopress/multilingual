require 'liquid'

require "octopress-multilingual/version"
require "octopress-multilingual/set_lang_tag"
require "octopress-multilingual/translation_tag"
require "octopress-multilingual/filters"
require "octopress-multilingual/hooks"
require "octopress-multilingual/jekyll"
require "octopress-multilingual/command"
require "octopress-debugger"

module Octopress
  module Multilingual
    extend self
    attr_accessor :site

    def main_language
      @lang ||= begin
        if lang = site.config['lang']
          lang.downcase
        end
      end
    end

    def site
      @site ||= Octopress.site
    end

    def language_name(name=nil)
      language_names[name] || name
    end

    def lang_dict
      @lang_dict ||= begin
        data = {}
        site.languages.each do |lang|
          data[lang] = site.data["lang_#{lang}"]
        end
        data
      end
    end

    def language_names
      @language_names ||= begin
        config = SafeYAML.load_file(File.expand_path('../../language_key.yml', __FILE__))
        if lang_config = site.config['language_names']
          config.merge!(lang_config)
        end
        config
      end
    end

    def translated_posts
      @translated_posts ||= begin
        filter = lambda {|p| p.data['translation_id']}
        site.posts.reverse.select(&filter).group_by(&filter)
      end
    end

    def translated_pages
      @translated_pages ||= begin
        filter = lambda {|p| p.data['translation_id']}
        site.pages.select(&filter).group_by(&filter)
      end
    end

    def languages
      @languages ||= begin
        languages = site.posts.dup.concat(site.pages).select(&:lang).group_by(&:lang).keys
        (languages.unshift(main_language)).uniq
      end
    end

    def posts_by_language(lang=nil)
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

      @posts_by_language[lang] || []
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

    def articles_by_language(lang=nil)
      @articles_by_language ||= begin
        articles = {}

        languages.each do |lang|
          if posts = posts_by_language(lang)
            articles[lang] = posts.reject do |p|
              p.data['linkpost']
            end
          end
        end

        articles
      end

      @articles_by_language[lang] || []
    end

    def linkposts_by_language(lang=nil)
      @linkposts_by_language ||= begin
        linkposts = {}

        languages.each do |lang|
          if posts = posts_by_language(lang)
            linkposts[lang] = posts.select do |p|
              p.data['linkpost']
            end
          end
        end

        linkposts
      end

      @linkposts_by_language[lang] || []
    end

    def metadata_index_by_language(index)
      # Get site categories or tags
      site_indexes = site.send(index)

      indexes = {}

      # Filter indexes for each language
      languages.each do |lang|
        indexes[lang] = {}
        site_indexes.each do |index, posts|
          posts = posts.select do |p| 
            p.lang == lang || (lang == main_language && p.lang.nil?) || p.crosspost_languages
          end

          indexes[lang][index] = posts unless posts.empty?
        end
      end

      indexes
    end

    def categories_by_language(lang=nil)
      @categories ||= metadata_index_by_language(:categories)
      @categories[lang] || {}
    end

    def tags_by_language(lang=nil)
      @tags ||= metadata_index_by_language(:tags)
      @tags[lang] || {}
    end

    def page_payload(lang, payload={})
      if lang
        payload['site'] ||= {}

        {
          'posts'      => posts_by_language(lang),
          'linkposts'  => linkposts_by_language(lang),
          'articles'   => articles_by_language(lang),
          'categories' => categories_by_language(lang),
          'tags'       => tags_by_language(lang)
        }.each do |key, value|
          payload['site'][key] = value
        end

        payload['lang'] = lang_dict[lang]

        if defined?(Octopress::Ink) && site.config['lang']
          payload.merge!(Octopress::Ink.payload(lang))
        end
      end

      payload
    end

    def site_payload(payload)
      if main_language
        payload['site'].merge!({
          'posts_by_language'      => posts_by_language,
          'linkposts_by_language'  => linkposts_by_language,
          'articles_by_language'   => articles_by_language,
          'categories_by_language' => categories_by_language,
          'tags_by_language'       => tags_by_language,
          'languages'              => languages
        })
        payload['lang'] = lang_dict[main_language]
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
