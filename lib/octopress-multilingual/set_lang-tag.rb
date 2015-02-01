require 'liquid'

module Octopress
  module Multilingual
    class PostsByTag < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @lang = markup.strip
      end

      def render(context)
        @context         = context
        @languages       = @context['site.languages']

        # If a language is defined
        if lang && lang != @context['page.lang']

          store_state                    # Store current language and post arrays
          set_lang lang                  # Set to specified language
          content = super(context)       # Render
          restore_state                  # Restore language and post arrays

          content
        else
          # If the language argument resovles to nil
          # this will render contents normally
          # 
          super(context)
        end
      end

      # Swap out site.posts, site.linkposts, and site.articles with
      # arrays filtered by the selected language
      #
      def set_lang(lang)
        @context.environments.first['page']['lang'] = lang
        Multilingual.page_payload(lang).each do |key,value| 
          @context.environments.first['site'][key] = value
        end
      end

      def store_state
        @current_lang       = @context['page.lang']
        @site               = @context['site'].clone
      end

      def restore_state
        @context.environments.first['page']['lang'] = @current_lang
        @context.environments.first['site'] = @site
      end

      def lang

        # Read tag arguments as a string first, if that fails,
        # Look at the local context, to see if it is a variable
        #
        if lang = [@lang, @context[@lang]].select do |l| 
            @languages.include?(l)
          end.first

          lang.downcase
        end
      end
    end
  end
end

Liquid::Template.register_tag('set_lang', Octopress::Multilingual::PostsByTag)

