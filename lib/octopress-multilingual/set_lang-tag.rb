require 'liquid'

module Octopress
  module Multilingual
    class PostsByTag < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @lang = markup.strip
      end

      def render(context)
        @context     = context
        @languages   = @context['site.languages']
        @lang_posts  = @context['site.posts_by_language']
        main_lang   = @context['site.main_language']

        # Render with new posts context
        if lang

          # Set to specified language
          set_post_lang lang
          set_current_lang(lang)

          # Render
          content = super(context)

          # Reset to main language
          set_post_lang main_lang
          set_current_lang(main_lang)

          content
        else
          # Tell scope it's in the main
          super(context)
        end
      end

      def set_post_lang(lang)
        site = @context.environments.first['site']
        site['posts'] = @lang_posts[lang]

        if defined? Octopress::Linkblog
          site['linkposts'] = site['linkposts_by_language'][lang]
          site['articles']  = site['articles_by_language'][lang] 
        end
      end

      def set_current_lang(lang)
        @context.environments.first['site']['lang'] = lang
      end

      def lang
        # If lang is a local variable, read it from the context
        lang = [@lang, @context[@lang]].select{|l| @languages.include?(l)}.first
        if !lang.nil?
          lang.downcase
        end
      end
    end
  end
end

Liquid::Template.register_tag('set_lang', Octopress::Multilingual::PostsByTag)

