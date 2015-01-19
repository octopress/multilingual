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
        @languages  = context['site.languages']
        lang_posts  = context['site.posts_by_language']

        # Was a language passed in?
        if lang
          # Set posts loop, to language
          context.environments.first['site']['posts'] = lang_posts[lang]

          # Render with new posts context
          rendered = super(context)

          # Restore posts to context
          context.environments.first['site']['posts'] = lang_posts[context['site.main_language']]

          rendered
        else
          super(context)
        end
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

Liquid::Template.register_tag('post_lang', Octopress::Multilingual::PostsByTag)

