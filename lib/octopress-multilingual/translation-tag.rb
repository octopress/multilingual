module Octopress
  module Multilingual
    module Tags
      class Translations < Liquid::Tag
        def initialize(tag, input, tokens)
          super
          @tag = tag.strip
          @input = input.strip
        end

        def render(context)
          @context = context
          if translations
            if @tag == 'translation_list'
              list = translations.dup.map do |t|
                "<li translation-item lang-#{t.lang}'>#{anchor(t)}</li>"
              end.join(' ,')
              "<ul class='translation-list'>#{list}</uL>"
            else
              translations.dup.map do |t|
                anchor(t)
              end.join(', ')
            end
          end
        end

        def anchor(item)
          "<a class='translation-link lang-#{item.lang}' href='#{ item.url }'>#{ item.lang }</a>"
        end

        def translations
          if item = @context[@input]
            item['translations'] if item['translated']
          end
        end
      end
    end
  end
end

Liquid::Template.register_tag('translations', Octopress::Multilingual::Tags::Translations)
Liquid::Template.register_tag('translation_list', Octopress::Multilingual::Tags::Translations)
