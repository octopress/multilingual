require 'liquid'

module Octopress
  module Multilingual
    class PostsByTag < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @lang = markup.strip
      end

      def render(context)
        @context    = context
        @languages  = @context['site.languages']
        @lang_posts  = @context['site.posts_by_language']

        # Render with new posts context
        if lang

          # Set posts loop, to language
          set_post_lang lang

          # Render
          content = super(context)

          # Reset posts to main language
          set_post_lang context['site.main_language']

          content
        else
          super(context)
        end
      end

      def set_post_lang(lang)
        @context.environments.first['site']['posts'] = @lang_posts[lang]
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

