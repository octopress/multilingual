module Octopress
  module Multilingual
    module Tags
      class SetLang < Liquid::Block
        def initialize(tag_name, markup, tokens)
          super
          @input = markup.strip
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
          payload = Multilingual.page_payload(lang)
          set_payload('site', payload)
          set_payload('lang', payload)
        end

        def set_payload(payload_key, payload)
          payload[payload_key].each do |key,value| 
            @context.environments.first[payload_key][key] = value
          end
        end

        def store_state
          @current_lang       = @context['page.lang']
          @site               = @context['site'].clone
          @lang               = @context['lang'].clone
        end

        def restore_state
          @context.environments.first['page']['lang'] = @current_lang
          @context.environments.first['site'] = @site
          @context.environments.first['lang'] = @lang
        end

        def lang

          # Read tag arguments as a string first, if that fails,
          # Look at the local context, to see if it is a variable
          #
          if lang = [@input, @context[@input]].select do |l| 
              @languages.include?(l)
            end.first

            lang.downcase
          end
        end
      end
    end
  end
end

Liquid::Template.register_tag('set_lang', Octopress::Multilingual::Tags::SetLang)
